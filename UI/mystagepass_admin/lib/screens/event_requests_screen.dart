import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../models/search_result.dart';
import '../utils/alert_helpers.dart';
import 'dart:async';

class EventRequestsScreen extends StatefulWidget {
  const EventRequestsScreen({super.key});

  @override
  State<EventRequestsScreen> createState() => _EventRequestsScreenState();
}

class _EventRequestsScreenState extends State<EventRequestsScreen> {
  List<Event> _events = [];
  bool _isLoading = false;
  String _searchQuery = "";
  String? _statusFilter = "All";

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 5;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    if (_searchQuery.isNotEmpty && _searchQuery.length < 3) {
      setState(() {
        _events = [];
        _currentPage = 1;
        _totalPages = 1;
        _hasPrevious = false;
        _hasNext = false;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      var provider = Provider.of<EventProvider>(context, listen: false);

      if (_statusFilter == "All") {
        var pendingParams = {
          'Page': (_currentPage - 1).toString(),
          'PageSize': _pageSize.toString(),
          'Status': 'pending',
        };

        var rejectedParams = {
          'Page': (_currentPage - 1).toString(),
          'PageSize': _pageSize.toString(),
          'Status': 'rejected',
        };

        if (_searchQuery.length >= 3) {
          pendingParams['searchTerm'] = _searchQuery;
          rejectedParams['searchTerm'] = _searchQuery;
        }

        var pendingData = await provider.get(filter: pendingParams);
        var rejectedData = await provider.get(filter: rejectedParams);

        List<Event> allEvents = [...pendingData.result, ...rejectedData.result];

        if (mounted) {
          setState(() {
            _events = allEvents;
            _totalPages = pendingData.meta.totalPages;
            _currentPage = pendingData.meta.currentPage + 1;
            _hasPrevious = pendingData.meta.hasPrevious;
            _hasNext = pendingData.meta.hasNext || rejectedData.meta.hasNext;
            _isLoading = false;
          });
        }
      } else {
        var params = {
          'Page': (_currentPage - 1).toString(),
          'PageSize': _pageSize.toString(),
          'Status': _statusFilter!.toLowerCase(),
        };

        if (_searchQuery.length >= 3) {
          params['searchTerm'] = _searchQuery;
        }

        SearchResult<Event> data = await provider.get(filter: params);

        if (mounted) {
          setState(() {
            _events = data.result;
            _totalPages = data.meta.totalPages;
            _currentPage = data.meta.currentPage + 1;
            _hasPrevious = data.meta.hasPrevious;
            _hasNext = data.meta.hasNext;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AlertHelpers.showError(context, "Failed to load event requests: $e");
      }
      debugPrint("Error fetching events: $e");
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _searchQuery = query.trim();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _currentPage = 1);
      _fetchEvents();
    });
  }

  void _onStatusFilterChanged(String? value) {
    setState(() {
      _statusFilter = value;
      _currentPage = 1;
    });
    _fetchEvents();
  }

  Future<void> _handleApprove(Event event) async {
    if (event.eventId == null) {
      AlertHelpers.showError(
        context,
        "Cannot approve event: Event ID is missing",
      );
      return;
    }

    try {
      var provider = Provider.of<EventProvider>(context, listen: false);
      await provider.updateStatus(event.eventId!, "approved");

      if (mounted) {
        AlertHelpers.showSuccess(
          context,
          "Event '${event.eventName ?? 'Unknown'}' has been approved successfully!",
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        AlertHelpers.showError(context, "Failed to approve event: $e");
      }
      debugPrint("Error approving event: $e");
    }
  }

  Future<void> _handleReject(Event event) async {
    if (event.eventId == null) {
      AlertHelpers.showError(
        context,
        "Cannot reject event: Event ID is missing",
      );
      return;
    }

    try {
      var provider = Provider.of<EventProvider>(context, listen: false);
      await provider.updateStatus(event.eventId!, "rejected");

      if (mounted) {
        AlertHelpers.showSuccess(
          context,
          "Event '${event.eventName ?? 'Unknown'}' has been rejected.",
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        AlertHelpers.showError(context, "Failed to reject event: $e");
      }
      debugPrint("Error rejecting event: $e");
    }
  }

  void _showConfirmDialog(Event event, bool isApprove) {
    String statusLower = event.status?.statusName?.toLowerCase() ?? 'pending';
    bool isRejected = statusLower == 'rejected';

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(isApprove ? "Approve Event" : "Reject Event"),
        content: Text(
          isApprove
              ? isRejected
                    ? "Are you sure you want to reactivate '${event.eventName ?? 'this event'}'?"
                    : "Are you sure you want to approve '${event.eventName ?? 'this event'}'?"
              : "Are you sure you want to reject '${event.eventName ?? 'this event'}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isApprove) {
                _handleApprove(event);
              } else {
                _handleReject(event);
              }
            },
            child: Text(
              isApprove ? (isRejected ? "Reactivate" : "Approve") : "Reject",
              style: TextStyle(
                color: isApprove ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9DB4FF),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              _buildBackButton(),
              const SizedBox(height: 10),
              _buildFilters(),
              const SizedBox(height: 20),
              if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
                _buildSearchHint(),
              _buildTableStack(),
              const SizedBox(height: 20),
              if (_events.isNotEmpty) _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Event Requests for Approval",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
          const Icon(Icons.pending_actions, size: 32, color: Color(0xFF1A237E)),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop(true);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFF1A237E),
        ),
        label: const Text(
          "Back to Event Management",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          foregroundColor: const Color(0xFF1A237E),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 280,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              cursorColor: const Color(0xFF1A237E),
              cursorWidth: 1.0,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search by performer or location",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 16,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty && _searchQuery.length < 3
                    ? const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.orange,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(hoverColor: const Color(0xFFE3F2FD)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  items: ["All", "Pending", "Rejected"]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _onStatusFilterChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHint() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Enter at least 3 characters to search by performer name or location",
              style: TextStyle(fontSize: 12, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableStack() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTableHeader(),
              SizedBox(
                height: 48.0 * 5,
                child: _events.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty &&
                                      _searchQuery.length >= 3
                                  ? "No ${_statusFilter == 'All' ? '' : _statusFilter!.toLowerCase()} requests found for '$_searchQuery'"
                                  : _statusFilter == 'All'
                                  ? "No pending or rejected event requests"
                                  : "No ${_statusFilter!.toLowerCase()} event requests",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          int rowNumber =
                              ((_currentPage - 1) * _pageSize) + index + 1;
                          return _buildEventRow(rowNumber, _events[index]);
                        },
                      ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF5865F2)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5865F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _tableHeaderCell('#', width: 40),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Date', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Performer', flex: 3),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Location', flex: 3),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Regular', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('VIP', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Premium', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Status', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Actions', width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(int number, Event event) {
    String dateStr = event.eventDate != null
        ? DateFormat('dd MMM yyyy').format(event.eventDate!)
        : "N/A";

    String loc = event.location?.locationName ?? event.locationName ?? "N/A";
    String city = event.location?.city?.name ?? "";
    String fullLocation;

    if (city.isNotEmpty && city != "N/A") {
      fullLocation = "$loc, $city";
    } else {
      fullLocation = loc;
    }

    String statusLower = event.status?.statusName?.toLowerCase() ?? 'pending';
    bool isPending = statusLower == 'pending';

    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _tableCell(number.toString(), width: 40, isBold: true, center: true),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(dateStr, flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(
            event.performer?.artistName ?? "N/A",
            flex: 3,
            isGrey: event.performer?.artistName == null,
            isItalic: event.performer?.artistName == null,
          ),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(
            fullLocation,
            flex: 3,
            isGrey: loc == "N/A",
            isItalic: loc == "N/A",
          ),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(
            "${event.regularPrice ?? 0}KM",
            flex: 2,
            center: true,
            isBold: true,
          ),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(
            "${event.vipPrice ?? 0}KM",
            flex: 2,
            center: true,
            isBold: true,
          ),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(
            "${event.premiumPrice ?? 0}KM",
            flex: 2,
            center: true,
            isBold: true,
          ),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(
            width: 80,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 70),
                child: _buildStatusBadge(statusLower),
              ),
            ),
          ),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(
            width: 100,
            child: Center(
              child: isPending
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _showConfirmDialog(event, true),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => _showConfirmDialog(event, false),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: () => _showConfirmDialog(event, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.restore,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Approve",
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    if (status == 'pending') {
      bgColor = const Color(0xFFFFF8E1);
      borderColor = Colors.orange;
      textColor = Colors.orange.shade800;
      icon = Icons.access_time;
    } else if (status == 'rejected') {
      bgColor = const Color(0xFFFFEBEE);
      borderColor = Colors.red;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
    } else {
      bgColor = Colors.grey.shade100;
      borderColor = Colors.grey;
      textColor = Colors.grey.shade800;
      icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                color: textColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text, {int? flex, double? width}) {
    Widget content = Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
    return flex != null
        ? Expanded(flex: flex, child: content)
        : SizedBox(width: width, child: content);
  }

  Widget _tableCell(
    String text, {
    int? flex,
    double? width,
    bool isBold = false,
    bool center = false,
    bool isGrey = false,
    bool isItalic = false,
  }) {
    return Container(
      width: width,
      child: flex != null
          ? Expanded(
              flex: flex,
              child: _cellText(text, isBold, center, isGrey, isItalic),
            )
          : _cellText(text, isBold, center, isGrey, isItalic),
    );
  }

  Widget _cellText(
    String text,
    bool isBold,
    bool center,
    bool isGrey,
    bool isItalic,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: isGrey ? Colors.grey.shade500 : Colors.black,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _verticalDivider(Color color) =>
      VerticalDivider(color: color, thickness: 1, indent: 6, endIndent: 6);

  Widget _buildPagination() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _hasPrevious
                ? () {
                    setState(() => _currentPage--);
                    _fetchEvents();
                  }
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: _hasPrevious ? Colors.white : Colors.white38,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$_currentPage of $_totalPages",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          IconButton(
            onPressed: _hasNext
                ? () {
                    setState(() => _currentPage++);
                    _fetchEvents();
                  }
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: _hasNext ? Colors.white : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
