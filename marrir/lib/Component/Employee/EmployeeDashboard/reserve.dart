import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employee/reserves_service.dart';

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
    // If your DioService already injects token via interceptor, you can skip this.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Token not found, please login again.');
    }
    // If needed, set header manually:
    // DioService.instance.options.headers['Authorization'] = 'Bearer $token';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error ?? 'Failed to load reserves')),
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
                const SnackBar(
                    content: Text("Token not found, please login again.")),
              );
            }
          },
        ),
        title: const Text(
          "Reserves",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Reserves",
                        style: TextStyle(
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
                              const Text("Total Employees",
                                  style: TextStyle(fontSize: 14)),
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
                          value: "This Month",
                          items: const [
                            DropdownMenuItem(
                              value: "This Month",
                              child: Text("This Month"),
                            ),
                            DropdownMenuItem(
                              value: "Last Month",
                              child: Text("Last Month"),
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
                    const Text(
                      "Incoming Reserve Requests",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Show rows:",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 10),

                    // Header
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromRGBO(142, 198, 214, 1),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Reserve Name",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Created At",
                              style: TextStyle(
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
                          ? const Center(
                              child: Text('No reserve requests found'))
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
}
