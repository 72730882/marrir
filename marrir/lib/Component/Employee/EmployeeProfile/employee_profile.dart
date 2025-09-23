import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/user.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EditProfile/edit_profile.dart';
// import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeHelp/help.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSecurity/security.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:marrir/Component/onboarding/SplashScreen/splash_screen.dart';

class ProfilePage extends StatefulWidget {
  final Function(Widget) onChildSelected;

  const ProfilePage({super.key, required this.onChildSelected});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userId = "";
  String userImage = "";
  bool isLoading = true;
  String token = ""; // Store token locally

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access_token") ?? "";
    final email = prefs.getString("user_email") ?? "";

    if (token.isNotEmpty && email.isNotEmpty) {
      try {
        final user = await ApiService.getUserInfo(email: email, Token: token);

        // Decide which image to use
        String imageUrl = "";
        if (user["cv"] != null && user["cv"]["head_photo"] != null) {
          imageUrl = user["cv"]["head_photo"];
        } else if (user["profile"] != null &&
            user["profile"]["image"] != null) {
          imageUrl = user["profile"]["image"];
        }

        setState(() {
          userName =
              "${user["first_name"] ?? ""} ${user["last_name"] ?? ""}".trim();
          userId = user["id"]?.toString() ?? "";
          userImage = imageUrl;
          isLoading = false;
        });
      } catch (e) {
        debugPrint("Failed to load user info: $e");
        setState(() {
          userName = "Unknown";
          userId = "";
          userImage = "";
          isLoading = false;
        });
      }
    } else {
      setState(() {
        userName = "Unknown";
        userId = "";
        userImage = "";
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    widget.onChildSelected(
      EditProfilePage(
        onChildSelected: widget.onChildSelected,
        userName: userName,
        userId: userId,
        userImage: userImage,
        token: token, // ✅ Pass the real token here
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WaveBackground(
          title: "Profile",
          onBack: () {},
          onNotification: () {},
          bottomContent: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage:
                    userImage.isNotEmpty ? NetworkImage(userImage) : null,
                child: userImage.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.blue)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                isLoading ? "Loading..." : userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                isLoading ? "" : "ID: $userId",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              _buildProfileOption(
                context,
                "Edit Profile",
                Icons.person_2,
                null, // We handle navigation separately
                onTap: _navigateToEditProfile,
              ),
              _buildProfileOption(
                context,
                "Security",
                Icons.security_sharp,
                SecurityPage(onChildSelected: widget.onChildSelected),
              ),
              _buildProfileOption(
                context,
                "Setting",
                Icons.settings,
                SettingPage(onChildSelected: widget.onChildSelected),
              ),
              // _buildProfileOption(
              //   context,
              //   "Help",
              //   Icons.help,
              //   HelpFAQPage(onChildSelected: widget.onChildSelected),
              // ),
              _buildProfileOption(
                context,
                "Logout",
                Icons.logout,
                const SizedBox(),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(
      BuildContext context, String title, IconData icon, Widget? page,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: onTap ?? () => widget.onChildSelected(page!),
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
                      color: Colors.white,
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
                      color: Color(0xFF333333),
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
