import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

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
              /// ==== bar === ///
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
                    children: const [
                      Text(
                        "Total Employees",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "0",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "+0%",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ===== Process Transfer Request Section =====
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
                        decoration: BoxDecoration(
                          color: const Color(0xFF65b2c9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 16),
                        child: Row(
                          children: const [
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
                      _buildTableRow("CBE", "Type", "10000", "2024-1-15",
                          Icons.image, "Active"),
                      _buildTableRow("CBE", "Type", "10000", "2024-1-15",
                          Icons.image, "Active"),
                      _buildTableRow("CBE", "Type", "10000", "2024-1-15",
                          Icons.image, "Active"),
                      _buildTableRow("CBE", "Type", "10000", "2024-1-15",
                          Icons.image, "Active"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Table Row =====
  static Widget _buildTableRow(String bank, String txnId, String amount,
      String date, IconData screenshot, String status) {
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
              _TableCellIcon(screenshot, 100),
              Container(
                width: 80,
                child: Text(
                  status,
                  style: TextStyle(
                    color: status.trim().toLowerCase() == "active"
                        ? Colors.green[400]
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // smaller font
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 600, // sum of all cell widths
          child: const Divider(
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
    return Container(
      width: width,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12, // smaller font
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
    return Container(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12, // smaller font
        ),
      ),
    );
  }
}

// ===== Table Cell Icon =====
class _TableCellIcon extends StatelessWidget {
  final IconData icon;
  final double width;
  const _TableCellIcon(this.icon, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: Colors.grey), // smaller icon
    );
  }
}
