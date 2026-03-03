import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/alert_helpers.dart';
import '../widgets/bottom_nav_bar.dart';

class FavoritesScreen extends StatefulWidget {
  final int userId;

  const FavoritesScreen({super.key, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser == null) auth.fetchMyProfile();
      if (auth.currentUserInfo == null) auth.fetchCurrentUserInfo();
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        selected: NavItem.favorites,
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
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Consumer2<FavoriteProvider, AuthProvider>(
                  builder: (context, favoriteProvider, authProvider, _) {
                    final count = favoriteProvider.favorites.length;
                    return Container(
                      color: const Color(0xFFF5F6F8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1D235D),
                                width: 1.2,
                              ),
                            ),
                            child: ClipOval(
                              child: authProvider.profileImageBytes != null
                                  ? Image.memory(
                                      authProvider.profileImageBytes!,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(
                                        'assets/images/NoProfileImage.png',
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                const Text(
                                  "Favorites",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                if (count > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    "· $count ${count == 1 ? 'event' : 'events'}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Consumer<FavoriteProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1D235D),
                          ),
                        );
                      }

                      if (provider.favorites.isEmpty) {
                        return Center(
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
                                  Icons.favorite_border_rounded,
                                  size: 48,
                                  color: Color(0xFF1D235D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No favorites yet",
                                style: TextStyle(
                                  color: Color(0xFF1D235D),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Events you like will appear here",
                                style: TextStyle(
                                  color: Color(0xFF1D235D),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => await provider.fetchFavorites(),
                        color: const Color(0xFF1D235D),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(25, 14, 25, 24),
                          itemCount: provider.favorites.length,
                          itemBuilder: (context, index) {
                            final fav = provider.favorites[index];
                            final event = fav.event;
                            return _buildFavoriteCard(
                              context,
                              provider,
                              fav,
                              event,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    FavoriteProvider provider,
    dynamic fav,
    dynamic event,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                'assets/images/favorite.jpg',
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
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
                            Text(
                              event?.eventName ?? "Unknown Event",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                event?.performer?.user?.fullName ?? "",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _confirmRemove(
                          context,
                          provider,
                          fav.customerFavoriteEventID!,
                          event?.eventName ?? "this event",
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                              event?.eventDate != null
                                  ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(event.eventDate!)
                                  : "Date TBA",
                            ),
                            const SizedBox(height: 6),
                            _buildInfoRow(
                              Icons.access_time_rounded,
                              Colors.grey[400]!,
                              event?.eventDate != null
                                  ? DateFormat('HH:mm').format(event.eventDate!)
                                  : "Time TBA",
                            ),
                            if (event?.location?.locationName != null) ...[
                              const SizedBox(height: 6),
                              _buildInfoRow(
                                Icons.location_on_rounded,
                                const Color(0xFFE53935),
                                event.location.locationName,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            children: [
                              _buildPriceRow("Premium", event?.premiumPrice),
                              _buildPriceRow("VIP", event?.vipPrice),
                              _buildPriceRow("Regular", event?.regularPrice),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                          width: 0.8,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 13,
                          color: Colors.white54,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Tap heart to remove from favorites",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(196, 255, 255, 255),
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
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  TableRow _buildPriceRow(String label, dynamic price) {
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

  void _confirmRemove(
    BuildContext context,
    FavoriteProvider provider,
    int favoriteId,
    String eventName,
  ) {
    AlertHelpers.showConfirmationAlert(
      context,
      "Remove Favorite",
      "Are you sure you want to remove \"$eventName\" from favorites?",
      confirmButtonText: "Remove",
      cancelButtonText: "Cancel",
      isDelete: true,
      onConfirm: () async {
        try {
          await provider.removeFavorite(favoriteId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFE8F5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF2E7D32), width: 1),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
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
                        "Removed from favorites.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFFFEBEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFB71C1C), width: 1),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
                content: Row(
                  children: const [
                    Icon(
                      Icons.error_rounded,
                      color: Color(0xFFB71C1C),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Failed to remove from favorites.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F0000),
                          fontWeight: FontWeight.w500,
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
    );
  }
}
