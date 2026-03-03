import 'package:flutter/material.dart';
import 'package:mystagepass_admin/screens/event_requests_screen.dart';
import 'package:mystagepass_admin/screens/upcoming_events_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../models/search_result.dart';
import 'dart:async';
import 'package:mystagepass_admin/widgets/base_layout.dart';

class EventManagementScreen extends StatefulWidget {
  final int userId;
  const EventManagementScreen({super.key, required this.userId});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  List<Event> _events = [];
  bool _isLoading = false;
  String _searchQuery = "";
  String? _statusFilter = "All";

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 6;

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
      var params = {
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
        'Status': 'approved',
      };

      if (_searchQuery.length >= 3) params['searchTerm'] = _searchQuery;
      if (_statusFilter != "All") {
        params['IsUpcoming'] = (_statusFilter == "Upcoming").toString();
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
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      userId: widget.userId,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
            child: _buildHeader(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
            child: Column(
              children: [
                _buildFilters(),
                if (_searchQuery.isNotEmpty && _searchQuery.length < 3) ...[
                  const SizedBox(height: 10),
                  _buildSearchHint(),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 24, 40, 24),
              child: _buildTableStack(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 8, 40, 50),
            child: Column(
              children: [
                if (_events.isNotEmpty) _buildPagination(),
                const SizedBox(height: 12),
                _buildBottomButtonsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.confirmation_number_outlined,
              size: 36,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Text(
              "Event Management",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Row(
        children: [
          Container(
            width: 220,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              cursorColor: const Color.fromARGB(255, 29, 35, 93),
              cursorWidth: 1.0,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search",
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
              ).copyWith(hoverColor: const Color.fromARGB(192, 81, 136, 182)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  items: ["All", "Upcoming", "Ended"]
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
      constraints: const BoxConstraints(maxWidth: 900),
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
              "Enter at least 3 characters to search by event name or location",
              style: TextStyle(fontSize: 12, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableStack() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
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
                height: 56.0 * _pageSize,
                child: _events.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty &&
                                      _searchQuery.length >= 3
                                  ? "No events found for '$_searchQuery'"
                                  : _statusFilter != "All"
                                  ? "No $_statusFilter events found"
                                  : "No events found",
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
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 29, 35, 93),
                  ),
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
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _tableHeaderCell('#', width: 45),
            _vd(),
            _tableHeaderCell('Date', width: 110),
            _vd(),
            _tableHeaderCell('Performer Name', flex: 2),
            _vd(),
            _tableHeaderCell('Location', flex: 3),
            _vd(),
            _tableHeaderCell('Tickets Sold', width: 95),
            _vd(),
            _tableHeaderCell('Status', width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(int number, Event event) {
    String dateStr = event.eventDate != null
        ? DateFormat('dd MMM yyyy').format(event.eventDate!)
        : "N/A";
    bool isUpcoming = event.eventDate?.isAfter(DateTime.now()) ?? false;
    String loc = event.location?.locationName ?? event.locationName ?? "N/A";
    String city = event.location?.city?.name ?? "";
    String fullLocation = city.isNotEmpty && city != "N/A"
        ? "$loc, $city"
        : loc;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _tableCell(number.toString(), width: 45, isBold: true, center: true),
          _vd(),
          _tableCell(dateStr, width: 110),
          _vd(),
          Expanded(
            flex: 2,
            child: _cellText(
              event.performer?.artistName ?? event.eventName ?? "N/A",
              false,
              false,
              event.performer?.artistName == null && event.eventName == null,
              event.performer?.artistName == null && event.eventName == null,
            ),
          ),
          _vd(),
          Expanded(
            flex: 3,
            child: _cellText(
              fullLocation,
              false,
              false,
              loc == "N/A",
              loc == "N/A",
            ),
          ),
          _vd(),
          _tableCell(
            "${event.ticketsSold ?? 0}",
            width: 95,
            center: true,
            isBold: true,
          ),
          _vd(),
          SizedBox(
            width: 100,
            child: Center(child: _buildStatusBadge(isUpcoming)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isUpcoming) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isUpcoming ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isUpcoming ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.check : Icons.close,
            size: 10,
            color: isUpcoming ? Colors.green[800]! : Colors.red[800]!,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              isUpcoming ? "Upcoming" : "Ended",
              style: TextStyle(
                color: isUpcoming ? Colors.green[800]! : Colors.red[800]!,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text, {int? flex, double? width}) {
    final content = Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(249, 8, 18, 70),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
    if (flex != null) return Expanded(flex: flex, child: content);
    return SizedBox(width: width, child: content);
  }

  Widget _tableCell(
    String text, {
    double? width,
    bool isBold = false,
    bool center = false,
    bool isGrey = false,
    bool isItalic = false,
  }) {
    return SizedBox(
      width: width,
      child: _cellText(text, isBold, center, isGrey, isItalic),
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
            color: isGrey
                ? Colors.grey.shade500
                : const Color.fromARGB(248, 0, 0, 1),
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _vd() => VerticalDivider(
    color: const Color.fromARGB(77, 145, 156, 218),
    thickness: 1,
    indent: 6,
    endIndent: 6,
  );

  Widget _buildPagination() {
    return Row(
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
            size: 32,
            color: _hasPrevious ? Colors.white : Colors.white38,
          ),
        ),
        Text(
          "$_currentPage of $_totalPages",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
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
            size: 32,
            color: _hasNext ? Colors.white : Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtonsRow() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            label: const Text(
              "Back to Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromARGB(255, 29, 35, 93),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpcomingEventsScreen(userId: widget.userId),
                    ),
                  );
                },
                icon: const Icon(Icons.upcoming, size: 20),
                label: const Text(
                  "Upcoming Events",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(255, 29, 35, 93),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final shouldRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventRequestsScreen(userId: widget.userId),
                    ),
                  );
                  if (shouldRefresh == true) _fetchEvents();
                },
                icon: const Icon(Icons.pending_actions, size: 20),
                label: const Text(
                  "Requests for Approval",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(255, 29, 35, 93),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
