import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/services/Employee/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final payments = await PaymentService.getUserPayments();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatStatus(String status, LanguageProvider languageProvider) {
    switch (status.toLowerCase()) {
      case 'paid':
        return _getTranslatedCompleted(languageProvider);
      case 'pending':
        return _getTranslatedPending(languageProvider);
      case 'failed':
        return _getTranslatedFailed(languageProvider);
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
      body: _isLoading
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
                        onPressed: _loadPayments,
                        child: Text(_getTranslatedRetry(languageProvider)),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTranslatedListDescription(languageProvider),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),

                      // Table
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              const Color.fromRGBO(142, 198, 214, 1),
                            ),
                            headingTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            columns: [
                              DataColumn(
                                  label: Text(
                                      _getTranslatedBank(languageProvider))),
                              DataColumn(
                                  label: Text(_getTranslatedTransactionID(
                                      languageProvider))),
                              DataColumn(
                                  label: Text(
                                      _getTranslatedAmount(languageProvider))),
                              DataColumn(
                                  label: Text(
                                      _getTranslatedDate(languageProvider))),
                              DataColumn(
                                  label: Text(
                                      _getTranslatedType(languageProvider))),
                              DataColumn(
                                  label: Text(
                                      _getTranslatedStatus(languageProvider))),
                            ],
                            rows: _payments.isEmpty
                                ? [
                                    DataRow(cells: [
                                      DataCell(Text(
                                          _getTranslatedNoPaymentsFound(
                                              languageProvider))),
                                      const DataCell(Text("")),
                                      const DataCell(Text("")),
                                      const DataCell(Text("")),
                                      const DataCell(Text("")),
                                      const DataCell(Text("")),
                                    ])
                                  ]
                                : _payments.map((payment) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(
                                            payment['card']?.toString() ??
                                                _getTranslatedTelr(
                                                    languageProvider))),
                                        DataCell(Text(
                                            payment['ref']?.toString() ??
                                                _getTranslatedNotAvailable(
                                                    languageProvider))),
                                        DataCell(Text(
                                            "${payment['amount']?.toStringAsFixed(2) ?? '0.00'} ${_getTranslatedAED(languageProvider)}")),
                                        DataCell(Text(_formatDate(
                                            payment['created_at']?.toString() ??
                                                ''))),
                                        DataCell(Text(
                                            payment['type']?.toString() ??
                                                _getTranslatedNotAvailable(
                                                    languageProvider))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                  payment['status']
                                                          ?.toString() ??
                                                      ''),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _formatStatus(
                                                  payment['status']
                                                          ?.toString() ??
                                                      '',
                                                  languageProvider),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المدفوعات";
    if (lang == 'am') return "ክፍያዎች";
    return "Payments";
  }

  String _getTranslatedTokenNotFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز غير موجود، يرجى تسجيل الدخول مرة أخرى";
    if (lang == 'am') return "ቶከን አልተገኘም፣ እባክዎ እንደገና ይግቡ";
    return "Token not found, please login again";
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

  String _getTranslatedListDescription(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "قائمة المدفوعات";
    if (lang == 'am') return "የክፍያዎች ዝርዝር";
    return "The list of payments";
  }

  String _getTranslatedBank(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "البنك";
    if (lang == 'am') return "ባንክ";
    return "Bank";
  }

  String _getTranslatedTransactionID(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "رقم المعاملة";
    if (lang == 'am') return "የግብይት መለያ";
    return "Transaction ID";
  }

  String _getTranslatedAmount(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "المبلغ";
    if (lang == 'am') return "መጠን";
    return "Amount";
  }

  String _getTranslatedDate(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "التاريخ";
    if (lang == 'am') return "ቀን";
    return "Date";
  }

  String _getTranslatedType(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "النوع";
    if (lang == 'am') return "ዓይነት";
    return "Type";
  }

  String _getTranslatedStatus(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الحالة";
    if (lang == 'am') return "ሁኔታ";
    return "Status";
  }

  String _getTranslatedNoPaymentsFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لم يتم العثور على مدفوعات";
    if (lang == 'am') return "ክፍያዎች አልተገኙም";
    return "No payments found";
  }

  String _getTranslatedTelr(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تلر";
    if (lang == 'am') return "ቴልር";
    return "Telr";
  }

  String _getTranslatedNotAvailable(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "غير متوفر";
    if (lang == 'am') return "አይገኝም";
    return "N/A";
  }

  String _getTranslatedAED(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "درهم";
    if (lang == 'am') return "ዲርሃም";
    return "AED";
  }

  String _getTranslatedCompleted(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "مكتمل";
    if (lang == 'am') return "ተጠናቋል";
    return "Completed";
  }

  String _getTranslatedPending(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "قيد الانتظار";
    if (lang == 'am') return "በመጠባበቅ ላይ";
    return "Pending";
  }

  String _getTranslatedFailed(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل";
    if (lang == 'am') return "አልተሳካም";
    return "Failed";
  }
}
