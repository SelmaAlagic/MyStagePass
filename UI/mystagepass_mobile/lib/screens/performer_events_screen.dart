import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mystagepass_mobile/providers/event_provider.dart';
import 'package:provider/provider.dart';
import '../models/Event/event.dart';
import '../providers/performer_provider.dart';
import '../widgets/performer_nav_bar.dart';

class PerformerEventsScreen extends StatefulWidget {
  final int userId;

  const PerformerEventsScreen({super.key, required this.userId});

  @override
  State<PerformerEventsScreen> createState() => _PerformerEventsScreenState();
}

class _PerformerEventsScreenState extends State<PerformerEventsScreen> {
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  int _totalCount = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _filtersVisible = false;

  String _selectedStatus = 'All';
  String _selectedTime = 'All';

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  Future<void> _loadMyEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<PerformerProvider>(context, listen: false);
      final result = await provider.getMyEvents();

      if (!mounted) return;
      setState(() {
        _events = result.result;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load your events";
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Event> filtered = List.from(_events);

    if (_selectedStatus != 'All') {
      filtered = filtered
          .where(
            (e) =>
                (e.status?.statusName ?? '').toLowerCase() ==
                _selectedStatus.toLowerCase(),
          )
          .toList();
    }

    if (_selectedTime == 'Upcoming') {
      filtered = filtered
          .where(
            (e) => e.eventDate != null && e.eventDate!.isAfter(DateTime.now()),
          )
          .toList();
    } else if (_selectedTime == 'Ended') {
      filtered = filtered
          .where(
            (e) => e.eventDate != null && e.eventDate!.isBefore(DateTime.now()),
          )
          .toList();
    }

    _filteredEvents = filtered;
    _totalCount = filtered.length;
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = 'All';
      _selectedTime = 'All';
      _applyFilters();
    });
  }

  void _updateEventLocally(Event updatedEvent) {
    setState(() {
      final index = _events.indexWhere(
        (e) => e.eventID == updatedEvent.eventID,
      );
      if (index != -1) {
        _events[index] = updatedEvent;
      }
      _applyFilters();
    });
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

  void _showEditModal(BuildContext context, Event event) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: event.eventName ?? '');
    final descriptionController = TextEditingController(
      text: event.description ?? '',
    );
    final regularController = TextEditingController(
      text: event.regularPrice?.toString() ?? '',
    );
    final vipController = TextEditingController(
      text: event.vipPrice?.toString() ?? '',
    );
    final premiumController = TextEditingController(
      text: event.premiumPrice?.toString() ?? '',
    );
    DateTime? selectedDate = event.eventDate;
    TimeOfDay? selectedTime = event.eventDate != null
        ? TimeOfDay(
            hour: event.eventDate!.hour,
            minute: event.eventDate!.minute,
          )
        : null;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D235D).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Color(0xFF1D235D),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Edit Event",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D235D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.eventName ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),

                      _modalSectionHeader("Event Info"),
                      const SizedBox(height: 10),
                      _modalField(
                        controller: nameController,
                        label: "Event Name",
                        icon: Icons.event_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Name is required";
                          if (v.length < 5) return "Minimum 5 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _modalField(
                        controller: descriptionController,
                        label: "Description",
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 10)
                            return "Minimum 10 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF1D235D),
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                selectedTime?.hour ?? 0,
                                selectedTime?.minute ?? 0,
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: Color(0xFF1D235D),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Date",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      selectedDate != null
                                          ? DateFormat(
                                              'dd MMM yyyy',
                                            ).format(selectedDate!)
                                          : "Select date",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: selectedDate != null
                                            ? const Color(0xFF2D3142)
                                            : Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF1D235D),
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedTime = picked;
                              if (selectedDate != null) {
                                selectedDate = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                  picked.hour,
                                  picked.minute,
                                );
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Color(0xFF1D235D),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Time",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      selectedTime != null
                                          ? selectedTime!.format(context)
                                          : "Select time",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: selectedTime != null
                                            ? const Color(0xFF2D3142)
                                            : Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  Text(
                                    event.location?.locationName ?? "—",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _modalSectionHeader("Ticket Prices"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _modalPriceField(
                              controller: regularController,
                              label: "Regular",
                              color: const Color(0xFF1D235D),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _modalPriceField(
                              controller: vipController,
                              label: "VIP",
                              color: const Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _modalPriceField(
                              controller: premiumController,
                              label: "Premium",
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate())
                                        return;
                                      setModalState(() => isLoading = true);
                                      try {
                                        final provider =
                                            Provider.of<EventProvider>(
                                              context,
                                              listen: false,
                                            );
                                        await provider.update(event.eventID!, {
                                          if (nameController.text.isNotEmpty)
                                            'eventName': nameController.text,
                                          if (descriptionController
                                              .text
                                              .isNotEmpty)
                                            'description':
                                                descriptionController.text,
                                          if (regularController.text.isNotEmpty)
                                            'regularPrice': int.tryParse(
                                              regularController.text,
                                            ),
                                          if (vipController.text.isNotEmpty)
                                            'vipPrice': int.tryParse(
                                              vipController.text,
                                            ),
                                          if (premiumController.text.isNotEmpty)
                                            'premiumPrice': int.tryParse(
                                              premiumController.text,
                                            ),
                                          if (selectedDate != null)
                                            'eventDate': selectedDate!
                                                .toIso8601String(),
                                        });

                                        if (!mounted) return;

                                        final updatedEvent = Event(
                                          eventID: event.eventID,
                                          eventName:
                                              nameController.text.isNotEmpty
                                              ? nameController.text
                                              : event.eventName,
                                          description:
                                              descriptionController
                                                  .text
                                                  .isNotEmpty
                                              ? descriptionController.text
                                              : event.description,
                                          regularPrice:
                                              regularController.text.isNotEmpty
                                              ? int.tryParse(
                                                  regularController.text,
                                                )
                                              : event.regularPrice,
                                          vipPrice:
                                              vipController.text.isNotEmpty
                                              ? int.tryParse(vipController.text)
                                              : event.vipPrice,
                                          premiumPrice:
                                              premiumController.text.isNotEmpty
                                              ? int.tryParse(
                                                  premiumController.text,
                                                )
                                              : event.premiumPrice,
                                          eventDate:
                                              selectedDate ?? event.eventDate,
                                          location: event.location,
                                          status: event.status,
                                          performer: event.performer,
                                          totalTickets: event.totalTickets,
                                          ticketsSold: event.ticketsSold,
                                          ratingAverage: event.ratingAverage,
                                          ratingCount: event.ratingCount,
                                          timeStatus: event.timeStatus,
                                          userRating: event.userRating,
                                        );

                                        Navigator.pop(context);
                                        _showSuccessSnackbar(
                                          "Event updated successfully.",
                                        );
                                        _updateEventLocally(updatedEvent);
                                      } catch (e) {
                                        setModalState(() => isLoading = false);
                                        _showErrorSnackbar(
                                          "Failed to update event. Please try again.",
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: const Color(0xFF1D235D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Save Changes",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _modalSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D235D),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Color(0xFFEAECF0), thickness: 1)),
      ],
    );
  }

  Widget _modalField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: Color(0xFF2D3142)),
      cursorColor: const Color(0xFF1D235D),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        floatingLabelStyle: const TextStyle(color: Color(0xFF1D235D)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF1D235D)),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D235D), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _modalPriceField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
      cursorColor: color,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: color),
        floatingLabelStyle: TextStyle(color: color),
        suffixText: "KM",
        suffixStyle: TextStyle(fontSize: 11, color: color.withOpacity(0.6)),
        filled: true,
        fillColor: color.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
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
      ),
    );
  }

  Widget _filterChip(
    String label,
    String value,
    String groupValue,
    void Function(String) onSelected,
  ) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D235D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D235D) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: PerformerBottomNavBar(
        selected: PerformerNavItem.home,
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
                      "My Events",
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
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip(
                              "All",
                              "All",
                              _selectedStatus,
                              (v) => setState(() {
                                _selectedStatus = v;
                                _applyFilters();
                              }),
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              "Approved",
                              "Approved",
                              _selectedStatus,
                              (v) => setState(() {
                                _selectedStatus = v;
                                _applyFilters();
                              }),
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              "Pending",
                              "Pending",
                              _selectedStatus,
                              (v) => setState(() {
                                _selectedStatus = v;
                                _applyFilters();
                              }),
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              "Rejected",
                              "Rejected",
                              _selectedStatus,
                              (v) => setState(() {
                                _selectedStatus = v;
                                _applyFilters();
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Time",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _filterChip(
                            "All",
                            "All",
                            _selectedTime,
                            (v) => setState(() {
                              _selectedTime = v;
                              _applyFilters();
                            }),
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            "Upcoming",
                            "Upcoming",
                            _selectedTime,
                            (v) => setState(() {
                              _selectedTime = v;
                              _applyFilters();
                            }),
                          ),
                          const SizedBox(width: 8),
                          _filterChip(
                            "Ended",
                            "Ended",
                            _selectedTime,
                            (v) => setState(() {
                              _selectedTime = v;
                              _applyFilters();
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                              onPressed: _loadMyEvents,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D235D),
                              ),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1D235D,
                                ).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.event_note_rounded,
                                size: 48,
                                color: Color(0xFF1D235D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No events found",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Try adjusting your filters",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMyEvents,
                        color: const Color(0xFF1D235D),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(25, 14, 25, 24),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) =>
                              _buildEventCard(_filteredEvents[index]),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final bool isPastEvent =
        event.eventDate != null && event.eventDate!.isBefore(DateTime.now());
    final String status = event.status?.statusName ?? "Pending";
    final bool isApproved = status.toLowerCase() == "approved";
    final bool canEdit = isApproved && !isPastEvent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 210,
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
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/my-events.jpg', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.72),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
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
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 4),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isPastEvent
                          ? Colors.red.withOpacity(0.75)
                          : Colors.green.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPastEvent ? "Ended" : "Upcoming",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    Colors.grey[400]!,
                    event.eventDate != null
                        ? DateFormat('dd MMM yyyy').format(event.eventDate!)
                        : "Date TBA",
                  ),
                  const SizedBox(height: 3),
                  _buildInfoRow(
                    Icons.access_time_rounded,
                    Colors.grey[400]!,
                    event.eventDate != null
                        ? DateFormat('HH:mm').format(event.eventDate!)
                        : "Time TBA",
                  ),
                  if (event.location?.locationName != null) ...[
                    const SizedBox(height: 3),
                    _buildInfoRow(
                      Icons.location_on_rounded,
                      const Color(0xFFE53935),
                      event.location!.locationName!,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.7),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Row(
                      children: [
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isPastEvent) {
                              _showErrorSnackbar(
                                "You cannot edit an event that has already passed.",
                              );
                              return;
                            }
                            if (!isApproved) {
                              _showErrorSnackbar(
                                "You cannot edit an event that is not approved.",
                              );
                              return;
                            }
                            _showEditModal(context, event);
                          },
                          icon: Icon(
                            Icons.edit_rounded,
                            size: 13,
                            color: canEdit
                                ? const Color(0xFF08084A)
                                : const Color(0xFF08084A).withOpacity(0.35),
                          ),
                          label: Text(
                            "Edit Event",
                            style: TextStyle(
                              fontSize: 12,
                              color: canEdit
                                  ? const Color(0xFF08084A)
                                  : const Color(0xFF08084A).withOpacity(0.35),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canEdit
                                ? const Color(0xFFEEF0FF)
                                : const Color(0xFFEEF0FF).withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
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

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case "approved":
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        break;
      case "rejected":
        color = Colors.red;
        icon = Icons.cancel_rounded;
        break;
      case "pending":
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
