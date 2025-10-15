import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/services/Employer/employee_create.service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import your LanguageProvider

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final EmployeeService _employeeService = EmployeeService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> employees = [];
  List<dynamic> filteredEmployees = [];
  bool isLoading = true;
  String managerId = "";
  String? errorMessage;

  // Filter variables
  String ageFilter = "All Ages";
  String heightFilter = "All Heights";
  String weightFilter = "All Weights";

  // Filter options
  final List<String> ageOptions = [
    "All Ages",
    "18-25",
    "26-35",
    "36-45",
    "46+"
  ];

  final List<String> heightOptions = [
    "All Heights",
    "150-160 cm",
    "161-170 cm",
    "171-180 cm",
    "181-190 cm",
    "191+ cm"
  ];

  final List<String> weightOptions = [
    "All Weights",
    "50-60 kg",
    "61-70 kg",
    "71-80 kg",
    "81-90 kg",
    "91+ kg"
  ];

  @override
  void initState() {
    super.initState();
    _loadManagerIdAndFetchEmployees();
  }

  Future<void> _loadManagerIdAndFetchEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedManagerId = prefs.getString('manager_id');
      final String? storedUserId = prefs.getString('user_id');

      final String actualManagerId = storedManagerId ?? storedUserId ?? "";

      if (actualManagerId.isEmpty) {
        setState(() {
          errorMessage = 'Manager ID not found. Please login again.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        managerId = actualManagerId;
        errorMessage = null;
      });

      await fetchEmployees();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading manager ID: $e';
      });
    }
  }

  Future<void> fetchEmployees() async {
    if (managerId.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final employeeList = await _employeeService.getEmployees(managerId);

      setState(() {
        employees = employeeList;
        filteredEmployees = employeeList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching employees: $e';
        employees = [];
        filteredEmployees = [];
      });
    }
  }

  void filterEmployees() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty &&
          ageFilter == "All Ages" &&
          heightFilter == "All Heights" &&
          weightFilter == "All Weights") {
        filteredEmployees = employees;
      } else {
        filteredEmployees = employees.where((employee) {
          // Text search
          final name =
              '${_getEmployeeField(employee, 'first_name')} ${_getEmployeeField(employee, 'last_name')}'
                  .toLowerCase();
          final email = _getEmployeeField(employee, 'email').toLowerCase();
          final phone =
              _getEmployeeField(employee, 'phone_number').toLowerCase();
          final passport =
              _getEmployeeField(employee, 'passport_number').toLowerCase();

          bool matchesSearch = query.isEmpty ||
              name.contains(query) ||
              email.contains(query) ||
              phone.contains(query) ||
              passport.contains(query);

          // Age filter
          bool matchesAge = true;
          if (ageFilter != "All Ages") {
            final age = _getEmployeeField(employee, 'age');
            if (age != 'N/A') {
              final ageNum = int.tryParse(age);
              if (ageNum != null) {
                matchesAge = _matchesAgeRange(ageNum, ageFilter);
              }
            }
          }

          // Height filter
          bool matchesHeight = true;
          if (heightFilter != "All Heights") {
            final height = _getEmployeeField(employee, 'height');
            if (height != 'N/A') {
              final heightNum = double.tryParse(height);
              if (heightNum != null) {
                matchesHeight = _matchesHeightRange(heightNum, heightFilter);
              }
            }
          }

          // Weight filter
          bool matchesWeight = true;
          if (weightFilter != "All Weights") {
            final weight = _getEmployeeField(employee, 'weight');
            if (weight != 'N/A') {
              final weightNum = double.tryParse(weight);
              if (weightNum != null) {
                matchesWeight = _matchesWeightRange(weightNum, weightFilter);
              }
            }
          }

          return matchesSearch && matchesAge && matchesHeight && matchesWeight;
        }).toList();
      }
    });
  }

  bool _matchesAgeRange(int age, String range) {
    switch (range) {
      case "18-25":
        return age >= 18 && age <= 25;
      case "26-35":
        return age >= 26 && age <= 35;
      case "36-45":
        return age >= 36 && age <= 45;
      case "46+":
        return age >= 46;
      default:
        return true;
    }
  }

  bool _matchesHeightRange(double height, String range) {
    switch (range) {
      case "150-160 cm":
        return height >= 150 && height <= 160;
      case "161-170 cm":
        return height >= 161 && height <= 170;
      case "171-180 cm":
        return height >= 171 && height <= 180;
      case "181-190 cm":
        return height >= 181 && height <= 190;
      case "191+ cm":
        return height >= 191;
      default:
        return true;
    }
  }

  bool _matchesWeightRange(double weight, String range) {
    switch (range) {
      case "50-60 kg":
        return weight >= 50 && weight <= 60;
      case "61-70 kg":
        return weight >= 61 && weight <= 70;
      case "71-80 kg":
        return weight >= 71 && weight <= 80;
      case "81-90 kg":
        return weight >= 81 && weight <= 90;
      case "91+ kg":
        return weight >= 91;
      default:
        return true;
    }
  }

  Future<void> addEmployee(Map<String, dynamic> employeeData) async {
    try {
      setState(() => isLoading = true);

      await _employeeService.addEmployee(employeeData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee added successfully')),
      );

      await fetchEmployees(); // Refresh the list
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding employee: $e')),
      );
    }
  }

  void _showAddEmployeeDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final countryController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Employee'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration:
                        const InputDecoration(labelText: 'First Name *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      hintText: '+251XXXXXXXXX or 09XXXXXXXX',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (!RegExp(r'^(\+251|0)[1-9]\d{8}$').hasMatch(value)) {
                        return 'Please enter a valid Ethiopian phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: countryController,
                    decoration: const InputDecoration(labelText: 'Country *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter country';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password *'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final employeeData = {
                    "first_name": firstNameController.text,
                    "last_name": lastNameController.text,
                    "email": emailController.text,
                    "phone_number": phoneController.text,
                    "country": countryController.text,
                    "password": passwordController.text,
                  };

                  await addEmployee(employeeData);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Employee'),
            ),
          ],
        );
      },
    );
  }

  String _getEmployeeField(dynamic employee, String fieldName) {
    try {
      final value = employee[fieldName];
      return value?.toString() ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(dynamic employee) {
    final status = _getEmployeeField(employee, 'status');

    if (status == 'N/A' || status.isEmpty) {
      return 'Active';
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Employee Summary Card =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.t('employee'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Chip(
                    label: Text(
                      lang.t('this_month'),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 17),

              // ===== Summary Bar =====
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
                      Text(
                        lang.t("total_employees"),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        employees.length.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "+0%",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ===== Employees Section =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.t("employees"),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _showAddEmployeeDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65B2C9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(lang.t("add_employee_button")),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== Search Bar =====
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: lang.t("search_employees"),
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
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
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            filterEmployees();
                          },
                        ),
                      ),
                      onChanged: (value) => filterEmployees(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.filter_list),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Filters =====
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildDropdown(ageFilter, ageOptions, (value) {
                    setState(() => ageFilter = value!);
                    filterEmployees();
                  }),
                  const SizedBox(width: 8),
                  _buildDropdown(heightFilter, heightOptions, (value) {
                    setState(() => heightFilter = value!);
                    filterEmployees();
                  }),
                  const SizedBox(width: 8),
                  _buildDropdown(weightFilter, weightOptions, (value) {
                    setState(() => weightFilter = value!);
                    filterEmployees();
                  }),
                  const SizedBox(width: 8),
                  if (ageFilter != "All Ages" ||
                      heightFilter != "All Heights" ||
                      weightFilter != "All Weights")
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          ageFilter = "All Ages";
                          heightFilter = "All Heights";
                          weightFilter = "All Weights";
                        });
                        filterEmployees();
                      },
                      tooltip: 'Clear all filters',
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // ===== Loading/Error States =====
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (errorMessage != null)
                Expanded(
                  child: Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (filteredEmployees.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No employees found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (ageFilter != "All Ages" ||
                            heightFilter != "All Heights" ||
                            weightFilter != "All Weights" ||
                            _searchController.text.isNotEmpty)
                          Text(
                            "Try adjusting your search or filters",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchEmployees,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      // ===== Employee Table Header =====
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF65B2C9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Name",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Phone Number",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Email",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ===== Employee Table Rows =====
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredEmployees.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.grey,
                            height: 0.7,
                            thickness: 0.2,
                          ),
                          itemBuilder: (context, index) {
                            final employee = filteredEmployees[index];
                            final status = _getStatusText(employee);
                            final statusColor = _getStatusColor(status);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${_getEmployeeField(employee, 'first_name')} ${_getEmployeeField(employee, 'last_name')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _getEmployeeField(
                                          employee, 'phone_number'),
                                      style: const TextStyle(
                                        fontFamily: 'Monospace',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _getEmployeeField(employee, 'email'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: statusColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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

  Widget _buildDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 207, 207, 207),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
