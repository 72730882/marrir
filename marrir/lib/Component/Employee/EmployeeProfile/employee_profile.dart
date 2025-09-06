import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EditProfile/edit_profile.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeHelp/help.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/security.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:marrir/Component/onboarding/SplashScreen/splash_screen.dart';

class ProfilePage extends StatelessWidget {
  final Function(Widget) onChildSelected;

  const ProfilePage({super.key, required this.onChildSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with 3 layered waves
        WaveBackground(
          title: "Profile",
          onBack: () {}, // you can add logic if needed
          onNotification: () {},
          bottomContent: const Column(
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

        const SizedBox(height: 20),

        // Profile options
        Expanded(
          child: ListView(
            children: [
              _buildProfileOption(
                context,
                "Edit Profile",
                Icons.person_2,
                EditProfilePage(onChildSelected: onChildSelected),
              ),
              _buildProfileOption(
                context,
                "Security",
                Icons.security_sharp,
                SecurityPage(onChildSelected: onChildSelected),
              ),
              _buildProfileOption(
                context,
                "Setting",
                Icons.settings,
                SettingPage(onChildSelected: onChildSelected),
              ),
              _buildProfileOption(
                context,
                "Help",
                Icons.help,
                HelpFAQPage(onChildSelected: onChildSelected),
              ),
              _buildProfileOption(
                context,
                "Logout",
                Icons.logout,
                const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: title == "Logout"
            ? () => _showLogoutDialog(context)
            : () => onChildSelected(page),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF65B2C9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "End Session",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            // Align the title to the center
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 15, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate back to login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF65B2C9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Yes, End Session",
                    style: TextStyle(
                      color: Colors.white, // white text
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 248, 248, 248),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF333333), // dark gray text
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
