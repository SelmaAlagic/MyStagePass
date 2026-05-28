import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystagepass_admin/utils/snack_helpers.dart';
import 'package:provider/provider.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../utils/alert_helpers.dart';
import 'event_management_screen.dart';
import 'package:mystagepass_admin/widgets/sidebar_layout.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);

class EventRequestsScreen extends StatefulWidget {
  const EventRequestsScreen({super.key, required this.userId});
  final int userId;

  @override
  State<EventRequestsScreen> createState() => _EventRequestsScreenState();
}

class _EventRequestsScreenState extends State<EventRequestsScreen> {
  List<Event> _events = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _statusFilter = 'Pending';

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
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
      if (mounted) {
        setState(() {
          _events = [];
          _currentPage = 1;
          _totalPages = 1;
          _totalCount = 0;
          _hasPrevious = false;
          _hasNext = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final provider = Provider.of<EventProvider>(context, listen: false);

      final params = <String, dynamic>{
        'Page': _currentPage - 1,
        'PageSize': _pageSize,
        'Status': _statusFilter.toLowerCase(),
      };

      if (_searchQuery.length >= 3) params['searchTerm'] = _searchQuery;

      final data = await provider.get(filter: params);

      if (mounted) {
        setState(() {
          _events = data.result;
          _totalPages = max(1, data.meta.totalPages);
          _totalCount = data.meta.count;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '').trim();
        SnackHelpers.showError(context, msg);
      }
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    _fetchEvents();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _searchQuery = value.trim());

    if (_searchQuery.length >= 3 || _searchQuery.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 450), () {
        _currentPage = 1;
        _fetchEvents();
      });
    }
  }

  void _onStatusFilterChanged(String? value) {
    if (value == null) return;
    setState(() {
      _statusFilter = value;
      _currentPage = 1;
    });
    _fetchEvents();
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Future<void> _handleApprove(Event event) async {
    try {
      final provider = Provider.of<EventProvider>(context, listen: false);
      await provider.updateStatus(event.eventId!, 'approved');
      if (mounted) {
        SnackHelpers.showSuccess(
          context,
          "Event '${event.eventName ?? 'Unknown'}' has been approved successfully!",
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        SnackHelpers.showError(context, 'Failed to approve event: $e');
      }
      debugPrint('Error approving event: $e');
    }
  }

  Future<void> _handleRejectWithReason(Event event, String reason) async {
    try {
      final provider = Provider.of<EventProvider>(context, listen: false);
      await provider.updateStatus(event.eventId!, 'rejected', reason: reason);
      if (mounted) {
        SnackHelpers.showSuccess(
          context,
          "Event '${event.eventName ?? 'Unknown'}' has been rejected.",
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '').trim();
        SnackHelpers.showError(context, msg);
      }
    }
  }

  void _showRejectDialog(Event event) {
    final TextEditingController reasonController = TextEditingController();
    String? fieldError;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: _white,
          surfaceTintColor: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_navy, _navyMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: _white,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Reject Event',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: _white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: _red.withOpacity(0.22)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: _red,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The performer will be notified about the rejection and the reason provided.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _red,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Rejection Reason',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _t1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: fieldError != null ? _red : _border,
                            width: fieldError != null ? 1.5 : 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: reasonController,
                          maxLines: 3,
                          cursorColor: _navyMid,
                          cursorWidth: 1.2,
                          style: const TextStyle(fontSize: 13, color: _t1),
                          onChanged: (_) {
                            if (fieldError != null)
                              setS(() => fieldError = null);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter rejection reason...',
                            hintStyle: TextStyle(color: _t2, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      if (fieldError != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 12,
                              color: _red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              fieldError!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: const BoxDecoration(
                    color: _bg,
                    border: Border(top: BorderSide(color: _border)),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _t2,
                            side: const BorderSide(color: _border),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final reason = reasonController.text.trim();
                            if (reason.isEmpty) {
                              setS(
                                () => fieldError =
                                    'Rejection reason is required.',
                              );
                              return;
                            }
                            if (reason.length < 5) {
                              setS(
                                () => fieldError =
                                    'Reason must be at least 5 characters.',
                              );
                              return;
                            }
                            Navigator.pop(ctx);
                            AlertHelpers.showConfirmationAlert(
                              context,
                              'Reject Event',
                              'Are you sure you want to reject "${event.eventName}"? The performer will be notified.',
                              confirmButtonText: 'Yes, Reject',
                              cancelButtonText: 'Go Back',
                              isDelete: true,
                              onConfirm: () =>
                                  _handleRejectWithReason(event, reason),
                            );
                          },
                          icon: const Icon(Icons.close_rounded, size: 14),
                          label: const Text(
                            'Reject Event',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _red,
                            foregroundColor: _white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(Event event, bool isApprove) {
    final statusLower = event.status?.statusName?.toLowerCase() ?? 'pending';
    final isRejected = statusLower == 'rejected';

    final title = isApprove
        ? (isRejected ? 'Reactivate Event' : 'Approve Event')
        : 'Reject Event';

    final message = isApprove
        ? isRejected
              ? "Are you sure you want to reactivate '${event.eventName ?? 'this event'}'? This event will be visible again."
              : "Are you sure you want to approve '${event.eventName ?? 'this event'}'? The organizer will be notified."
        : "Are you sure you want to reject '${event.eventName ?? 'this event'}'? The organizer will be notified.";

    AlertHelpers.showConfirmationAlert(
      context,
      title,
      message,
      confirmButtonText: isApprove
          ? (isRejected ? 'Reactivate' : 'Approve')
          : 'Reject',
      cancelButtonText: 'Cancel',
      isDelete: !isApprove,
      onConfirm: () => _handleApprove(event),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      userId: widget.userId,
      activeRouteKey: SidebarRoutes.events,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 20),
                _buildMainCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Event Requests',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Review and manage pending and rejected event requests.',
          style: TextStyle(fontSize: 13, color: _t2),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildFilterRow(),
          _buildTable(),
          if (!_isLoading && _events.isNotEmpty) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final hasActiveFilters =
        _statusFilter != 'Pending' || _searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 240,
                height: 38,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty && _searchQuery.length < 3
                        ? _navyMid.withOpacity(0.4)
                        : _border,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  cursorColor: _navy,
                  cursorWidth: 1.0,
                  style: const TextStyle(fontSize: 13, color: _t1),
                  decoration: InputDecoration(
                    hintText: 'Search requests...',
                    hintStyle: const TextStyle(color: _t2, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: _t2,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _t2,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 11,
                        color: _navyMid.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Type at least 3 characters',
                        style: TextStyle(
                          fontSize: 11,
                          color: _navyMid.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          _StatusDropdown(
            value: _statusFilter,
            onChanged: _onStatusFilterChanged,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                setState(() {
                  _statusFilter = 'Pending';
                  _searchQuery = '';
                  _currentPage = 1;
                });
                _searchController.clear();
                _fetchEvents();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt_off_rounded, size: 14, color: _t2),
                      SizedBox(width: 5),
                      Text(
                        'Clear filters',
                        style: TextStyle(
                          fontSize: 12,
                          color: _t2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                _fadeRoute(EventManagementScreen(userId: widget.userId)),
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 16, color: _navyMid),
                    SizedBox(width: 6),
                    Text(
                      'Event Management',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _navyMid,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        _buildTableHeader(),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
            ),
          )
        else if (_events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 36,
                  color: _t2.withOpacity(0.4),
                ),
                const SizedBox(height: 10),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No requests match "$_searchQuery"'
                      : _statusFilter == 'All'
                      ? 'No pending or rejected requests found'
                      : 'No ${_statusFilter.toLowerCase()} requests found',
                  style: const TextStyle(fontSize: 13, color: _t2),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final rowNum = ((_currentPage - 1) * _pageSize) + index + 1;
              return _buildEventRow(rowNum, _events[index], index);
            },
          ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(
          top: BorderSide(color: _border),
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          _th('#', width: 40),
          _th('Event', flex: 3),
          _th('Date', width: 110),
          _th('Performer', flex: 2),
          _th('Location', flex: 2),
          _th('Requested', width: 140),
          _th('Status', width: 110),
          _th('Actions', width: 130),
        ],
      ),
    );
  }

  Widget _th(String label, {int? flex, double? width}) {
    final w = Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _t2,
      ),
    );
    if (flex != null) return Expanded(flex: flex, child: w);
    return SizedBox(
      width: width,
      child: Center(child: w),
    );
  }

  Widget _buildEventRow(int number, Event event, int index) {
    final isEven = index % 2 == 0;
    final name = event.eventName ?? 'N/A';
    final performerName = event.performer?.artistName ?? 'N/A';

    final loc = event.location?.locationName ?? event.locationName ?? 'N/A';
    final city = event.location?.city?.name ?? '';
    final fullLocation = city.isNotEmpty && city != 'N/A' ? '$loc, $city' : loc;

    final dateStr = event.eventDate != null
        ? DateFormat('dd MMM yyyy').format(event.eventDate!)
        : 'N/A';

    final requestedStr = event.createdAt != null
        ? DateFormat('dd MMM yyyy').format(event.createdAt!)
        : 'N/A';

    final statusLower = event.status?.statusName?.toLowerCase() ?? 'pending';
    final isPending = statusLower == 'pending';
    final isPastEvent =
        event.eventDate != null && event.eventDate!.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () => _showEventDetailDialog(event),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _HoverRow(
          isEven: isEven,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _t2,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    color: name == 'N/A' ? _t2 : _t1,
                    fontStyle: name == 'N/A'
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 110,
                child: Center(
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      color: dateStr == 'N/A' ? _t2 : _t1,
                      fontStyle: dateStr == 'N/A'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  performerName,
                  style: TextStyle(
                    fontSize: 13,
                    color: performerName == 'N/A' ? _t2 : _t1,
                    fontStyle: performerName == 'N/A'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  fullLocation,
                  style: TextStyle(
                    fontSize: 13,
                    color: fullLocation == 'N/A' ? _t2 : _t2,
                    fontStyle: fullLocation == 'N/A'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 140,
                child: Center(
                  child: Text(
                    requestedStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: requestedStr == 'N/A' ? _t2 : _t2,
                      fontStyle: requestedStr == 'N/A'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: Center(child: _buildStatusBadge(statusLower)),
              ),
              SizedBox(
                width: 130,
                child: Center(
                  child: isPending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionIconButton(
                              icon: Icons.check_rounded,
                              color: _green,
                              bg: _green.withOpacity(0.1),
                              enabled: !isPastEvent,
                              onTap: () => _showConfirmDialog(event, true),
                            ),
                            const SizedBox(width: 8),
                            _ActionIconButton(
                              icon: Icons.close_rounded,
                              color: _red,
                              bg: _red.withOpacity(0.1),
                              enabled: !isPastEvent,
                              onTap: () => _showRejectDialog(event),
                            ),
                          ],
                        )
                      : Opacity(
                          opacity: isPastEvent ? 0.35 : 1,
                          child: GestureDetector(
                            onTap: isPastEvent
                                ? null
                                : () => _showConfirmDialog(event, true),
                            child: Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _green.withOpacity(0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.restore_rounded,
                                    size: 13,
                                    color: _green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Approve',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _green,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildStatusBadge(String status) {
    Color fg;
    Color bg;
    Color border;
    String label;

    if (status == 'pending') {
      fg = const Color(0xFFB45309);
      bg = const Color(0xFFFFF7ED);
      border = const Color(0xFFFED7AA);
      label = 'Pending';
    } else if (status == 'rejected') {
      fg = const Color(0xFFB91C1C);
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      label = 'Rejected';
    } else {
      fg = _t2;
      bg = _bg;
      border = _border;
      label = 'Unknown';
    }

    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final from = ((_currentPage - 1) * _pageSize) + 1;
    final to = ((_currentPage - 1) * _pageSize) + _events.length;

    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (startPage + 4).clamp(1, _totalPages);
    if (endPage - startPage < 4) {
      startPage = (endPage - 4).clamp(1, _totalPages);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $from to $to of $_totalCount requests',
            style: const TextStyle(fontSize: 12, color: _t2),
          ),
          const Spacer(),
          Row(
            children: [
              _PagArrow(
                icon: Icons.chevron_left_rounded,
                enabled: _hasPrevious,
                onTap: () => _goToPage(_currentPage - 1),
              ),
              const SizedBox(width: 4),
              ...List.generate(endPage - startPage + 1, (i) {
                final page = startPage + i;
                final isActive = page == _currentPage;
                return GestureDetector(
                  onTap: () => _goToPage(page),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? _navyMid : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? _navyMid : _border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? _white : _t1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              _PagArrow(
                icon: Icons.chevron_right_rounded,
                enabled: _hasNext,
                onTap: () => _goToPage(_currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEventDetailDialog(Event event) {
    final statusLower = event.status?.statusName?.toLowerCase() ?? '';
    final isRejected = statusLower == 'rejected';
    if (!isRejected) return;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => Dialog(
        backgroundColor: _white,
        surfaceTintColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, _navyMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: _white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.eventName ?? 'Event Details',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            event.performer?.artistName ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: _white,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _detailItem(
                            Icons.person_outline_rounded,
                            'Rejected by',
                            event.statusChangedByAdminName ?? 'N/A',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _detailItem(
                            Icons.access_time_rounded,
                            'Rejected on',
                            event.statusChangedAt != null
                                ? DateFormat(
                                    'dd MMM yyyy · HH:mm',
                                  ).format(event.statusChangedAt!)
                                : 'N/A',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _red.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.notes_rounded, size: 13, color: _red),
                              SizedBox(width: 6),
                              Text(
                                'Rejection Reason',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.cancellationReason?.isNotEmpty == true
                                ? event.cancellationReason!
                                : 'No reason provided.',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _t1,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: const BoxDecoration(
                  color: _bg,
                  border: Border(top: BorderSide(color: _border)),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _t2,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Widget _detailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: _navyMid.withOpacity(0.6)),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _t2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _t1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatefulWidget {
  final String value;
  final void Function(String?) onChanged;

  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(0, 42),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 168,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusOption(
                        value: 'Pending',
                        label: 'Pending',
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFFB45309),
                      ),
                      _statusOption(
                        value: 'Rejected',
                        label: 'Rejected',
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFB91C1C),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusOption({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = widget.value == value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Material(
        color: isSelected ? _bg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: _bg,
          onTap: () {
            _close();
            widget.onChanged(value);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _t1 : _t2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.value != 'All';
    final label = switch (widget.value) {
      'Pending' => 'Pending',
      'Rejected' => 'Rejected',
      _ => 'Pending',
    };

    final icon = switch (widget.value) {
      'Pending' => Icons.schedule_rounded,
      'Rejected' => Icons.cancel_rounded,
      _ => Icons.schedule_rounded,
    };

    final iconColor = switch (widget.value) {
      'Pending' => const Color(0xFFB45309),
      'Rejected' => const Color(0xFFB91C1C),
      _ => const Color(0xFFB45309),
    };
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isOpen || isActive
                  ? const Color(0xFFE8EDFF)
                  : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOpen || isActive
                    ? const Color(0xFF2D3A8C).withOpacity(0.4)
                    : const Color(0xFFECEFF8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isOpen || isActive
                        ? const Color(0xFF2D3A8C)
                        : const Color(0xFF1E2642),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _isOpen || isActive
                        ? const Color(0xFF2D3A8C)
                        : const Color(0xFF8A93B2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverRow extends StatefulWidget {
  final bool isEven;
  final Widget child;

  const _HoverRow({required this.isEven, required this.child});

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFFEEF1FF)
              : widget.isEven
              ? _card
              : const Color(0xFFFAFBFF),
          border: const Border(bottom: BorderSide(color: _border, width: 0.5)),
        ),
        child: widget.child,
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.bg,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }
}

class _PagArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PagArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled ? _bg : const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? _t1 : _t2.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
