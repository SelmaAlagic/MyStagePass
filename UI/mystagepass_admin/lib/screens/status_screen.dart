import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Status/status.dart';
import '../models/Event/event.dart';
import '../providers/status_provider.dart';
import '../widgets/sidebar_layout.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _red = Color(0xFFEF4444);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);
const _blue = Color(0xFF3B82F6);

const _rowHeight = 50.0;
const _pageSize = 5;
const _headerHeight = 47.0;
const _footerHeight = 48.0;
const _panelBodyHeight = _rowHeight * _pageSize + _headerHeight + _footerHeight;

class StatusScreen extends StatelessWidget {
  final int userId;
  const StatusScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      userId: userId,
      activeRouteKey: SidebarRoutes.statuses,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                const _StatusBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statuses',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        SizedBox(height: 4),
        SizedBox(height: 2),
        Text(
          'View event statuses and browse their associated events.',
          style: TextStyle(fontSize: 13, color: _t2),
        ),
      ],
    );
  }
}

class _StatusBody extends StatefulWidget {
  const _StatusBody();

  @override
  State<_StatusBody> createState() => _StatusBodyState();
}

class _StatusBodyState extends State<_StatusBody> {
  Status? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatusTable(
            selectedStatus: _selectedStatus,
            onStatusSelected: (s) => setState(() => _selectedStatus = s),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _EventsPanel(status: _selectedStatus)),
      ],
    );
  }
}

class _StatusTable extends StatefulWidget {
  final Status? selectedStatus;
  final void Function(Status) onStatusSelected;

  const _StatusTable({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  State<_StatusTable> createState() => _StatusTableState();
}

class _StatusTableState extends State<_StatusTable> {
  final _provider = StatusProvider();

  List<Status> _items = [];
  bool _loading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrev = false, _hasNext = false;

  final TextEditingController _search = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{
        'Page': _currentPage - 1,
        'PageSize': _pageSize,
        if (_searchQuery.isNotEmpty) 'Name': _searchQuery,
      };
      final res = await _provider.get(filter: params);
      if (!mounted) return;
      setState(() {
        _items = res.result;
        _totalPages = res.meta.totalPages;
        _totalCount = res.meta.count ?? 0;
        _currentPage = res.meta.currentPage + 1;
        _hasPrev = res.meta.hasPrevious;
        _hasNext = res.meta.hasNext;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    if (v.isEmpty) _search.clear();
    setState(() => _searchQuery = v);
    if (v.length >= 3 || v.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 450), () {
        _currentPage = 1;
        _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statuses',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _t1,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _navyMid.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_totalCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _navyMid,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 170,
                      height: 34,
                      child: TextField(
                        controller: _search,
                        onChanged: _onSearchChanged,
                        cursorColor: _navy,
                        cursorWidth: 1.0,
                        style: const TextStyle(fontSize: 13, color: _t1),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: const TextStyle(color: _t2, fontSize: 13),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 15,
                            color: _t2,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _search.clear();
                                    _onSearchChanged('');
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: _t2,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: _bg,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 9,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _navyMid,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
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
                              'Type at least 3 characters to search',
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
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: const BoxDecoration(
              color: _bg,
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      '#',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _t2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status Name',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _t2,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Center(
                    child: Text(
                      'Events',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _t2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            _loadingWidget()
          else if (_items.isEmpty)
            _emptyWidget('No statuses found')
          else
            ..._items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isSelected =
                  widget.selectedStatus?.statusId == item.statusId;
              return _StatusRow(
                index: (_currentPage - 1) * _pageSize + idx + 1,
                status: item,
                eventCount: item.events?.length ?? 0,
                isEven: idx % 2 == 0,
                isSelected: isSelected,
                onTap: () => widget.onStatusSelected(item),
              );
            }),
          _PaginationFooter(
            from: (_currentPage - 1) * _pageSize + 1,
            to: (_currentPage - 1) * _pageSize + _items.length,
            total: _totalCount,
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasPrev: _hasPrev,
            hasNext: _hasNext,
            onPage: (p) {
              _currentPage = p;
              _load();
            },
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatefulWidget {
  final int index;
  final Status status;
  final int eventCount;
  final bool isEven;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusRow({
    required this.index,
    required this.status,
    required this.eventCount,
    required this.isEven,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_StatusRow> createState() => _StatusRowState();
}

class _StatusRowState extends State<_StatusRow> {
  bool _hovered = false;

  Color _dotColor(String? name) {
    switch (name?.toLowerCase()) {
      case 'approved':
        return _green;
      case 'pending':
        return _amber;
      case 'cancelled':
        return _red;
      case 'rejected':
        return _red;
      case 'sold out':
        return _blue;
      default:
        return _t2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected
        ? const Color(0xFFE8EDFF)
        : _hovered
        ? const Color(0xFFEEF1FF)
        : widget.isEven
        ? _card
        : const Color(0xFFFAFBFF);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: _rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              bottom: const BorderSide(color: _border, width: 0.5),
              left: BorderSide(
                color: widget.isSelected ? _navyMid : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected ? _navyMid : _t2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _dotColor(widget.status.statusName),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      widget.status.statusName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: widget.isSelected ? _navyMid : _t1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _navyMid.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.eventCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _navyMid,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventsPanel extends StatefulWidget {
  final Status? status;
  const _EventsPanel({required this.status});

  @override
  State<_EventsPanel> createState() => _EventsPanelState();
}

class _EventsPanelState extends State<_EventsPanel> {
  int _currentPage = 1;

  @override
  void didUpdateWidget(_EventsPanel old) {
    super.didUpdateWidget(old);
    if (old.status?.statusId != widget.status?.statusId) {
      _currentPage = 1;
    }
  }

  Color _dotColor(String? name) {
    switch (name?.toLowerCase()) {
      case 'approved':
        return _green;
      case 'pending':
        return _amber;
      case 'cancelled':
        return _red;
      case 'rejected':
        return _red;
      case 'sold out':
        return _blue;
      default:
        return _t2;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: widget.status == null
          ? _buildEmpty()
          : _buildContent(widget.status!),
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: _panelBodyHeight + 56,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _navyMid.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                size: 26,
                color: _navyMid,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a status',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _t1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Click on any status from the list\nto view its events here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _t2, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Status status) {
    final allEvents = status.events ?? [];
    final totalCount = allEvents.length;
    final totalPages = totalCount == 0 ? 1 : (totalCount / _pageSize).ceil();
    final hasPrev = _currentPage > 1;
    final hasNext = _currentPage < totalPages;

    final safePage = _currentPage.clamp(1, totalPages);
    if (safePage != _currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentPage = safePage);
      });
    }

    final paged = allEvents
        .skip((safePage - 1) * _pageSize)
        .take(_pageSize)
        .toList();

    final from = totalCount == 0 ? 0 : (safePage - 1) * _pageSize + 1;
    final to = (safePage - 1) * _pageSize + paged.length;

    final headerColor = _dotColor(status.statusName);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_navy, _navyMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_rounded, color: _white, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: headerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          status.statusName ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$totalCount event${totalCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: _headerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: _bg,
            border: Border(bottom: BorderSide(color: _border)),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _t2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Event Name',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _t2,
                  ),
                ),
              ),
              SizedBox(
                width: 130,
                child: Center(
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _t2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _rowHeight * _pageSize,
          child: totalCount == 0
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 32,
                        color: _t2.withOpacity(0.4),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No events with this status',
                        style: TextStyle(fontSize: 13, color: _t2),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    ...paged.asMap().entries.map((e) {
                      final idx = e.key;
                      final event = e.value;
                      final isEven = idx % 2 == 0;
                      final globalIdx = (safePage - 1) * _pageSize + idx + 1;
                      final dateStr = event.eventDate != null
                          ? DateFormat('dd MMM yyyy').format(event.eventDate!)
                          : 'N/A';

                      return Container(
                        height: _rowHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isEven ? _card : const Color(0xFFFAFBFF),
                          border: const Border(
                            bottom: BorderSide(color: _border, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  '$globalIdx',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _t2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                event.eventName ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _t1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 130,
                              child: Center(
                                child: Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _t2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    ...List.generate(
                      _pageSize - paged.length,
                      (i) => Container(
                        height: _rowHeight,
                        decoration: BoxDecoration(
                          color: (paged.length + i) % 2 == 0
                              ? _card
                              : const Color(0xFFFAFBFF),
                          border: const Border(
                            bottom: BorderSide(color: _border, width: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        _PaginationFooter(
          from: from,
          to: to,
          total: totalCount,
          currentPage: safePage,
          totalPages: totalPages,
          hasPrev: hasPrev,
          hasNext: hasNext,
          onPage: (p) => setState(() => _currentPage = p),
        ),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int from, to, total, currentPage, totalPages;
  final bool hasPrev, hasNext;
  final void Function(int) onPage;

  const _PaginationFooter({
    required this.from,
    required this.to,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrev,
    required this.hasNext,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox(height: _footerHeight);
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (startPage + 4).clamp(1, totalPages);
    if (endPage - startPage < 4) startPage = (endPage - 4).clamp(1, totalPages);

    return Container(
      height: _footerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $from–$to of $total',
            style: const TextStyle(fontSize: 11, color: _t2),
          ),
          const Spacer(),
          Row(
            children: [
              _PagArrow(
                icon: Icons.chevron_left_rounded,
                enabled: hasPrev,
                onTap: () => onPage(currentPage - 1),
              ),
              const SizedBox(width: 3),
              ...List.generate(endPage - startPage + 1, (i) {
                final page = startPage + i;
                final isActive = page == currentPage;
                return GestureDetector(
                  onTap: () => onPage(page),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? _navyMid : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isActive ? _navyMid : _border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? _white : _t1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 3),
              _PagArrow(
                icon: Icons.chevron_right_rounded,
                enabled: hasNext,
                onTap: () => onPage(currentPage + 1),
              ),
            ],
          ),
        ],
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
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: _border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? _t1 : _t2.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}

Widget _loadingWidget() => const Center(
  child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
);

Widget _emptyWidget(String message) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.inbox_rounded, size: 32, color: _t2.withOpacity(0.4)),
      const SizedBox(height: 10),
      Text(message, style: const TextStyle(fontSize: 13, color: _t2)),
    ],
  ),
);
