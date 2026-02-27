import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/Event/event.dart';
import '../providers/event_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class UpcomingEventsScreen extends StatefulWidget {
  final int userId;

  const UpcomingEventsScreen({super.key, required this.userId});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<Event> _events = [];
  int _totalCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  final _searchController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  final double _minPrice = 0;
  final double _maxPrice = 500;
  double _currentMin = 0;
  double _currentMax = 500;
  bool _filtersVisible = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favProvider = Provider.of<FavoriteProvider>(context, listen: false);
      if (favProvider.favorites.isEmpty) {
        favProvider.fetchFavorites();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final filter = {
        'isUpcoming': true,
        'status': 'Approved',
        if (_searchController.text.isNotEmpty)
          'searchTerm': _searchController.text,
        if (_dateFrom != null) 'eventDateFrom': _dateFrom!.toIso8601String(),
        if (_dateTo != null) 'eventDateTo': _dateTo!.toIso8601String(),
        if (_currentMin > 0) 'minPrice': _currentMin,
        if (_currentMax < _maxPrice) 'maxPrice': _currentMax,
      };

      final result = await eventProvider.get(filter: filter);
      final sorted = result.result
        ..sort(
          (a, b) => (a.eventDate ?? DateTime(9999)).compareTo(
            b.eventDate ?? DateTime(9999),
          ),
        );

      setState(() {
        _events = sorted;
        _totalCount = result.meta.count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load events";
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_dateFrom ?? DateTime.now())
          : (_dateTo ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D235D),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom)
          _dateFrom = picked;
        else
          _dateTo = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _dateFrom = null;
      _dateTo = null;
      _currentMin = _minPrice;
      _currentMax = _maxPrice;
    });
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        selected: NavItem.home,
        userId: widget.userId,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF5F6F8),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1D235D),
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Upcoming Events",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  if (_totalCount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      "· $_totalCount ${_totalCount == 1 ? 'event' : 'events'}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _filtersVisible = !_filtersVisible),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _filtersVisible
                            ? const Color(0xFF1D235D)
                            : const Color(0xFFE8EAF2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 15,
                            color: _filtersVisible
                                ? Colors.white
                                : const Color(0xFF1D235D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Filters",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _filtersVisible
                                  ? Colors.white
                                  : const Color(0xFF1D235D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_filtersVisible)
              Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        textSelectionTheme: const TextSelectionThemeData(
                          cursorColor: Color(0xFF1D235D),
                          selectionColor: Color(0xFFBBCBF5),
                          selectionHandleColor: Color(0xFF1D235D),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        cursorColor: const Color(0xFF1D235D),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2D3142),
                        ),
                        decoration: InputDecoration(
                          hintText: "Search by name or location...",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF1D235D),
                              width: 1,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _loadEvents(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _dateFrom != null
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_dateFrom!)
                                        : "From date",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _dateFrom != null
                                          ? const Color(0xFF2D3142)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _dateTo != null
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_dateTo!)
                                        : "To date",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _dateTo != null
                                          ? const Color(0xFF2D3142)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_dateFrom != null || _dateTo != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _dateFrom = null;
                                _dateTo = null;
                              }),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price range",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${_currentMin.toInt()} - ${_currentMax.toInt()} KM",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D235D),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF1D235D),
                        inactiveTrackColor: const Color(0xFFE8EAF2),
                        thumbColor: const Color(0xFF1D235D),
                        overlayColor: const Color(0xFF1D235D).withOpacity(0.15),
                        rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
                          tickMarkRadius: 0,
                        ),
                      ),
                      child: RangeSlider(
                        values: RangeValues(_currentMin, _currentMax),
                        min: _minPrice,
                        max: _maxPrice,
                        divisions: 50,
                        onChanged: (values) => setState(() {
                          _currentMin = values.start;
                          _currentMax = values.end;
                        }),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Clear",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: _loadEvents,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D235D),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Apply Filters",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1D235D),
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEvents,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D235D),
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  : _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D235D).withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_busy_rounded,
                              size: 56,
                              color: Color(0xFF1D235D),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "No upcoming events",
                            style: TextStyle(
                              color: Color(0xFF1D235D),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Try adjusting your filters",
                            style: TextStyle(
                              color: Color(0xFF1D235D),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      color: const Color(0xFF1D235D),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(25, 14, 25, 24),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          return Consumer<FavoriteProvider>(
                            builder: (context, favProvider, _) {
                              final isFavorited = favProvider.favorites.any(
                                (f) =>
                                    f.event?.eventID == _events[index].eventID,
                              );
                              return _buildEventCard(
                                _events[index],
                                isFavorited,
                                favProvider,
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
    Event event,
    bool isFavorited,
    FavoriteProvider favProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/my-events.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: event.performer?.user?.image != null
                            ? Image.memory(
                                base64Decode(event.performer!.user!.image!),
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/NoProfileImage.png',
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.eventName ?? "Event",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 4),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    event.performer?.artistName ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (event.ratingAverage != null &&
                                    event.ratingAverage! > 0) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    event.ratingAverage!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(width: 8),
                                  const Text(
                                    "no ratings",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (isFavorited) {
                            final fav = favProvider.favorites.firstWhere(
                              (f) => f.event?.eventID == event.eventID,
                            );
                            await favProvider.removeFavorite(
                              fav.customerFavoriteEventID!,
                            );
                          } else {
                            await favProvider.addFavorite(event.eventID!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorited
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorited ? Colors.red : Colors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today_rounded,
                              Colors.grey[400]!,
                              event.eventDate != null
                                  ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(event.eventDate!)
                                  : "Date TBA",
                            ),
                            const SizedBox(height: 5),
                            _buildInfoRow(
                              Icons.access_time_rounded,
                              Colors.grey[400]!,
                              event.eventDate != null
                                  ? DateFormat('HH:mm').format(event.eventDate!)
                                  : "Time TBA",
                            ),
                            if (event.location?.locationName != null) ...[
                              const SizedBox(height: 5),
                              _buildInfoRow(
                                Icons.location_on_rounded,
                                const Color(0xFFE53935),
                                event.location!.locationName!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Table(
                          defaultColumnWidth: const IntrinsicColumnWidth(),
                          children: [
                            _buildPriceRow("Premium", event.premiumPrice),
                            _buildPriceRow("VIP", event.vipPrice),
                            _buildPriceRow("Regular", event.regularPrice),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.shopping_cart_rounded,
                            size: 15,
                          ),
                          label: const Text(
                            "Buy Tickets",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 14,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  TableRow _buildPriceRow(String label, int? price) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 4),
          child: Text(
            "$label:",
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          price != null ? "$price KM" : "—",
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
