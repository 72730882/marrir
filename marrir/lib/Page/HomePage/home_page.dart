import 'package:flutter/material.dart';
import 'package:marrir/Component/homepage/ClientTalk/clienttalk.dart';
import 'package:marrir/Component/homepage/HomeService/service.dart';
import 'package:marrir/Component/homepage/OurImpact/ourimpact.dart';
import 'package:marrir/Component/homepage/PaymentMethod/payment_method.dart';
import 'package:marrir/Component/homepage/PromotedCvs/promotedcvs.dart';
import 'package:marrir/widgets/footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // Optional: match your Layout’s background
      body: SingleChildScrollView(
        // padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OurImpact(),
            SizedBox(height: 15),
            PromotedCVsScreen(),
            SizedBox(height: 15),
            ServicesApp(),
            SizedBox(height: 15),
            Clienttalk(),
            SizedBox(height: 15),
            PaymentMethods(),
            // SizedBox(height: 5),
            Footer()
          ],
        ),
      ),
    );
  }
}
