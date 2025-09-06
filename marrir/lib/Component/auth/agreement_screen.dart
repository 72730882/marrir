import 'package:flutter/material.dart';

class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== HEADER WITH CURVES =====
              Stack(
                children: [
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B4BBA), Color(0xFF48C2E9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 10,
                    child: Image.asset(
                      "assets/images/splash_image/logo3.png",
                      height: 100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ===== TITLE =====
              const Text(
                "Agreement",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // ===== STEP 1 =====
              _buildStep(
                step: "Step 1",
                description: "Download the agreement template",
                buttonText: "Download Agreement",
                icon: Icons.download_rounded,
                onPressed: () {
                  // TODO: Add download logic
                },
              ),
              const SizedBox(height: 20),

              // ===== STEP 2 =====
              _buildStep(
                step: "Step 2",
                description:
                    "Sign the agreement and upload the signed file",
                buttonText: "Upload Signed Agreement",
                icon: Icons.upload_rounded,
                onPressed: () {
                  // TODO: Add file picker logic
                },
              ),
              const SizedBox(height: 20),

              // ===== STEP 3 =====
              _buildStep(
                step: "Step 3",
                description:
                    "Submit the signed agreement for admin approval",
                buttonText: "Submit for Approval",
                icon: Icons.check_circle_outline,
                onPressed: () {
                  // TODO: Add submit logic
                },
              ),

              const SizedBox(height: 40),

              // ===== FOOTER LOGO =====
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                  child: Image.asset(
                    'assets/images/onboarding_images/logo2.png',
                    width: 70,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== HELPER WIDGET FOR EACH STEP =====
  Widget _buildStep({
    required String step,
    required String description,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.teal),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== SAME HEADER CLIPPER FROM REGISTER =====
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 50);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 100, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
