import 'package:flutter/material.dart';

class StepPassport extends StatelessWidget {
  const StepPassport({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Step 1: Passport Scan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Make sure the MRZ zone at the bottom is clearly visible!",
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 20),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, size: 40, color: Colors.blue),
                SizedBox(height: 10),
                Text("Tap to upload passport scan"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                8,
              ), // optional: rounded corners
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 120, // optional: horizontal padding
            ), // optional: vertical padding
          ),
          child: const Text(
            "Submit",
            style: TextStyle(
              color: Colors.white, // white text
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
