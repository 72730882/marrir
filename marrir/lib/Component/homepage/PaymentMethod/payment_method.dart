import 'package:flutter/material.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Accepted Payment Methods',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'We accept a wide range of payment methods to\n'
            'make transactions easier for you. Choose from\n'
            'trusted brands and make secure payments with ease.',
            style: TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 57, 57, 57),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color.fromARGB(255, 239, 249, 239),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaymentMethod(
                  'Visa',
                  'assets/images/OIP (1).jpeg', // Replace with your asset path
                  const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 12),
                _buildPaymentMethod(
                  'Mastercard',
                  'assets/images/OIP.jpeg', // Replace with your asset path
                  const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 12),
                _buildPaymentMethod(
                  'Paypal',
                  'assets/images/OIP.jpeg', // Replace with your asset path
                  const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 12),
                _buildPaymentMethod(
                  'Apple Pay',
                  'assets/images/OIP.jpeg', // Replace with your asset path
                  const Color.fromARGB(255, 255, 255, 255),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String name, String assetPath, Color boxColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
        // const SizedBox(height: ),
        Text(
          name,
          style: const TextStyle(
              fontSize: 12, color: Color.fromARGB(255, 74, 74, 74)),
        ),
      ],
    );
  }
}
