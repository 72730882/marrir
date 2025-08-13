import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We accept a wide range of payment methods to make transactions easier for you. '
            'Choose from trusted brands and make secure payments with ease.',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 57, 57, 57),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Row to display payment methods inline horizontally
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaymentMethod(
                'Visa',
                'assets/visa.svg',
                const Color.fromARGB(255, 171, 196, 222),
              ),
              const SizedBox(width: 14),
              _buildPaymentMethod(
                'Mastercard',
                'assets/mastercard.svg',
                const Color.fromARGB(255, 188, 149, 171),
              ),
              const SizedBox(width: 14),
              _buildPaymentMethod(
                'Paypal',
                'assets/paypal.svg',
                const Color.fromARGB(255, 153, 175, 177),
              ),
              const SizedBox(width: 14),
              _buildPaymentMethod(
                'Mastercard',
                'assets/mastercard.svg',
                const Color.fromARGB(255, 165, 143, 143),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String name, String iconPath, Color boxColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SvgPicture.asset(
            iconPath,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }
}
