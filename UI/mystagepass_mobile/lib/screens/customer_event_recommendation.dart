import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystagepass_mobile/models/EventRecommendation/recommendations.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/location_provider.dart';
import '../models/City/city.dart';
import '../widgets/bottom_nav_bar.dart';

class RecommendedEventsScreen extends StatefulWidget {
  final int userId;

  const RecommendedEventsScreen({super.key, required this.userId});

  @override
  State<RecommendedEventsScreen> createState() =>
      _RecommendedEventsScreenState();
}

class _RecommendedEventsScreenState extends State<RecommendedEventsScreen> {
  List<Recommendations> _recommendations = [];
  List<Recommendations> _filteredRecommendations = [];
  int _totalCount = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _filtersVisible = false;

  City? _selectedCity;
  List<City> _availableCities = [];

  DateTime? _dateFrom;
  DateTime? _dateTo;

  final double _minPrice = 0;
  final double _maxPrice = 500;
  double _currentMin = 0;
  double _currentMax = 500;

  final GlobalKey _cityKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final provider = Provider.of<LocationProvider>(context, listen: false);
      final result = await provider.get(filter: {'pageSize': 1000});
      final cityMap = <int, City>{};
      for (var loc in result.result) {
        if (loc.city != null && loc.city!.cityID != null) {
          cityMap[loc.city!.cityID!] = loc.city!;
        }
      }
      final cities = cityMap.values.toList()
        ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      setState(() => _availableCities = cities);
    } catch (_) {}
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final provider = Provider.of<RecommendationProvider>(
        context,
        listen: false,
      );
      final result = await provider.getRecommendations();
      setState(() {
        _recommendations = result;
      });
      _applyFilters();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load recommendations";
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = List<Recommendations>.from(_recommendations);

    if (_selectedCity != null) {
      filtered = filtered
          .where((r) => r.cityName == _selectedCity!.name)
          .toList();
    }

    if (_dateFrom != null) {
      final startOfDay = DateTime(
        _dateFrom!.year,
        _dateFrom!.month,
        _dateFrom!.day,
      );
      filtered = filtered.where((r) {
        if (r.eventDate == null) return false;
        return !r.eventDate!.isBefore(startOfDay);
      }).toList();
    }

    if (_dateTo != null) {
      final endOfDay = _dateTo!.add(const Duration(days: 1));
      filtered = filtered.where((r) {
        if (r.eventDate == null) return false;
        return r.eventDate!.isBefore(endOfDay);
      }).toList();
    }

    if (_currentMin > _minPrice || _currentMax < _maxPrice) {
      filtered = filtered.where((r) {
        final prices = [
          r.ticketPrices?['Regular'],
          r.ticketPrices?['VIP'],
          r.ticketPrices?['Premium'],
        ].whereType<int>();
        if (prices.isEmpty) return true;
        return prices.any((p) => p >= _currentMin && p <= _currentMax);
      }).toList();
    }

    setState(() {
      _filteredRecommendations = filtered;
      _totalCount = filtered.length;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _dateFrom = null;
      _dateTo = null;
      _currentMin = _minPrice;
      _currentMax = _maxPrice;
    });
    _applyFilters();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_dateFrom ?? DateTime.now())
          : (_dateTo ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2020),
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

  void _showCityDropdown() async {
    final RenderBox? buttonBox =
        _cityKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final offset = buttonBox.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + buttonBox.size.height,
        offset.dx + buttonBox.size.width,
        0,
      ),
      elevation: 8,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return SizedBox(
                width: buttonBox.size.width,
                height: 220,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _availableCities.length,
                        itemBuilder: (ctx, index) {
                          final city = _availableCities[index];
                          final isSelected =
                              _selectedCity?.cityID == city.cityID;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedCity = city);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              color: isSelected
                                  ? const Color(0xFF1D235D).withOpacity(0.07)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_city_rounded,
                                    size: 16,
                                    color: isSelected
                                        ? const Color(0xFF1D235D)
                                        : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      city.name ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? const Color(0xFF1D235D)
                                            : const Color(0xFF1D2939),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Color(0xFF1D235D),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Color(0xFF1D235D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        selected: NavItem.home,
        userId: widget.userId,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
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
                      "Recommended For You",
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
                              "Filter",
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
                      GestureDetector(
                        key: _cityKey,
                        onTap: _showCityDropdown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEAECF0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_city_rounded,
                                color: Color(0xFF1D235D),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedCity?.name ?? "Select city",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _selectedCity != null
                                        ? const Color(0xFF1D2939)
                                        : Colors.grey[400],
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF1D235D),
                              ),
                            ],
                          ),
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
                          overlayColor: const Color(
                            0xFF1D235D,
                          ).withOpacity(0.15),
                          rangeTickMarkShape:
                              const RoundRangeSliderTickMarkShape(
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
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
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D235D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Apply Filters",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
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
                              onPressed: _loadRecommendations,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D235D),
                              ),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : _filteredRecommendations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1D235D,
                                ).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.recommend_rounded,
                                size: 44,
                                color: Color(0xFF1D235D),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "No recommendations yet",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Buy tickets or save events to get personalized recommendations",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1D235D),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRecommendations,
                        color: const Color(0xFF1D235D),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                          itemCount: _filteredRecommendations.length,
                          itemBuilder: (context, index) =>
                              _buildRecommendationCard(
                                _filteredRecommendations[index],
                              ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Recommendations rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 110),
                    child: Text(
                      rec.eventName ?? 'Unknown Event',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 13,
                        color: Color(0xFF1D235D),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          rec.performerName ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1D235D),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rec.eventDate != null
                            ? DateFormat('dd MMM yyyy').format(rec.eventDate!)
                            : 'Unknown Date',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: Color(0xFFE53935),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          rec.cityName ?? 'Unknown City',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Color(0xFFEEEEEE),
                    height: 1,
                    thickness: 1,
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _priceChip(
                          "Regular",
                          rec.ticketPrices?['Regular'],
                          const Color(0xFF1D235D),
                        ),
                        const SizedBox(width: 6),
                        _priceChip(
                          "VIP",
                          rec.ticketPrices?['VIP'],
                          const Color(0xFF6A1B9A),
                        ),
                        const SizedBox(width: 6),
                        _priceChip(
                          "Premium",
                          rec.ticketPrices?['Premium'],
                          const Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.recommend_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Recommended",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceChip(String label, int? price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        "$label: ${price != null ? '$price KM' : '—'}",
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
