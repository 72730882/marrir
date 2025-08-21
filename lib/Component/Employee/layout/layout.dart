import 'package:flutter/material.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/dashboard.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/help.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/rating.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/reserve.dart';
import 'package:marrir/Component/Employee/EmployeeDashboard/status.dart';
import 'package:marrir/Component/Employee/layout/header_drawer.dart';
import 'package:marrir/Component/homepage/PaymentMethod/payment_method.dart';
import 'package:marrir/Component/homepage/PromotedCvs/promotedcvs.dart';
import 'employee_header.dart';
import 'employee_footer.dart';

// Import screens

class EmployeeLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool showHeader;

  const EmployeeLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
    this.showHeader = true,
  });

  @override
  State<EmployeeLayout> createState() => _EmployeeLayoutState();
}

class _EmployeeLayoutState extends State<EmployeeLayout> {
  bool _isDrawerOpen = false;
  int _selectedMenuIndex = -1; // -1 = tab layout, >=0 = drawer page

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _onMenuSelected(int index) {
    setState(() {
      _selectedMenuIndex = index;
      _isDrawerOpen = false; // Close drawer immediately after selection
    });
  }

  bool get _isDrawerScreen => _selectedMenuIndex != -1;

  Widget _getSelectedScreen() {
    switch (_selectedMenuIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const StatusUpdateScreen();
      case 2:
        return const RatingScreen();
      case 3:
        return const ReservesScreen();
      case 4:
        return const PromotedCVsScreen();
      case 5:
        return const PaymentMethods();
      case 6:
        return const HelpCenterScreen();
      default:
        return widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Only show header if not on a drawer screen
                if (widget.showHeader && !_isDrawerScreen)
                  EmployeeHeader(onMenuTap: _toggleDrawer),

                Expanded(child: _getSelectedScreen()),
              ],
            ),
          ),

          // Overlay background when drawer is open
          if (_isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleDrawer, // Close drawer when tapping outside
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),

          // Full-screen Animated Drawer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? 0 : -MediaQuery.of(context).size.width,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: EmployeeHeaderDrawer(
                closeDrawer: _toggleDrawer,
                onMenuSelected: _onMenuSelected,
                selectedIndex: _selectedMenuIndex,
              ),
            ),
          ),
        ],
      ),

      // Hide footer when a drawer screen is active
      bottomNavigationBar: _isDrawerScreen
          ? null
          : EmployeeNavBar(
              currentIndex: widget.currentIndex,
              onTabSelected: widget.onTabSelected,
            ),
    );
  }
}
