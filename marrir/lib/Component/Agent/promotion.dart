import 'package:flutter/material.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';
import 'package:marrir/services/Employer/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import your LanguageProvider

class AgentPromotionPage extends StatefulWidget {
  const AgentPromotionPage({super.key});

  @override
  State<AgentPromotionPage> createState() => _AgentPromotionPageState();
}

class _AgentPromotionPageState extends State<AgentPromotionPage> {
  final EmployeeDashboardService _promotionService = EmployeeDashboardService();
  final PaymentService _paymentService = PaymentService();
  List<Map<String, dynamic>> _packages = [];
  bool _isInitialLoading = true;
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
        _isInitialLoading = true;
        _errorMessage = '';
      });

      final packages = await _promotionService.getPromotionPackages();

      setState(() {
        _packages = packages;
        _isInitialLoading = false;
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
        _packageLoadingStates[packageId] = true;
        _errorMessage = '';
      });

      // Get package details
      final package = _packages.firstWhere((p) => p['id'] == packageId);

      // Convert price to double
      final price = package['price'] is num
          ? package['price'].toDouble()
          : double.tryParse(package['price'].toString()) ?? 0.0;

      // Get user ID
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      // Show payment confirmation dialog
      final proceed = await _showPaymentConfirmation(
        packageName: '${package['duration']} Promotion',
        amount: price,
      );

      if (!proceed) {
        setState(() {
          _packageLoadingStates[packageId] = false;
        });
        return;
      }

      // Initiate Telr payment
      final paymentResult = await _paymentService.createTelrPayment(
        amount: price,
        package: '${package['duration']} Promotion',
        userId: userId,
      );

      // Handle payment result
      if (paymentResult['order'] != null &&
          paymentResult['order']['url'] != null) {
        final paymentUrl = paymentResult['order']['url'];

        // Launch the payment URL using platform-agnostic method
        await _launchPaymentUrl(paymentUrl);

        // Show success message - payment is being processed
        setState(() {
          _packageLoadingStates[packageId] = false;
          _selectedPackageId = packageId;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Redirected to payment gateway. Complete the payment and return to the app.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        throw Exception('Failed to get payment URL from Telr');
      }
    } catch (e) {
      setState(() {
        _packageLoadingStates[packageId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      print('❌ Error purchasing package: $e');
    }
  }

  Future<void> _completePurchase(int packageId) async {
    try {
      final result = await _promotionService.buyPromotionPackage(packageId);

      setState(() {
        _selectedPackageId = packageId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package purchased successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ Package purchased: $result');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete purchase: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showPaymentConfirmation(
      {required String packageName, required double amount}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Package: $packageName'),
                Text('Amount: \$${amount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Text(
                  'You will be redirected to Telr payment gateway to complete the payment securely.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'After payment, return to this app to see your updated status.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65B2C9),
                ),
                child: const Text('Proceed to Payment'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      // Platform-agnostic URL launching
      if (isWeb()) {
        _launchUrlWeb(url);
      } else {
        _launchUrlMobile(url);
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
      _showUrlFallback(url);
    }
  }

  bool isWeb() {
    return identical(0, 0.0);
  }

  void _launchUrlWeb(String url) {
    try {
      if (hasFlutterWindow()) {
        flutterWindowOpen(url, '_blank');
      } else {
        _openUrlWithAnchorTag(url);
      }
    } catch (e) {
      _showUrlFallback(url);
    }
  }

  bool hasFlutterWindow() {
    try {
      return (() {
        try {
          return (() => true)();
        } catch (e) {
          return false;
        }
      })();
    } catch (e) {
      return false;
    }
  }

  void flutterWindowOpen(String url, String target) {
    _openUrlWithAnchorTag(url);
  }

  void _openUrlWithAnchorTag(String url) {
    final html = '''
      <script>
        function openUrl() {
          const link = document.createElement('a');
          link.href = '$url';
          link.target = '_blank';
          link.rel = 'noopener noreferrer';
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        }
        openUrl();
      </script>
    ''';

    _showUrlFallback(url);
  }

  Future<void> _launchUrlMobile(String url) async {
    try {
      // Use url_launcher package for mobile
      // await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      _showUrlFallback(url);
    } catch (e) {
      _showUrlFallback(url);
    }
  }

  void _showUrlFallback(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please copy this URL and open it in your browser:'),
            const SizedBox(height: 16),
            SelectableText(
              url,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'After completing payment, return to this app.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard functionality
              Navigator.pop(context);
            },
            child: const Text('Copy URL'),
          ),
        ],
      ),
    );
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
              Text(
                lang.t("promotions"),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                lang.t("choose_plan"),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 94, 91, 91),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isInitialLoading && _packages.isEmpty)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPromotionPackages,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
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
                                    borderRadius: BorderRadius.circular(24)),
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
                const Divider(color: Colors.grey, thickness: 0.5, height: 1),
                const SizedBox(height: 20),
                if (_selectedPackageId != null)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
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
                            borderRadius: BorderRadius.circular(12)),
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
