import os
import uuid
from fastapi import UploadFile, HTTPException
from typing import Optional


def uploadFileToLocal(file: UploadFile) -> Optional[str]:
    """
    Upload a file to the local static directory with proper Windows file handling
    """
    try:
        # Get file extension
        file_extension = os.path.splitext(
            file.filename)[1].lower() if file.filename else ".jpg"

        # Determine file type
        if file_extension in ['.mp4', '.mov', '.avi', '.wmv']:
            file_type = "videos"
        elif file_extension in ['.jpg', '.jpeg', '.png']:
            file_type = "images"
        else:
            file_type = "documents"

        # Create directory if it doesn't exist
        os.makedirs(f"static/{file_type}/uploads/", exist_ok=True)

        # Generate unique filename
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        final_path = f"static/{file_type}/uploads/{unique_filename}"

        # Read file content and write directly to final destination
        content = file.file.read()

        # Write content to final destination
        with open(final_path, "wb") as buffer:
            buffer.write(content)

        # Close the original file to release the lock
        file.file.close()

        return f"{file_type}/uploads/{unique_filename}"

    except Exception as e:
        # Ensure file is closed even if error occurs
        try:
            file.file.close()
        except:
            pass
        raise HTTPException(
            status_code=500, detail=f"File upload failed: {str(e)}")

# Alternative version for large files (streaming)


def uploadFileToLocalStreaming(file: UploadFile, max_size_mb: int = 100) -> Optional[str]:
    """
    Stream file upload to avoid memory issues with large files
    """
    try:
        file_extension = os.path.splitext(
            file.filename)[1].lower() if file.filename else ".jpg"

        # Determine file type
        if file_extension in ['.mp4', '.mov', '.avi', '.wmv']:
            file_type = "videos"
        elif file_extension in ['.jpg', '.jpeg', '.png']:
            file_type = "images"
        else:
            file_type = "documents"

        # Create directory
        os.makedirs(f"static/{file_type}/uploads/", exist_ok=True)

        # Generate unique filename
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        final_path = f"static/{file_type}/uploads/{unique_filename}"

        # Stream file content with size validation
        max_size_bytes = max_size_mb * 1024 * 1024
        total_size = 0
        chunk_size = 8192  # 8KB chunks

        with open(final_path, "wb") as buffer:
            while True:
                chunk = file.file.read(chunk_size)
                if not chunk:
                    break
                total_size += len(chunk)
                if total_size > max_size_bytes:
                    raise ValueError(
                        f"File too large. Maximum allowed is {max_size_mb} MB.")
                buffer.write(chunk)

        file.file.close()

        return f"{file_type}/uploads/{unique_filename}"

    except Exception as e:
        try:
            file.file.close()
        except:
            pass
        # Clean up if file was partially written
        try:
            if 'final_path' in locals() and os.path.exists(final_path):
                os.unlink(final_path)
        except:
            pass
        raise HTTPException(
            status_code=500, detail=f"File upload failed: {str(e)}")
