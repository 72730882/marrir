import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class ReservePage extends StatefulWidget {
  const ReservePage({super.key});

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  List<Map<String, dynamic>> employees = [];
  
  bool isLoading = true;
  String? token;
  String? userId;
 bool isReserving = false;
 final Set<int> selectedIds = {}; // ✅ must be integers


  @override
  void initState() {
    super.initState();
    _initAndFetchEmployees();
  }

  Future<void> _initAndFetchEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("access_token") ?? "";
    userId = prefs.getString("user_id") ?? "";

    if (token!.isEmpty || userId!.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    await fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getEmployees(
        token: token!,
        managerId: userId!,
      );
      setState(() {
        employees = data.map((e) => {
 "id": e['id'],  // convert String -> int
  "name": "${e['first_name']} ${e['last_name']}",
  "role": e['occupation'] ?? "Unknown Role",
  "experience": e['experience'] ?? "N/A",
  "status": e['disabled'] == true ? "Reserved" : "Available",
}).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching employees: $e");
    }
  }
void toggleSelection(int id) {
  setState(() {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  });
}

  void clearSelection() {
    setState(() => selectedIds.clear());
  }

  Future<void> reserveEmployees() async {
  if (selectedIds.isEmpty || token == null || userId == null) return;

  setState(() => isReserving = true);
  try {
  await ApiService.reserveCv(
  token: token!,
  reserverId: userId!,      // string UUID ✅
  cvIds: selectedIds.toList(), // List<int> ✅
  reason: "Reserved by agent",
  
);



    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reserved successfully ✅")),
      );
      setState(() {
        selectedIds.clear();
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  } finally {
    if (mounted) setState(() => isReserving = false);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE =====
            const Text(
              "Reserve",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: const Text("Search Employees",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(height: 1, color: Colors.grey.shade300),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search transfers...",
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey.withOpacity(0.6)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                      ElevatedButton(
  onPressed: selectedIds.isEmpty ? null : reserveEmployees,
  style: ElevatedButton.styleFrom(
    backgroundColor: selectedIds.isNotEmpty ? Colors.blue : Colors.grey,
  ),
  child: isReserving
      ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
      : const Text("Reserve"),
),


                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(() => selectedIds.clear());
                          },
                          child: const Text("Reverse"),
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
                      const Text("Results",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () {
                                    debugPrint(
                                        "Selected: $selectedIds"); // you can show dialog here
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              "Show Selected (${selectedIds.length})",
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed:
                                selectedIds.isEmpty ? null : clearSelection,
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
                  Container(height: 1, color: const Color.fromRGBO(224, 224, 224, 1)),
                  const SizedBox(height: 12),

                  // Employee list
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : employees.isEmpty
                          ? const Text("No employees found")
                          : Column(
                              children: employees.map((emp) {
                               final empIdStr = emp['id'].toString();
final bool isSelected = selectedIds.contains(int.tryParse(empIdStr) ?? -1);
                                return Container(
                                  key: ValueKey(empIdStr),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Left side info
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(emp['name'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(emp['role']),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${emp['experience']} experience",
                                            style: const TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                      // Right side
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: emp['status'] ==
                                                      "Available"
                                                  ? Colors.green.shade100
                                                  : Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              emp['status'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: emp['status'] ==
                                                        "Available"
                                                    ? Colors.green
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (_) =>
                                                toggleSelection(emp['id']),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Extracted search card for clarity
  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: const Text("Search Employees",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Container(height: 1, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search transfers...",
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.withOpacity(0.6)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 228, 227, 227),
                            width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.filter_list)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        borderRadius: BorderRadius.circular(6)),
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
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text("Reverse",
                      style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
