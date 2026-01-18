import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Performer/performer.dart';
import '../providers/performer_provider.dart';
import 'dart:async';

class PerformerRequestsScreen extends StatefulWidget {
  const PerformerRequestsScreen({super.key});

  @override
  State<PerformerRequestsScreen> createState() =>
      _PerformerRequestsScreenState();
}

class _PerformerRequestsScreenState extends State<PerformerRequestsScreen> {
  List<Performer> _performers = [];
  bool _isLoading = false;
  String _searchQuery = "";

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

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return "N/A";
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 9) {
      return "${digits.substring(0, 3)}/${digits.substring(3, 6)}-${digits.substring(6)}";
    }
    return phone;
  }

  Future<void> _fetchPerformers() async {
    setState(() => _isLoading = true);
    try {
      var provider = Provider.of<PerformerProvider>(context, listen: false);
      var params = {
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
        'IsPending': 'true',
      };

      if (_searchQuery.length >= 3) {
        params['searchTerm'] = _searchQuery;
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

  Future<void> _handleApproveReject(int performerId, bool isApproved) async {
    try {
      var provider = Provider.of<PerformerProvider>(context, listen: false);
      await provider.approvePerformer(performerId, isApproved);

      if (mounted) {
        setState(() {
          _performers.removeWhere((p) => p.performerId == performerId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved
                  ? "Performer successfully approved"
                  : "Performer successfully rejected",
            ),
            backgroundColor: isApproved ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
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
              _buildSearch(),
              const SizedBox(height: 20),
              _buildTableStack(),
              const SizedBox(height: 20),
              if (_performers.isNotEmpty) _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Performer Requests",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
          const Icon(Icons.pending_actions, size: 32, color: Color(0xFF1A237E)),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFF1A237E),
        ),
        label: const Text(
          "Back to Performer Management",
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

  Widget _buildSearch() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      alignment: Alignment.centerLeft,
      child: Container(
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
    );
  }

  Widget _buildTableStack() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
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
                height: 48.0 * 5,
                child: _performers.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No pending requests",
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
                  color: Colors.white,
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
            _tableHeaderCell('Name', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Phone', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Email', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Genres', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Actions', width: 180),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerRow(int number, Performer performer) {
    String performerName =
        performer.artistName ?? performer.user?.fullName ?? "N/A";

    String genresText = performer.genres != null && performer.genres!.isNotEmpty
        ? performer.genres!.join(", ")
        : "No specific genres";

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
          _tableCell(performerName, flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(_formatPhoneNumber(performer.user?.phoneNumber), flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(performer.user?.email ?? "N/A", flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(genresText, flex: 2),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(
            width: 180,
            child: Center(child: _buildActionButtons(performer)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Performer performer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => _handleApproveReject(performer.performerId!, true),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: Colors.green[800], size: 14),
                const SizedBox(width: 4),
                Text(
                  "Approve",
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _handleApproveReject(performer.performerId!, false),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, color: Colors.red[800], size: 14),
                const SizedBox(width: 4),
                Text(
                  "Reject",
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeaderCell(String text, {int? flex, double? width}) {
    Widget content = Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    return flex != null
        ? Expanded(flex: flex, child: content)
        : SizedBox(width: width, child: content);
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
}
