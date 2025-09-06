from pathlib import Path
from readmrz import MrzDetector, MrzReader


def read_mrz(file_name: str):
    detector = MrzDetector()
    reader = MrzReader()

    BASE_DIR = Path.cwd()
    full_path = BASE_DIR / "static" / file_name
    
    image = detector.read(str(full_path))

    cropped = detector.crop_area(image)
    result = reader.process(cropped)
    return result
