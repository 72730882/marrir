import 'package:flutter/material.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // make page scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Employee Summary Card =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Transfers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Chip(
                    label: Text("This Month"),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Two Cards Side by Side =====
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: "Transfer Requested",
                      value: "0",
                      count: "N/A",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: "Transfers Requests",
                      value: "0",
                      count: "N/A",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ===== Incoming Reserve Requests Section =====
              const Text(
                "Incoming Transfer Requests",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 117, 97, 229),
                ),
              ),
              const SizedBox(height: 30),

              _buildShowRowsDropdown(),

              const SizedBox(height: 20),

              // ===== First Table =====
              Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "From",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Created At",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    _buildTableRow("Hanan N", "2024-03-15"),
                    _buildTableRow("Hanan N", "2024-03-15"),
                    _buildTableRow("Hanan N", "2024-03-15"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ===== Process Reserve Request Section =====
              const Text(
                "Process Transfer Request",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 117, 97, 229),
                ),
              ),
              const SizedBox(height: 30),

              _buildShowRowsDropdown(),

              const SizedBox(height: 20),

              // ===== Second Table =====
              Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(
                            child: Text(
                              "Batch No.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Transfer To",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Created At",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTableRow3("001", "Hanan", "2024-03-15"),
                    _buildTableRow3("002", "Hanan", "2024-03-15"),
                    _buildTableRow3("003", "Hanan", "2024-03-15"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helper for Summary Card =====
  static Widget _buildSummaryCard({
    required String title,
    required String value,
    required String count,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Count - ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: count,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helper for "Show Rows" Dropdown =====
  static Widget _buildShowRowsDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Show rows:",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            children: const [
              Text("5"),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  // ===== Helper for Table Row (2 Columns) =====
  static Widget _buildTableRow(String from, String date) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                from,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.6,
        ),
      ],
    );
  }

  // ===== Helper for Table Row (3 Columns) =====
  static Widget _buildTableRow3(String batch, String to, String date) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  batch,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  to,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.6,
        ),
      ],
    );
  }
}
