import 'package:flutter/material.dart';

class TransferProfilePage extends StatelessWidget {
  const TransferProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Page Title =====
              const Text(
                "Transfer",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "You can search for an employee that you want to transfer",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 20),

              // ===== Approved Agreement User =====
              _buildTransferCard(
                title: "Transfer to Approved Agreement User",
                subtitle:
                    "These users have a pre-approved agreement with you. Transfers are free",
              ),

              const SizedBox(height: 20),

              // ===== Non-Agreement User =====
              _buildTransferCard(
                title: "Transfer to Non-Agreement User",
                subtitle:
                    "These users do not have a pre-approved agreement with you. Transfers fee is required",
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
                      width: double.infinity,
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
                                    "John Smith",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Software Engineer"),
                                  SizedBox(height: 4),
                                  Text(
                                    "Agreement: Approved",
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
                                      color: Colors.greenAccent.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "Available",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 40, 118, 42),
                                          fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                    "Sarah Johnson",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Project Manager"),
                                  SizedBox(height: 4),
                                  Text(
                                    "Agreement: Non-Agreement",
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
                                      color: Colors.greenAccent.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "Available",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 40, 118, 42),
                                          fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                    "Mike Davis",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Designer"),
                                  SizedBox(height: 4),
                                  Text(
                                    "Agreement: Aproved",
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
                                      "Tranferred",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
      ),
    );
  }

  // ===== Transfer Card (Search + Filter + Buttons) =====
  static Widget _buildTransferCard(
      {required String title, required String subtitle}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0))),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 7),

          // Divider line
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),

          // Search fields row with labels
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Search Employee",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search employee",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12), // Grey hint and smaller
                        prefixIcon:
                            const Icon(Icons.search, size: 18), // smaller icon
                        // reduce gap
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12), // smaller text
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Transfer To",
                        style: TextStyle(fontSize: 15, color: Colors.black)),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter transfer destination",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14), // Grey hint and smaller
                        
                        
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12), // smaller text
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

     // Search + Filter Row
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 0),
  child: Row(
    children: [
      Expanded(
        child: Container(
          height: 40, // minimized height
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 239, 239), // gray background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Filter by",
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    border: InputBorder.none, // remove inner borders
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: const Icon(Icons.filter_list, size: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

          const SizedBox(height: 8),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    "Transfer",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
