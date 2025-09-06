import 'package:flutter/material.dart';

class StepPassport extends StatelessWidget {
  const StepPassport({super.key});

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Tap to upload passport scan",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
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
                const Text(
                  "No file chosen",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
