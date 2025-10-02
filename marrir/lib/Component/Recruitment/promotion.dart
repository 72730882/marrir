import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';
import 'package:marrir/services/Employer/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import your LanguageProvider
class RecruitmentPromotionPage extends StatefulWidget {
  const RecruitmentPromotionPage({super.key});

  @override
  State<RecruitmentPromotionPage> createState() =>
      _RecruitmentPromotionPageState();
}

class _RecruitmentPromotionPageState extends State<RecruitmentPromotionPage> {
  final EmployeeDashboardService _promotionService = EmployeeDashboardService();
  final PaymentService _paymentService = PaymentService();

  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int? _selectedPackageId;
  final Map<int, bool> _packageLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadPromotionPackages();
  }

  Future<void> _loadPromotionPackages() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final packages = await _promotionService.getPromotionPackages();

      setState(() {
        _packages = packages;
        _isLoading = false;
        for (var package in packages) {
          _packageLoadingStates[package['id']] = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load promotion packages';
      });
      print('❌ Error loading promotion packages: $e');
    }
  }

  Future<void> _buyPackage(int packageId) async {
    try {
      setState(() => _packageLoadingStates[packageId] = true);

      final package = _packages.firstWhere((p) => p['id'] == packageId);
      final price = double.tryParse(package['price'].toString()) ?? 0.0;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final proceed = await _showPaymentConfirmation(
        packageName: '${package['duration']} Promotion',
        amount: price,
      );

      if (!proceed) {
        setState(() => _packageLoadingStates[packageId] = false);
        return;
      }

      final paymentResult = await _paymentService.createTelrPayment(
        amount: price,
        package: '${package['duration']} Promotion',
        userId: userId,
      );

      if (paymentResult['order']?['url'] != null) {
        final paymentUrl = paymentResult['order']['url'];

        // TODO: Replace with actual url_launcher
        print('🔗 Open Payment URL: $paymentUrl');

        setState(() {
          _packageLoadingStates[packageId] = false;
          _selectedPackageId = packageId;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Redirected to payment gateway. Complete the payment.'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        throw Exception('Failed to get payment URL from Telr');
      }
    } catch (e) {
      setState(() => _packageLoadingStates[packageId] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Payment failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _showPaymentConfirmation(
      {required String packageName, required double amount}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Payment'),
            content: Text(
                'Package: $packageName\nAmount: \$${amount.toStringAsFixed(2)}'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Proceed'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '\$0';
    return '\$${price.toString()}';
  }

  @override
  Widget build(BuildContext context) {
            final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
               Text(lang.t("promotions"),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(lang.t("choose_plan"),
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 32),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                          onPressed: _loadPromotionPackages,
                          child: const Text('Retry'))
                    ],
                  ),
                ),
              if (!_isLoading && _packages.isEmpty && _errorMessage.isEmpty)
                const Text('No promotion packages available',
                    style: TextStyle(color: Colors.grey)),
              if (_packages.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final package = _packages[index];
                      final packageId = package['id'];
                      final isLoading =
                          _packageLoadingStates[packageId] ?? false;
                      final isSelected = _selectedPackageId == packageId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F4F8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF65B2C9), width: 2)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(_formatPrice(package['price']),
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF65B2C9))),
                            const SizedBox(height: 8),
                            Text("Duration: ${package['duration']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text("Promotion",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _buyPackage(packageId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF65B2C9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white)))
                                  : Text(
                                      "${package['profile_count']} Profile Count",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (_selectedPackageId != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Proceeding with selected package...")),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65B2C9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continue',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
