import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/services/Employee/dashboard_service.dart';
import 'package:marrir/services/Employer/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For web URL launching
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

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
          SnackBar(
            content: Text(_getTranslatedPaymentRedirectMessage()),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 5),
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
          content: Text('${_getTranslatedPaymentFailed()}: ${e.toString()}'),
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
        SnackBar(
          content: Text(_getTranslatedPurchaseSuccess()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getTranslatedPurchaseFailed()}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showPaymentConfirmation(
      {required String packageName, required double amount}) async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_getTranslatedConfirmPayment(languageProvider)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${_getTranslatedPackage(languageProvider)}: $packageName'),
                Text(
                    '${_getTranslatedAmount(languageProvider)}: \$${amount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Text(
                  _getTranslatedPaymentRedirectDescription(languageProvider),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _getTranslatedPaymentReturnMessage(languageProvider),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_getTranslatedCancel(languageProvider)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                ),
                child: Text(_getTranslatedProceedToPayment(languageProvider)),
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
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTranslatedPaymentURL(languageProvider)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getTranslatedCopyURLMessage(languageProvider)),
            const SizedBox(height: 16),
            SelectableText(
              url,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getTranslatedPaymentReturnMessage(languageProvider),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTranslatedOK(languageProvider)),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard functionality would go here
              Navigator.pop(context);
            },
            child: Text(_getTranslatedCopyURL(languageProvider)),
          ),
        ],
      ),
    );
  }

  void _navigateToEmployeeSelection() {
    if (!_hasActiveSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedPurchasePackageFirst())),
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
    final languageProvider = Provider.of<LanguageProvider>(context);

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
                SnackBar(
                    content:
                        Text(_getTranslatedTokenNotFound(languageProvider))),
              );
            }
          },
        ),
        centerTitle: true,
        title: Text(
          _getTranslatedTitle(languageProvider),
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                _getTranslatedPromotions(languageProvider),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                _getTranslatedChoosePlan(languageProvider),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
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
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _getTranslatedActiveSubscription(languageProvider),
                        style:
                            const TextStyle(color: Colors.green, fontSize: 14),
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
                                '${_getTranslatedError(languageProvider)}: $_error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadPackages,
                                child:
                                    Text(_getTranslatedRetry(languageProvider)),
                              ),
                            ],
                          ),
                        )
                      : _packages.isEmpty
                          ? Center(
                              child: Text(
                                  _getTranslatedNoPackages(languageProvider)),
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
                                    "${_getTranslatedDuration(languageProvider)}: ${package['duration']}",
                                    "${package['profile_count']} ${_getTranslatedProfileCount(languageProvider)}",
                                    isLoading: isLoading,
                                    onTap: () => _buyPackage(packageId),
                                    languageProvider: languageProvider,
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
                child:
                    Text(_getTranslatedContinueToSelection(languageProvider)),
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
    required LanguageProvider languageProvider,
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
                child: Text(_getTranslatedBuyNow(languageProvider)),
              ),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الترقية";
    if (lang == 'am') return "ማስተዋወቅ";
    return "Promotion";
  }

  String _getTranslatedPromotions(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الترقيات";
    if (lang == 'am') return "ማስተዋወቅ";
    return "Promotions";
  }

  String _getTranslatedChoosePlan(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر الخطة المناسبة لك";
    if (lang == 'am') return "ለእርስዎ ተስማሚ የሆነውን እቅድ ይምረጡ";
    return "Choose the plan that's right for you";
  }

  String _getTranslatedActiveSubscription(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لديك اشتراك نشط";
    if (lang == 'am') return "ንቁ የሆነ ምዝገባ አለዎት";
    return "You have an active subscription";
  }

  String _getTranslatedError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "خطأ";
    if (lang == 'am') return "ስህተት";
    return "Error";
  }

  String _getTranslatedRetry(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إعادة المحاولة";
    if (lang == 'am') return "እንደገና ሞክር";
    return "Retry";
  }

  String _getTranslatedNoPackages(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لا توجد باقات متاحة";
    if (lang == 'am') return "ምንም ጥቅሎች የሉም";
    return "No packages available";
  }

  String _getTranslatedDuration(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المدة";
    if (lang == 'am') return "ቆይታ";
    return "Duration";
  }

  String _getTranslatedProfileCount(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "عدد الملفات الشخصية";
    if (lang == 'am') return "የመገለጫ ብዛት";
    return "Profile Count";
  }

  String _getTranslatedContinueToSelection(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المتابعة إلى اختيار الموظف";
    if (lang == 'am') return "ወደ ሰራተኛ ምርጫ ቀጥል";
    return "Continue to Employee Selection";
  }

  String _getTranslatedBuyNow(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اشتر الآن";
    if (lang == 'am') return "አሁን ይግዙ";
    return "Buy Now";
  }

  String _getTranslatedConfirmPayment(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تأكيد الدفع";
    if (lang == 'am') return "ክፍያ አረጋግጥ";
    return "Confirm Payment";
  }

  String _getTranslatedPackage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الباقة";
    if (lang == 'am') return "ጥቅል";
    return "Package";
  }

  String _getTranslatedAmount(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المبلغ";
    if (lang == 'am') return "መጠን";
    return "Amount";
  }

  String _getTranslatedPaymentRedirectDescription(
      LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar')
      return "سيتم توجيهك إلى بوابة الدفع Telr لإكمال الدفع بأمان.";
    if (lang == 'am') return "ወደ Telr የክፍያ መግቢያ በደህንነት ክፍያውን ለማጠናቀቅ ይመራሉ።";
    return "You will be redirected to Telr payment gateway to complete the payment securely.";
  }

  String _getTranslatedPaymentReturnMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar')
      return "بعد الدفع، ارجع إلى هذا التطبيق لرؤية حالة التحديث.";
    if (lang == 'am') return "ከክፍያ በኋላ፣ ወደዚህ መተግበሪያ ተመለስ የተዘመነውን ሁኔታ ለማየት።";
    return "After payment, return to this app to see your updated status.";
  }

  String _getTranslatedCancel(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إلغاء";
    if (lang == 'am') return "ሰርዝ";
    return "Cancel";
  }

  String _getTranslatedProceedToPayment(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المتابعة إلى الدفع";
    if (lang == 'am') return "ወደ ክፍያ ቀጥል";
    return "Proceed to Payment";
  }

  String _getTranslatedPaymentURL(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رابط الدفع";
    if (lang == 'am') return "የክፍያ አድራሻ";
    return "Payment URL";
  }

  String _getTranslatedCopyURLMessage(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "يرجى نسخ هذا الرابط وفتحه في متصفحك:";
    if (lang == 'am') return "እባክዎ ይህን አድራሻ ይቅዱ እና በአሳሽዎ ውስጥ ይክፈቱት:";
    return "Please copy this URL and open it in your browser:";
  }

  String _getTranslatedOK(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "موافق";
    if (lang == 'am') return "እሺ";
    return "OK";
  }

  String _getTranslatedCopyURL(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "نسخ الرابط";
    if (lang == 'am') return "አድራሻ ቅዱ";
    return "Copy URL";
  }

  String _getTranslatedPurchasePackageFirst() {
    return "Please purchase a package first";
  }

  String _getTranslatedPaymentRedirectMessage() {
    return "Redirected to payment gateway. Complete the payment and return to the app.";
  }

  String _getTranslatedPaymentFailed() {
    return "Payment failed";
  }

  String _getTranslatedPurchaseSuccess() {
    return "Package purchased successfully!";
  }

  String _getTranslatedPurchaseFailed() {
    return "Failed to complete purchase";
  }

  String _getTranslatedTokenNotFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز غير موجود، يرجى تسجيل الدخول مرة أخرى";
    if (lang == 'am') return "ቶከን አልተገኘም፣ እባክዎ እንደገና ይግቡ";
    return "Token not found, please login again";
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
