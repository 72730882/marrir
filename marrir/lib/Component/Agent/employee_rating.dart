import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class EmployeeRatingPage extends StatefulWidget {
  const EmployeeRatingPage({super.key});

  @override
  State<EmployeeRatingPage> createState() => _EmployeeRatingPageState();
}

class _EmployeeRatingPageState extends State<EmployeeRatingPage> {
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  String? token;
  String? userId;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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
        employees = data
            .map((e) => {
                  "id": e['id'],
                  "name": "${e['first_name']} ${e['last_name']}",
                  "rating": (e['rating'] ?? 0).toDouble(), // 👈 assume backend sends rating
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching employees for rating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Page Title =====
              const Center(
                child: Text(
                  "Employee Ratings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // ===== Card Container =====
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ===== Table Header =====
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF65B2C9),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Reserve Name",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "CV Rating",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== Table Rows =====
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (employees.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text("No employees found")),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: employees.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 0.5,
                          thickness: 0.7,
                          color: Colors.grey,
                        ),
                        itemBuilder: (context, index) {
                          final emp = employees[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 28, horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    emp['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        emp['rating'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
