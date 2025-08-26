import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EmployeePage()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          "Payments",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "The list of payments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),

            // Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal, // allow horizontal scroll for many columns
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
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
                    DataColumn(label: Text("Screenshot")),
                    DataColumn(label: Text("Status")),
                  ],
                  rows: List.generate(
                    4,
                    (index) => DataRow(
                      cells: [
                        const DataCell(Text("CBE")),
                        const DataCell(Text("Type")),
                        const DataCell(Text("10000")),
                        const DataCell(Text("26-08-2025")), // example date
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.image, color: Colors.blue),
                            onPressed: () {
                              // TODO: open screenshot image
                            },
                          ),
                        ),
                        const DataCell(Text("Pending")),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
