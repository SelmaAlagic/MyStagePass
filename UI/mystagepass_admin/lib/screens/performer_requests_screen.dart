import 'package:flutter/material.dart';
import 'package:mystagepass_admin/widgets/sidebar_layout.dart';
import 'package:provider/provider.dart';
import '../models/Performer/performer.dart';
import '../providers/performer_provider.dart';
import 'performer_management_screen.dart';
import 'dart:async';
import '../utils/alert_helpers.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);

class PerformerRequestsScreen extends StatefulWidget {
  const PerformerRequestsScreen({super.key, required this.userId});
  final int userId;

  @override
  State<PerformerRequestsScreen> createState() =>
      _PerformerRequestsScreenState();
}

class _PerformerRequestsScreenState extends State<PerformerRequestsScreen> {
  List<Performer> _performers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 6;

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
    if (_searchQuery.isNotEmpty && _searchQuery.length < 3) {
      if (mounted) {
        setState(() {
          _performers = [];
          _currentPage = 1;
          _totalPages = 1;
          _totalCount = 0;
          _hasPrevious = false;
          _hasNext = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final provider = Provider.of<PerformerProvider>(context, listen: false);
      final params = <String, dynamic>{
        'Page': _currentPage - 1,
        'PageSize': _pageSize,
        'IsPending': 'true',
      };
      if (_searchQuery.length >= 3) params['searchTerm'] = _searchQuery;

      final data = await provider.get(filter: params);

      if (mounted) {
        setState(() {
          _performers = data.result;
          _totalPages = data.meta.totalPages < 1 ? 1 : data.meta.totalPages;
          _totalCount = data.meta.count;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error fetching performers: $e');
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() => _currentPage = page);
    _fetchPerformers();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _searchQuery = value.trim());
    if (_searchQuery.length >= 3 || _searchQuery.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 450), () {
        setState(() => _currentPage = 1);
        _fetchPerformers();
      });
    }
  }

  Future<void> _handleApproveReject(int performerId, bool isApproved) async {
    try {
      final provider = Provider.of<PerformerProvider>(context, listen: false);
      await provider.approvePerformer(performerId, isApproved);
      if (mounted) {
        AlertHelpers.showSuccess(
          context,
          isApproved
              ? 'Performer successfully approved.'
              : 'Performer successfully rejected.',
        );
        _fetchPerformers();
      }
    } catch (e) {
      if (mounted) AlertHelpers.showError(context, 'Error: $e');
    }
  }

  void _showConfirmDialog(
    BuildContext modalCtx,
    Performer performer,
    bool isApprove,
  ) {
    final name =
        performer.artistName ?? performer.user?.fullName ?? 'this performer';
    AlertHelpers.showConfirmationAlert(
      context,
      isApprove ? 'Approve Performer' : 'Reject Performer',
      isApprove
          ? 'Are you sure you want to approve "$name"? They will be notified via email.'
          : 'Are you sure you want to reject "$name"? They will be notified via email.',
      confirmButtonText: isApprove ? 'Approve' : 'Reject',
      cancelButtonText: 'Cancel',
      isDelete: !isApprove,
      onConfirm: () {
        Navigator.of(modalCtx).pop();
        _handleApproveReject(performer.performerId!, isApprove);
      },
    );
  }

  void _showDetailsModal(Performer performer) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => _PerformerDetailsModal(
        performer: performer,
        onApprove: () => _showConfirmDialog(ctx, performer, true),
        onReject: () => _showRejectReasonModal(performer),
      ),
    );
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      userId: widget.userId,
      activeRouteKey: SidebarRoutes.performers,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 20),
                _buildMainCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Performer Requests',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Review and manage pending performer registration requests.',
          style: TextStyle(fontSize: 13, color: _t2),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildFilterRow(),
          _buildTable(),
          if (!_isLoading && _performers.isNotEmpty) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final hasActiveFilters = _searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 240,
                height: 38,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty && _searchQuery.length < 3
                        ? _navyMid.withOpacity(0.4)
                        : _border,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  cursorColor: _navy,
                  cursorWidth: 1.0,
                  style: const TextStyle(fontSize: 13, color: _t1),
                  decoration: InputDecoration(
                    hintText: 'Search requests...',
                    hintStyle: const TextStyle(color: _t2, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: _t2,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _t2,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 11,
                        color: _navyMid.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Type at least 3 characters',
                        style: TextStyle(
                          fontSize: 11,
                          color: _navyMid.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (hasActiveFilters) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _currentPage = 1;
                });
                _searchController.clear();
                _fetchPerformers();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt_off_rounded, size: 14, color: _t2),
                      SizedBox(width: 5),
                      Text(
                        'Clear filters',
                        style: TextStyle(
                          fontSize: 12,
                          color: _t2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              _fadeRoute(PerformerManagementScreen(userId: widget.userId)),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 16, color: _navyMid),
                    SizedBox(width: 6),
                    Text(
                      'Performer Management',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _navyMid,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        _buildTableHeader(),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
            ),
          )
        else if (_performers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 36,
                  color: _t2.withOpacity(0.4),
                ),
                const SizedBox(height: 10),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No requests match "$_searchQuery"'
                      : 'No pending performer requests found',
                  style: const TextStyle(fontSize: 13, color: _t2),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _performers.length,
            itemBuilder: (context, index) {
              final rowNum = ((_currentPage - 1) * _pageSize) + index + 1;
              return _buildPerformerRow(rowNum, _performers[index], index);
            },
          ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(
          top: BorderSide(color: _border),
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          _th('#', width: 40),
          _th('Artist Name', flex: 2),
          _th('Full Name', flex: 2),
          _th('Email', flex: 3),
          _th('Phone', width: 130),
          _th('Genres', flex: 2),
          _th('', width: 110),
        ],
      ),
    );
  }

  Widget _th(String label, {int? flex, double? width}) {
    final w = Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _t2,
      ),
    );
    if (flex != null) return Expanded(flex: flex, child: w);
    return SizedBox(
      width: width,
      child: Center(child: w),
    );
  }

  Widget _buildPerformerRow(int number, Performer performer, int index) {
    final isEven = index % 2 == 0;
    final artistName = performer.artistName ?? 'N/A';
    final fullName = performer.user?.fullName ?? 'N/A';
    final email = performer.user?.email ?? 'N/A';
    final phone = _formatPhone(performer.user?.phoneNumber);
    final genres = performer.genres != null && performer.genres!.isNotEmpty
        ? performer.genres!.join(', ')
        : 'No genres';

    return _HoverRow(
      isEven: isEven,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _t2,
              ),
            ),
          ),
          Expanded(flex: 2, child: _cell(artistName, bold: true)),
          Expanded(flex: 2, child: _cell(fullName)),
          Expanded(flex: 3, child: _cell(email)),
          SizedBox(width: 130, child: Center(child: _cell(phone))),
          Expanded(flex: 2, child: _cell(genres, muted: true)),
          SizedBox(
            width: 110,
            child: Center(
              child: GestureDetector(
                onTap: () => _showDetailsModal(performer),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _navyMid.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 12,
                          color: _navyMid,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _navyMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectReasonModal(Performer performer) {
    final controller = TextEditingController();
    String? _fieldError;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Dialog(
            backgroundColor: _white,
            surfaceTintColor: _white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_navy, _navyMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: _white,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Reject Performer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: _white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: _red.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: _red.withOpacity(0.22)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: _red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You are about to reject "${performer.artistName ?? performer.user?.fullName ?? 'this performer'}". They will be notified via email.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _red,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Reason label
                        const Text(
                          'Rejection Reason',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _t1,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Reason text field
                        Container(
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _fieldError != null ? _red : _border,
                              width: _fieldError != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: controller,
                            maxLines: 3,
                            cursorColor: _navyMid,
                            cursorWidth: 1.2,
                            style: const TextStyle(fontSize: 13, color: _t1),
                            onChanged: (_) {
                              if (_fieldError != null) {
                                setS(() => _fieldError = null);
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter rejection reason...',
                              hintStyle: TextStyle(color: _t2, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),

                        // Error text
                        if (_fieldError != null) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 12,
                                color: _red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fieldError!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Footer ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    decoration: const BoxDecoration(
                      color: _bg,
                      border: Border(top: BorderSide(color: _border)),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _t2,
                              side: const BorderSide(color: _border),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            child: const Text(
                              'Keep Request',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final reason = controller.text.trim();
                              if (reason.isEmpty) {
                                setS(
                                  () => _fieldError =
                                      'Rejection reason is required.',
                                );
                                return;
                              }
                              if (reason.length < 5) {
                                setS(
                                  () => _fieldError =
                                      'Reason must be at least 5 characters.',
                                );
                                return;
                              }
                              Navigator.pop(ctx);
                              await Provider.of<PerformerProvider>(
                                context,
                                listen: false,
                              ).approvePerformer(
                                performer.performerId!,
                                false,
                                reason: reason,
                              );
                              if (mounted) {
                                AlertHelpers.showSuccess(
                                  context,
                                  'Performer rejected successfully.',
                                );
                                _fetchPerformers();
                              }
                            },
                            icon: const Icon(Icons.close_rounded, size: 14),
                            label: const Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _red,
                              foregroundColor: _white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
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
        },
      ),
    );
  }

  Widget _cell(String text, {bool bold = false, bool muted = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: (text == 'N/A' || muted) ? _t2 : _t1,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        fontStyle: text == 'N/A' ? FontStyle.italic : FontStyle.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    final from = ((_currentPage - 1) * _pageSize) + 1;
    final to = ((_currentPage - 1) * _pageSize) + _performers.length;

    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (startPage + 4).clamp(1, _totalPages);
    if (endPage - startPage < 4)
      startPage = (endPage - 4).clamp(1, _totalPages);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $from to $to of $_totalCount requests',
            style: const TextStyle(fontSize: 12, color: _t2),
          ),
          const Spacer(),
          Row(
            children: [
              _PagArrow(
                icon: Icons.chevron_left_rounded,
                enabled: _hasPrevious,
                onTap: () => _goToPage(_currentPage - 1),
              ),
              const SizedBox(width: 4),
              ...List.generate(endPage - startPage + 1, (i) {
                final page = startPage + i;
                final isActive = page == _currentPage;
                return GestureDetector(
                  onTap: () => _goToPage(page),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? _navyMid : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? _navyMid : _border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? _white : _t1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              _PagArrow(
                icon: Icons.chevron_right_rounded,
                enabled: _hasNext,
                onTap: () => _goToPage(_currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'N/A';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 9) {
      return '${digits.substring(0, 3)}/${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }
}

class _PerformerDetailsModal extends StatelessWidget {
  final Performer performer;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PerformerDetailsModal({
    required this.performer,
    required this.onApprove,
    required this.onReject,
  });

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'N/A';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 9) {
      return '${digits.substring(0, 3)}/${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final genres = performer.genres != null && performer.genres!.isNotEmpty
        ? performer.genres!.join(', ')
        : 'N/A';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_navy, _navyMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: _white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Pending Request',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: _white,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: Color(0xFFB45309),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This performer is pending review. Once approved, they will gain full access to the platform. If deactivation is ever needed, it can be done from Performer Management.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB45309),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _infoTile(
                              icon: Icons.person_outline_rounded,
                              label: 'Full Name',
                              value: performer.user?.fullName ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _infoTile(
                              icon: Icons.star_outline_rounded,
                              label: 'Artist Name',
                              value: performer.artistName ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _infoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: performer.user?.email ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _infoTile(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: _formatPhone(performer.user?.phoneNumber),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _infoTile(
                        icon: Icons.library_music_outlined,
                        label: 'Genres',
                        value: genres,
                      ),
                      if (performer.bio != null &&
                          performer.bio!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _infoTile(
                          icon: Icons.notes_rounded,
                          label: 'Bio',
                          value: performer.bio!,
                          multiline: true,
                        ),
                      ],
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: const BoxDecoration(
                  color: _bg,
                  border: Border(top: BorderSide(color: _border)),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close_rounded, size: 14),
                        label: const Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _red,
                          side: BorderSide(color: _red.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_rounded, size: 14),
                        label: const Text(
                          'Approve',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: const Color(0xFFDCFCE7),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
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
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    bool multiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: _navyMid.withOpacity(0.7)),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _t2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty ? _t2 : _t1,
                  ),
                  maxLines: multiline ? 4 : 1,
                  overflow: multiline
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverRow extends StatefulWidget {
  final bool isEven;
  final Widget child;
  const _HoverRow({required this.isEven, required this.child});

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFFEEF1FF)
              : widget.isEven
              ? _card
              : const Color(0xFFFAFBFF),
          border: const Border(bottom: BorderSide(color: _border, width: 0.5)),
        ),
        child: widget.child,
      ),
    );
  }
}

class _PagArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PagArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled ? _bg : const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? _t1 : _t2.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
