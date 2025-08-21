import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';

class EditProfilePage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const EditProfilePage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Header with 3 layered waves
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            children: [
              ClipPath(
                clipper: WaveClipper1(),
                child: Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 125, 180, 197),
                        Color.fromARGB(255, 171, 120, 180),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: WaveClipper2(),
                child: Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 156, 102, 166),
                        Color(0xFF65B2C9),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: WaveClipper3(),
                child: Container(
                  height: 260,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        onChildSelected(
                          ProfilePage(onChildSelected: onChildSelected),
                        );
                      },
                    ),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 26),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "John Smith",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "ID: 25030024",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🔹 Form fields with labels on top
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildLabeledTextField("Full Name", "John Smith"),
                _buildLabeledTextField("Phone", "+251 9 12 34 56 78"),
                _buildLabeledTextField("Email Address", "example@example.com"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // TODO: implement update functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65B2C9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for labeled text fields
  Widget _buildLabeledTextField(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: const Color(0xFFEAF6FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wave Clippers
class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    var firstControl = Offset(size.width * 0.25, size.height * 0.85);
    var firstEnd = Offset(size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(
      firstControl.dx,
      firstControl.dy,
      firstEnd.dx,
      firstEnd.dy,
    );
    var secondControl = Offset(size.width * 0.75, size.height * 0.55);
    var secondEnd = Offset(size.width, size.height * 0.7);
    path.quadraticBezierTo(
      secondControl.dx,
      secondControl.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.6);
    var firstControl = Offset(size.width * 0.25, size.height * 0.75);
    var firstEnd = Offset(size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(
      firstControl.dx,
      firstControl.dy,
      firstEnd.dx,
      firstEnd.dy,
    );
    var secondControl = Offset(size.width * 0.75, size.height * 0.45);
    var secondEnd = Offset(size.width, size.height * 0.6);
    path.quadraticBezierTo(
      secondControl.dx,
      secondControl.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.5);
    var firstControl = Offset(size.width * 0.25, size.height * 0.65);
    var firstEnd = Offset(size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
      firstControl.dx,
      firstControl.dy,
      firstEnd.dx,
      firstEnd.dy,
    );
    var secondControl = Offset(size.width * 0.75, size.height * 0.35);
    var secondEnd = Offset(size.width, size.height * 0.5);
    path.quadraticBezierTo(
      secondControl.dx,
      secondControl.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
