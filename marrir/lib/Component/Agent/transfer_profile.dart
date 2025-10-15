import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/transfer_service.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import your LanguageProvider

class TransferProfilePage extends StatefulWidget {
  const TransferProfilePage({super.key});

  @override
  State<TransferProfilePage> createState() => _TransferProfilePageState();
}

class _TransferProfilePageState extends State<TransferProfilePage> {
  final TransferService _transferService = TransferService();

  List<dynamic> _relatedUsers = [];
  List<dynamic> _unrelatedUsers = [];
  List<dynamic> _allEmployees = [];
  List<dynamic> _filteredEmployees = [];
  final List<dynamic> _selectedEmployees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _employeeSearchController =
      TextEditingController();
  final TextEditingController _approvedSearchController =
      TextEditingController();
  final TextEditingController _nonApprovedSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _employeeSearchController.addListener(_onEmployeeSearchChanged);
  }

  @override
  void dispose() {
    _employeeSearchController.dispose();
    _approvedSearchController.dispose();
    _nonApprovedSearchController.dispose();
    super.dispose();
  }

  void _onEmployeeSearchChanged() {
    setState(() {
      _filterEmployees();
    });
  }

  void _filterEmployees() {
    final query = _employeeSearchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredEmployees = List.from(_allEmployees);
    } else {
      _filteredEmployees = _allEmployees.where((employee) {
        final name = employee['name']?.toString().toLowerCase() ?? '';
        final jobTitle = employee['job_title']?.toString().toLowerCase() ?? '';
        return name.contains(query) || jobTitle.contains(query);
      }).toList();
    }
  }

  List<dynamic> _getFilteredUsers(
      List<dynamic> users, TextEditingController controller) {
    final query = controller.text.toLowerCase();
    if (query.isEmpty) return users;
    return users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final agencyData = await _transferService.getAgencyRecruitment();
      _relatedUsers = agencyData['related'] ?? [];
      _unrelatedUsers = agencyData['unrelated'] ?? [];

      final employees = await _transferService.searchTransferEmployees();
      _allEmployees = employees;
      _filteredEmployees = List.from(_allEmployees);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  void _toggleEmployeeSelection(dynamic employee) {
    setState(() {
      final id = employee['user_id'];
      final exists = _selectedEmployees.any((e) => e['user_id'] == id);
      if (exists) {
        _selectedEmployees.removeWhere((e) => e['user_id'] == id);
      } else {
        _selectedEmployees.add(employee);
      }
    });
  }

  Future<void> _handleTransfer(String receiverId) async {
    if (_selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select employees to transfer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final userIds =
          _selectedEmployees.map((e) => e['user_id'].toString()).toList();

      final result = await _transferService.transferEmployee(
        userIds: userIds,
        receiverId: receiverId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Transfer initiated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedEmployees.clear();
        _employeeSearchController.clear();
        _approvedSearchController.clear();
        _nonApprovedSearchController.clear();
        _filterEmployees();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to transfer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSelectedEmployees() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selected Employees'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _selectedEmployees.length,
            itemBuilder: (context, index) {
              final employee = _selectedEmployees[index];
              return ListTile(
                title: Text(employee['name'] ?? 'Unknown'),
                subtitle: Text(employee['job_title'] ?? ''),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferCard({
    required String title,
    required String subtitle,
    required List<dynamic> users,
    required TextEditingController searchController,
    required VoidCallback onTransfer,
  }) {
    final filteredUsers = _getFilteredUsers(users, searchController);
    final lang = Provider.of<LanguageProvider>(context);

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
                color: Colors.black,
              )),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 7),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 12),

          // Transfer To search
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Transfer To",
                  style: TextStyle(fontSize: 15, color: Colors.black)),
              const SizedBox(height: 4),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search transfer destination...",
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (searchController.text.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('matching_results'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...filteredUsers.take(3).map((user) {
                  return ListTile(
                    title: Text(user['name'] ?? 'Unknown'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        searchController.text = user['name'] ?? '';
                        setState(() {});
                      },
                      child: const Text('Select'),
                    ),
                  );
                }),
                if (filteredUsers.isEmpty)
                  Text(lang.t('no_results'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: onTransfer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF65b2c9),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(lang.t('transfer_selected')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.t('transfer'),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                lang.t('transfer_hint'),
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              else ...[
                // Approved agreement
                _buildTransferCard(
                  title: lang.t('approved_title'),
                  subtitle: lang.t('approved_subtitle'),
                  users: _relatedUsers,
                  searchController: _approvedSearchController,
                  onTransfer: () {
                    if (_approvedSearchController.text.isNotEmpty) {
                      final filtered = _getFilteredUsers(
                          _relatedUsers, _approvedSearchController);
                      if (filtered.isNotEmpty) {
                        _handleTransfer(filtered.first['user_id'].toString());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'No matching approved agreement user found'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please choose a transfer destination'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Non-agreement
                _buildTransferCard(
                  title: lang.t('non_approved_title'),
                  subtitle: lang.t('non_approved_subtitle'),
                  users: _unrelatedUsers,
                  searchController: _nonApprovedSearchController,
                  onTransfer: () {
                    if (_nonApprovedSearchController.text.isNotEmpty) {
                      final filtered = _getFilteredUsers(
                          _unrelatedUsers, _nonApprovedSearchController);
                      if (filtered.isNotEmpty) {
                        _handleTransfer(filtered.first['user_id'].toString());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('No matching non-agreement user found'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please choose a transfer destination'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Employee search + selection
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            lang.t('search_employees'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _selectedEmployees.isNotEmpty
                                ? _showSelectedEmployees
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(
                              "${lang.t('show_selected')}  (${_selectedEmployees.length})",
                              style: TextStyle(
                                color: _selectedEmployees.isNotEmpty
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _selectedEmployees.isNotEmpty
                                ? () =>
                                    setState(() => _selectedEmployees.clear())
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              side: BorderSide(
                                color: _selectedEmployees.isNotEmpty
                                    ? Colors.grey
                                    : Colors.grey[300]!,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(
                              lang.t('remove_all'),
                              style: TextStyle(
                                color: _selectedEmployees.isNotEmpty
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Colors.grey),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _employeeSearchController,
                        decoration: InputDecoration(
                          hintText: lang.t('search_hint2'),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_filteredEmployees.isEmpty &&
                          _employeeSearchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            lang.t('no_employees_found'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Column(
                          children: _filteredEmployees.map((employee) {
                            final isSelected = _selectedEmployees.any(
                                (e) => e['user_id'] == employee['user_id']);
                            final hasAgreement = _relatedUsers.any((user) =>
                                user['user_id'] == employee['user_id']);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          employee['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(employee['job_title'] ?? ''),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${lang.t('agreement')}: ${hasAgreement ? lang.t('approved') : lang.t('non_agreement')}",
                                          style: const TextStyle(
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent.shade100,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          lang.t('available'),
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 40, 118, 42),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (_) =>
                                            _toggleEmployeeSelection(employee),
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
            ],
          ),
        ),
      ),
    );
  }
}
