import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeProfile/EmployeeSetting/setting.dart';
import 'package:marrir/Component/Employee/wave_background.dart';
import 'package:marrir/services/user.dart';

class DeleteAccountPage extends StatefulWidget {
  final Function(Widget)? onChildSelected;
  final String accessToken;
  final String userId;

  const DeleteAccountPage({
    super.key,
    this.onChildSelected,
    required this.accessToken,
    required this.userId,
  });

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  final Color _primaryBlueDark = const Color(0xFF65B2C9);
  final Color _cardBlue = const Color(0xFFE6F2F9);
  final Color _textPrimary = const Color(0xFF2C2C2C);
  final Color _textSecondary = const Color(0xFF6F7A86);
  final Color _chipGrey = const Color(0xFFE7EEF2);
  final Color _pillGrey = const Color(0xFFF1F5F7);
  final Color _errorRed = const Color(0xFFE53935);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.deleteAccount(
      accessToken: widget.accessToken,
      password: _passwordCtrl.text,
      userId: widget.userId,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Account deleted successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Account deleted")),
      );

      // Navigate to login or home screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Something went wrong"),
          backgroundColor: _errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              WaveBackground(
                title: "Delete Account",
                onBack: () {
                  if (widget.onChildSelected != null) {
                    widget.onChildSelected!(
                      SettingPage(onChildSelected: widget.onChildSelected!),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                onNotification: () {},
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'Are You Sure You Want To\nDelete Your Account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Info card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _cardBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This action will permanently delete all of your data, and you will not be able to recover it. Please keep the following in mind before proceeding:',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: _textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _bullet(
                              'All your expenses, income and associated transactions will be eliminated.'),
                          const SizedBox(height: 10),
                          _bullet(
                              'You will not be able to access your account or any related information.'),
                          const SizedBox(height: 10),
                          _bullet('This action cannot be undone.'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Please Enter Your Password To Confirm\nDeletion Of Your Account.',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _PasswordPillField(
                      controller: _passwordCtrl,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      chipColor: _chipGrey,
                      pillColor: const Color(0xFFE0EAEE),
                      textColor: _textPrimary,
                      hintDots: '••••••••',
                    ),

                    const SizedBox(height: 22),

                    // Primary button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlueDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Yes, Delete Account',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (widget.onChildSelected != null) {
                                  widget.onChildSelected!(
                                    SettingPage(
                                        onChildSelected:
                                            widget.onChildSelected!),
                                  );
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _pillGrey,
                          foregroundColor: _textPrimary,
                          side: BorderSide(color: _pillGrey),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF8CA4B5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordPillField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final Color chipColor;
  final Color pillColor;
  final Color textColor;
  final String hintDots;

  const _PasswordPillField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    required this.chipColor,
    required this.pillColor,
    required this.textColor,
    required this.hintDots,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            height: 48,
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintDots,
                hintStyle: TextStyle(
                  color: textColor.withOpacity(0.6),
                  letterSpacing: 3,
                  fontSize: 18,
                ),
              ),
              style: const TextStyle(fontSize: 18, letterSpacing: 3),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF536571),
              size: 20,
            ),
            splashRadius: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
