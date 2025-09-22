import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/services/Employee/status_sevice.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _goBack,
        ),
        centerTitle: true,
        title: const Text(
          "Status Update",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Provide an overview of your current employee status.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Generate PDF Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Generate Status PDF"),
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
                    const Text("Status *",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      hint: const Text("Select Status"),
                      items: statusMap.keys
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
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
                    const Text("Reason",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            "Optional: provide a reason for the status update...",
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
                            child: const Text("Add Update"),
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
                            child: const Text("Results"),
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
                const Text("Date Range",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _fromDate = null;
                      _toDate = null;
                    });
                  },
                  child: const Text("Reset",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField("From", _fromDate, () async {
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
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField("To", _toDate, () async {
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
                  }),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickButton("Today", _setTodayRange),
                _quickButton("This Week", _setWeekRange),
                _quickButton("This Month", _setMonthRange),
              ],
            ),

            const SizedBox(height: 16),

            // Status Results Section
            if (_statusResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status Log",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                                statusLabel,
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
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  "No status updates found for the selected date range.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _goBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    if (token != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => EmployeePage(token: token)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Token not found, please login again.")));
    }
  }

  Future<void> _addStatus() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a status")));
      return;
    }

    final apiStatus = statusMap[_selectedStatus!];
    if (apiStatus == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid status")));
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    if (userId == null) return;

    await EmployeeStatusService.generatePdf(userId: userId);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("PDF generated!")));
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
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

  Widget _quickButton(String text, VoidCallback onTap) {
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
}
