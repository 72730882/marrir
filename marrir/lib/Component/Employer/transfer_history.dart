import 'package:flutter/material.dart';
import 'package:marrir/services/Employer/transfer_service.dart';

class TransferHistoryPage extends StatefulWidget {
  const TransferHistoryPage({super.key});

  @override
  State<TransferHistoryPage> createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  final TransferService _transferService = TransferService();
  List<dynamic> _incomingTransfers = [];
  List<dynamic> _processTransfers = [];
  Map<String, dynamic> _transferStats = {};
  bool _isLoading = true;
  String _errorMessage = '';
  int _rowsToShow = 5;

  @override
  void initState() {
    super.initState();
    _loadTransferData();
  }

  Future<void> _loadTransferData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load data sequentially to better handle errors
      try {
        final stats = await _transferService.getTransferStats();
        setState(() {
          _transferStats = stats;
        });
      } catch (e) {
        print('⚠️ Warning: Failed to load transfer stats: $e');
      }

      try {
        final incoming = await _transferService.getIncomingTransfers();
        setState(() {
          _incomingTransfers = incoming;
        });
      } catch (e) {
        print('⚠️ Warning: Failed to load incoming transfers: $e');
      }

      try {
        final process = await _transferService.getProcessTransfers();
        setState(() {
          _processTransfers = process;
        });
      } catch (e) {
        print('⚠️ Warning: Failed to load process transfers: $e');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load transfer data: ${e.toString()}';
      });
      print('❌ Error loading transfer data: $e');
    }
  }

  // ===== ADD THE MISSING HELPER METHODS =====

  String _getField(dynamic item, String fieldName,
      {String defaultValue = 'N/A'}) {
    try {
      final value = item[fieldName];
      return value?.toString() ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _getRequesterName(dynamic transfer) {
    final requester = transfer['requester'] ?? {};
    final company = requester['company'] ?? {};
    return company['company_name'] ??
        '${requester['first_name'] ?? ''} ${requester['last_name'] ?? ''}'
            .trim();
  }

  String _getReceiverName(dynamic transfer) {
    final receiver = transfer['receiver'] ?? {};
    final company = receiver['company'] ?? {};
    return company['company_name'] ??
        '${receiver['first_name'] ?? ''} ${receiver['last_name'] ?? ''}'.trim();
  }

  int _getTransferCount(dynamic transfer) {
    final transfers = transfer['transfers'] ?? [];
    return transfers.length;
  }

  // ===== END OF HELPER METHODS =====

  @override
  Widget build(BuildContext context) {
    final requestedCount = _transferStats['requested']?.toString() ?? '0';
    final receivedCount = _transferStats['received']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTransferData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Loading Indicator =====
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // ===== Error Message =====
                if (_errorMessage.isNotEmpty)
                  Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _loadTransferData,
                        child: const Text('Try Again'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                if (!_isLoading && _errorMessage.isEmpty) ...[
                  // ===== Employee Summary Card =====
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transfers",
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

                  // ===== Two Cards Side by Side =====
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Transfer Requested",
                          value: requestedCount,
                          count: _processTransfers.length.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: "Transfers Received",
                          value: receivedCount,
                          count: _incomingTransfers.length.toString(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ===== Incoming Transfer Requests Section =====
                  const Text(
                    "Incoming Transfer Requests",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7561E5),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildShowRowsDropdown(),

                  const SizedBox(height: 20),

                  // ===== Incoming Transfers Table =====
                  if (_incomingTransfers.isEmpty)
                    const Center(
                      child: Text(
                        "No incoming transfer requests",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF65B2C9),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 16),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "From",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Created At",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          ..._incomingTransfers
                              .take(_rowsToShow)
                              .map((transfer) {
                            final requesterName = _getRequesterName(transfer);
                            final createdAt =
                                _formatDate(_getField(transfer, 'created_at'));
                            return _buildTableRow(requesterName, createdAt);
                          }),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // ===== Process Transfer Request Section =====
                  const Text(
                    "Process Transfer Request",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7561E5),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildShowRowsDropdown(),

                  const SizedBox(height: 20),

                  // ===== Process Transfers Table =====
                  if (_processTransfers.isEmpty)
                    const Center(
                      child: Text(
                        "No process transfer requests",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF65B2C9),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 16),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Batch No.",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Transfer To",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Created At",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ..._processTransfers
                              .take(_rowsToShow)
                              .map((transfer) {
                            final batchId = _getField(transfer, 'id');
                            final receiverName = _getReceiverName(transfer);
                            final createdAt =
                                _formatDate(_getField(transfer, 'created_at'));
                            return _buildTableRow3(
                                batchId, receiverName, createdAt);
                          }),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helper for Summary Card =====
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

  // ===== Helper for "Show Rows" Dropdown =====
  Widget _buildShowRowsDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Show rows:",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<int>(
            value: _rowsToShow,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            items: const [
              DropdownMenuItem(value: 5, child: Text("5")),
              DropdownMenuItem(value: 10, child: Text("10")),
              DropdownMenuItem(value: 20, child: Text("20")),
            ],
            onChanged: (value) {
              setState(() {
                _rowsToShow = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // ===== Helper for Table Row (2 Columns) =====
  Widget _buildTableRow(String from, String date) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  from,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.6,
        ),
      ],
    );
  }

  // ===== Helper for Table Row (3 Columns) =====
  Widget _buildTableRow3(String batch, String to, String date) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  batch,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  to,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.6,
        ),
      ],
    );
  }
}
