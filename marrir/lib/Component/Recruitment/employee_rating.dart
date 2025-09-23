import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/employee_rating.dart';

class REmployeeRatingPage extends StatefulWidget {
  const REmployeeRatingPage({super.key});

  @override
  State<REmployeeRatingPage> createState() => _EmployeeRatingPageState();
}

class _EmployeeRatingPageState extends State<REmployeeRatingPage> {
  final RatingService _ratingService = RatingService();
  List<dynamic> _employees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEmployeeRatings();
  }

  Future<void> _loadEmployeeRatings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final employees = await _ratingService.getEmployeeRatings();

      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load employee ratings';
      });
      print('❌ Error loading employee ratings: $e');
    }
  }

  // Helper method to calculate overall rating
  double _calculateOverallRating(Map<String, dynamic> employee) {
    final ratings = employee['ratings'] ?? {};
    final adminRating = ratings['admin_rating'] ?? 0.0;
    final selfRating = ratings['self_rating'] ?? 0.0;
    final sponsorRating = ratings['sponsor_rating'] ?? 0.0;

    // Calculate average or use a weighted formula based on your requirements
    return (adminRating + selfRating + sponsorRating) / 3;
  }

  // Helper method to get employee name
  String _getEmployeeName(Map<String, dynamic> employee) {
    final user = employee['user'] ?? {};
    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }

    return 'Unknown Employee';
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
              const SizedBox(height: 30),

              // ===== Loading Indicator =====
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // ===== Error Message =====
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),

              // ===== Refresh Button =====
              if (_errorMessage.isNotEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: _loadEmployeeRatings,
                    child: const Text('Try Again'),
                  ),
                ),

              // ===== No Employees Message =====
              if (!_isLoading && _employees.isEmpty && _errorMessage.isEmpty)
                const Center(
                  child: Text(
                    'No employees found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),

              // ===== Employee Ratings Table =====
              if (!_isLoading && _employees.isNotEmpty) ...[
                const SizedBox(height: 20),

                // ===== Card Container =====
                Expanded(
                  child: Container(
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
                                flex: 2,
                                child: Text(
                                  "Employee Name",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Rating",
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
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _employees.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 0.5,
                              thickness: 0.7,
                              color: Colors.grey,
                            ),
                            itemBuilder: (context, index) {
                              final employee = _employees[index];
                              final overallRating =
                                  _calculateOverallRating(employee);
                              final employeeName = _getEmployeeName(employee);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        employeeName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            overallRating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // ===== Refresh Button in App Bar =====
      floatingActionButton: FloatingActionButton(
        onPressed: _loadEmployeeRatings,
        backgroundColor: const Color(0xFF65B2C9),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
