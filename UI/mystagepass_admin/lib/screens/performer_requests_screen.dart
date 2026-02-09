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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 60),
                _buildSearch(),
                const SizedBox(height: 30),
                _buildTableStack(),
                const SizedBox(height: 30),
                if (_performers.isNotEmpty) _buildPagination(),
                const SizedBox(height: 30),
                _buildBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pending_actions, size: 36, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              "Performer Requests",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        label: const Text(
          "Back to Performer Management",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromARGB(255, 29, 35, 93),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
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
      constraints: const BoxConstraints(maxWidth: 900),
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
                height: 56.0 * _pageSize,
                child: _performers.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pending_actions,
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
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _tableHeaderCell('#', width: 40),
            _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
            _tableHeaderCell('Name', width: 140),
            _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
            _tableHeaderCell('Email', width: 200),
            _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
            _tableHeaderCell('Phone', width: 130),
            _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
            _tableHeaderCell('Genres', width: 160),
            _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
            _tableHeaderCell('Actions', width: 110),
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
        : "No genres";

    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _tableCell(number.toString(), width: 40, isBold: true, center: true),
          _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
          _tableCell(performerName, width: 140),
          _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
          _tableCell(performer.user?.email ?? "N/A", width: 200),
          _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
          _tableCell(
            _formatPhoneNumber(performer.user?.phoneNumber),
            width: 130,
          ),
          _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
          _tableCell(genresText, width: 160),
          _verticalDivider(const Color.fromARGB(77, 145, 156, 218)),
          SizedBox(
            width: 110,
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
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.green),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => _handleApproveReject(performer.performerId!, false),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: const Icon(Icons.close, size: 16, color: Colors.red),
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
          color: Color.fromARGB(249, 8, 18, 70),
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
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: const Color.fromARGB(248, 0, 0, 1),
            fontSize: 13,
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
            size: 32,
            color: _hasPrevious ? Colors.white : Colors.white38,
          ),
        ),
        Text(
          "$_currentPage of $_totalPages",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
            size: 32,
            color: _hasNext ? Colors.white : Colors.white38,
          ),
        ),
      ],
    );
  }
}
