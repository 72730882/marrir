import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final EmployeeDashboardService _promotionService = EmployeeDashboardService();
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  String? _error;
  bool _hasActiveSubscription = false;

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
      // Silently handle subscription check error
      print('Subscription check error: $e');
    }
  }

  Future<void> _buyPackage(int packageId) async {
    try {
      final paymentData =
          await _promotionService.buyPromotionPackage(packageId);

      // Handle payment redirect - you might want to open a WebView here
      if (paymentData.containsKey('order') &&
          paymentData['order'].containsKey('url')) {
        final paymentUrl = paymentData['order']['url'];
        // Navigate to payment screen or open WebView
        _showPaymentDialog(paymentUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to buy package: ${e.toString()}')),
      );
    }
  }

  void _showPaymentDialog(String paymentUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Required'),
        content: const Text('You will be redirected to complete your payment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement payment navigation here
              // For example: Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewScreen(url: paymentUrl)));
            },
            child: const Text('Continue'),
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
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _planCard(
                                    "\$${package['price']}",
                                    "Duration: ${package['duration']}",
                                    "${package['profile_count']} Profile Count",
                                    onTap: () => _buyPackage(package['id']),
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

  Widget _planCard(String price, String duration, String profileCount,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
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
              child: Text(
                profileCount,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            // if (onTap != null)
            //   ElevatedButton(
            //     onPressed: onTap,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.blue,
            //       foregroundColor: Colors.white,
            //     ),
            //     child: const Text('Buy Now'),
            //   ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for EmployeeSelectionScreen - you'll need to implement this
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
