import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marrir/services/Employee/cv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepPassport extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onNextStep;

  const StepPassport({
    super.key,
    required this.onSuccess,
    required this.onNextStep,
  });

  @override
  State<StepPassport> createState() => _StepPassportState();
}

class _StepPassportState extends State<StepPassport> {
  File? _passportFile;
  bool _isLoading = false;
  String _fileName = "No file chosen";
  String? _errorMessage;
  String? _userId; // Store user ID

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("user_id");
    });
  }

  Future<void> _pickPassportImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1200,
        maxHeight: 1600,
      );

      if (image != null) {
        setState(() {
          _passportFile = File(image.path);
          _fileName = image.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to pick image: $e";
      });
    }
  }

  Future<void> _uploadPassport() async {
    if (_passportFile == null) {
      setState(() {
        _errorMessage = "Please select a passport image first";
      });
      return;
    }

    if (_userId == null) {
      setState(() {
        _errorMessage = "User not identified. Please login again.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("access_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      // Upload passport with user ID
      final result = await CVService.uploadPassport(
        passportFile: _passportFile!,
        userId: _userId!, // Pass the user ID
        token: token,
      );

      // Handle successful upload
      if ((result["id"] != null || result["user_id"] != null)) {
        widget.onSuccess();
        widget.onNextStep();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Passport uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to upload passport - invalid response format");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Upload failed: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF8EC6D6);
    const Color borderColor = Color(0xFFD1D1D6);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Title
          const Text(
            "Step 1: Passport Scan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // User info (for debugging/confirmation)
          if (_userId != null)
            Text(
              "Uploading for user: ${_userId!.substring(0, 8)}...",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 4),

          // Subtitle
          const Text(
            "Scan Your Passport",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          // Warning Text
          const Text(
            "Make sure the MRZ zone at the bottom is clearly visible!",
            style: TextStyle(
              fontSize: 13,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Upload Box
          GestureDetector(
            onTap: _pickPassportImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: borderColor, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
                color: _passportFile != null ? Colors.green[50] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _passportFile != null
                        ? Icons.check_circle
                        : Icons.cloud_upload_outlined,
                    size: 40,
                    color: _passportFile != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _passportFile != null
                        ? "Passport selected"
                        : "Tap to upload passport scan",
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          _passportFile != null ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _pickPassportImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Choose File",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _fileName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _passportFile != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Preview image (if selected)
          if (_passportFile != null) ...[
            const Text(
              "Preview:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.file(
                _passportFile!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _uploadPassport,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Submit Passport",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Loading indicator
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            const Text(
              "Uploading passport...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
