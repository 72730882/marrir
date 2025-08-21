import 'package:flutter/material.dart';

class CVFooter extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isFirstStep;
  final bool isLastStep;

  const CVFooter({
    super.key,
    this.onPrevious,
    this.onNext,
    required this.isFirstStep,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button is always visible
          ElevatedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white, // icon color
            ),
            label: const Text(
              "Previous",
              style: TextStyle(
                color: Colors.white, // text color
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
          ),

          // Next / Finish button
          ElevatedButton.icon(
            onPressed: onNext,
            icon: Icon(
              isLastStep ? Icons.check : Icons.arrow_forward,
              color: Colors.white, // icon color
            ),
            label: Text(
              isLastStep ? "Finish" : "Next",
              style: const TextStyle(
                color: Colors.white, // text color
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            ),
          ),
        ],
      ),
    );
  }
}
