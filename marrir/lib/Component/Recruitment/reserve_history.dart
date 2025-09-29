import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/get_reserve.dart';
import 'package:marrir/model/recerve_model.dart';
import 'package:marrir/Dio/dio.dart';

class ReserveHistoryPage extends StatefulWidget {
  const ReserveHistoryPage({super.key});

  @override
  State<ReserveHistoryPage> createState() => _ReserveHistoryPageState();
}

class _ReserveHistoryPageState extends State<ReserveHistoryPage> {
  final ReserveHistoryService _reserveHistoryService =
      ReserveHistoryService(DioClient());

  // Data lists
  List<ReserveHistory> _reserveHistory = [];
  List<IncomingReserveRequest> _incomingRequests = [];
  List<ReserveDetail> _selectedBatchDetails = [];

  // Loading states
  bool _isLoadingHistory = false;
  bool _isLoadingRequests = false;
  bool _isLoadingDetails = false;

  // Error messages
  String _historyError = '';
  String _requestsError = '';

  // Pagination
  int _historyLimit = 5;
  int _requestsLimit = 5;

  // Selected batch for details
  int? _selectedBatchId;

  @override
  void initState() {
    super.initState();
    _loadReserveHistory();
    _loadIncomingRequests();
  }

  Future<void> _loadReserveHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = '';
    });

    final response = await _reserveHistoryService.getReserveHistory(
      limit: _historyLimit,
    );

    setState(() {
      _isLoadingHistory = false;
      if (response.success) {
        _reserveHistory = response.data ?? [];
      } else {
        _historyError = response.message;
      }
    });
  }

  Future<void> _loadIncomingRequests() async {
    setState(() {
      _isLoadingRequests = true;
      _requestsError = '';
    });

    final response = await _reserveHistoryService.getIncomingReserveRequests(
      limit: _requestsLimit,
    );

    setState(() {
      _isLoadingRequests = false;
      if (response.success) {
        _incomingRequests = response.data ?? [];
      } else {
        _requestsError = response.message;
      }
    });
  }

  Future<void> _loadReserveDetails(int batchReserveId) async {
    setState(() {
      _isLoadingDetails = true;
      _selectedBatchId = batchReserveId;
    });

    final response =
        await _reserveHistoryService.getReserveRequestDetails(batchReserveId);

    setState(() {
      _isLoadingDetails = false;
      if (response.success) {
        _selectedBatchDetails = response.data ?? [];
      } else {
        _selectedBatchDetails = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    });
  }

  Future<void> _updateReserveStatus({
    required int batchReserveId,
    required List<int> cvIds,
    required String status,
    String? reason,
  }) async {
    final response = await _reserveHistoryService.updateReserveStatus(
      batchReserveId: batchReserveId,
      cvIds: cvIds,
      status: status,
      reason: reason,
    );

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
      // Reload data
      _loadIncomingRequests();
      if (_selectedBatchId == batchReserveId) {
        _loadReserveDetails(batchReserveId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  void _showReserveDetailsDialog(IncomingReserveRequest request) {
    _loadReserveDetails(request.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reserve Details - Batch #${request.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: _isLoadingDetails
              ? const Center(child: CircularProgressIndicator())
              : _selectedBatchDetails.isEmpty
                  ? const Text('No details found')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final detail in _selectedBatchDetails)
                          ListTile(
                            title: Text(detail.employeeName),
                            subtitle: Text('Occupation: ${detail.occupation}'),
                            trailing: Text(detail.status.toUpperCase()),
                          ),
                      ],
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_selectedBatchDetails.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      final cvIds =
                          _selectedBatchDetails.map((d) => d.cvId).toList();
                      _updateReserveStatus(
                        batchReserveId: request.id,
                        cvIds: cvIds,
                        status: 'accepted',
                      );
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Accept All',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _showDeclineDialog(request.id);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Decline All',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showDeclineDialog(int batchReserveId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Reserve Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for declining...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final cvIds = _selectedBatchDetails.map((d) => d.cvId).toList();
              _updateReserveStatus(
                batchReserveId: batchReserveId,
                cvIds: cvIds,
                status: 'declined',
                reason: reasonController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Confirm Decline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reserve History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Chip(
                    label: Text("This Month"),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Summary Cards =====
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: "Reserves Requested",
                      value: _reserveHistory.length.toString(),
                      count: _reserveHistory.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: "Reserves Requests",
                      value: _incomingRequests.length.toString(),
                      count: _incomingRequests.length.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ===== Incoming Reserve Requests Section =====
              _buildIncomingRequestsSection(),

              const SizedBox(height: 40),

              // ===== Reserve History Section =====
              _buildReserveHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String count,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Count - ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: count,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Incoming Reserve Requests",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 117, 97, 229),
          ),
        ),
        const SizedBox(height: 30),
        _buildRowsDropdown(
          value: _requestsLimit,
          onChanged: (value) {
            setState(() {
              _requestsLimit = value;
            });
            _loadIncomingRequests();
          },
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              // Table Header
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF65b2c9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("From",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("Role",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("Created At",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("Action",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Table Rows
              if (_isLoadingRequests)
                const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator())
              else if (_requestsError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_requestsError,
                      style: const TextStyle(color: Colors.red)),
                )
              else if (_incomingRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No incoming reserve requests"),
                )
              else
                ..._incomingRequests
                    .map((request) => _buildIncomingRequestRow(request)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingRequestRow(IncomingReserveRequest request) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(request.reserverName,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text(request.reserverRole)),
              Expanded(child: Text(_formatDate(request.createdAt))),
              Expanded(
                child: TextButton(
                  onPressed: () => _showReserveDetailsDialog(request),
                  child: const Text("View Details",
                      style: TextStyle(color: Color(0xFF65b2c9))),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey, height: 1, thickness: 0.6),
      ],
    );
  }

  Widget _buildReserveHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reserve History",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 117, 97, 229),
          ),
        ),
        const SizedBox(height: 30),
        _buildRowsDropdown(
          value: _historyLimit,
          onChanged: (value) {
            setState(() {
              _historyLimit = value;
            });
            _loadReserveHistory();
          },
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              // Table Header
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF65b2c9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                child: const Row(
                  children: [
                    Expanded(
                        child: Text("Batch No.",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text("Reserved To",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text("Created At",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text("Employees",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              // Table Rows
              if (_isLoadingHistory)
                const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator())
              else if (_historyError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_historyError,
                      style: const TextStyle(color: Colors.red)),
                )
              else if (_reserveHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No reserve history found"),
                )
              else
                ..._reserveHistory.map((history) => _buildHistoryRow(history)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryRow(ReserveHistory history) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                  child: Text("#${history.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text(history.reserverName)),
              Expanded(child: Text(_formatDate(history.createdAt))),
              Expanded(child: Text("${history.reserves.length} employees")),
            ],
          ),
        ),
        const Divider(color: Colors.grey, height: 1, thickness: 0.6),
      ],
    );
  }

  Widget _buildRowsDropdown({
    required int value,
    required Function(int) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Show rows:",
            style: TextStyle(fontSize: 16, color: Colors.black87)),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 2))
            ],
          ),
          child: DropdownButton<int>(
            value: value,
            underline: const SizedBox(),
            isExpanded: true,
            items: [5, 10, 20, 50].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            onChanged: (newValue) => onChanged(newValue!),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
