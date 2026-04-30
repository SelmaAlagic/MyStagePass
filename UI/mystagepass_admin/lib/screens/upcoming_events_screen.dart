import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../models/Location/location.dart';
import '../providers/location_provider.dart';
import 'dart:async';
import '../widgets/sidebar_layout.dart';
import 'event_management_screen.dart';
import '../utils/alert_helpers.dart';
import '../utils/image_helpers.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _red = Color(0xFFEF4444);
const _amber = Color(0xFFF59E0B);

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key, required this.userId});
  final int userId;

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<Event> _events = [];
  bool _isLoading = false;
  bool _isLoadingLocations = false;
  String _searchQuery = '';
  int? _selectedLocationId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  double _minPrice = 0;
  double _maxPrice = 500;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 6;

  List<Location> _locations = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _fetchLocations();
    await _fetchEvents();
  }

  Future<void> _fetchLocations() async {
    try {
      if (mounted) setState(() => _isLoadingLocations = true);
      final provider = Provider.of<LocationProvider>(context, listen: false);
      final data = await provider.get(filter: {'PageSize': '100'});
      if (mounted) {
        setState(() {
          _locations = data.result;
          _isLoadingLocations = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _fetchEvents() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final provider = Provider.of<EventProvider>(context, listen: false);
      final params = <String, String>{
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
        'IncludeCancelled': 'true',
        'IsUpcoming': 'true',
      };
      if (_searchQuery.length >= 3) params['searchTerm'] = _searchQuery;
      if (_selectedLocationId != null)
        params['LocationId'] = _selectedLocationId.toString();
      if (_dateFrom != null)
        params['EventDateFrom'] = DateFormat('yyyy-MM-dd').format(_dateFrom!);
      if (_dateTo != null)
        params['EventDateTo'] = DateFormat('yyyy-MM-dd').format(_dateTo!);
      if (_minPrice > 0) params['MinPrice'] = _minPrice.toString();
      if (_maxPrice < 500) params['MaxPrice'] = _maxPrice.toString();

      final data = await provider.get(filter: params);
      if (mounted) {
        setState(() {
          _events = data.result;
          _totalPages = data.meta.totalPages;
          _totalCount = data.meta.count ?? 0;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _searchQuery = value.trim());
    if (value.length >= 3 || value.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 450), () {
        setState(() => _currentPage = 1);
        _fetchEvents();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedLocationId = null;
      _dateFrom = null;
      _dateTo = null;
      _minPrice = 0;
      _maxPrice = 500;
      _currentPage = 1;
    });
    _searchController.clear();
    _fetchEvents();
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() => _currentPage = page);
    _fetchEvents();
  }

  Future<void> _cancelEvent(Event event, String reason) async {
    try {
      final provider = Provider.of<EventProvider>(context, listen: false);

      await provider.cancelEvent(event.eventId!, reason);

      if (mounted) {
        AlertHelpers.showSuccess(
          context,
          'Event "${event.eventName}" has been cancelled successfully.',
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        AlertHelpers.showError(context, 'Failed to cancel event: $e');
      }
    }
  }

  void _showEventDetail(Event event) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => _UpcomingEventDetailDialog(
        event: event,
        onCancelWithReason: (reason) => _cancelEvent(event, reason),
      ),
    );
  }

  Future<void> _selectDate(bool isFrom) async {
    DateTime? temp = isFrom
        ? (_dateFrom ?? DateTime.now())
        : (_dateTo ?? DateTime.now().add(const Duration(days: 30)));
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          color: _white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _navyMid,
                    onPrimary: _white,
                    surface: _white,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: temp!,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  onDateChanged: (d) => temp = d,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel', style: TextStyle(color: _t2)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        if (isFrom)
                          _dateFrom = temp;
                        else
                          _dateTo = temp;
                        _currentPage = 1;
                      });
                      _fetchEvents();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navyMid,
                      foregroundColor: _white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
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
            constraints: const BoxConstraints(maxWidth: 1200),
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
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _totalCount > 0
              ? '$_totalCount approved upcoming events'
              : 'Approved upcoming events',
          style: const TextStyle(fontSize: 13, color: _t2),
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
          _buildGrid(),
          if (!_isLoading && _events.isNotEmpty) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final bool hasFilters =
        _searchQuery.isNotEmpty ||
        _selectedLocationId != null ||
        _dateFrom != null ||
        _dateTo != null ||
        _minPrice > 0 ||
        _maxPrice < 500;

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
                width: 220,
                height: 38,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  cursorColor: _navyMid,
                  cursorWidth: 1,
                  style: const TextStyle(fontSize: 13, color: _t1),
                  decoration: InputDecoration(
                    hintText: 'Search events...',
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
          const SizedBox(width: 8),

          _buildLocationDropdown(),
          const SizedBox(width: 8),

          _buildDateChip(
            label: _dateFrom != null
                ? 'From: ${DateFormat('dd/MM').format(_dateFrom!)}'
                : 'From date',
            icon: Icons.calendar_today_rounded,
            active: _dateFrom != null,
            onTap: () => _selectDate(true),
            onClear: _dateFrom != null
                ? () {
                    setState(() {
                      _dateFrom = null;
                      _currentPage = 1;
                    });
                    _fetchEvents();
                  }
                : null,
          ),
          const SizedBox(width: 8),

          _buildDateChip(
            label: _dateTo != null
                ? 'To: ${DateFormat('dd/MM').format(_dateTo!)}'
                : 'To date',
            icon: Icons.calendar_today_rounded,
            active: _dateTo != null,
            onTap: () => _selectDate(false),
            onClear: _dateTo != null
                ? () {
                    setState(() {
                      _dateTo = null;
                      _currentPage = 1;
                    });
                    _fetchEvents();
                  }
                : null,
          ),
          const SizedBox(width: 8),

          _buildPriceDropdown(),
          const SizedBox(width: 8),

          if (hasFilters)
            GestureDetector(
              onTap: _clearFilters,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt_off_rounded, size: 14, color: _t2),
                      SizedBox(width: 5),
                      Text(
                        'Clear',
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

  Widget _buildGrid() {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: _navyMid, strokeWidth: 2),
        ),
      );
    }

    if (_events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 36,
              color: _t2.withOpacity(0.4),
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No events match "$_searchQuery"'
                  : 'No upcoming events found',
              style: const TextStyle(fontSize: 13, color: _t2),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.45,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _events.length,
        itemBuilder: (_, i) => _buildEventCard(_events[i]),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return PopupMenuButton<int?>(
      offset: const Offset(0, 46),
      color: _white,
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _selectedLocationId != null ? const Color(0xFFE8EDFF) : _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedLocationId != null
                ? _navyMid.withOpacity(0.4)
                : _border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: _selectedLocationId != null ? _navyMid : _t2,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedLocationId != null
                  ? (_locations
                            .firstWhere(
                              (l) => l.locationId == _selectedLocationId,
                              orElse: () => _locations.first,
                            )
                            .locationName ??
                        'Location')
                  : 'Location',
              style: TextStyle(
                fontSize: 13,
                color: _selectedLocationId != null ? _navyMid : _t2,
                fontWeight: _selectedLocationId != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: _selectedLocationId != null ? _navyMid : _t2,
            ),
          ],
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: null,
          height: 36,
          onTap: () {
            setState(() {
              _selectedLocationId = null;
              _currentPage = 1;
            });
            _fetchEvents();
          },
          child: const Text(
            'All locations',
            style: TextStyle(fontSize: 13, color: _t2),
          ),
        ),
        ..._locations.map(
          (loc) => PopupMenuItem<int?>(
            value: loc.locationId,
            height: 36,
            onTap: () {
              setState(() {
                _selectedLocationId = loc.locationId;
                _currentPage = 1;
              });
              _fetchEvents();
            },
            child: Text(
              loc.locationName ?? 'N/A',
              style: const TextStyle(fontSize: 13, color: _t1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE8EDFF) : _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? _navyMid.withOpacity(0.4) : _border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: active ? _navyMid : _t2),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: active ? _navyMid : _t2,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close_rounded, size: 12, color: _t2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDropdown() {
    final bool active = _minPrice > 0 || _maxPrice < 500;
    return PopupMenuButton(
      offset: const Offset(0, 46),
      color: _white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE8EDFF) : _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? _navyMid.withOpacity(0.4) : _border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_money_rounded,
              size: 14,
              color: active ? _navyMid : _t2,
            ),
            const SizedBox(width: 4),
            Text(
              active
                  ? '${_minPrice.toInt()} - ${_maxPrice.toInt()} KM'
                  : 'Price Range',
              style: TextStyle(
                fontSize: 13,
                color: active ? _navyMid : _t2,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: active ? _navyMid : _t2,
            ),
          ],
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (ctx, setS) => SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _t1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 500,
                    divisions: 50,
                    activeColor: _navyMid,
                    inactiveColor: _border,
                    labels: RangeLabels(
                      '${_minPrice.toInt()} KM',
                      '${_maxPrice.toInt()} KM',
                    ),
                    onChanged: (v) => setS(() {
                      _minPrice = v.start;
                      _maxPrice = v.end;
                    }),
                    onChangeEnd: (v) {
                      setState(() {
                        _minPrice = v.start;
                        _maxPrice = v.end;
                        _currentPage = 1;
                      });
                      _fetchEvents();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_minPrice.toInt()} KM',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _navyMid,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${_maxPrice.toInt()} KM',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _navyMid,
                            fontSize: 12,
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
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    final isCancelled = event.status?.statusName?.toLowerCase() == 'cancelled';
    final dateStr = event.eventDate != null
        ? DateFormat('dd MMM yyyy').format(event.eventDate!)
        : 'N/A';
    final timeStr = event.eventDate != null
        ? DateFormat('HH:mm').format(event.eventDate!)
        : '';
    final city = event.location?.city?.name ?? '';
    final locName = event.location?.locationName ?? '';
    final fullLoc = city.isNotEmpty && locName.isNotEmpty
        ? '$locName, $city'
        : city.isNotEmpty
        ? city
        : locName;
    final rating = event.performer?.averageRating;
    final performer = event.performer?.artistName ?? '';

    return GestureDetector(
      onTap: () => _showEventDetail(event),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _HoverCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Image.asset(
                        'assets/images/events.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isCancelled)
                      Positioned(
                        top: 8,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _red.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'CANCELLED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    if (rating != null && rating > 0 && !isCancelled)
                      Positioned(
                        top: 8,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E).withOpacity(0.75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: _amber,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            event.eventName ?? 'Event',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (performer.isNotEmpty)
                            Text(
                              performer,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: _t2,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$dateStr  $timeStr',
                            style: const TextStyle(fontSize: 11, color: _t2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: _red,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              fullLoc,
                              style: const TextStyle(fontSize: 11, color: _t2),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          if (event.regularPrice != null)
                            _priceChip(
                              'Regular',
                              event.regularPrice!,
                              _navyMid,
                            ),
                          if (event.vipPrice != null)
                            _priceChip('VIP', event.vipPrice!, _amber),
                          if (event.premiumPrice != null)
                            _priceChip(
                              'Premium',
                              event.premiumPrice!,
                              const Color(0xFF8B5CF6),
                            ),
                        ],
                      ),

                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _navyMid,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: _white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceChip(String label, int price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '$label: $price KM',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final from = ((_currentPage - 1) * _pageSize) + 1;
    final to = ((_currentPage - 1) * _pageSize) + _events.length;

    int start = (_currentPage - 2).clamp(1, _totalPages);
    int end = (start + 4).clamp(1, _totalPages);
    if (end - start < 4) start = (end - 4).clamp(1, _totalPages);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $from–$to of $_totalCount events',
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
              ...List.generate(end - start + 1, (i) {
                final page = start + i;
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
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? _navyMid.withOpacity(0.3) : _border,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? _navyMid.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _hovered ? 16 : 8,
              offset: Offset(0, _hovered ? 6 : 2),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _UpcomingEventDetailDialog extends StatelessWidget {
  final Event event;
  final Function(String reason) onCancelWithReason;

  const _UpcomingEventDetailDialog({
    required this.event,
    required this.onCancelWithReason,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = event.status?.statusName?.toLowerCase() == 'cancelled';
    final isUpcoming = event.eventDate?.isAfter(DateTime.now()) ?? false;
    final dateStr = event.eventDate != null
        ? DateFormat('dd MMM yyyy · HH:mm').format(event.eventDate!)
        : 'N/A';
    final loc = event.location?.locationName ?? event.locationName ?? 'N/A';
    final city = event.location?.city?.name ?? '';
    final fullLoc = city.isNotEmpty ? '$loc, $city' : loc;
    final performer = event.performer;
    final user = performer?.user;
    final hasImage = user?.image != null && user!.image!.isNotEmpty;
    final initials = _initials(user?.firstName, user?.lastName);
    final genres = performer?.genres ?? [];
    final rating = performer?.averageRating;

    return Dialog(
      backgroundColor: _white,
      surfaceTintColor: _white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
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
                      Icons.event_rounded,
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
                        if (performer?.artistName?.isNotEmpty == true)
                          Text(
                            performer!.artistName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isCancelled) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'CANCELLED',
                        style: TextStyle(
                          color: _white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
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

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (performer != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _border, width: 1.5),
                              ),
                              child: ClipOval(
                                child: hasImage
                                    ? ClipOval(
                                        child: ImageHelpers.getImage(
                                          user!.image!,
                                          height: 52,
                                          width: 52,
                                        ),
                                      )
                                    : Container(
                                        color: _navyMid.withOpacity(0.1),
                                        child: Center(
                                          child: Text(
                                            initials,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _navyMid,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          performer.artistName ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _t1,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (rating != null) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF8E1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFFFE082),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 11,
                                                color: Color(0xFFF59E0B),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                rating.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF92400E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (user?.email?.isNotEmpty == true) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          size: 11,
                                          color: _t2,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            user!.email!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: _t2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (user?.phoneNumber?.isNotEmpty ==
                                      true) ...[
                                    const SizedBox(height: 1),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 11,
                                          color: _t2,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          user!.phoneNumber!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _t2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (genres.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: genres
                              .take(5)
                              .map(
                                (g) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _navyMid.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _navyMid.withOpacity(0.18),
                                    ),
                                  ),
                                  child: Text(
                                    g,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _navyMid,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoTile(
                                icon: Icons.calendar_today_rounded,
                                label: 'Date & Time',
                                value: dateStr,
                              ),
                              const SizedBox(height: 6),
                              _infoTile(
                                icon: Icons.location_on_rounded,
                                iconColor: _red,
                                label: 'Location',
                                value: fullLoc,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoTile(
                                icon: Icons.confirmation_number_rounded,
                                iconColor: _navyMid,
                                label: 'Tickets Sold',
                                value: '${event.ticketsSold ?? 0}',
                              ),
                              if (event.createdAt != null) ...[
                                const SizedBox(height: 6),
                                _infoTile(
                                  icon: Icons.access_time_rounded,
                                  label: 'Created',
                                  value: DateFormat(
                                    'dd MMM yyyy',
                                  ).format(event.createdAt!),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _priceChipCard(
                            'Regular',
                            event.regularPrice,
                            Icons.confirmation_number_outlined,
                            const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _priceChipCard(
                            'VIP',
                            event.vipPrice,
                            Icons.star_rounded,
                            _amber,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _priceChipCard(
                            'Premium',
                            event.premiumPrice,
                            Icons.workspace_premium_rounded,
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),

                    if (isCancelled) ...[
                      const SizedBox(height: 12),
                      _noticeBanner(
                        icon: Icons.cancel_rounded,
                        color: _red,
                        text:
                            'This event has been cancelled. All ticket holders have been notified and refunds processed.'
                            '${event.cancellationReason != null && event.cancellationReason!.isNotEmpty ? "\n\nReason: ${event.cancellationReason}" : ""}',
                      ),
                    ] else if (isUpcoming) ...[
                      const SizedBox(height: 12),
                      _noticeBanner(
                        icon: Icons.admin_panel_settings_rounded,
                        color: _amber,
                        text:
                            'Cancelling this event is irreversible. Ensure there is a valid reason before proceeding — all ticket holders will be automatically notified and refunded.',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (!isCancelled && isUpcoming)
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
                          'Keep Event',
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
                        onPressed: () => _showCancelConfirmation(context),
                        icon: const Icon(Icons.cancel_outlined, size: 14),
                        label: const Text(
                          'Cancel Event',
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
    );
  }

  Widget _infoTile({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: iconColor ?? _navyMid.withOpacity(0.6)),
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
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _t1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceChipCard(String label, int? price, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  price != null ? '$price KM' : 'N/A',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noticeBanner({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: color, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    String? _fieldError;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Dialog(
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
                  // ── Header ──────────────────────────────────────────
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
                            'Cancel Event',
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

                  // ── Body ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info banner
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: _red,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This action is irreversible. All ticket holders will be notified and refunded automatically.',
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

                        // Reason label
                        const Text(
                          'Cancellation Reason',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _t1,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Reason text field
                        Container(
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _fieldError != null ? _red : _border,
                              width: _fieldError != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: reasonController,
                            maxLines: 3,
                            cursorColor: _navyMid,
                            cursorWidth: 1.2,
                            style: const TextStyle(fontSize: 13, color: _t1),
                            onChanged: (_) {
                              if (_fieldError != null) {
                                setS(() => _fieldError = null);
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter cancellation reason...',
                              hintStyle: TextStyle(color: _t2, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),

                        // Error text
                        if (_fieldError != null) ...[
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
                                _fieldError!,
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

                  // ── Footer ──────────────────────────────────────────
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
                              'Keep Event',
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
                                  () => _fieldError =
                                      'Cancellation reason is required.',
                                );
                                return;
                              }
                              if (reason.length < 5) {
                                setS(
                                  () => _fieldError =
                                      'Reason must be at least 5 characters.',
                                );
                                return;
                              }
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              onCancelWithReason(reason);
                            },
                            icon: const Icon(Icons.cancel_outlined, size: 14),
                            label: const Text(
                              'Cancel Event',
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
          );
        },
      ),
    );
  }

  String _initials(String? first, String? last) {
    final f = (first?.isNotEmpty == true) ? first![0].toUpperCase() : '';
    final l = (last?.isNotEmpty == true) ? last![0].toUpperCase() : '';
    return '$f$l'.isEmpty ? '?' : '$f$l';
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
