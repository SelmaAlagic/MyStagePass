import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/models/EventRecommendation/recommendations.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
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
  int _totalCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
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
        _totalCount = result.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load recommendations";
        _isLoading = false;
      });
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
            child: Image.asset('assets/images/pozadina.jpg', fit: BoxFit.cover),
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
                    : _recommendations.isEmpty
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
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) =>
                              _buildRecommendationCard(_recommendations[index]),
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
                  Text(
                    rec.eventName ?? 'Unknown Event',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                    overflow: TextOverflow.ellipsis,
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
                        rec.eventDate ?? 'Unknown Date',
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
              right: -18,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Recommended",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
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
