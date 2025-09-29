import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/payment_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentPaymentPage extends StatefulWidget {
  const AgentPaymentPage({super.key});

  @override
  State<AgentPaymentPage> createState() => _AgentPaymentPageState();
}

class _AgentPaymentPageState extends State<AgentPaymentPage> {
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
        return status ?? 'Unknown';
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
                // ===== Payments List Section =====
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
                              _TableHeaderCell("Payment Method", 120),
                              _TableHeaderCell("Transaction ID", 150),
                              _TableHeaderCell("Amount", 100),
                              _TableHeaderCell("Date", 120),
                              _TableHeaderCell("Type", 100),
                              _TableHeaderCell("Status", 100),
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
                            // Use the invoice data structure
                            final paymentMethod =
                                payment['card']?.toString() ?? 'Telr';
                            final transactionId =
                                payment['ref']?.toString() ?? 'N/A';
                            final amount = _formatAmount(payment['amount']);
                            final date = _formatDate(
                                payment['created_at']?.toString() ?? '');
                            final type =
                                payment['type']?.toString() ?? 'Promotion';
                            final status =
                                payment['status']?.toString() ?? 'pending';

                            return _buildTableRow(paymentMethod, transactionId,
                                amount, date, type, status);
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
  Widget _buildTableRow(String paymentMethod, String transactionId,
      String amount, String date, String type, String status) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              _TableCell(paymentMethod, 120),
              _TableCell(transactionId, 150),
              _TableCell(amount, 100),
              _TableCell(date, 120),
              _TableCell(type, 100),
              SizedBox(
                width: 100,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatStatus(status).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 690, // sum of all cell widths
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
