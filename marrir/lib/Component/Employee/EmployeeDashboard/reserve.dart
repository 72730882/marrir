import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/reserves_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class ReservesScreen extends StatefulWidget {
  const ReservesScreen({super.key});

  @override
  State<ReservesScreen> createState() => _ReservesScreenState();
}

class _ReservesScreenState extends State<ReservesScreen> {
  final _service = ReserveService();
  bool _loading = true;
  String? _error;
  List<ReserveBatchItem> _items = [];
  final int _skip = 0;
  int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _ensureTokenInHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token not found, please login again.');
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _ensureTokenInHeaders();
      final data =
          await _service.getMyIncomingReserves(skip: _skip, limit: _limit);
      setState(() {
        _items = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        final languageProvider =
            Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(_error ?? _getTranslatedFailedToLoad(languageProvider))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso;
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final totalEmployees = _items.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        title: Text(
          _getTranslatedTitle(languageProvider),
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        _getTranslatedReserves(languageProvider),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Card for total employees
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                  _getTranslatedTotalEmployees(
                                      languageProvider),
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 5),
                              Text(
                                "$totalEmployees",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "+0%",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Filter row (only visual; wire up as needed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: _getTranslatedThisMonth(languageProvider),
                          items: [
                            DropdownMenuItem(
                              value: _getTranslatedThisMonth(languageProvider),
                              child: Text(
                                  _getTranslatedThisMonth(languageProvider)),
                            ),
                            DropdownMenuItem(
                              value: _getTranslatedLastMonth(languageProvider),
                              child: Text(
                                  _getTranslatedLastMonth(languageProvider)),
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                        DropdownButton<int>(
                          value: _limit,
                          items: const [
                            DropdownMenuItem(value: 5, child: Text("5")),
                            DropdownMenuItem(value: 10, child: Text("10")),
                            DropdownMenuItem(value: 20, child: Text("20")),
                          ],
                          onChanged: (value) async {
                            if (value == null) return;
                            setState(() => _limit = value);
                            await _fetchData();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Text(
                      _getTranslatedIncomingRequests(languageProvider),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getTranslatedShowRows(languageProvider),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),

                    // Header
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromRGBO(142, 198, 214, 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getTranslatedReserveName(languageProvider),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getTranslatedCreatedAt(languageProvider),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Data rows
                    Expanded(
                      child: _items.isEmpty
                          ? Center(
                              child: Text(_getTranslatedNoReservesFound(
                                  languageProvider)))
                          : ListView.separated(
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return InkWell(
                                  onTap: () async {
                                    // Optional: Load batch details when tapped
                                    // final details = await _service.getMyIncomingReservesDetail(
                                    //   batchReserveId: item.id,
                                    // );
                                    // Show modal, navigate, etc.
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.reserverFullName,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                        Text(
                                          _formatDate(item.createdAt),
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Translation helper methods
  String _getTranslatedTitle(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الحجوزات";
    if (lang == 'am') return "ቦታ ያለው";
    return "Reserves";
  }

  String _getTranslatedReserves(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الحجوزات";
    if (lang == 'am') return "ቦታ ያለው";
    return "Reserves";
  }

  String _getTranslatedTotalEmployees(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "إجمالي الموظفين";
    if (lang == 'am') return "ጠቅላላ ሰራተኞች";
    return "Total Employees";
  }

  String _getTranslatedThisMonth(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "هذا الشهر";
    if (lang == 'am') return "ይህ ወር";
    return "This Month";
  }

  String _getTranslatedLastMonth(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الشهر الماضي";
    if (lang == 'am') return "ያለፈው ወር";
    return "Last Month";
  }

  String _getTranslatedIncomingRequests(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "طلبات الحجز الواردة";
    if (lang == 'am') return "የሚመጡ የቦታ ማስያዣ ጥያቄዎች";
    return "Incoming Reserve Requests";
  }

  String _getTranslatedShowRows(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "عرض الصفوف:";
    if (lang == 'am') return "ረድፎችን አሳይ:";
    return "Show rows:";
  }

  String _getTranslatedReserveName(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "اسم الحجز";
    if (lang == 'am') return "የቦታ ማስያዣ ስም";
    return "Reserve Name";
  }

  String _getTranslatedCreatedAt(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "تاريخ الإنشاء";
    if (lang == 'am') return "የተፈጠረበት ቀን";
    return "Created At";
  }

  String _getTranslatedNoReservesFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "لم يتم العثور على طلبات حجز";
    if (lang == 'am') return "ምንም የቦታ ማስያዣ ጥያቄዎች አልተገኙም";
    return "No reserve requests found";
  }

  String _getTranslatedFailedToLoad(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "فشل تحميل الحجوزات";
    if (lang == 'am') return "ቦታ ያለው መጫን አልተሳካም";
    return "Failed to load reserves";
  }

  String _getTranslatedTokenNotFound(LanguageProvider languageProvider) {
    final lang = languageProvider.currentLang;
    if (lang == 'ar') return "الرمز غير موجود، يرجى تسجيل الدخول مرة أخرى";
    if (lang == 'am') return "ቶከን አልተገኘም፣ እባክዎ እንደገና ይግቡ";
    return "Token not found, please login again";
  }
}
