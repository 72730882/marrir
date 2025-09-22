import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import './EditCv.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
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
        employees = data.map((e) => {
          "id": e['id'],
          "name": "${e['first_name']} ${e['last_name']}",
          "passport": e['passport_number'] ?? "",
          "email": e['email'] ?? "",
          "phone": e['phone_number'] ?? "",
          "country": e['country'] ?? "",
          "status": e['disabled'] == true ? "Inactive" : "Active",
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching employees: $e");
    }
  }

  Future<void> showAddEmployeeDialog() async {
    final success = await showDialog(
      context: context,
      builder: (_) => AddEmployeeDialog(token: token!, userId: userId!),
    );
    if (success == true) fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Employee Summary Header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Employee",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  Chip(label: Text("This Month"), backgroundColor: Colors.white),
                ],
              ),
              const SizedBox(height: 17),

              // ===== Total Employees Card =====
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
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Employees",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      const SizedBox(height: 8),
                      Text("${employees.length}",
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ===== Employees Section Header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Employees",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: showAddEmployeeDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65B2C9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("+ Add Employee"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== Search Bar =====
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search employees...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search),
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
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.filter_list),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Employee Table =====
                     Flexible(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : employees.isEmpty
                        ? const Center(child: Text("No employees found"))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 900, // Adjust width for all columns
                              child: SizedBox(
                                height:
                                    400, // Fix height to prevent vertical overflow
                                child: ListView.builder(
                                  itemCount:
                                      employees.length + 1, // +1 for header
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      // Header
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF65B2C9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: const [
                                            SizedBox(
                                                width: 150,
                                                child: Text("Name",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            SizedBox(
                                                width: 150,
                                                child: Text("Email",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            SizedBox(
                                                width: 120,
                                                child: Text("Phone",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            SizedBox(
                                                width: 120,
                                                child: Text("Country",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            SizedBox(
                                                width: 120,
                                                child: Text("Status",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            SizedBox(
                                                width: 150,
                                                child: Text("Actions",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                          ],
                                        ),
                                      );
                                    } else {
                                      final emp = employees[index - 1];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 8),
                                        color: Colors.white,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                                width: 150,
                                                child: Text(emp['name'])),
                                            SizedBox(
                                                width: 150,
                                                child: Text(emp['email'])),
                                            SizedBox(
                                                width: 120,
                                                child: Text(emp['phone'])),
                                            SizedBox(
                                                width: 120,
                                                child: Text(emp['country'])),
                                            SizedBox(
                                                width: 120,
                                                child: Text(emp['status'])),
                                            SizedBox(
                                              width: 150,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditCvPage(
                                                                  employee:
                                                                      emp),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text("Edit CV",
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  PopupMenuButton<String>(
                                                    onSelected: (value) {},
                                                    itemBuilder: (context) =>
                                                        const [
                                                      PopupMenuItem(
                                                          value: 'view',
                                                          child: Text(
                                                              'View Details')),
                                                      PopupMenuItem(
                                                          value: 'update',
                                                          child: Text(
                                                              'Update Status')),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Add Employee Dialog =====
class AddEmployeeDialog extends StatefulWidget {
  final String token;
  final String userId;

  const AddEmployeeDialog({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();

  bool isSubmitting = false;

  Future<void> submitEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final data = {
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "email": _emailController.text,
        "phone_number": _phoneController.text,
        "country": "Ethiopia",
        "role": "employee",
        "password": "Default123!"
      };

      await ApiService.createEmployee(
        token: widget.token,
        data: data,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error adding employee: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Employee"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: "Date of Birth"),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dobController.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  }
                },
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: "Gender"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : submitEmployee,
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}
