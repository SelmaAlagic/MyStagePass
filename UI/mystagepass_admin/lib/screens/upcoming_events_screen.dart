import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../models/search_result.dart';
import 'dart:async';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<Event> _events = [];
  bool _isLoading = false;
  String _searchQuery = "";
  String _locationQuery = "";
  DateTime? _dateFrom;
  DateTime? _dateTo;
  double _minPrice = 0;
  double _maxPrice = 500;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 6;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      var provider = Provider.of<EventProvider>(context, listen: false);

      var params = {
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
        'Status': 'approved',
        'IsUpcoming': 'true',
      };

      if (_searchQuery.length >= 3) {
        params['searchTerm'] = _searchQuery;
      }

      if (_dateFrom != null) {
        params['EventDateFrom'] = _dateFrom!.toIso8601String();
      }

      if (_dateTo != null) {
        params['EventDateTo'] = _dateTo!.toIso8601String();
      }

      if (_minPrice > 0) {
        params['MinPrice'] = _minPrice.toString();
      }

      if (_maxPrice < 500) {
        params['MaxPrice'] = _maxPrice.toString();
      }

      SearchResult<Event> data = await provider.get(filter: params);

      List<Event> filteredEvents = data.result;
      if (_locationQuery.length >= 3) {
        filteredEvents = filteredEvents.where((event) {
          String cityName = event.location?.city?.name?.toLowerCase() ?? '';
          return cityName.contains(_locationQuery.toLowerCase());
        }).toList();
      }

      if (mounted) {
        setState(() {
          _events = filteredEvents;
          _totalPages = data.meta.totalPages;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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

  void _onLocationChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _locationQuery = query.trim();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _currentPage = 1);
      _fetchEvents();
    });
  }

  Future<void> _selectDateFrom() async {
    final DateTime? picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      fieldHintText: "",
      fieldLabelText: "",
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5865F2),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateFrom = picked;
      });
      setState(() => _currentPage = 1);
      _fetchEvents();
    }
  }

  Future<void> _selectDateTo() async {
    final DateTime? picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      fieldHintText: "",
      fieldLabelText: "",
      context: context,
      initialDate: _dateTo ?? (_dateFrom ?? DateTime.now()),
      firstDate: _dateFrom ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5865F2),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateTo = picked;
      });
      setState(() => _currentPage = 1);
      _fetchEvents();
    }
  }

  void _clearDates() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
    setState(() => _currentPage = 1);
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9DB4FF),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildFilterBar(),
              Expanded(
                child: _events.isEmpty && !_isLoading
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          Expanded(child: _buildEventsGridWithLoader()),
                          _buildPagination(),
                        ],
                      ),
              ),
            ],
          ),
          Positioned(left: 32, bottom: 32, child: _buildBackButton()),
        ],
      ),
    );
  }

  Widget _buildEventsGridWithLoader() {
    return Stack(
      children: [
        Visibility(visible: !_isLoading, child: _buildEventsGrid()),

        if (_isLoading) ...[
          Container(color: Colors.white),

          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 29, 35, 93),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF5865F2),
                              ),
                              value: null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Loading events...",
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Upcoming events",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
              letterSpacing: -0.5,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_outlined),
              iconSize: 32,
              color: const Color(0xFF5865F2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        label: const Text(
          "Back to Event Management",
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
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSearchField(
                  controller: _searchController,
                  hint: "Search by name",
                  icon: Icons.search,
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSearchField(
                  controller: _locationController,
                  hint: "Location",
                  icon: Icons.location_on_outlined,
                  onChanged: _onLocationChanged,
                ),
              ),
              const SizedBox(width: 12),
              _buildDateRangeField(),
              const SizedBox(width: 12),
              _buildPriceField(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF5865F2), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateRangeField() {
    bool hasDate = _dateFrom != null || _dateTo != null;
    String dateText = "";

    if (_dateFrom != null && _dateTo != null) {
      dateText =
          "${DateFormat('dd/MM').format(_dateFrom!)} - ${DateFormat('dd/MM').format(_dateTo!)}";
    } else if (_dateFrom != null) {
      dateText = "From ${DateFormat('dd/MM').format(_dateFrom!)}";
    } else if (_dateTo != null) {
      dateText = "To ${DateFormat('dd/MM').format(_dateTo!)}";
    } else {
      dateText = "Date";
    }

    return Container(
      width: 160,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton(
        offset: const Offset(0, 50),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF5865F2),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  fontSize: 14,
                  color: hasDate ? Colors.black87 : Colors.grey[400],
                  fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasDate)
              InkWell(
                onTap: _clearDates,
                child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
              ),
          ],
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Date Range",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _selectDateFrom();
                          },
                          icon: const Icon(Icons.event, size: 16),
                          label: Text(
                            _dateFrom != null
                                ? DateFormat('dd/MM/yy').format(_dateFrom!)
                                : "From",
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5865F2),
                            side: const BorderSide(color: Color(0xFF5865F2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _selectDateTo();
                          },
                          icon: const Icon(Icons.event, size: 16),
                          label: Text(
                            _dateTo != null
                                ? DateFormat('dd/MM/yy').format(_dateTo!)
                                : "To",
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5865F2),
                            side: const BorderSide(color: Color(0xFF5865F2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    bool hasPrice = _minPrice > 0 || _maxPrice < 500;

    return Container(
      width: 140,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton(
        offset: const Offset(0, 50),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.attach_money, color: Color(0xFF5865F2), size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                hasPrice
                    ? "${_minPrice.toInt()}-${_maxPrice.toInt()} KM"
                    : "Price",
                style: TextStyle(
                  fontSize: 14,
                  color: hasPrice ? Colors.black87 : Colors.grey[400],
                  fontWeight: hasPrice ? FontWeight.w500 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: StatefulBuilder(
              builder: (context, setStatePopup) {
                return SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Price Range",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 500,
                        divisions: 50,
                        activeColor: const Color(0xFF5865F2),
                        inactiveColor: const Color(0xFF9DB4FF),
                        labels: RangeLabels(
                          "${_minPrice.toInt()} KM",
                          "${_maxPrice.toInt()} KM",
                        ),
                        onChanged: (RangeValues values) {
                          setStatePopup(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                        },
                        onChangeEnd: (RangeValues values) {
                          setState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                          setState(() => _currentPage = 1);
                          _fetchEvents();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_minPrice.toInt()} KM",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5865F2),
                              ),
                            ),
                            Text(
                              "${_maxPrice.toInt()} KM",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5865F2),
                              ),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            "No upcoming events found",
            style: TextStyle(
              fontSize: 20,
              color: const Color.fromARGB(255, 234, 230, 230),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters",
            style: TextStyle(
              fontSize: 15,
              color: const Color.fromARGB(255, 231, 230, 230),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 16,
      ),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(_events[index]);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    String dateStr = event.eventDate != null
        ? DateFormat('dd.MM.yyyy.').format(event.eventDate!)
        : "N/A";
    String timeStr = event.eventDate != null
        ? " / " + DateFormat('HH:mm').format(event.eventDate!) + "h"
        : "";
    String location = event.location?.city?.name ?? "N/A";
    String eventLocation = event.location?.locationName ?? "";
    String performerName = event.performer?.artistName ?? "N/A";
    double? rating = event.performer?.averageRating;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF9DB4FF), const Color(0xFF9DB4FF)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/NoProfileImage.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        rating?.toStringAsFixed(1) ?? "N/A",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    performerName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr + timeStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 13, color: Colors.red[600]),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          eventLocation.isNotEmpty
                              ? "$eventLocation, $location"
                              : location,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: RotatedBox(
              quarterTurns: 1,
              child: SvgPicture.asset(
                'assets/svg/barcode.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}

class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    final patterns = [
      (1.0, 2.0),
      (3.0, 1.5),
      (2.0, 2.5),
      (1.5, 1.0),
      (4.0, 3.0),
      (2.0, 1.5),
      (1.0, 2.0),
      (3.0, 1.0),
      (2.5, 2.0),
      (1.5, 3.0),
      (3.0, 1.5),
      (2.0, 2.5),
      (4.0, 1.0),
      (1.0, 2.0),
      (2.0, 1.5),
      (3.0, 2.0),
      (1.5, 1.0),
      (2.5, 3.0),
      (1.0, 1.5),
      (3.0, 2.0),
      (2.0, 1.0),
      (4.0, 2.5),
      (1.5, 2.0),
      (2.0, 1.5),
      (3.0, 1.0),
    ];

    double currentY = size.height * 0.1;

    for (var pattern in patterns) {
      if (currentY >= size.height * 0.9) break;

      final strokeWidth = pattern.$1;
      final spacing = pattern.$2 * 1.5;

      paint.strokeWidth = strokeWidth;

      canvas.drawLine(
        Offset(size.width * 0.1, currentY),
        Offset(size.width * 0.9, currentY),
        paint,
      );

      currentY += spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
