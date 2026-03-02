import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystagepass_mobile/providers/event_provider.dart';
import 'package:provider/provider.dart';
import '../models/Location/location.dart';
import '../models/City/city.dart';
import '../models/search_result.dart';
import '../providers/location_provider.dart';

class AddEventScreen extends StatefulWidget {
  final int userId;

  const AddEventScreen({super.key, required this.userId});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _cityKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _regularController = TextEditingController();
  final _vipController = TextEditingController();
  final _premiumController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  City? _selectedCity;
  Location? _selectedLocation;

  List<Location> _allLocations = [];
  List<City> _cities = [];
  List<Location> _filteredLocations = [];

  bool _isLoadingLocations = true;
  bool _isSubmitting = false;

  final Color _darkBlue = const Color(0xFF1D235D);
  final Color _darkText = const Color(0xFF1D2939);

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final provider = Provider.of<LocationProvider>(context, listen: false);
      SearchResult<Location> result = await provider.get(
        filter: {'pageSize': 1000},
      );
      final locations = result.result;

      final cityMap = <int, City>{};
      for (var loc in locations) {
        if (loc.city != null && loc.city!.cityID != null) {
          cityMap[loc.city!.cityID!] = loc.city!;
        }
      }

      setState(() {
        _allLocations = locations;
        _cities = cityMap.values.toList();
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
    }
  }

  void _onCitySelected(City city) {
    setState(() {
      _selectedCity = city;
      _selectedLocation = null;
      _filteredLocations = _allLocations
          .where((loc) => loc.city?.cityID == city.cityID)
          .toList();
    });
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
                        itemCount: _cities.length,
                        itemBuilder: (ctx, index) {
                          final city = _cities[index];
                          final isSelected =
                              _selectedCity?.cityID == city.cityID;
                          return InkWell(
                            onTap: () {
                              _onCitySelected(city);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              color: isSelected
                                  ? _darkBlue.withOpacity(0.07)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_city_rounded,
                                    size: 16,
                                    color: isSelected
                                        ? _darkBlue
                                        : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      city.name ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? _darkBlue
                                            : _darkText,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: _darkBlue,
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
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: _darkBlue,
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

  void _showLocationDropdown() async {
    if (_selectedCity == null) return;

    final RenderBox? buttonBox =
        _locationKey.currentContext?.findRenderObject() as RenderBox?;
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
                child: _filteredLocations.isEmpty
                    ? Center(
                        child: Text(
                          "No locations in this city",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _filteredLocations.length,
                              itemBuilder: (ctx, index) {
                                final loc = _filteredLocations[index];
                                final isSelected =
                                    _selectedLocation?.locationID ==
                                    loc.locationID;
                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedLocation = loc);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    color: isSelected
                                        ? _darkBlue.withOpacity(0.07)
                                        : Colors.transparent,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 16,
                                          color: isSelected
                                              ? _darkBlue
                                              : Colors.grey[500],
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                loc.locationName ?? '',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isSelected
                                                      ? _darkBlue
                                                      : _darkText,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              if (loc.address != null)
                                                Text(
                                                  loc.address!,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: _darkBlue,
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
                            child: Text(
                              "Done",
                              style: TextStyle(
                                color: _darkBlue,
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE8F5E9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      _showErrorSnackbar("Please select event date and time.");
      return;
    }

    if (_selectedLocation == null) {
      _showErrorSnackbar("Please select a location.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = Provider.of<EventProvider>(context, listen: false);

      final eventDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await provider.insert({
        'eventName': _nameController.text,
        'description': _descriptionController.text,
        'regularPrice': int.parse(_regularController.text),
        'vipPrice': int.parse(_vipController.text),
        'premiumPrice': int.parse(_premiumController.text),
        'eventDate': eventDate.toIso8601String(),
        'locationID': _selectedLocation!.locationID,
      });

      if (!mounted) return;
      _showSuccessSnackbar("Event submitted for approval!");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar("Failed to create event. Please try again.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _regularController.dispose();
    _vipController.dispose();
    _premiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF5F6F8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  Text(
                    "Add New Event",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _darkBlue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _darkBlue.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: _darkBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Your event will be reviewed by an admin before going live.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader("Event Info"),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _nameController,
                        label: "Event Name",
                        icon: Icons.event_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return "Event name is required";
                          if (v.length < 5) return "Minimum 5 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _descriptionController,
                        label: "Description",
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return "Description is required";
                          if (v.length < 10) return "Minimum 10 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader("Date & Time"),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: _darkBlue,
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null)
                            setState(() => _selectedDate = picked);
                        },
                        child: _buildPickerContainer(
                          icon: Icons.calendar_today_rounded,
                          label: "Event Date",
                          value: _selectedDate != null
                              ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                              : null,
                          placeholder: "Select date",
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: _darkBlue,
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null)
                            setState(() => _selectedTime = picked);
                        },
                        child: _buildPickerContainer(
                          icon: Icons.access_time_rounded,
                          label: "Event Time",
                          value: _selectedTime?.format(context),
                          placeholder: "Select time",
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader("Location"),
                      const SizedBox(height: 14),

                      _isLoadingLocations
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFEAECF0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      color: _darkBlue,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Loading...",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
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
                                      border: Border.all(
                                        color: const Color(0xFFEAECF0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_city_rounded,
                                          color: _darkBlue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _selectedCity?.name ??
                                                "Select city",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _selectedCity != null
                                                  ? _darkText
                                                  : Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: _darkBlue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                GestureDetector(
                                  key: _locationKey,
                                  onTap: _selectedCity != null
                                      ? _showLocationDropdown
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedCity != null
                                          ? Colors.white
                                          : const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFEAECF0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: _selectedCity != null
                                              ? _darkBlue
                                              : Colors.grey[400],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _selectedLocation?.locationName ??
                                                (_selectedCity != null
                                                    ? "Select location"
                                                    : "Select city first"),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _selectedLocation != null
                                                  ? _darkText
                                                  : Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: _selectedCity != null
                                              ? _darkBlue
                                              : Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (_selectedLocation != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _darkBlue.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _darkBlue.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline_rounded,
                                          color: _darkBlue,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Capacity: ${_selectedLocation!.capacity ?? '—'} people",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _darkBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (_selectedLocation!.address !=
                                            null) ...[
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.place_outlined,
                                            color: _darkBlue,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _selectedLocation!.address!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _darkBlue,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                      const SizedBox(height: 24),

                      _buildSectionHeader("Ticket Prices"),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceField(
                              controller: _regularController,
                              label: "Regular",
                              color: _darkBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPriceField(
                              controller: _vipController,
                              label: "VIP",
                              color: const Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPriceField(
                              controller: _premiumController,
                              label: "Premium",
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkBlue,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "Submit for Approval",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _darkBlue,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Color(0xFFEAECF0), thickness: 1)),
      ],
    );
  }

  Widget _buildPickerContainer({
    required IconData icon,
    required String label,
    required String? value,
    required String placeholder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _darkBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value ?? placeholder,
                  style: TextStyle(
                    fontSize: 14,
                    color: value != null ? _darkText : Colors.grey[400],
                    fontWeight: value != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14, color: _darkText),
      cursorColor: _darkBlue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF98A2B3)),
        floatingLabelStyle: TextStyle(color: _darkBlue),
        prefixIcon: Icon(icon, color: _darkBlue, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB71C1C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
      cursorColor: color,
      validator: (v) {
        if (v == null || v.isEmpty) return "Required";
        if (int.tryParse(v) == null) return "Invalid";
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: color),
        floatingLabelStyle: TextStyle(color: color),
        suffixText: "KM",
        suffixStyle: TextStyle(fontSize: 11, color: color.withOpacity(0.6)),
        filled: true,
        fillColor: color.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB71C1C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
        ),
      ),
    );
  }
}
