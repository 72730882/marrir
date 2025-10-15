import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/services/Employee/status_sevice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class StatusUpdateScreen extends StatefulWidget {
  const StatusUpdateScreen({super.key});

  @override
  State<StatusUpdateScreen> createState() => _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends State<StatusUpdateScreen> {
  String? _selectedStatus;
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Map<String, dynamic>> _statusResults = [];

  final Map<String, String> statusMap = {
    "Active": "stable",
    "Inactive": "incomplete",
    "On Leave": "disease",
    "Terminated": "death",
    "Refuse Work": "refuse_work",
    "Hold": "hold",
    "Other": "other",
  };

  final Map<String, Color> statusColors = {
    "Active": Colors.green,
    "Inactive": Colors.orange,
    "On Leave": Colors.blue,
    "Terminated": Colors.red,
    "Refuse Work": Colors.deepPurple,
    "Hold": Colors.brown,
    "Other": Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _goBack(languageProvider),
        ),
        centerTitle: true,
        title: Text(
          _getTranslatedTitle(languageProvider),
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTranslatedDescription(languageProvider),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Generate PDF Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(_getTranslatedGeneratePDF(languageProvider)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Form Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getTranslatedStatus(languageProvider),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      hint: Text(_getTranslatedSelectStatus(languageProvider)),
                      items: statusMap.keys
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(_getTranslatedStatusValue(
                                    e, languageProvider)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_getTranslatedReason(languageProvider),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: _getTranslatedReasonHint(languageProvider),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(142, 198, 214, 1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child:
                                Text(_getTranslatedAddUpdate(languageProvider)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _fetchResults,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child:
                                Text(_getTranslatedResults(languageProvider)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Date Range Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_getTranslatedDateRange(languageProvider),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _fromDate = null;
                      _toDate = null;
                    });
                  },
                  child: Text(_getTranslatedReset(languageProvider),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                      _getTranslatedFrom(languageProvider), _fromDate,
                      () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _fromDate = picked;
                      });
                    }
                  }, languageProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                      _getTranslatedTo(languageProvider), _toDate, () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _toDate = picked;
                      });
                    }
                  }, languageProvider),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickButton(_getTranslatedToday(languageProvider),
                    _setTodayRange, languageProvider),
                _quickButton(_getTranslatedThisWeek(languageProvider),
                    _setWeekRange, languageProvider),
                _quickButton(_getTranslatedThisMonth(languageProvider),
                    _setMonthRange, languageProvider),
              ],
            ),

            const SizedBox(height: 16),

            // Status Results Section
            if (_statusResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTranslatedStatusLog(languageProvider),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _statusResults.length,
                    itemBuilder: (context, index) {
                      final status = _statusResults[index];
                      final statusValue = status['status'] ?? '';
                      final statusLabel = statusMap.entries
                          .firstWhere((e) => e.value == statusValue,
                              orElse: () => const MapEntry('Unknown', ''))
                          .key;
                      final date = DateTime.tryParse(status['date'] ?? '') ??
                          DateTime.now();
                      final color = statusColors[statusLabel] ?? Colors.grey;

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTranslatedStatusValue(
                                    statusLabel, languageProvider),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: color),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${date.day}-${date.month}-${date.year}",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                              if (status['reason'] != null &&
                                  (status['reason'] as String).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    status['reason'],
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade800),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _getTranslatedNoStatusUpdates(languageProvider),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _goBack(LanguageProvider languageProvider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    if (token != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => EmployeePage(token: token)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_getTranslatedTokenNotFound(languageProvider))));
    }
  }

  Future<void> _addStatus() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_getTranslatedSelectStatusError(languageProvider))));
      return;
    }

    final apiStatus = statusMap[_selectedStatus!];
    if (apiStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_getTranslatedInvalidStatus(languageProvider))));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    if (userId == null) return;

    final res = await EmployeeStatusService.addStatus(
      userId: userId,
      status: apiStatus,
      reason: _reasonController.text.isNotEmpty ? _reasonController.text : '',
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(res['message'] ?? '')));

    _fetchResults(); // Refresh list after adding
  }

  Future<void> _fetchResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    if (userId == null) return;

    final results = await EmployeeStatusService.getStatuses(
      userId: userId,
      fromDate: _fromDate,
      toDate: _toDate,
    );
    setState(() {
      _statusResults = results;
    });
  }

  Future<void> _generatePdf() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    if (userId == null) return;

    await EmployeeStatusService.generatePdf(userId: userId);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedPDFGenerated(languageProvider))));
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap,
      LanguageProvider languageProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              date != null ? "${date.day}-${date.month}-${date.year}" : label,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(
      String text, VoidCallback onTap, LanguageProvider languageProvider) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  void _setTodayRange() {
    DateTime today = DateTime.now();
    setState(() {
      _fromDate = DateTime(today.year, today.month, today.day);
      _toDate = DateTime(today.year, today.month, today.day);
    });
    _fetchResults();
  }

  void _setWeekRange() {
    DateTime today = DateTime.now();
    int weekday = today.weekday;
    DateTime startOfWeek = today.subtract(Duration(days: weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    setState(() {
      _fromDate = startOfWeek;
      _toDate = endOfWeek;
    });
    _fetchResults();
  }

  void _setMonthRange() {
    DateTime today = DateTime.now();
    DateTime startOfMonth = DateTime(today.year, today.month, 1);
    DateTime endOfMonth = DateTime(today.year, today.month + 1, 0);
    setState(() {
      _fromDate = startOfMonth;
      _toDate = endOfMonth;
    });
    _fetchResults();
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تحديث الحالة";
    if (lang == 'am') return "ሁኔታ አዘምን";
    return "Status Update";
  }

  String _getTranslatedDescription(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تقديم نظرة عامة عن حالة الموظف الحالية.";
    if (lang == 'am') return "የአሁኑ የተጠቃሚ ሁኔታ አጠቃላይ እይታ ይስጡ።";
    return "Provide an overview of your current employee status.";
  }

  String _getTranslatedGeneratePDF(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إنشاء ملف PDF للحالة";
    if (lang == 'am') return "የሁኔታ PDF ፍጠር";
    return "Generate Status PDF";
  }

  String _getTranslatedStatus(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الحالة *";
    if (lang == 'am') return "ሁኔታ *";
    return "Status *";
  }

  String _getTranslatedSelectStatus(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر الحالة";
    if (lang == 'am') return "ሁኔታ ይምረጡ";
    return "Select Status";
  }

  String _getTranslatedStatusValue(
      String status, LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;

    switch (status) {
      case "Active":
        if (lang == 'ar') return "نشط";
        if (lang == 'am') return "ንቁ";
        return "Active";
      case "Inactive":
        if (lang == 'ar') return "غير نشط";
        if (lang == 'am') return "ንቃት የለውም";
        return "Inactive";
      case "On Leave":
        if (lang == 'ar') return "في إجازة";
        if (lang == 'am') return "በእረፍት ላይ";
        return "On Leave";
      case "Terminated":
        if (lang == 'ar') return "منتهي";
        if (lang == 'am') return "ተቆርጧል";
        return "Terminated";
      case "Refuse Work":
        if (lang == 'ar') return "رفض العمل";
        if (lang == 'am') return "ሥራ ማቃለል";
        return "Refuse Work";
      case "Hold":
        if (lang == 'ar') return "معلق";
        if (lang == 'am') return "ያሮግ";
        return "Hold";
      case "Other":
        if (lang == 'ar') return "أخرى";
        if (lang == 'am') return "ሌላ";
        return "Other";
      case "Unknown":
        if (lang == 'ar') return "غير معروف";
        if (lang == 'am') return "የማይታወቅ";
        return "Unknown";
      default:
        return status;
    }
  }

  String _getTranslatedReason(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "السبب";
    if (lang == 'am') return "ምክንያት";
    return "Reason";
  }

  String _getTranslatedReasonHint(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختياري: تقديم سبب لتحديث الحالة...";
    if (lang == 'am') return "አማራጭ: ለሁኔታ ማዘመኛ ምክንያት ይስጡ...";
    return "Optional: provide a reason for the status update...";
  }

  String _getTranslatedAddUpdate(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إضافة تحديث";
    if (lang == 'am') return "አዘምን ጨምር";
    return "Add Update";
  }

  String _getTranslatedResults(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "النتائج";
    if (lang == 'am') return "ውጤቶች";
    return "Results";
  }

  String _getTranslatedDateRange(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "نطاق التاريخ";
    if (lang == 'am') return "የቀን ክልል";
    return "Date Range";
  }

  String _getTranslatedReset(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إعادة تعيين";
    if (lang == 'am') return "እንደገና አቀናብር";
    return "Reset";
  }

  String _getTranslatedFrom(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "من";
    if (lang == 'am') return "ከ";
    return "From";
  }

  String _getTranslatedTo(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إلى";
    if (lang == 'am') return "እስከ";
    return "To";
  }

  String _getTranslatedToday(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اليوم";
    if (lang == 'am') return "ዛሬ";
    return "Today";
  }

  String _getTranslatedThisWeek(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "هذا الأسبوع";
    if (lang == 'am') return "ይህ ሳምንት";
    return "This Week";
  }

  String _getTranslatedThisMonth(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "هذا الشهر";
    if (lang == 'am') return "ይህ ወር";
    return "This Month";
  }

  String _getTranslatedStatusLog(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "سجل الحالة";
    if (lang == 'am') return "የሁኔታ መዝገብ";
    return "Status Log";
  }

  String _getTranslatedNoStatusUpdates(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') {
      return "لم يتم العثور على تحديثات حالة لنطاق التاريخ المحدد.";
    }
    if (lang == 'am') return "ለተመረጠው የቀን ክልል ምንም የሁኔታ ማዘመኛዎች አልተገኙም።";
    return "No status updates found for the selected date range.";
  }

  String _getTranslatedTokenNotFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز غير موجود، يرجى تسجيل الدخول مرة أخرى";
    if (lang == 'am') return "ቶከን አልተገኘም፣ እባክዎ እንደገና ይግቡ";
    return "Token not found, please login again";
  }

  String _getTranslatedSelectStatusError(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اختر حالة";
    if (lang == 'am') return "ሁኔታ ይምረጡ";
    return "Select a status";
  }

  String _getTranslatedInvalidStatus(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "حالة غير صالحة";
    if (lang == 'am') return "ልክ ያልሆነ ሁኔታ";
    return "Invalid status";
  }

  String _getTranslatedPDFGenerated(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تم إنشاء ملف PDF!";
    if (lang == 'am') return "PDF ተፈጥሯል!";
    return "PDF generated!";
  }
}
