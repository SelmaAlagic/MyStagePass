import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/Event/event.dart';
import '../providers/purchase_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class CustomerMyEventsScreen extends StatefulWidget {
  final int userId;

  const CustomerMyEventsScreen({super.key, required this.userId});

  @override
  State<CustomerMyEventsScreen> createState() => _CustomerMyEventsScreenState();
}

class _CustomerMyEventsScreenState extends State<CustomerMyEventsScreen> {
  List<Event> _events = [];
  int _totalCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

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
      final purchaseProvider = Provider.of<PurchaseProvider>(
        context,
        listen: false,
      );
      final result = await purchaseProvider.getMyEvents();

      if (!mounted) return;
      setState(() {
        _events = result.result;
        _totalCount = result.meta.count;
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

  void _showReviewModal(Event event) {
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D235D).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 40,
                        color: Color(0xFF1D235D),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Rate this event",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.eventName ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedRating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: index < selectedRating
                                  ? Colors.amber
                                  : Colors.grey[300],
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedRating > 0
                          ? _getRatingText(selectedRating)
                          : "Tap to rate",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedRating == 0
                                ? null
                                : () async {
                                    try {
                                      final reviewProvider =
                                          Provider.of<ReviewProvider>(
                                            context,
                                            listen: false,
                                          );
                                      await reviewProvider.submitReview(
                                        eventId: event.eventID!,
                                        rating: selectedRating,
                                      );

                                      if (mounted) {
                                        setState(() {
                                          event.userRating = selectedRating;
                                          event.ratingCount =
                                              (event.ratingCount ?? 0) + 1;
                                          double totalScore =
                                              (event.ratingAverage ?? 0) *
                                              ((event.ratingCount ?? 1) - 1);
                                          totalScore += selectedRating;
                                          event.ratingAverage =
                                              totalScore / event.ratingCount!;
                                        });
                                      }
                                      Navigator.pop(context);

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: const Color(
                                              0xFFE8F5E9,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: const BorderSide(
                                                color: Color(0xFF2E7D32),
                                                width: 1,
                                              ),
                                            ),
                                            margin: const EdgeInsets.all(16),
                                            duration: const Duration(
                                              seconds: 3,
                                            ),
                                            content: Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Color(0xFF2E7D32),
                                                  size: 20,
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    "Review submitted successfully!",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF1B5E20),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.pop(context);
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            content: Row(
                                              children: const [
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    "Failed to submit review. Please try again.",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF1D235D),
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Submit",
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
            );
          },
        );
      },
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return "Poor";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Very Good";
      case 5:
        return "Excellent";
      default:
        return "";
    }
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
                    : _events.isEmpty
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
                              "No events yet",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Your purchased event tickets will appear here",
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
                          itemCount: _events.length,
                          itemBuilder: (context, index) =>
                              _buildEventCard(_events[index]),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 220,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    event.eventName ?? "Event",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                event.ratingAverage != null &&
                                        event.ratingAverage! > 0
                                    ? Text(
                                        event.ratingAverage!.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "No ratings",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white54,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                              ],
                            ),
                            if (event.performer?.artistName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  event.performer!.artistName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isPastEvent
                              ? Colors.red.withOpacity(0.85)
                              : Colors.green.withOpacity(0.85),
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
                    ],
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
                    child: event.userRating != null
                        ? Row(
                            children: [
                              const Spacer(),
                              _buildRatedBadge(event.userRating!),
                            ],
                          )
                        : isPastEvent
                        ? Row(
                            children: [
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => _showReviewModal(event),
                                icon: const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Colors.amber,
                                ),
                                label: const Text(
                                  "Rate Event",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    159,
                                    60,
                                    73,
                                    190,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 10,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) => Container(
                              width: constraints.maxWidth,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFF8E1,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFFB300,
                                  ).withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 13,
                                    color: Color(0xFFFFB300),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "You'll be able to rate this event once it takes place.",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFFFE082),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _buildRatedBadge(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Your rating  ",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        ...List.generate(
          5,
          (index) => Icon(
            index < rating ? Icons.star : Icons.star_outline,
            size: 13,
            color: index < rating ? Colors.amber : Colors.white38,
          ),
        ),
      ],
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
