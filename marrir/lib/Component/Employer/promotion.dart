import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  final EmployeeDashboardService _promotionService = EmployeeDashboardService();
  List<Map<String, dynamic>> _packages = [];
  bool _isInitialLoading = true;
  String _errorMessage = '';
  int? _selectedPackageId;
  // Track loading state for each package individually
  Map<int, bool> _packageLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadPromotionPackages();
  }

  Future<void> _loadPromotionPackages() async {
    try {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = '';
      });

      final packages = await _promotionService.getPromotionPackages();

      setState(() {
        _packages = packages;
        _isInitialLoading = false;
        // Initialize loading states for all packages
        for (var package in packages) {
          _packageLoadingStates[package['id']] = false;
        }
      });
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'Failed to load promotion packages';
      });
      print('❌ Error loading promotion packages: $e');
    }
  }

  Future<void> _buyPackage(int packageId) async {
    try {
      setState(() {
        // Set loading state only for this specific package
        _packageLoadingStates[packageId] = true;
        _errorMessage = '';
      });

      final result = await _promotionService.buyPromotionPackage(packageId);

      setState(() {
        _packageLoadingStates[packageId] = false;
        _selectedPackageId = packageId;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package purchased successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ Package purchased: $result');
    } catch (e) {
      setState(() {
        _packageLoadingStates[packageId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to purchase package: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      print('❌ Error purchasing package: $e');
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '\$0';
    if (price is int || price is double) {
      return '\$${price.toStringAsFixed(0)}';
    }
    if (price is String) {
      return '\$$price';
    }
    return '\$0';
  }

  String _formatDuration(dynamic duration) {
    if (duration == null) return 'No duration';
    return 'Duration: $duration';
  }

  String _formatProfileCount(dynamic count) {
    if (count == null) return '0 Profile Count';
    if (count == 1) return '1 Profile Count';
    return '$count Profile Counts';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // ===== Title =====
              const Text(
                "Promotions",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // ===== Subtitle =====
              const Text(
                "Choose the plan that's right for you",
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 94, 91, 91),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ===== Loading Indicator =====
              if (_isInitialLoading && _packages.isEmpty)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // ===== Error Message =====
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),

              // ===== Refresh Button =====
              if (_errorMessage.isNotEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: _loadPromotionPackages,
                    child: const Text('Try Again'),
                  ),
                ),

              // ===== No Packages Message =====
              if (!_isInitialLoading &&
                  _packages.isEmpty &&
                  _errorMessage.isEmpty)
                const Center(
                  child: Text(
                    'No promotion packages available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),

              // ===== Promotion Packages List =====
              if (_packages.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final package = _packages[index];
                      final packageId = package['id'];
                      final price = package['price'];
                      final duration = package['duration'];
                      final profileCount = package['profile_count'] ?? 1;
                      final isSelected = _selectedPackageId == packageId;
                      final isLoading =
                          _packageLoadingStates[packageId] ?? false;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F4F8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF65B2C9),
                                  width: 2,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _formatPrice(price),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF65B2C9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Promotion",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _buyPackage(packageId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF65B2C9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _formatProfileCount(profileCount),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ==== GRAY LINE DIVIDER ====
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  height: 1,
                ),
                const SizedBox(height: 20),

                // ==== CONTINUE BUTTON ====
                if (_selectedPackageId != null)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle continue action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Proceeding with selected package...'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF65B2C9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
