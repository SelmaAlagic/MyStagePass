import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mystagepass_admin/models/Genre/genre.dart';
import 'package:mystagepass_admin/providers/genre_provider.dart';
import 'package:mystagepass_admin/utils/snack_helpers.dart';
import 'package:mystagepass_admin/widgets/sidebar_layout.dart';

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

class GenresScreen extends StatelessWidget {
  final int userId;
  const GenresScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      userId: userId,
      activeRouteKey: SidebarRoutes.genres,
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
                const _GenresBody(),
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
          'Genres',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Global Administration',
          style: TextStyle(
            fontSize: 13,
            color: _t2,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Manage music genres and browse their associated performers.',
          style: TextStyle(fontSize: 13, color: _t2),
        ),
      ],
    );
  }
}

class _GenresBody extends StatefulWidget {
  const _GenresBody();

  @override
  State<_GenresBody> createState() => _GenresBodyState();
}

class _GenresBodyState extends State<_GenresBody> {
  Genre? _selectedGenre;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _GenresTable(
            selectedGenre: _selectedGenre,
            onGenreSelected: (g) => setState(() => _selectedGenre = g),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _PerformersPanel(genre: _selectedGenre)),
      ],
    );
  }
}

class _GenresTable extends StatefulWidget {
  final Genre? selectedGenre;
  final void Function(Genre) onGenreSelected;

  const _GenresTable({
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  @override
  State<_GenresTable> createState() => _GenresTableState();
}

class _GenresTableState extends State<_GenresTable> {
  final _provider = GenreProvider();

  List<Genre> _items = [];
  bool _loading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrev = false, _hasNext = false;
  final int _pageSize = 7;

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
    } catch (e) {
      debugPrint('GenresTable _load error: $e');
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

  Future<void> _showAdd() async {
    final nameCtrl = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => _GenreDialog(
        title: 'Add Genre',
        controller: nameCtrl,
        onSave: () => Navigator.pop(ctx, nameCtrl.text.trim()),
        onCancel: () => Navigator.pop(ctx),
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      await _provider.insert({'name': result});

      if (mounted) {
        SnackHelpers.showSuccess(context, 'Genre added successfully!');
      }

      _currentPage = 1;
      _load();
    } catch (e) {
      if (mounted) {
        if (mounted) {
          String msg = e.toString().replaceFirst('Exception: ', '').trim();
          SnackHelpers.showError(context, msg);
        }
      }
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Genres',
                  style: const TextStyle(
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showAdd,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _navyMid,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _navy.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 15, color: _white),
                          SizedBox(width: 5),
                          Text(
                            'Add Genre',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _white,
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
          if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
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
                    'Genre Name',
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
                      'Performers',
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
            _emptyWidget('No genres found')
          else
            ..._items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final performerCount = item.performers?.length ?? 0;
              final isSelected = widget.selectedGenre?.genreId == item.genreId;
              return _GenreRow(
                index: (_currentPage - 1) * _pageSize + idx + 1,
                genre: item,
                performerCount: performerCount,
                isEven: idx % 2 == 0,
                isSelected: isSelected,
                onTap: () => widget.onGenreSelected(item),
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

class _GenreRow extends StatefulWidget {
  final int index;
  final Genre genre;
  final int performerCount;
  final bool isEven;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreRow({
    required this.index,
    required this.genre,
    required this.performerCount,
    required this.isEven,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GenreRow> createState() => _GenreRowState();
}

class _GenreRowState extends State<_GenreRow> {
  bool _hovered = false;

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
          height: 50,
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
                child: Text(
                  widget.genre.name ?? 'N/A',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: widget.isSelected ? _navyMid : _t1,
                  ),
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
                      color: widget.isSelected
                          ? _navyMid.withOpacity(0.15)
                          : _navyMid.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.performerCount}',
                      style: TextStyle(
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

class _PerformersPanel extends StatelessWidget {
  final Genre? genre;
  const _PerformersPanel({required this.genre});

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
      child: genre == null ? _buildEmpty() : _buildList(genre!),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
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
              'Select a genre',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _t1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Click on any genre from the list\nto view its performers here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _t2, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Genre genre) {
    final performers = genre.performers ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                child: const Icon(
                  Icons.music_note_rounded,
                  color: _white,
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      genre.name ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _white,
                      ),
                    ),
                    Text(
                      '${performers.length} performer${performers.length == 1 ? '' : 's'}',
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
        if (performers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 32,
                    color: _t2.withOpacity(0.4),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No performers in this genre',
                    style: TextStyle(fontSize: 13, color: _t2),
                  ),
                ],
              ),
            ),
          )
        else
          ...performers.asMap().entries.map((e) {
            final idx = e.key;
            final name = e.value;
            final isEven = idx % 2 == 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isEven ? _card : const Color(0xFFFAFBFF),
                border: const Border(
                  bottom: BorderSide(color: _border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _navyMid.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _navyMid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _t1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _green.withOpacity(0.2)),
                    ),
                    child: const Text(
                      'Performer',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _green,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _GenreDialog extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _GenreDialog({
    required this.title,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_GenreDialog> createState() => _GenreDialogState();
}

class _GenreDialogState extends State<_GenreDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
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
              _dialogHeader(
                title: widget.title,
                icon: Icons.music_note_rounded,
                onCancel: widget.onCancel,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Genre Name *'),
                      const SizedBox(height: 8),
                      _validatedField(
                        controller: widget.controller,
                        hint: 'Enter genre name...',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Genre name is required';
                          if (v.trim().length < 3)
                            return 'Minimum 3 characters';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _dialogFooter(
                onCancel: widget.onCancel,
                onSave: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    widget.onSave();
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
    if (total == 0) return const SizedBox.shrink();
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (startPage + 4).clamp(1, totalPages);
    if (endPage - startPage < 4) startPage = (endPage - 4).clamp(1, totalPages);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

Widget _dialogHeader({
  required String title,
  required IconData icon,
  required VoidCallback onCancel,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_navy, _navyMid],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _white, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _white,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onCancel,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.close_rounded, color: _white, size: 14),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _dialogFooter({
  required VoidCallback onCancel,
  required VoidCallback onSave,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: const BoxDecoration(
      color: _bg,
      border: Border(top: BorderSide(color: _border)),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: const BorderSide(color: _border, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              foregroundColor: _t2,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navyMid,
              foregroundColor: _white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _fieldLabel(String text) => Text(
  text,
  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _t2),
);

Widget _validatedField({
  required TextEditingController controller,
  required String hint,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,
    autofocus: true,
    cursorColor: _navy,
    cursorWidth: 1.0,
    validator: validator,
    style: const TextStyle(fontSize: 14, color: _t1),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _t2),
      filled: true,
      fillColor: _bg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
        borderSide: const BorderSide(color: _navyMid, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11, color: _red),
    ),
  );
}

Widget _loadingWidget() => const Padding(
  padding: EdgeInsets.symmetric(vertical: 48),
  child: Center(child: CircularProgressIndicator(color: _navy, strokeWidth: 2)),
);

Widget _emptyWidget(String message) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 48),
  child: Center(
    child: Column(
      children: [
        Icon(Icons.inbox_rounded, size: 32, color: _t2.withOpacity(0.4)),
        const SizedBox(height: 10),
        Text(message, style: const TextStyle(fontSize: 13, color: _t2)),
      ],
    ),
  ),
);
