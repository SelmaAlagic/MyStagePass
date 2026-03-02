import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Purchase/purchase.dart';
import '../providers/purchase_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'customer_tickets_screen.dart';

class PurchasesScreen extends StatefulWidget {
  final int userId;

  const PurchasesScreen({super.key, required this.userId});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  List<Purchase> _purchases = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser == null) await auth.fetchMyProfile();
      if (auth.profileImageBytes == null) await auth.fetchMyProfile();
      _loadPurchases();
    });
  }

  Future<void> _loadPurchases() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final provider = Provider.of<PurchaseProvider>(context, listen: false);
      final result = await provider.get(filter: {'Page': 0, 'PageSize': 100});
      if (!mounted) return;
      setState(() {
        _purchases = result.result.where((p) => p.isDeleted != true).toList();
        _purchases.sort(
          (a, b) => (b.purchaseDate ?? DateTime(0)).compareTo(
            a.purchaseDate ?? DateTime(0),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load purchases";
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "—";
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$day.$month.${dt.year}  ·  $h:$m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        selected: NavItem.purchases,
        userId: widget.userId,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/pozadina.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Container(
                    color: const Color(0xFFF5F6F8),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      right: 16,
                      bottom: 12,
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
                        Text(
                          "My Purchases",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        if (_purchases.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            "· ${_purchases.length} ${_purchases.length == 1 ? 'purchase' : 'purchases'}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
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
                              onPressed: _loadPurchases,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D235D),
                              ),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : _purchases.isEmpty
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
                                Icons.shopping_cart_outlined,
                                size: 48,
                                color: Color(0xFF1D235D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No purchases yet",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Your ticket purchases will appear here",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPurchases,
                        color: const Color(0xFF1D235D),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                          itemCount: _purchases.length,
                          itemBuilder: (context, index) =>
                              _buildPurchaseCard(_purchases[index]),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(Purchase purchase) {
    final tickets =
        purchase.tickets?.where((t) => t.isDeleted != true).toList() ?? [];
    final ticketCount = tickets.length;
    final eventName = tickets.isNotEmpty
        ? (tickets.first.event?.eventName ?? "Event")
        : "Purchase #${purchase.purchaseID}";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D235D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Purchase Details",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D235D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Color(0xFF1D235D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(purchase.purchaseDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF616161),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 12,
                        color: Color(0xFF1D235D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$ticketCount ${ticketCount == 1 ? 'ticket' : 'tickets'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF616161),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: tickets.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketsScreen(
                            userId: widget.userId,
                            preloadedTickets: tickets,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D235D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Show Tickets",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
