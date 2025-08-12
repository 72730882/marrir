import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const CustomNavbar({
    super.key,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFDAF1F9), // Light blue like your design
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Image.asset(
              'assets/images/splash_image/logo3.png', // your logo path
              height: 80,
              
              
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onLoginTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF65b2c9),
                foregroundColor: Colors.white,
                 side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Login"),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: onRegisterTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.lightBlue,
                side: const BorderSide(color: Colors.lightBlue),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Register"),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.translate, color: Colors.purple),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
