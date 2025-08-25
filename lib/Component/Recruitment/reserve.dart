import 'package:flutter/material.dart';

class ReservePage extends StatelessWidget {
  const ReservePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // so page scrolls if needed
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE =====
            const Text(
              "Reserve",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You can search for an employee that you want to reserve",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 20),

            // ===== SEARCH BOX CARD =====
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      "Search Employees",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Divider line
                  Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),

                  // Search bar + filter icon
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search transfers...",
                              hintStyle: TextStyle(
                                color:
                                    Colors.grey.withOpacity(0.6), // faded hint
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color:
                                    Colors.grey.withOpacity(0.6), // faded icon
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 228, 227, 227),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.filter_list),
                        ),
                      ],
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF65b2c9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text("Search"),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "Reverse",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== RESULTS CARD =====
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Results",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              "Show Selected (0)",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              "Remove All",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                 // Divider line
                  Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),

                  // Employee Cards (3 samples)
                  Column(
                    children: [
                      // === Card 1 ===
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Hanna",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text("Software Engineer"),
                                SizedBox(height: 4),
                                Text(
                                  "5 years experience",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            // Right side status
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Available",
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Checkbox(value: false, onChanged: (val) {}),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // === Card 2 ===
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Hanan",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text("Driver"),
                                SizedBox(height: 4),
                                Text(
                                  "7 years experience",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            // Right side status
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Available",
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Checkbox(value: false, onChanged: (val) {}),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // === Card 3 ===
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "John Doe",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text("Designer"),
                                SizedBox(height: 4),
                                Text(
                                  "3 years experience",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            // Right side status
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Reserved",
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Checkbox(value: false, onChanged: (val) {}),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
