import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/get_reserve.dart';
import 'package:marrir/model/recerve_model.dart';
import 'package:marrir/Dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:marrir/Component/Language/language_provider.dart';

class ReserveHistoryPage extends StatefulWidget {
  const ReserveHistoryPage({super.key});

  @override
  State<ReserveHistoryPage> createState() => _ReserveHistoryPageState();
}

class _ReserveHistoryPageState extends State<ReserveHistoryPage> {
  final ReserveHistoryService _reserveHistoryService =
      ReserveHistoryService(DioClient());

  List<ReserveHistory> _reserveHistory = [];
  List<IncomingReserveRequest> _incomingRequests = [];
  List<ReserveDetail> _selectedBatchDetails = [];

  bool _isLoadingHistory = false;
  bool _isLoadingRequests = false;
  bool _isLoadingDetails = false;

  String _historyError = '';
  String _requestsError = '';

  int _historyLimit = 5;
  int _requestsLimit = 5;

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

    final lang = Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${lang.t('reserve_details')} - Batch #${request.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: _isLoadingDetails
              ? const Center(child: CircularProgressIndicator())
              : _selectedBatchDetails.isEmpty
                  ? Text(lang.t('no_details_found'))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final detail in _selectedBatchDetails)
                          ListTile(
                            title: Text(detail.employeeName),
                            subtitle: Text(
                                '${lang.t('occupation')}: ${detail.occupation}'),
                            trailing: Text(detail.status.toUpperCase()),
                          ),
                      ],
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.t('close')),
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
                    child: Text(lang.t('accept_all'),
                        style: const TextStyle(color: Colors.white)),
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
                    child: Text(lang.t('decline_all'),
                        style: const TextStyle(color: Colors.white)),
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
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.t('decline_reserve_request')),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            hintText: lang.t('enter_decline_reason'),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.t('cancel')),
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
            child: Text(lang.t('confirm_decline')),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.t('reserve_history'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Chip(
                    label: Text(lang.t('this_month')),
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
                      title: lang.t('reserves_requested'),
                      value: _reserveHistory.length.toString(),
                      count: _reserveHistory.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: lang.t('reserves_requests'),
                      value: _incomingRequests.length.toString(),
                      count: _incomingRequests.length.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _buildIncomingRequestsSection(),

              const SizedBox(height: 40),

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
                TextSpan(
                  text: "$title - ",
                  style: const TextStyle(
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
    final lang = Provider.of<LanguageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('incoming_reserve_requests'),
          style: const TextStyle(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang.t('from'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(lang.t('role'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(lang.t('created_at'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(lang.t('action'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(lang.t('no_incoming_reserve_requests')),
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
    final lang = Provider.of<LanguageProvider>(context);

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
                  child: Text(lang.t('view_details'),
                      style: const TextStyle(color: Color(0xFF65b2c9))),
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
    final lang = Provider.of<LanguageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('reserve_history'),
          style: const TextStyle(
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
                child: Row(
                  children: [
                    Expanded(
                        child: Text(lang.t('batch_no'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text(lang.t('reserved_to'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text(lang.t('created_at'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text(lang.t('employees'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(lang.t('no_reserve_history_found')),
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
    final lang = Provider.of<LanguageProvider>(context);

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
              Expanded(
                  child: Text(
                      "${history.reserves.length} ${lang.t('employees')}")),
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
    final lang = Provider.of<LanguageProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${lang.t('show_rows')}:",
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
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
