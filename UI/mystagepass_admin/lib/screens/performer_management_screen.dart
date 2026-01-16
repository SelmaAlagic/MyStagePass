import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Performer/performer.dart';
import '../providers/performer_provider.dart';
import 'dart:async';

class PerformerManagementScreen extends StatefulWidget {
  const PerformerManagementScreen({super.key});

  @override
  State<PerformerManagementScreen> createState() =>
      _PerformerManagementScreenState();
}

class _PerformerManagementScreenState extends State<PerformerManagementScreen> {
  List<Performer> _performers = [];
  bool _isLoading = false;
  String _searchQuery = "";
  bool? _statusFilter;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 5;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPerformers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchPerformers() async {
    setState(() => _isLoading = true);
    try {
      var provider = Provider.of<PerformerProvider>(context, listen: false);
      var params = {
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
      };

      if (_searchQuery.length >= 3) {
        params['searchTerm'] = _searchQuery;
      }

      if (_statusFilter != null) {
        params['IsApproved'] = _statusFilter.toString();
      }

      var data = await provider.get(filter: params);

      if (mounted) {
        setState(() {
          _performers = data.result;
          _totalPages = data.meta.totalPages;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error: $e");
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _searchQuery = query;
    if (query.length >= 3 || query.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() => _currentPage = 1);
        _fetchPerformers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9DB4FF),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              _buildBackButton(),
              const SizedBox(height: 10),
              _buildFilters(),
              const SizedBox(height: 20),
              _buildTableStack(),
              const SizedBox(height: 20),
              if (_performers.isNotEmpty) _buildPagination(),
              const SizedBox(height: 20),
              _buildPerformerRequestsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Performer Management",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
          const Icon(Icons.music_note, size: 32, color: Color(0xFF1A237E)),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFF1A237E),
        ),
        label: const Text(
          "Back to Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          foregroundColor: const Color(0xFF1A237E),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
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
              cursorColor: const Color(0xFF1A237E),
              cursorWidth: 1.0,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
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
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(hoverColor: const Color(0xFFE3F2FD)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter == null
                      ? "All"
                      : (_statusFilter == true ? "Approved" : "Rejected"),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  items: ["All", "Approved", "Rejected"]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value == "All") {
                        _statusFilter = null;
                      } else if (value == "Approved") {
                        _statusFilter = true;
                      } else {
                        _statusFilter = false;
                      }
                      _currentPage = 1;
                    });
                    _fetchPerformers();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableStack() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTableHeader(),
              SizedBox(
                height: 48.0 * 5, // Fiksna visina za 5 redova
                child: _performers.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No performers found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _performers.length,
                        itemBuilder: (context, index) {
                          int rowNumber =
                              ((_currentPage - 1) * _pageSize) + index + 1;
                          return _buildPerformerRow(
                            rowNumber,
                            _performers[index],
                          );
                        },
                      ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF5865F2)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5865F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _tableHeaderCell('#', width: 40),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Full Name', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Artist Name', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Genres', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Rating', width: 90),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Status', width: 90),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Actions', width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerRow(int number, Performer performer) {
    String genresText = performer.genres != null && performer.genres!.isNotEmpty
        ? performer.genres!.join(", ")
        : "No specific genres";

    bool hasRating =
        performer.averageRating != null && performer.averageRating! > 0;
    String ratingText = hasRating
        ? "${performer.averageRating!.toStringAsFixed(1)} ⭐"
        : "No ratings";

    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _tableCell(number.toString(), width: 40, isBold: true, center: true),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(performer.user?.fullName ?? "N/A", flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(performer.artistName ?? "N/A", flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(
            genresText,
            flex: 2,
            isGrey: performer.genres == null || performer.genres!.isEmpty,
            isItalic: performer.genres == null || performer.genres!.isEmpty,
          ),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(
            width: 90,
            child: Center(
              child: hasRating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          performer.averageRating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFA500),
                        ),
                      ],
                    )
                  : Text(
                      "No ratings",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
          ),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(
            width: 90,
            child: Center(child: _buildStatusBadge(performer)),
          ),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(
            width: 80,
            child: Center(
              child: InkWell(
                onTap: () {
                  // Edit action
                },
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Performer performer) {
    final bool approved = performer.isApproved ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: approved ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: approved ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Text(
        approved ? "Approved" : "Rejected",
        style: TextStyle(
          color: approved ? Colors.green[800] : Colors.red[800],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text, {int? flex, double? width}) {
    Widget content = Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
    return flex != null
        ? Expanded(flex: flex, child: content)
        : SizedBox(width: width, child: content);
  }

  Widget _tableCell(
    String text, {
    int? flex,
    double? width,
    bool isBold = false,
    bool center = false,
    bool isGrey = false,
    bool isItalic = false,
  }) {
    return Container(
      width: width,
      child: flex != null
          ? Expanded(
              flex: flex,
              child: _cellText(text, isBold, center, isGrey, isItalic),
            )
          : _cellText(text, isBold, center, isGrey, isItalic),
    );
  }

  Widget _cellText(
    String text,
    bool isBold,
    bool center,
    bool isGrey,
    bool isItalic,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: isGrey ? Colors.grey.shade500 : Colors.black,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _verticalDivider(Color color) =>
      VerticalDivider(color: color, thickness: 1, indent: 6, endIndent: 6);

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _hasPrevious
              ? () {
                  setState(() => _currentPage--);
                  _fetchPerformers();
                }
              : null,
          icon: Icon(
            Icons.chevron_left,
            color: _hasPrevious ? Colors.white : Colors.white38,
          ),
        ),
        Text(
          "$_currentPage of $_totalPages",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: _hasNext
              ? () {
                  setState(() => _currentPage++);
                  _fetchPerformers();
                }
              : null,
          icon: Icon(
            Icons.chevron_right,
            color: _hasNext ? Colors.white : Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformerRequestsButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to performer requests screen
        },
        icon: const Icon(Icons.person_add_alt_1, size: 20, color: Colors.white),
        label: const Text(
          "Performer Requests",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5865F2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
