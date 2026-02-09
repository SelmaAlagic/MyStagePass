import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../models/search_result.dart';
import '../models/Location/location.dart';
import '../providers/location_provider.dart';
import 'dart:async';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

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
      if (mounted) {
        setState(() {
          _isLoadingLocations = true;
        });
      }

      var locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      var params = {'PageSize': '100'};
      var locationsData = await locationProvider.get(filter: params);

      if (mounted) {
        setState(() {
          _locations = locationsData.result;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
      }
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

    if (mounted) {
      setState(() => _isLoading = true);
    }

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

      if (_selectedLocationId != null) {
        params['LocationId'] = _selectedLocationId.toString();
      }

      if (_dateFrom != null) {
        params['EventDateFrom'] = DateFormat('yyyy-MM-dd').format(_dateFrom!);
      }

      if (_dateTo != null) {
        params['EventDateTo'] = DateFormat('yyyy-MM-dd').format(_dateTo!);
      }

      if (_minPrice > 0) {
        params['MinPrice'] = _minPrice.toString();
      }

      if (_maxPrice < 500) {
        params['MaxPrice'] = _maxPrice.toString();
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
      debugPrint("Error fetching events: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _searchQuery = query.trim();
    });

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
                      initialDate: tempDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (date) {
                        tempDate = date;
                      },
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
                      initialDate: tempDate,
                      firstDate: _dateFrom ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (date) {
                        tempDate = date;
                      },
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildFilters(),
                ],
              ),
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildSearchHint(),
                      ),

                    Expanded(child: _buildEventsContent()),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_events.isNotEmpty) _buildPagination(),
                  const SizedBox(height: 20),
                  _buildBottomButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsContent() {
    if (_isLoading) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(40),
          child: const CircularProgressIndicator(
            color: Color.fromARGB(255, 29, 35, 93),
          ),
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(child: _buildEmptyState());
    }

    return _buildEventsGrid();
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.upcoming_rounded, size: 36, color: Colors.white),
            SizedBox(width: 12),
            Text(
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Row(
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
                                onTap: () {
                                  _onLocationChanged(location.locationId);
                                },
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
                        if (value != null) {
                          _onLocationChanged(value);
                        }
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
            decoration: BoxDecoration(
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
      constraints: const BoxConstraints(maxWidth: 1200),
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
              "Enter at least 3 characters to search by event name",
              style: TextStyle(fontSize: 12, color: Colors.orange[800]),
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
          Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty && _searchQuery.length >= 3
                ? "No events found for '$_searchQuery'"
                : "No upcoming events found",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid() {
    return GridView.builder(
      shrinkWrap: false,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.8,
        crossAxisSpacing: 24,
        mainAxisSpacing: 20,
      ),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(_events[index]);
      },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 29, 35, 93),
                  Color.fromARGB(255, 50, 60, 130),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
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
                          size: 35,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color.fromARGB(255, 29, 35, 93),
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    performerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 29, 35, 93),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "$dateStr at $timeStr",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.red[600]),
                      const SizedBox(width: 5),
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
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 3,
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
          ),

          Container(
            width: 50,
            margin: const EdgeInsets.only(right: 5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: RotatedBox(
              quarterTurns: 1,
              child: SizedBox(
                height: 85,
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: 'EVENT${event.eventId ?? 0}',
                  drawText: false,
                  color: Colors.black,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip(String label, int price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 29, 35, 93).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 29, 35, 93),
          width: 1,
        ),
      ),
      child: Text(
        "$label: $price KM",
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 29, 35, 93),
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Align(
        alignment: Alignment.centerLeft,
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
      ),
    );
  }
}
