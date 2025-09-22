import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';
import 'package:marrir/services/Employee/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
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
          "Payments",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPayments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "The list of payments",
                        style: TextStyle(
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
                            columns: const [
                              DataColumn(label: Text("Bank")),
                              DataColumn(label: Text("Transaction ID")),
                              DataColumn(label: Text("Amount")),
                              DataColumn(label: Text("Date")),
                              DataColumn(label: Text("Type")),
                              DataColumn(label: Text("Status")),
                            ],
                            rows: _payments.isEmpty
                                ? [
                                    const DataRow(cells: [
                                      DataCell(Text("No payments found")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                    ])
                                  ]
                                : _payments.map((payment) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(
                                            payment['card']?.toString() ??
                                                'Telr')),
                                        DataCell(Text(
                                            payment['ref']?.toString() ??
                                                'N/A')),
                                        DataCell(Text(
                                            "${payment['amount']?.toStringAsFixed(2) ?? '0.00'} AED")),
                                        DataCell(Text(_formatDate(
                                            payment['created_at']?.toString() ??
                                                ''))),
                                        DataCell(Text(
                                            payment['type']?.toString() ??
                                                'N/A')),
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
                                              _formatStatus(payment['status']
                                                      ?.toString() ??
                                                  ''),
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
}
