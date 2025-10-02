import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Updated import path

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            languageProvider.t('accepted_payment_methods'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            languageProvider.t('payment_methods_description'),
            style: const TextStyle(
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
                  languageProvider.t('visa'),
                  'assets/images/OIP (1).jpeg',
                  const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 12),
                _buildPaymentMethod(
                  languageProvider.t('mastercard'),
                  'assets/images/OIP.jpeg',
                  const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 12),
                _buildPaymentMethod(
                  languageProvider.t('paypal'),
                  'assets/images/OIP.jpeg',
                  const Color.fromARGB(255, 255, 255, 255),
                ),
                const SizedBox(width: 12),
                _buildPaymentMethod(
                  languageProvider.t('apple_pay'),
                  'assets/images/OIP.jpeg',
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
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
              fontSize: 12, color: Color.fromARGB(255, 74, 74, 74)),
        ),
      ],
    );
  }
}
