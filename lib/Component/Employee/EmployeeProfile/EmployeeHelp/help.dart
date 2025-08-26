import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/employee_profile.dart';

class HelpFAQPage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const HelpFAQPage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===== Wave Header =====
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper1(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7DAFC5), Color(0xFFAB78B4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: WaveClipper2(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9C66A6), Color(0xFF65B2C9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: WaveClipper3(),
                  child: Container(color: Colors.white.withOpacity(0.15)),
                ),

                // ===== Top Bar =====
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => onChildSelected(
                          ProfilePage(onChildSelected: onChildSelected),
                        ),
                      ),
                      const Text(
                        "Help & FAQs",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== Subtitle =====
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "How Can We Help You?",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ===== Tabs =====
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TabBar(
                      indicator: BoxDecoration(
                        color: Color(0xFF65B2C9),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      labelColor: Colors.white,
                      labelPadding: EdgeInsets.symmetric(horizontal: 6),
                      unselectedLabelColor: Colors.black54,
                      tabs: [
                        Tab(
                          child: SizedBox(
                            height: 40,
                            child: Center(child: Text("FAQ")),
                          ),
                        ),
                        Tab(
                          child: SizedBox(
                            height: 40,
                            child: Center(child: Text("Contact Us")),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== Tab Content =====
                  Expanded(
                    child: TabBarView(
                      children: [
                        // === FAQ TAB ===
                        _buildFAQContent(),

                        // === CONTACT TAB ===
                        _buildContactContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shared search + categories
  Widget _buildSharedHeader() {
    return Column(
      children: [
        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF65B2C9)),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Categories
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategory("General", true),
            _buildCategory("Account", false),
            _buildCategory("Services", false),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // FAQ TAB
  Widget _buildFAQContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSharedHeader(),
          _buildFAQItem("How to use Marrir?"),
          _buildFAQItem("How to contact support?"),
          _buildFAQItem(
            "Are there any privacy or data security measures in place?",
          ),
          _buildFAQItem("How can I reset my password if I forget it?"),
        ],
      ),
    );
  }

  // CONTACT TAB
  Widget _buildContactContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSharedHeader(),

          // White Card Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField("Full Name"),
                const SizedBox(height: 15),
                _buildTextField("Email"),
                const SizedBox(height: 15),
                _buildTextField("Message", maxLines: 5, isMessage: true),
                const SizedBox(height: 20),

                // Gradient Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7DAFC5), Color(0xFF65B2C9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Footer Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterIcon(Icons.facebook),
              _buildFooterIcon(Icons.phone),
              _buildFooterIcon(Icons.mail_outline),
              _buildFooterIcon(Icons.chat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(question),
        trailing: const Icon(Icons.expand_more, color: Colors.black54),
      ),
    );
  }

  Widget _buildCategory(String text, bool selected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF65B2C9) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    int maxLines = 1,
    bool isMessage = false,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: isMessage
            ? const EdgeInsets.symmetric(vertical: 40, horizontal: 10)
            : const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF65B2C9),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

// Same Wave Clippers
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
