import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/alert_helpers.dart';
import '../utils/image_helpers.dart';
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
      if (auth.currentUser == null) {
        auth.fetchMyProfile();
      }
      if (auth.currentUserInfo == null) {
        auth.fetchCurrentUserInfo();
      }
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selected: NavItem.favorites,
        userId: widget.userId,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final fullName = auth.currentUserInfo?['fullName'] ?? "User";
                  final email = auth.currentUserInfo?['email'] ?? "";
                  final profileImage = auth.currentUser?.image;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: profileImage != null
                                ? ImageHelpers.getImageFromBytes(
                                    auth.profileImageBytes,
                                    height: 46,
                                    width: 46,
                                  )
                                : const CircleAvatar(
                                    radius: 23,
                                    backgroundImage: AssetImage(
                                      'assets/images/NoProfileImage.png',
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
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

              Expanded(
                child: Consumer<FavoriteProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (provider.favorites.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              color: Colors.white54,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No favorite events yet",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: provider.favorites.length,
                      itemBuilder: (context, index) {
                        final fav = provider.favorites[index];
                        final event = fav.event;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/concert.jpg',
                                  width: double.infinity,
                                  height: 230,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.25),
                                        Colors.black.withOpacity(0.82),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event?.eventName ??
                                                  "Unknown Event",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
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
                                                color: Colors.black.withOpacity(
                                                  0.35,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.favorite_rounded,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoRow(
                                        Icons.person_rounded,
                                        event?.performer?.user?.fullName ?? "-",
                                      ),
                                      const SizedBox(height: 5),
                                      _buildInfoRow(
                                        Icons.calendar_today_rounded,
                                        event?.eventDate != null
                                            ? _formatDate(event!.eventDate!)
                                            : "-",
                                      ),
                                      const SizedBox(height: 5),
                                      _buildInfoRow(
                                        Icons.location_on_rounded,
                                        event?.location?.locationName ?? "-",
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          _buildPriceChip(
                                            "Regular",
                                            "\$${event?.regularPrice ?? '-'}",
                                          ),
                                          const SizedBox(width: 8),
                                          _buildPriceChip(
                                            "VIP",
                                            "\$${event?.vipPrice ?? '-'}",
                                          ),
                                          const SizedBox(width: 8),
                                          _buildPriceChip(
                                            "Premium",
                                            "\$${event?.premiumPrice ?? '-'}",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChip(String label, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
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
        await provider.removeFavorite(favoriteId);
      },
    );
  }
}
