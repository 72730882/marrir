import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/payment_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentService _paymentService = PaymentService();
  List<dynamic> _payments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _totalPayments = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please login to access payments';
        });
        return;
      }

      await _loadPayments();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading payments: $e';
      });
    }
  }

  Future<void> _loadPayments() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final payments = await _paymentService.getUserPayments();

      setState(() {
        _payments = payments;
        _totalPayments = payments.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load payments: $e';
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00 AED';
    if (amount is num) return '${amount.toStringAsFixed(2)} AED';
    if (amount is String) {
      return '${double.tryParse(amount)?.toStringAsFixed(2) ?? '0.00'} AED';
    }
    return '0.00 AED';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'accepted':
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ==== Total Payments Card === ///
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Payments",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _totalPayments.toString(),
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "+$_totalPayments%",
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _checkAuthAndLoadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else ...[
                const Text(
                  "The list of payments",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),

                // ===== Scrollable Horizontal Table =====
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF65b2c9),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 16),
                          child: const Row(
                            children: [
                              _TableHeaderCell("Bank", 100),
                              _TableHeaderCell("Transaction ID", 120),
                              _TableHeaderCell("Amount", 80),
                              _TableHeaderCell("Date", 100),
                              _TableHeaderCell("Screenshot", 100),
                              _TableHeaderCell("Status", 80),
                            ],
                          ),
                        ),

                        // Table Rows
                        if (_payments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No payments found"),
                          )
                        else
                          ..._payments.map((payment) {
                            final bank = payment['bank']?.toString() ?? 'N/A';
                            final txnId = payment['ref']?.toString() ?? 'N/A';
                            final amount = _formatAmount(payment['amount']);
                            final date = _formatDate(
                                payment['created_at']?.toString() ?? '');
                            final screenshot =
                                payment['screenshot']?.toString() ?? '';
                            final status =
                                payment['status']?.toString() ?? 'pending';

                            return _buildTableRow(
                                bank, txnId, amount, date, screenshot, status);
                          }),
                      ],
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

  // ===== Table Row =====
  Widget _buildTableRow(String bank, String txnId, String amount, String date,
      String screenshotUrl, String status) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              _TableCell(bank, 100),
              _TableCell(txnId, 120),
              _TableCell(amount, 80),
              _TableCell(date, 100),

              // Screenshot Column
              SizedBox(
                width: 100,
                child: screenshotUrl.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: Image.network(screenshotUrl),
                            ),
                          );
                        },
                        child: const Icon(Icons.image,
                            size: 20, color: Colors.grey),
                      )
                    : const Icon(Icons.image_not_supported,
                        size: 20, color: Colors.red),
              ),

              // Status Column
              SizedBox(
                width: 80,
                child: Text(
                  _formatStatus(status),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 600,
          child: Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.3,
          ),
        ),
      ],
    );
  }
}

// ===== Table Header Cell =====
class _TableHeaderCell extends StatelessWidget {
  final String title;
  final double width;
  const _TableHeaderCell(this.title, this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ===== Table Cell =====
class _TableCell extends StatelessWidget {
  final String text;
  final double width;
  const _TableCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
