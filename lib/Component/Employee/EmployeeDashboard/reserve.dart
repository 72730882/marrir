import 'package:flutter/material.dart';
import 'package:marrir/Page/Employee/employee_page.dart';

class ReservesScreen extends StatelessWidget {
  const ReservesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EmployeePage()),
            );
          },
        ),
        title: const Text(
          "Reserves",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card for total employees
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reserves",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Total Employees", style: TextStyle(fontSize: 14)),
                    SizedBox(height: 5),
                    Text(
                      "0",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
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

            const SizedBox(height: 20),

            // Filter row
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
                  onChanged: (value) {},
                ),
                DropdownButton<int>(
                  value: 5,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text("5")),
                    DropdownMenuItem(value: 10, child: Text("10")),
                    DropdownMenuItem(value: 20, child: Text("20")),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Text(
              "Incoming Reserve Requests",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              "Show rows:",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),

            // Table
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromRGBO(142, 198, 214, 1), // Header color
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
              child: ListView(
                children: [
                  buildTableRow("Hanan N", "2024-03-15"),
                  buildTableRow("Hanan N", "2024-03-12"),
                  buildTableRow("Hanan N", "2024-03-10"),
                  buildTableRow("Hanan N", "2024-03-08"),
                  buildTableRow("Hanan N", "2024-03-05"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTableRow(String name, String date) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 14)),
          Text(date, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
