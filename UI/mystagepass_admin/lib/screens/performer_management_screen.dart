import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Performer/performer.dart';
import '../providers/performer_provider.dart';
import '../providers/user_provider.dart';
import 'performer_requests_screen.dart';
import 'dart:async';
import 'package:mystagepass_admin/widgets/sidebar_layout.dart';
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

const _pendingFg = Color(0xFFB45309);
const _pendingBg = Color(0xFFFFF7ED);
const _pendingBorder = Color(0xFFFED7AA);

class PerformerManagementScreen extends StatefulWidget {
  final int userId;
  const PerformerManagementScreen({super.key, required this.userId});

  @override
  State<PerformerManagementScreen> createState() =>
      _PerformerManagementScreenState();
}

class _PerformerManagementScreenState extends State<PerformerManagementScreen> {
  List<Performer> _performers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _statusFilter;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 6;
  final _editFormKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late TextEditingController _editArtistNameController;
  late TextEditingController _editBioController;
  late TextEditingController _editFirstNameController;
  late TextEditingController _editLastNameController;
  late TextEditingController _editEmailController;
  late TextEditingController _editPhoneController;
  late TextEditingController _editUsernameController;

  @override
  void initState() {
    super.initState();
    _editArtistNameController = TextEditingController();
    _editBioController = TextEditingController();
    _editFirstNameController = TextEditingController();
    _editLastNameController = TextEditingController();
    _editEmailController = TextEditingController();
    _editPhoneController = TextEditingController();
    _editUsernameController = TextEditingController();
    _fetchPerformers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _editArtistNameController.dispose();
    _editBioController.dispose();
    _editFirstNameController.dispose();
    _editLastNameController.dispose();
    _editEmailController.dispose();
    _editPhoneController.dispose();
    _editUsernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchPerformers() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final provider = Provider.of<PerformerProvider>(context, listen: false);
      final params = <String, String>{
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
      };
      if (_searchQuery.isNotEmpty && _searchQuery.length >= 3) {
        params['searchTerm'] = _searchQuery;
      }
      if (_statusFilter != null) {
        if (_statusFilter == 'Approved') {
          params['IsApproved'] = 'true';
        } else if (_statusFilter == 'Rejected') {
          params['IsApproved'] = 'false';
        } else if (_statusFilter == 'Pending') {
          params['IsPending'] = 'true';
        }
      }
      final data = await provider.get(filter: params);
      if (mounted) {
        setState(() {
          _performers = data.result;
          _totalPages = data.meta.totalPages;
          _totalCount = data.meta.count ?? 0;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    _fetchPerformers();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _searchQuery = value);
    if (value.length >= 3 || value.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 450), () {
        _currentPage = 1;
        _fetchPerformers();
      });
    }
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  void _showDeactivateConfirm(Performer performer) {
    final name =
        performer.artistName ?? performer.user?.fullName ?? 'this performer';
    AlertHelpers.showConfirmationAlert(
      context,
      'Deactivate Performer',
      'Are you sure you want to deactivate "$name"? Their account will be deactivated immediately.',
      confirmButtonText: 'Deactivate',
      cancelButtonText: 'Cancel',
      isDelete: true,
      onConfirm: () async {
        try {
          final provider = Provider.of<UserProvider>(context, listen: false);
          await provider.deactivate(performer.user!.userId!);
          if (mounted) {
            AlertHelpers.showSuccess(
              context,
              'Performer "$name" has been deactivated successfully.',
            );
            _fetchPerformers();
          }
        } catch (e) {
          if (mounted)
            AlertHelpers.showError(
              context,
              'Failed to deactivate performer: $e',
            );
        }
      },
    );
  }

  void _showEditModal(Performer performer) {
    _editArtistNameController.text = performer.artistName ?? '';
    _editBioController.text = performer.bio ?? '';
    _editFirstNameController.text = performer.user?.firstName ?? '';
    _editLastNameController.text = performer.user?.lastName ?? '';
    _editEmailController.text = performer.user?.email ?? '';
    _editPhoneController.text = performer.user?.phoneNumber ?? '';
    _editUsernameController.text = performer.user?.username ?? '';

    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_navy, _navyMid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
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
                              Icons.edit_rounded,
                              color: _white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Performer',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _white,
                                ),
                              ),
                              Text(
                                performer.artistName ??
                                    performer.user?.fullName ??
                                    '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: _white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Form(
                          key: _editFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _editSectionLabel('Performer Info'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _editFieldValidated(
                                      controller: _editArtistNameController,
                                      label: 'Artist Name',
                                      icon: Icons.star_outline_rounded,
                                      hint: 'Artist name',
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        if (v.trim().length < 5)
                                          return 'Min. 5 characters';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _editFieldValidated(
                                      controller: _editUsernameController,
                                      label: 'Username',
                                      icon: Icons.alternate_email_rounded,
                                      hint: 'Username',
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        if (v.trim().length < 5)
                                          return 'Min. 5 characters';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _editFieldValidated(
                                controller: _editBioController,
                                label: 'Bio',
                                icon: Icons.notes_rounded,
                                hint: 'Enter bio',
                                maxLines: 2,
                                validator: (v) {
                                  if (v == null) return null;
                                  if (v.trim().isNotEmpty &&
                                      v.trim().length < 10)
                                    return 'Min. 10 characters';
                                  if (v.trim().length > 100)
                                    return 'Max. 100 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _editSectionLabel('Personal Info'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _editFieldValidated(
                                      controller: _editFirstNameController,
                                      label: 'First Name',
                                      icon: Icons.person_outline_rounded,
                                      hint: 'First name',
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        if (v.trim().length < 3)
                                          return 'Min. 3 characters';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _editFieldValidated(
                                      controller: _editLastNameController,
                                      label: 'Last Name',
                                      icon: Icons.person_outline_rounded,
                                      hint: 'Last name',
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        if (v.trim().length < 3)
                                          return 'Min. 3 characters';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _editFieldValidated(
                                      controller: _editEmailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      hint: 'Email',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Required';
                                        if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(v.trim()))
                                          return 'Invalid email format';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _editFieldValidated(
                                      controller: _editPhoneController,
                                      label: 'Phone',
                                      icon: Icons.phone_outlined,
                                      hint: 'Phone number',
                                      keyboardType: TextInputType.phone,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return null;
                                        if (!RegExp(
                                          r'^\+?0?\d{8,14}$',
                                        ).hasMatch(v.trim()))
                                          return 'Invalid (8–14 digits)';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      decoration: const BoxDecoration(
                        color: _bg,
                        border: Border(top: BorderSide(color: _border)),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                side: const BorderSide(
                                  color: _border,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                foregroundColor: _t2,
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!(_editFormKey.currentState
                                              ?.validate() ??
                                          false))
                                        return;
                                      setModal(() => isSubmitting = true);
                                      try {
                                        final performerProvider =
                                            Provider.of<PerformerProvider>(
                                              context,
                                              listen: false,
                                            );

                                        await performerProvider.update(
                                          performer.performerId!,
                                          {
                                            'artistName':
                                                _editArtistNameController.text,
                                            'bio': _editBioController.text,
                                            'firstName':
                                                _editFirstNameController.text,
                                            'lastName':
                                                _editLastNameController.text,
                                            'email': _editEmailController.text,
                                            'phoneNumber':
                                                _editPhoneController.text,
                                            'username':
                                                _editUsernameController.text,
                                          },
                                        );

                                        if (mounted) {
                                          Navigator.pop(ctx);
                                          AlertHelpers.showSuccess(
                                            context,
                                            'Performer successfully updated.',
                                          );
                                          _fetchPerformers();
                                        }
                                      } catch (e) {
                                        setModal(() => isSubmitting = false);
                                        if (mounted)
                                          AlertHelpers.showError(
                                            context,
                                            'Failed to update performer: $e',
                                          );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navyMid,
                                foregroundColor: _white,
                                disabledBackgroundColor: _navyMid.withOpacity(
                                  0.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: _white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
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
        },
      ),
    );
  }

  Widget _editSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: _navyMid,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _t1,
          ),
        ),
      ],
    );
  }

  Widget _editFieldValidated({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _t2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          cursorColor: _navy,
          cursorWidth: 1.0,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: _t1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _t2, fontSize: 13),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 12,
                top: maxLines > 1 ? 12 : 0,
                right: 8,
              ),
              child: Icon(icon, size: 16, color: _navyMid),
            ),
            prefixIconConstraints: const BoxConstraints(),
            filled: true,
            fillColor: _bg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
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
              borderSide: BorderSide(color: _navyMid.withOpacity(0.5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _red),
            ),
            errorStyle: const TextStyle(fontSize: 10, color: _red),
          ),
        ),
      ],
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
          'Performer Management',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Overview of all performers in the system.',
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
    final hasActiveFilters = _statusFilter != null || _searchQuery.isNotEmpty;

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
                width: 220,
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
                    hintText: 'Search performers...',
                    hintStyle: TextStyle(color: _t2, fontSize: 13),
                    prefixIcon: Icon(
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
                            child: Icon(
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
          const SizedBox(width: 10),
          _StatusFilterDropdown(
            value: _statusFilter,
            onChanged: (val) {
              setState(() {
                _statusFilter = val;
                _currentPage = 1;
              });
              _fetchPerformers();
            },
          ),
          if (hasActiveFilters) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                setState(() {
                  _statusFilter = null;
                  _searchQuery = '';
                  _currentPage = 1;
                });
                _searchController.clear();
                _fetchPerformers();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 34,
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
              _fadeRoute(PerformerRequestsScreen(userId: widget.userId)),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    Icon(Icons.person_add_alt_rounded, size: 16, color: _white),
                    SizedBox(width: 6),
                    Text(
                      'Performer Requests',
                      style: TextStyle(
                        fontSize: 13,
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
                  Icons.music_note_rounded,
                  size: 36,
                  color: _t2.withOpacity(0.4),
                ),
                const SizedBox(height: 10),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No performers match "$_searchQuery"'
                      : 'No performers found',
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
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
          top: BorderSide(color: _border),
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          _th('#', width: 40),
          _th('Full Name', flex: 2),
          _th('Artist Name', flex: 2),
          _th('Genres', flex: 3),
          _th('Rating', width: 90),
          _th('Status', width: 100),
          _th('Actions', width: 80),
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
    final genresText = performer.genres != null && performer.genres!.isNotEmpty
        ? performer.genres!.join(', ')
        : 'No genres';
    final hasRating =
        performer.averageRating != null && performer.averageRating! > 0;

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
          Expanded(
            flex: 2,
            child: Text(
              performer.user?.fullName ?? 'N/A',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _t1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              performer.artistName ?? 'N/A',
              style: const TextStyle(fontSize: 13, color: _t2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              genresText,
              style: TextStyle(
                fontSize: 13,
                color: performer.genres == null || performer.genres!.isEmpty
                    ? _t2
                    : _t1,
                fontWeight:
                    performer.genres == null || performer.genres!.isEmpty
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 90,
            child: Center(
              child: hasRating
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            performer.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      'No rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: _t2.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Center(child: _buildStatusBadge(performer)),
          ),
          SizedBox(
            width: 80,
            child: Center(child: _buildActionsRow(performer)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Performer performer) {
    Color fg, bg, border;
    String label;

    if (performer.isApproved == true) {
      fg = const Color(0xFF15803D);
      bg = _green.withOpacity(0.1);
      border = _green.withOpacity(0.3);
      label = 'Approved';
    } else if (performer.isApproved == false) {
      fg = const Color(0xFFB91C1C);
      bg = _red.withOpacity(0.08);
      border = _red.withOpacity(0.25);
      label = 'Rejected';
    } else {
      fg = _pendingFg;
      bg = _pendingBg;
      border = _pendingBorder;
      label = 'Pending';
    }

    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(Performer performer) {
    if (performer.isApproved != true) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIconBtn(
          icon: Icons.edit_outlined,
          color: _navyMid,
          onTap: () => _showEditModal(performer),
        ),
        const SizedBox(width: 6),
        _ActionIconBtn(
          icon: Icons.block_rounded,
          color: _red,
          onTap: () => _showDeactivateConfirm(performer),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final from = ((_currentPage - 1) * _pageSize) + 1;
    final to = ((_currentPage - 1) * _pageSize) + _performers.length;

    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (startPage + 4).clamp(1, _totalPages);
    if (endPage - startPage < 4) {
      startPage = (endPage - 4).clamp(1, _totalPages);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $from to $to of $_totalCount performers',
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
}

class _StatusFilterDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _StatusFilterDropdown({required this.value, required this.onChanged});

  @override
  State<_StatusFilterDropdown> createState() => _StatusFilterDropdownState();
}

class _StatusFilterDropdownState extends State<_StatusFilterDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(0, 42),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dropdownOption(
                        label: 'All Statuses',
                        value: null,
                        icon: Icons.tune_rounded,
                        color: _t2,
                      ),
                      _dropdownOption(
                        label: 'Approved',
                        value: 'Approved',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF15803D),
                      ),
                      _dropdownOption(
                        label: 'Rejected',
                        value: 'Rejected',
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFB91C1C),
                      ),
                      _dropdownOption(
                        label: 'Pending',
                        value: 'Pending',
                        icon: Icons.schedule_rounded,
                        color: _pendingFg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownOption({
    required String label,
    required String? value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = widget.value == value;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Material(
        color: isSelected ? _bg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: _bg,
          onTap: () {
            _close();
            widget.onChanged(value);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? _t1 : _t2,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_rounded, size: 14, color: _navyMid),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  IconData get _triggerIcon => switch (widget.value) {
    'Approved' => Icons.check_circle_rounded,
    'Rejected' => Icons.cancel_rounded,
    'Pending' => Icons.schedule_rounded,
    _ => Icons.tune_rounded,
  };

  Color get _triggerColor => switch (widget.value) {
    'Approved' => const Color(0xFF15803D),
    'Rejected' => const Color(0xFFB91C1C),
    'Pending' => _pendingFg,
    _ => _t2,
  };

  @override
  Widget build(BuildContext context) {
    final isActive = widget.value != null;
    final label = widget.value ?? 'Status';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isOpen || isActive ? const Color(0xFFE8EDFF) : _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOpen || isActive
                    ? _navyMid.withOpacity(0.4)
                    : _border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_triggerIcon, size: 14, color: _triggerColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isOpen || isActive ? _navyMid : _t1,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _isOpen || isActive ? _navyMid : _t2,
                  ),
                ),
              ],
            ),
          ),
        ),
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
        height: 60,
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

class _ActionIconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionIconBtn> createState() => _ActionIconBtnState();
}

class _ActionIconBtnState extends State<_ActionIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(0.08) : _white,
            shape: BoxShape.circle,
            border: Border.all(
              color: _hovered ? widget.color.withOpacity(0.3) : _border,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 15,
            color: _hovered ? widget.color : widget.color.withOpacity(0.5),
          ),
        ),
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
