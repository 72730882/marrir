import 'package:flutter/material.dart';
import 'package:marrir/services/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class EmployeeHeaderDrawer extends StatefulWidget {
  final VoidCallback closeDrawer;
  final Function(int) onMenuSelected;
  final int selectedIndex;
  final String token;

  const EmployeeHeaderDrawer({
    super.key,
    required this.closeDrawer,
    required this.onMenuSelected,
    required this.selectedIndex,
    required this.token,
  });

  @override
  State<EmployeeHeaderDrawer> createState() => _EmployeeHeaderDrawerState();
}

class _EmployeeHeaderDrawerState extends State<EmployeeHeaderDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ✅ Initialize empty lists to prevent LateInitializationError
  List<Animation<Offset>> _slideAnimations = [];
  List<Animation<double>> _fadeAnimations = [];

  Map<String, dynamic>? userData;
  bool isLoading = true;

  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.home_outlined, "title": "Dashboard"},
    {"icon": Icons.access_time, "title": "Status"},
    {"icon": Icons.star_border, "title": "Rating"},
    {"icon": Icons.bookmark_border, "title": "Reserves"},
    {"icon": Icons.campaign_outlined, "title": "Promotion"},
    {"icon": Icons.payment_outlined, "title": "Payments"},
    {"icon": Icons.help_outline, "title": "Help Center"},
  ];

  static const _bgWhite = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF8E8E93);
  static const _primary = Color(0xFF65b2c9);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // ✅ Populate animation lists
    _slideAnimations = List.generate(menuItems.length, (index) {
      final start = index * 0.1;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _fadeAnimations = List.generate(menuItems.length, (index) {
      final start = index * 0.1;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _controller.forward();

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("user_email");

      if (email == null) throw Exception("No stored email found");

      final data =
          await ApiService.getUserInfo(email: email, Token: widget.token);

      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Failed to load user info: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final fullName = userData != null
        ? "${userData!['first_name']} ${userData!['last_name']}"
        : _getTranslatedLoading(languageProvider);
    final role = userData?['role'] ?? "";

    return Material(
      color: _bgWhite,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person_outline, size: 28, color: _ink),
                      const SizedBox(height: 8),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role,
                        style: const TextStyle(fontSize: 14, color: _muted),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _ink),
                    onPressed: widget.closeDrawer,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE5E5E5), thickness: 1),
              const SizedBox(height: 20),

              // Animated menu items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(menuItems.length, (index) {
                      return SlideTransition(
                        position: _slideAnimations[index],
                        child: FadeTransition(
                          opacity: _fadeAnimations[index],
                          child: _buildMenuItem(
                            menuItems[index]["icon"],
                            menuItems[index]["title"],
                            index,
                            languageProvider,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index,
      LanguageProvider languageProvider) {
    final isSelected = widget.selectedIndex == index;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: InkWell(
            onTap: () {
              widget.onMenuSelected(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? _primary.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isHovered || isSelected ? Colors.black : _primary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _getTranslatedMenuItem(title, languageProvider),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isHovered || isSelected ? Colors.black : _ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Translation helper methods
  String _getTranslatedLoading(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "جاري التحميل...";
    if (lang == 'am') return "በመጫን ላይ...";
    return "Loading...";
  }

  String _getTranslatedMenuItem(
      String title, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    switch (title) {
      case "Dashboard":
        if (lang == 'ar') return "لوحة التحكم";
        if (lang == 'am') return "ዳሽቦርድ";
        return "Dashboard";

      case "Status":
        if (lang == 'ar') return "الحالة";
        if (lang == 'am') return "ሁኔታ";
        return "Status";

      case "Rating":
        if (lang == 'ar') return "التقييم";
        if (lang == 'am') return "ደረጃ";
        return "Rating";

      case "Reserves":
        if (lang == 'ar') return "الحجوزات";
        if (lang == 'am') return "ቦታ ያለው";
        return "Reserves";

      case "Promotion":
        if (lang == 'ar') return "الترقية";
        if (lang == 'am') return "ማስተዋወቅ";
        return "Promotion";

      case "Payments":
        if (lang == 'ar') return "المدفوعات";
        if (lang == 'am') return "ክፍያዎች";
        return "Payments";

      case "Help Center":
        if (lang == 'ar') return "مركز المساعدة";
        if (lang == 'am') return "የእገዛ ማዕከል";
        return "Help Center";

      default:
        return title;
    }
  }

  // String _getTranslatedNoEmailError(LanguageProvider languageProvider) {
  //   final lang = languageProvider.currentLang;
  //   if (lang == 'ar') return "لم يتم العثور على بريد إلكتروني مخزن";
  //   if (lang == 'am') return "የተቀመጠ ኢሜይል አልተገኘም";
  //   return "No stored email found";
  // }

  // String _getTranslatedLoadUserError(LanguageProvider languageProvider) {
  //   final lang = languageProvider.currentLang;
  //   if (lang == 'ar') return "فشل تحميل معلومات المستخدم";
  //   if (lang == 'am') return "የተጠቃሚ መረጃ መጫን አልተሳካም";
  //   return "Failed to load user info";
  // }
}
