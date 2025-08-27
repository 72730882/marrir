import 'package:flutter/material.dart';

class EmployeeHeaderDrawer extends StatefulWidget {
  final VoidCallback closeDrawer;
  final Function(int) onMenuSelected;
  final int selectedIndex;

  const EmployeeHeaderDrawer({
    super.key,
    required this.closeDrawer,
    required this.onMenuSelected,
    required this.selectedIndex,
  });

  @override
  State<EmployeeHeaderDrawer> createState() => _EmployeeHeaderDrawerState();
}

class _EmployeeHeaderDrawerState extends State<EmployeeHeaderDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _animations;

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

    _animations = List.generate(menuItems.length, (index) {
      final start = index * 0.1;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person_outline, size: 28, color: _ink),
                      SizedBox(height: 8),
                      Text(
                        'Hanan N',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'UX/UI Designer',
                        style: TextStyle(fontSize: 14, color: _muted),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(menuItems.length, (index) {
                      return SlideTransition(
                        position: _animations[index],
                        child: _buildMenuItem(
                          menuItems[index]["icon"],
                          menuItems[index]["title"],
                          index,
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

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = widget.selectedIndex == index;
    // Track hover state
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
                    title,
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
}
