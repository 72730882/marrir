import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/cv_service.dart'; // Make sure your CVService has userId & token
import 'package:shared_preferences/shared_preferences.dart';

class AdditionalContactForm extends StatefulWidget {
  const AdditionalContactForm({super.key});

  @override
  State<AdditionalContactForm> createState() => _AdditionalContactFormState();
}

class _AdditionalContactFormState extends State<AdditionalContactForm> {
  final _formKey = GlobalKey<FormState>();

  final facebookController = TextEditingController();
  final xController = TextEditingController();
  final telegramController = TextEditingController();
  final tiktokController = TextEditingController();
  final instagramController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedContacts();
  }

  @override
  void dispose() {
    facebookController.dispose();
    xController.dispose();
    telegramController.dispose();
    tiktokController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      facebookController.text = prefs.getString('facebook') ?? '';
      xController.text = prefs.getString('x') ?? '';
      telegramController.text = prefs.getString('telegram') ?? '';
      tiktokController.text = prefs.getString('tiktok') ?? '';
      instagramController.text = prefs.getString('instagram') ?? '';
    });
  }

  Future<void> _saveContactsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('facebook', facebookController.text);
    await prefs.setString('x', xController.text);
    await prefs.setString('telegram', telegramController.text);
    await prefs.setString('tiktok', tiktokController.text);
    await prefs.setString('instagram', instagramController.text);
  }

  Future<void> _submitContacts() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 🔹 Get userId and token
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? token = prefs.getString('access_token');

      if (userId == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")),
        );
        setState(() => isLoading = false);
        return;
      }

      // 🔹 Call CVService
      final result = await CVService.submitAdditionalContacts(
        userId: userId,
        token: token,
        facebook: facebookController.text,
        x: xController.text,
        telegram: telegramController.text,
        tiktok: tiktokController.text,
        instagram: instagramController.text,
      );

      // 🔹 Save locally
      await _saveContactsLocally();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contacts submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildSocialInput(
      String label, IconData icon, TextEditingController controller) {
    const Color borderColor = Color(0xFFD1D1D6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF111111)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111111);
    const Color buttonColor = Color.fromRGBO(142, 198, 214, 1);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Step 10: Additional Contact Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 30),
            _buildSocialInput("Facebook", Icons.facebook, facebookController),
            _buildSocialInput(
                "X / Twitter", Icons.alternate_email, xController),
            _buildSocialInput("Telegram", Icons.send, telegramController),
            _buildSocialInput("TikTok", Icons.music_note, tiktokController),
            _buildSocialInput(
                "Instagram", Icons.camera_alt, instagramController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitContacts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
