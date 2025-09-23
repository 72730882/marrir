import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';
import 'package:marrir/services/Employer/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For web URL launching

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final EmployeeDashboardService _promotionService = EmployeeDashboardService();
  final PaymentService _paymentService = PaymentService();
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  String? _error;
  bool _hasActiveSubscription = false;
  final Map<int, bool> _packageLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadPackages();
    _checkSubscription();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await _promotionService.getPromotionPackages();
      setState(() {
        _packages = packages;
        _isLoading = false;
        // Initialize loading states
        for (var package in packages) {
          _packageLoadingStates[package['id']] = false;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkSubscription() async {
    try {
      final subscription = await _promotionService.getUserSubscription();
      setState(() {
        _hasActiveSubscription = subscription != null;
      });
    } catch (e) {
      print('Subscription check error: $e');
    }
  }

  Future<void> _buyPackage(int packageId) async {
    try {
      setState(() {
        _packageLoadingStates[packageId] = true;
        _error = null;
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

        // Launch the payment URL
        await _launchPaymentUrl(paymentUrl);

        // Show success message - payment is being processed
        setState(() {
          _packageLoadingStates[packageId] = false;
          _hasActiveSubscription =
              true; // Assume subscription is active after payment
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
    }
  }

  Future<void> _completePurchase(int packageId) async {
    try {
      // Mark package as purchased after payment
      final result = await _promotionService.buyPromotionPackage(packageId);

      setState(() {
        _hasActiveSubscription = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package purchased successfully!'),
          backgroundColor: Colors.green,
        ),
      );
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
                  backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
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
      if (kIsWeb) {
        // For web: open new browser tab
        // html.window.open(url, '_blank');
      } else {
        // For mobile/desktop: use url_launcher
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
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
              // Copy to clipboard functionality would go here
              Navigator.pop(context);
            },
            child: const Text('Copy URL'),
          ),
        ],
      ),
    );
  }

  void _navigateToEmployeeSelection() {
    if (!_hasActiveSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please purchase a package first')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? token = prefs.getString("access_token");

            if (token != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeePage(token: token),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Token not found, please login again.")),
              );
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          "Promotion",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                "Promotions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                "Choose the plan that's right for you",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 30),

            if (_hasActiveSubscription)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'You have an active subscription',
                        style: TextStyle(color: Colors.green, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            // Plans
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: $_error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadPackages,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _packages.isEmpty
                          ? const Center(
                              child: Text('No packages available'),
                            )
                          : ListView.builder(
                              itemCount: _packages.length,
                              itemBuilder: (context, index) {
                                final package = _packages[index];
                                final packageId = package['id'];
                                final isLoading =
                                    _packageLoadingStates[packageId] ?? false;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _planCard(
                                    "\$${package['price']}",
                                    "Duration: ${package['duration']}",
                                    "${package['profile_count']} Profile Count",
                                    isLoading: isLoading,
                                    onTap: () => _buyPackage(packageId),
                                  ),
                                );
                              },
                            ),
            ),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToEmployeeSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Continue to Employee Selection"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(
    String price,
    String duration,
    String profileCount, {
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 240,
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 254, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              duration,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(142, 198, 214, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      profileCount,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
            ),
            const SizedBox(height: 16),
            if (onTap != null && !isLoading)
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Buy Now'),
              ),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Placeholder for EmployeeSelectionScreen
class EmployeeSelectionScreen extends StatelessWidget {
  const EmployeeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Employees')),
      body: const Center(child: Text('Employee Selection Screen')),
    );
  }
}
