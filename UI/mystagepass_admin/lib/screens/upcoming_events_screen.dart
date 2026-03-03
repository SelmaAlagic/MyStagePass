import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../models/search_result.dart';
import '../models/Location/location.dart';
import '../providers/location_provider.dart';
import 'dart:async';
import '../widgets/base_layout.dart';

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
  String _searchQuery = "";
  int? _selectedLocationId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  double _minPrice = 0;
  double _maxPrice = 500;

  int _currentPage = 1;
  int _totalPages = 1;
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
      var locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      var locationsData = await locationProvider.get(
        filter: {'PageSize': '100'},
      );
      if (mounted) {
        setState(() {
          _locations = locationsData.result;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _fetchEvents() async {
    if (_searchQuery.isNotEmpty && _searchQuery.length < 3) {
      if (mounted) {
        setState(() {
          _events = [];
          _currentPage = 1;
          _totalPages = 1;
          _hasPrevious = false;
          _hasNext = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      var provider = Provider.of<EventProvider>(context, listen: false);

      var params = {
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
        'Status': 'approved',
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
      debugPrint("Error fetching events: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() => _searchQuery = query.trim());
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _currentPage = 1);
      _fetchEvents();
    });
  }

  void _onLocationChanged(int? locationId) {
    if (!mounted) return;
    setState(() {
      _selectedLocationId = locationId;
      _currentPage = 1;
    });
    _fetchEvents();
  }

  Future<void> _selectDateFrom() async {
    DateTime? tempDate = _dateFrom ?? DateTime.now();
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 300,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color.fromARGB(255, 29, 35, 93),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: tempDate!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (date) => tempDate = date,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            29,
                            35,
                            93,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _dateFrom = tempDate;
                            _currentPage = 1;
                          });
                          _fetchEvents();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            29,
                            35,
                            93,
                          ),
                          foregroundColor: Colors.white,
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
      },
    );
  }

  Future<void> _selectDateTo() async {
    DateTime? tempDate = _dateTo ?? (_dateFrom ?? DateTime.now());
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 300,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color.fromARGB(255, 29, 35, 93),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: tempDate!,
                      firstDate: _dateFrom ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (date) => tempDate = date,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            29,
                            35,
                            93,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _dateTo = tempDate;
                            _currentPage = 1;
                          });
                          _fetchEvents();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            29,
                            35,
                            93,
                          ),
                          foregroundColor: Colors.white,
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
      },
    );
  }

  void _clearDates() {
    if (!mounted) return;
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _currentPage = 1;
    });
    _fetchEvents();
  }

  void _clearFilters() {
    if (!mounted) return;
    setState(() {
      _searchQuery = "";
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

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      userId: widget.userId,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 5, 40, 0),
            child: _buildHeader(),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 24, 40, 8),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 29, 35, 93),
                      ),
                    )
                  : _events.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _events.length,
                      itemBuilder: (context, index) =>
                          _buildEventCard(_events[index]),
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(40, 8, 40, 50),
            child: Column(
              children: [
                if (_events.isNotEmpty) _buildPagination(),
                const SizedBox(height: 12),
                _buildBottomButton(),
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
          children: [
            const Icon(Icons.event, size: 36, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              "Upcoming Events",
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
              hintText: "Search by event name",
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
          child: _isLoadingLocations
              ? const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color.fromARGB(255, 29, 35, 93),
                    ),
                  ),
                )
              : Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbColor: MaterialStateProperty.all(Colors.grey),
                      thickness: MaterialStateProperty.all(8),
                      radius: const Radius.circular(4),
                    ),
                  ),
                  child: PopupMenuButton<int?>(
                    offset: const Offset(0, 45),
                    color: Colors.white,
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      maxHeight: 220,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLocationId != null
                              ? _locations
                                        .firstWhere(
                                          (loc) =>
                                              loc.locationId ==
                                              _selectedLocationId,
                                          orElse: () => _locations.first,
                                        )
                                        .locationName ??
                                    "Location"
                              : "Location",
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedLocationId != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                    itemBuilder: (context) => _locations
                        .map(
                          (location) => PopupMenuItem<int?>(
                            value: location.locationId,
                            height: 36,
                            child: InkWell(
                              onTap: () =>
                                  _onLocationChanged(location.locationId),
                              hoverColor: Colors.grey.shade300,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text(
                                  location.locationName ?? "N/A",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onSelected: (value) {
                      if (value != null) _onLocationChanged(value);
                    },
                  ),
                ),
        ),
        const SizedBox(width: 10),
        _buildDateRangeField(),
        const SizedBox(width: 10),
        _buildPriceField(),
        const SizedBox(width: 10),
        Container(
          height: 35,
          width: 35,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off, size: 18),
            tooltip: "Clear all filters",
            padding: EdgeInsets.zero,
            color: const Color.fromARGB(255, 29, 35, 93),
          ),
        ),
      ],
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
      dateText = "Date Range";
    }

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton(
        offset: const Offset(0, 40),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 13,
                color: hasDate ? Colors.black : Colors.grey,
                fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (hasDate) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: _clearDates,
                child: const Icon(Icons.close, size: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Date Range",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color.fromARGB(255, 29, 35, 93),
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
                          icon: const Icon(Icons.event, size: 14),
                          label: Text(
                            _dateFrom != null
                                ? DateFormat('dd/MM/yy').format(_dateFrom!)
                                : "From",
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color.fromARGB(
                              255,
                              29,
                              35,
                              93,
                            ),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 29, 35, 93),
                            ),
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
                          icon: const Icon(Icons.event, size: 14),
                          label: Text(
                            _dateTo != null
                                ? DateFormat('dd/MM/yy').format(_dateTo!)
                                : "To",
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color.fromARGB(
                              255,
                              29,
                              35,
                              93,
                            ),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 29, 35, 93),
                            ),
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
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton(
        offset: const Offset(0, 40),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_money, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              hasPrice
                  ? "${_minPrice.toInt()}-${_maxPrice.toInt()} KM"
                  : "Price Range",
              style: TextStyle(
                fontSize: 13,
                color: hasPrice ? Colors.black : Colors.grey,
                fontWeight: hasPrice ? FontWeight.w500 : FontWeight.normal,
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
                          fontSize: 14,
                          color: Color.fromARGB(255, 29, 35, 93),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 500,
                        divisions: 50,
                        activeColor: const Color.fromARGB(255, 29, 35, 93),
                        inactiveColor: Colors.grey.shade300,
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
                              "${_minPrice.toInt()} KM",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 29, 35, 93),
                              ),
                            ),
                            Text(
                              "${_maxPrice.toInt()} KM",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 29, 35, 93),
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

  Widget _buildSearchHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            "Enter at least 3 characters to search by event name",
            style: TextStyle(fontSize: 12, color: Colors.orange[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        _searchQuery.isNotEmpty && _searchQuery.length >= 3
            ? "No events found for '$_searchQuery'"
            : "No upcoming events",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    String dateStr = event.eventDate != null
        ? DateFormat('dd MMM yyyy').format(event.eventDate!)
        : "N/A";
    String timeStr = event.eventDate != null
        ? DateFormat('HH:mm').format(event.eventDate!)
        : "N/A";
    String location = event.location?.city?.name ?? "N/A";
    String eventLocation = event.location?.locationName ?? "";
    String performerName =
        event.performer?.artistName ?? event.eventName ?? "N/A";
    double? rating = event.performer?.averageRating;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/events.jpg', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.eventName ?? "Event",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 4),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (rating != null) ...[
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (performerName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        performerName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "$dateStr at $timeStr",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: Color(0xFFE53935),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          eventLocation.isNotEmpty
                              ? "$eventLocation, $location"
                              : location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (event.regularPrice != null)
                        _buildPriceChip("Regular", event.regularPrice!),
                      if (event.vipPrice != null)
                        _buildPriceChip("VIP", event.vipPrice!),
                      if (event.premiumPrice != null)
                        _buildPriceChip("Premium", event.premiumPrice!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, int price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white54, width: 1),
      ),
      child: Text(
        "$label: $price KM",
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
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

  Widget _buildBottomButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        label: const Text(
          "Back",
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
}
