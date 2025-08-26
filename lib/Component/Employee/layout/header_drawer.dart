import 'package:flutter/material.dart';

class EmployeeHeaderDrawer extends StatelessWidget {
  final VoidCallback closeDrawer;
  final Function(int) onMenuSelected;
  final int selectedIndex;

  const EmployeeHeaderDrawer({
    super.key,
    required this.closeDrawer,
    required this.onMenuSelected,
    required this.selectedIndex,
  });

  static const _bgWhite = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF8E8E93);
  static const _primary = Color(0xFF3A99D8);

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
                    onPressed: closeDrawer,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE5E5E5), thickness: 1),
              const SizedBox(height: 20),

              // Menu items
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem(Icons.home_outlined, "Dashboard", 0),
                    _buildMenuItem(Icons.access_time, "Status", 1),
                    _buildMenuItem(Icons.star_border, "Rating", 2),
                    _buildMenuItem(Icons.bookmark_border, "Reserves", 3),
                    _buildMenuItem(Icons.campaign_outlined, "Promotion", 4),
                    _buildMenuItem(Icons.payment_outlined, "Payments", 5),
                    _buildMenuItem(Icons.help_outline, "Help Center", 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        onMenuSelected(index); // ✅ Switch screen
        // Drawer will auto-close in layout after menu select
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: _primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
