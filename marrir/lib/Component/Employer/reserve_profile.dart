import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/reserve_service.dart';
import 'package:marrir/model/model.dart';
import 'package:marrir/Dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class ReserveProfilePage extends StatefulWidget {
  const ReserveProfilePage({super.key});

  @override
  State<ReserveProfilePage> createState() => _ReserveProfilePageState();
}

class _ReserveProfilePageState extends State<ReserveProfilePage> {
  final ReserveService _reserveService = ReserveService(DioClient());
  final TextEditingController _searchController = TextEditingController();

  List<UnreservedEmployee> _employees = [];
  final List<UnreservedEmployee> _selectedEmployees = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadUnreservedEmployees();
  }

  Future<void> _loadUnreservedEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await _reserveService.getUnreservedEmployees();

    setState(() {
      _isLoading = false;
      if (response.success) {
        _employees = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    });
  }

  Future<void> _searchEmployees() async {
    if (_searchController.text.isEmpty) {
      _loadUnreservedEmployees();
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    final response = await _reserveService.searchEmployees(
      search: _searchController.text,
    );

    setState(() {
      _isSearching = false;
      if (response.success) {
        _employees = response.data ?? [];
      } else {
        _errorMessage = response.message;
      }
    });
  }

  Future<void> _reserveSelectedEmployees() async {
    if (_selectedEmployees.isEmpty) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('select_at_least_one'))),
      );
      return;
    }

    final cvIds = _selectedEmployees
        .where((employee) => employee.cv?['id'] != null)
        .map((employee) => employee.cv!['id'] as int)
        .toList();

    if (cvIds.isEmpty) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('no_valid_cv'))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _reserveService.reserveCVs(cvIds);

    setState(() {
      _isLoading = false;
    });

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );

    if (response.success) {
      setState(() {
        _selectedEmployees.clear();
      });
      _loadUnreservedEmployees();
    }
  }

  void _toggleEmployeeSelection(UnreservedEmployee employee) {
    setState(() {
      if (_selectedEmployees.contains(employee)) {
        _selectedEmployees.remove(employee);
      } else {
        _selectedEmployees.add(employee);
      }
    });
  }

  void _clearAllSelection() {
    setState(() {
      _selectedEmployees.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.t('reserve'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lang.t('reserve_hint'),
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildSearchCard(),
            const SizedBox(height: 20),
            if (_isLoading) _buildLoadingIndicator(),
            if (_errorMessage.isNotEmpty) _buildErrorMessage(),
            _buildResultsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    final lang = Provider.of<LanguageProvider>(context);

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
            child: Text(
              lang.t('search_employees'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(height: 1, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: lang.t('search_hint'),
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
                            color: Color(0xFF65b2c9), width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _searchEmployees(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  tooltip: lang.t('filter'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _searchEmployees,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65b2c9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(lang.t('search')),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    _loadUnreservedEmployees();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(lang.t('clear'),
                      style: const TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorMessage() {
    final lang = Provider.of<LanguageProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
              child: Text(_errorMessage,
                  style: TextStyle(color: Colors.red.shade600))),
          IconButton(
            onPressed: _loadUnreservedEmployees,
            icon: const Icon(Icons.refresh),
            tooltip: lang.t('retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    final lang = Provider.of<LanguageProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lang.t('results'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _selectedEmployees.isNotEmpty
                        ? _reserveSelectedEmployees
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                        "${lang.t('reserve_selected')} (${_selectedEmployees.length})"),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _selectedEmployees.isNotEmpty
                        ? _clearAllSelection
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(lang.t('remove_all')),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          if (_employees.isEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(lang.t('no_employees'), textAlign: TextAlign.center),
            )
          else
            Column(
              children: _employees
                  .map((employee) => _buildEmployeeCard(employee))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(UnreservedEmployee employee) {
    final lang = Provider.of<LanguageProvider>(context);
    final isSelected = _selectedEmployees.contains(employee);
    const isAvailable = true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F4F8) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF65b2c9) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(employee.displayOccupation),
                const SizedBox(height: 4),
                Text(employee.experienceInfo,
                    style: const TextStyle(color: Colors.black54)),
                if (employee.nationality != null) ...[
                  const SizedBox(height: 4),
                  Text("${lang.t('nationality')}: ${employee.nationality}",
                      style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAvailable ? lang.t('available') : lang.t('reserved'),
                  style: const TextStyle(
                    color: isAvailable ? Colors.green : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: isSelected,
                onChanged: (val) => _toggleEmployeeSelection(employee),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.t('filter_employees')),
        content: Text(lang.t('filter_hint')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.t('close')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
