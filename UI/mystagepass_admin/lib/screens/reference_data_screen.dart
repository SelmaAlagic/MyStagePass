import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mystagepass_admin/models/City/city.dart';
import 'package:mystagepass_admin/models/Country/country.dart';
import 'package:mystagepass_admin/models/Location/location.dart';
import 'package:mystagepass_admin/providers/city_provider.dart';
import 'package:mystagepass_admin/providers/country_provider.dart';
import 'package:mystagepass_admin/providers/location_provider.dart';
import 'package:mystagepass_admin/utils/alert_helpers.dart';
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
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);

class ReferenceDataScreen extends StatefulWidget {
  final int userId;
  const ReferenceDataScreen({super.key, required this.userId});

  @override
  State<ReferenceDataScreen> createState() => _ReferenceDataScreenState();
}

class _ReferenceDataScreenState extends State<ReferenceDataScreen> {
  int _activeTab = 0;
  Country? _selectedCountry;
  City? _selectedCity;

  void _selectCountry(Country country) {
    setState(() {
      _selectedCountry = country;
      _selectedCity = null;
      _activeTab = 1;
    });
  }

  void _selectCity(City city) {
    setState(() {
      _selectedCity = city;
      _activeTab = 2;
    });
  }

  void _goToCountries() {
    setState(() {
      _activeTab = 0;
      _selectedCountry = null;
      _selectedCity = null;
    });
  }

  void _goToCities() {
    setState(() {
      _activeTab = 1;
      _selectedCity = null;
    });
  }

  void _clearCountrySelection() {
    setState(() {
      _selectedCountry = null;
    });
  }

  void _clearCitySelection() {
    setState(() {
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      userId: widget.userId,
      activeRouteKey: SidebarRoutes.referenceData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildTabBar(),
                const SizedBox(height: 24),
                if (_activeTab == 0)
                  _CountriesTab(onCountrySelected: _selectCountry)
                else if (_activeTab == 1)
                  _CitiesTab(
                    selectedCountry: _selectedCountry,
                    onBack: _goToCountries,
                    onCitySelected: _selectCity,
                    onCountryCleared: _clearCountrySelection,
                    onFilterCountryChanged: (country) {
                      setState(() => _selectedCountry = country);
                    },
                  )
                else
                  _LocationsTab(
                    selectedCity: _selectedCity,
                    selectedCountry: _selectedCountry,
                    onBackToCountries: _goToCountries,
                    onBackToCities: _goToCities,
                    onCityCleared: _clearCitySelection,
                    onFilterCityChanged: (city) {
                      setState(() => _selectedCity = city);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    List<Widget> breadcrumbs = [
      GestureDetector(
        onTap: _activeTab > 0 ? _goToCountries : null,
        child: Text(
          'Reference Data',
          style: TextStyle(
            fontSize: 13,
            color: _activeTab > 0 ? _navyMid : _t2,
            fontWeight: FontWeight.w600,
            decoration: _activeTab > 0 ? TextDecoration.underline : null,
          ),
        ),
      ),
    ];
    if (_activeTab >= 1 && _selectedCountry != null) {
      breadcrumbs.add(
        const Text(' › ', style: TextStyle(fontSize: 13, color: _t2)),
      );
      breadcrumbs.add(
        GestureDetector(
          onTap: _activeTab > 1 ? _goToCities : null,
          child: Text(
            _selectedCountry!.name ?? '',
            style: TextStyle(
              fontSize: 13,
              color: _activeTab > 1 ? _navyMid : _t2,
              fontWeight: FontWeight.w600,
              decoration: _activeTab > 1 ? TextDecoration.underline : null,
            ),
          ),
        ),
      );
    }
    if (_activeTab == 2 && _selectedCity != null) {
      breadcrumbs.add(
        const Text(' › ', style: TextStyle(fontSize: 13, color: _t2)),
      );
      breadcrumbs.add(
        Text(
          _selectedCity!.name ?? '',
          style: const TextStyle(
            fontSize: 13,
            color: _t2,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final titles = ['Countries', 'Cities', 'Locations'];
    final subtitles = [
      'Manage all countries.',
      _selectedCountry != null
          ? 'Manage cities in ${_selectedCountry!.name}.'
          : 'Manage all cities.',
      _selectedCity != null
          ? 'Manage locations in ${_selectedCity!.name}.'
          : 'Manage all locations.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[_activeTab],
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        const SizedBox(height: 4),
        Row(children: breadcrumbs),
        const SizedBox(height: 2),
        Text(
          subtitles[_activeTab],
          style: const TextStyle(fontSize: 13, color: _t2),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabBtn(
            label: 'Countries',
            icon: Icons.public_rounded,
            isActive: _activeTab == 0,
            onTap: _goToCountries,
          ),
          const SizedBox(width: 4),
          _TabBtn(
            label: _selectedCountry != null
                ? 'Cities · ${_selectedCountry!.name}'
                : 'Cities',
            icon: Icons.location_city_rounded,
            isActive: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
          const SizedBox(width: 4),
          _TabBtn(
            label: _selectedCity != null
                ? 'Locations · ${_selectedCity!.name}'
                : 'Locations',
            icon: Icons.place_rounded,
            isActive: _activeTab == 2,
            onTap: () => setState(() => _activeTab = 2),
          ),
        ],
      ),
    );
  }
}

class _CountriesTab extends StatefulWidget {
  final void Function(Country) onCountrySelected;
  const _CountriesTab({required this.onCountrySelected});

  @override
  State<_CountriesTab> createState() => _CountriesTabState();
}

class _CountriesTabState extends State<_CountriesTab> {
  final _provider = CountryProvider();
  List<Country> _items = [];
  bool _loading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrev = false, _hasNext = false;
  final int _pageSize = 6;
  final TextEditingController _search = TextEditingController();
  String _searchQuery = '';
  bool? _statusFilter;
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
        if (_searchQuery.isNotEmpty) 'CountryName': _searchQuery,
        if (_statusFilter != null) 'IsActive': _statusFilter,
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

  Future<void> _showAddEdit({Country? country}) async {
    final nameCtrl = TextEditingController(text: country?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => _NameDialog(
        title: country == null ? 'Add Country' : 'Edit Country',
        icon: Icons.public_rounded,
        label: 'Country Name',
        hint: 'Enter country name...',
        controller: nameCtrl,
        onSave: () => Navigator.pop(ctx, nameCtrl.text.trim()),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
    if (result == null || result.isEmpty) return;
    try {
      if (country == null) {
        await _provider.insert({'name': result, 'isActive': true});

        if (mounted) {
          SnackHelpers.showSuccess(context, 'Country successfully added');
        }
      } else {
        await _provider.update(country.countryId!, {
          'name': result,
          'isActive': country.isActive ?? true,
        });

        if (mounted) {
          SnackHelpers.showSuccess(context, 'Country successfully updated');
        }
      }

      _currentPage = 1;
      _load();
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '').trim();
        SnackHelpers.showError(context, msg);
      }
    }
  }

  Future<void> _deactivate(Country c) async {
    AlertHelpers.showConfirmationAlert(
      context,
      'Deactivate Country',
      'Are you sure you want to deactivate "${c.name}"?\nIt will be marked as inactive.',
      confirmButtonText: 'Deactivate',
      cancelButtonText: 'Cancel',
      isDelete: true,
      highlightText: c.name,
      onConfirm: () async {
        try {
          await _provider.delete(c.countryId!);
          if (mounted) {
            SnackHelpers.showSuccess(
              context,
              '"${c.name}" has been deactivated.',
            );
            setState(() => _currentPage = 1);
            await _load();
          }
        } catch (e) {
          if (mounted) {
            String msg = e.toString().replaceFirst('Exception: ', '').trim();
            SnackHelpers.showError(context, msg);
          }
        }
      },
    );
  }

  Future<void> _restore(Country c) async {
    AlertHelpers.showConfirmationAlert(
      context,
      'Reactivate Country',
      'Are you sure you want to reactivate "${c.name}"?',
      confirmButtonText: 'Reactivate',
      cancelButtonText: 'Cancel',
      isDelete: false,
      highlightText: c.name,
      onConfirm: () async {
        try {
          await _provider.update(c.countryId!, {
            'name': c.name,
            'isActive': true,
          });
          if (mounted) {
            SnackHelpers.showSuccess(
              context,
              '"${c.name}" has been reactivated.',
            );
            setState(() => _currentPage = 1);
            await _load();
          }
        } catch (e) {
          if (mounted) {
            String msg = e.toString().replaceFirst('Exception: ', '').trim();
            SnackHelpers.showError(context, msg);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TableCard(
      title: 'Countries',
      totalCount: _totalCount,
      onAdd: () => _showAddEdit(),
      addLabel: 'Add Country',
      searchController: _search,
      searchQuery: _searchQuery,
      onSearchChanged: _onSearchChanged,
      statusFilter: _statusFilter,
      onStatusChanged: (val) {
        setState(() {
          _statusFilter = val;
          _currentPage = 1;
        });
        _load();
      },
      hasActiveFilters: _searchQuery.isNotEmpty || _statusFilter != null,
      onClearFilters: () {
        _search.clear();
        setState(() {
          _searchQuery = '';
          _statusFilter = null;
          _currentPage = 1;
        });
        _load();
      },
      child: Column(
        children: [
          _TableHeader(
            columns: const [
              _ColDef('#', width: 52),
              _ColDef('Country', flex: 3),
              _ColDef('Cities', width: 90),
              _ColDef('Status', width: 110),
              _ColDef('Actions', width: 100),
            ],
          ),
          if (_loading)
            _loadingWidget()
          else if (_items.isEmpty)
            _emptyWidget('No countries found')
          else
            ..._items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isActive = item.isActive ?? true;
              final cityCount = item.cities?.length ?? 0;
              return _HoverRow(
                isEven: idx % 2 == 0,
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: _numCell(
                        '${(_currentPage - 1) * _pageSize + idx + 1}',
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => widget.onCountrySelected(item),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Row(
                            children: [
                              Text(
                                item.name ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _t1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: _t2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Center(
                        child: Text(
                          '$cityCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _t1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Center(child: _StatusBadge(isActive: isActive)),
                    ),
                    SizedBox(
                      width: 100,
                      child: _ActionsRow(
                        isActive: isActive,
                        onEdit: () => _showAddEdit(country: item),
                        onDeactivate: () => _deactivate(item),
                        onRestore: () => _restore(item),
                      ),
                    ),
                  ],
                ),
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
            label: 'countries',
          ),
        ],
      ),
    );
  }
}

class _CitiesTab extends StatefulWidget {
  final Country? selectedCountry;
  final VoidCallback onBack;
  final void Function(City) onCitySelected;
  final VoidCallback onCountryCleared;
  final void Function(Country?) onFilterCountryChanged;

  const _CitiesTab({
    required this.selectedCountry,
    required this.onBack,
    required this.onCitySelected,
    required this.onCountryCleared,
    required this.onFilterCountryChanged,
  });

  @override
  State<_CitiesTab> createState() => _CitiesTabState();
}

class _CitiesTabState extends State<_CitiesTab> {
  final _cityProvider = CityProvider();
  final _countryProvider = CountryProvider();
  List<City> _items = [];
  List<Country> _countries = [];
  bool _loading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrev = false, _hasNext = false;
  final int _pageSize = 6;
  final TextEditingController _search = TextEditingController();
  String _searchQuery = '';
  Country? _filterCountry;
  bool? _statusFilter;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filterCountry = widget.selectedCountry;
    _loadCountries();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final res = await _countryProvider.get(filter: {'PageSize': 200});
      setState(() => _countries = res.result);
    } catch (_) {}
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{
        'Page': _currentPage - 1,
        'PageSize': _pageSize,
        if (_searchQuery.isNotEmpty) 'CityName': _searchQuery,
        if (_filterCountry != null) 'CountryID': _filterCountry!.countryId,
        if (_statusFilter != null) 'IsActive': _statusFilter,
      };
      final res = await _cityProvider.get(filter: params);
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

  Future<void> _showAddEdit({City? city}) async {
    final nameCtrl = TextEditingController(text: city?.name ?? '');

    Country? selCountry = city != null
        ? _countries.firstWhere(
            (c) => c.countryId == city.countryId,
            orElse: () => _countries.isNotEmpty ? _countries.first : Country(),
          )
        : _filterCountry ?? (_countries.isNotEmpty ? _countries.first : null);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        Country? dialogCountry = selCountry;
        return StatefulBuilder(
          builder: (ctx, setDialog) => _CityDialog(
            title: city == null ? 'Add City' : 'Edit City',
            nameController: nameCtrl,
            countries: _countries,
            selectedCountry: dialogCountry,
            onCountryChanged: (c) {
              setDialog(() => dialogCountry = c);
              selCountry = c;
            },
            onSave: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty || name.length < 2) return;
              Navigator.pop(ctx, {
                'name': name,
                'countryId': dialogCountry?.countryId,
              });
            },
            onCancel: () => Navigator.pop(ctx),
          ),
        );
      },
    );

    if (result == null ||
        (result['name'] as String).isEmpty ||
        result['countryId'] == null)
      return;

    try {
      if (city == null) {
        await _cityProvider.insert({
          'name': result['name'],
          'countryID': result['countryId'],
          'isActive': true,
        });
        if (mounted)
          SnackHelpers.showSuccess(context, 'City successfully added');
      } else {
        await _cityProvider.update(city.cityId!, {
          'name': result['name'],
          'countryID': result['countryId'],
          'isActive': city.isActive ?? true,
        });
        if (mounted)
          SnackHelpers.showSuccess(context, 'City successfully updated');
      }
      _currentPage = 1;
      _load();
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '').trim();
        SnackHelpers.showError(context, msg);
      }
    }
  }

  Future<void> _deactivate(City c) async {
    AlertHelpers.showConfirmationAlert(
      context,
      'Deactivate City',
      'Are you sure you want to deactivate "${c.name}"?\nIt will be marked as inactive.',
      confirmButtonText: 'Deactivate',
      cancelButtonText: 'Cancel',
      isDelete: true,
      highlightText: c.name,
      onConfirm: () async {
        try {
          await _cityProvider.delete(c.cityId!);
          if (mounted) {
            SnackHelpers.showSuccess(
              context,
              '"${c.name}" has been deactivated.',
            );
            setState(() => _currentPage = 1);
            await _load();
          }
        } catch (e) {
          if (mounted) {
            String msg = e.toString().replaceFirst('Exception: ', '').trim();
            SnackHelpers.showError(context, msg);
          }
        }
      },
    );
  }

  Future<void> _restore(City c) async {
    AlertHelpers.showConfirmationAlert(
      context,
      'Reactivate City',
      'Are you sure you want to reactivate "${c.name}"?',
      confirmButtonText: 'Reactivate',
      cancelButtonText: 'Cancel',
      isDelete: false,
      onConfirm: () async {
        try {
          await _cityProvider.update(c.cityId!, {
            'name': c.name,
            'isActive': true,
          });
          if (mounted) {
            SnackHelpers.showSuccess(
              context,
              '"${c.name}" has been reactivated.',
            );
            setState(() => _currentPage = 1);
            await _load();
          }
        } catch (e) {
          if (mounted)
            SnackHelpers.showError(
              context,
              'Failed to reactivate city. Please try again later.',
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TableCard(
      title: _filterCountry != null
          ? 'Cities in ${_filterCountry!.name}'
          : 'Cities',
      totalCount: _totalCount,
      onAdd: () => _showAddEdit(),
      addLabel: 'Add City',
      searchController: _search,
      searchQuery: _searchQuery,
      onSearchChanged: _onSearchChanged,
      statusFilter: _statusFilter,
      onStatusChanged: (val) {
        setState(() {
          _statusFilter = val;
          _currentPage = 1;
        });
        _load();
      },
      hasActiveFilters:
          _searchQuery.isNotEmpty ||
          _filterCountry != null ||
          _statusFilter != null,
      onClearFilters: () {
        _search.clear();
        setState(() {
          _searchQuery = '';
          _filterCountry = null;
          _statusFilter = null;
          _currentPage = 1;
        });
        widget.onCountryCleared();

        _load();
      },
      extraHeader: _CountryDropdown(
        countries: _countries,
        selected: _filterCountry,
        onChanged: (c) {
          setState(() {
            _filterCountry = c;
            _currentPage = 1;
          });
          widget.onFilterCountryChanged(c);
          _load();
        },
      ),
      child: Column(
        children: [
          _TableHeader(
            columns: const [
              _ColDef('#', width: 52),
              _ColDef('City', flex: 3),
              _ColDef('Country', flex: 2),
              _ColDef('Locations', width: 100),
              _ColDef('Status', width: 110),
              _ColDef('Actions', width: 100),
            ],
          ),
          if (_loading)
            _loadingWidget()
          else if (_items.isEmpty)
            _emptyWidget('No cities found')
          else
            ..._items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isActive = item.isActive ?? true;
              final locationCount = item.locations?.length ?? 0;
              return _HoverRow(
                isEven: idx % 2 == 0,
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: _numCell(
                        '${(_currentPage - 1) * _pageSize + idx + 1}',
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => widget.onCitySelected(item),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Row(
                            children: [
                              Text(
                                item.name ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _t1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: _t2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.country?.name ?? 'N/A',
                        style: const TextStyle(fontSize: 12, color: _t2),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Center(
                        child: Text(
                          '$locationCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _t1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Center(child: _StatusBadge(isActive: isActive)),
                    ),
                    SizedBox(
                      width: 100,
                      child: _ActionsRow(
                        isActive: isActive,
                        onEdit: () => _showAddEdit(city: item),
                        onDeactivate: () => _deactivate(item),
                        onRestore: () => _restore(item),
                      ),
                    ),
                  ],
                ),
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
            label: 'cities',
          ),
        ],
      ),
    );
  }
}

class _LocationsTab extends StatefulWidget {
  final City? selectedCity;
  final Country? selectedCountry;
  final VoidCallback onBackToCountries;
  final VoidCallback onBackToCities;
  final VoidCallback onCityCleared;
  final void Function(City?) onFilterCityChanged;

  const _LocationsTab({
    this.selectedCity,
    required this.selectedCountry,
    required this.onBackToCountries,
    required this.onBackToCities,
    required this.onCityCleared,
    required this.onFilterCityChanged,
  });
  @override
  State<_LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<_LocationsTab> {
  final _provider = LocationProvider();
  final _cityProvider = CityProvider();
  List<Location> _items = [];
  List<City> _cities = [];
  bool _loading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrev = false, _hasNext = false;
  final int _pageSize = 6;
  final TextEditingController _search = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;
  City? _filterCity;
  bool? _statusFilter;

  @override
  void initState() {
    super.initState();
    _filterCity = widget.selectedCity;
    _loadCities();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final res = await _cityProvider.get(filter: {'PageSize': 200});
      setState(() => _cities = res.result);
    } catch (_) {}
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{
        'Page': _currentPage - 1,
        'PageSize': _pageSize,
        if (_searchQuery.isNotEmpty) 'LocationName': _searchQuery,
        if (_statusFilter != null) 'IsActive': _statusFilter,
        if (_filterCity != null) 'CityID': _filterCity!.cityId,
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

  Future<void> _showAddEdit({Location? location}) async {
    final nameCtrl = TextEditingController(text: location?.locationName ?? '');
    final addressCtrl = TextEditingController(text: location?.address ?? '');
    final capacityCtrl = TextEditingController(
      text: location?.capacity != null ? '${location!.capacity}' : '',
    );

    if (_cities.isEmpty) await _loadCities();

    City? selCity = location != null
        ? _cities.firstWhere(
            (c) => c.cityId == location.cityId,
            orElse: () =>
                _filterCity ?? (_cities.isNotEmpty ? _cities.first : City()),
          )
        : _filterCity ?? widget.selectedCity;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        City? dialogCity = selCity;
        return StatefulBuilder(
          builder: (ctx, setDialog) => _LocationDialog(
            title: location == null ? 'Add Location' : 'Edit Location',
            nameController: nameCtrl,
            addressController: addressCtrl,
            capacityController: capacityCtrl,
            cities: _cities,
            selectedCity: dialogCity,
            onCityChanged: (c) {
              setDialog(() => dialogCity = c);
              selCity = c;
            },
            onSave: () => Navigator.pop(ctx, {
              'name': nameCtrl.text.trim(),
              'address': addressCtrl.text.trim(),
              'capacity': int.tryParse(capacityCtrl.text) ?? 0,
              'cityId': dialogCity?.cityId,
            }),
            onCancel: () => Navigator.pop(ctx),
          ),
        );
      },
    );

    if (result == null ||
        (result['name'] as String).isEmpty ||
        result['cityId'] == null)
      return;

    final capacity = int.tryParse(result['capacity'].toString());
    if (capacity == null || capacity < 1 || capacity > 100000) return;

    try {
      final body = {
        'locationName': result['name'],
        'address': result['address'],
        'capacity': result['capacity'],
        'cityID': result['cityId'],
        'isActive': location?.isActive ?? true,
      };

      if (location == null) {
        await _provider.insert(body);
        if (mounted)
          SnackHelpers.showSuccess(context, 'Location successfully added');
      } else {
        await _provider.update(location.locationId!, body);
        if (mounted)
          SnackHelpers.showSuccess(context, 'Location successfully updated');
      }
      _currentPage = 1;
      _load();
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '').trim();
        SnackHelpers.showError(context, msg);
      }
    }
  }

  Future<void> _deactivate(Location l) async {
    AlertHelpers.showConfirmationAlert(
      context,
      'Deactivate Location',
      'Are you sure you want to deactivate "${l.locationName}"?\nIt will be marked as inactive.',
      confirmButtonText: 'Deactivate',
      cancelButtonText: 'Cancel',
      isDelete: true,
      highlightText: l.locationName,
      onConfirm: () async {
        try {
          await _provider.delete(l.locationId!);
          if (mounted) {
            SnackHelpers.showSuccess(
              context,
              '"${l.locationName}" has been deactivated.',
            );
            setState(() => _currentPage = 1);
            await _load();
          }
        } catch (e) {
          if (mounted) {
            String msg = e.toString().replaceFirst('Exception: ', '').trim();
            SnackHelpers.showError(context, msg);
          }
        }
      },
    );
  }

  Future<void> _restore(Location l) async {
    AlertHelpers.showConfirmationAlert(
      context,
      'Reactivate Location',
      'Are you sure you want to reactivate "${l.locationName}"?',
      confirmButtonText: 'Reactivate',
      cancelButtonText: 'Cancel',
      isDelete: false,
      highlightText: l.locationName,
      onConfirm: () async {
        try {
          await _provider.update(l.locationId!, {
            'name': l.locationName,
            'isActive': true,
          });
          if (mounted) {
            SnackHelpers.showSuccess(
              context,
              '"${l.locationName}" has been reactivated.',
            );
            setState(() => _currentPage = 1);
            await _load();
          }
        } catch (e) {
          if (mounted)
            SnackHelpers.showError(
              context,
              'Failed to reactivate location. Please try again later.',
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TableCard(
      title: _filterCity != null
          ? 'Locations in ${_filterCity!.name}'
          : 'Locations',
      totalCount: _totalCount,
      onAdd: () => _showAddEdit(),
      addLabel: 'Add Location',
      searchController: _search,
      searchQuery: _searchQuery,
      onSearchChanged: _onSearchChanged,
      statusFilter: _statusFilter,
      onStatusChanged: (val) {
        setState(() {
          _statusFilter = val;
          _currentPage = 1;
        });
        _load();
      },
      hasActiveFilters:
          _searchQuery.isNotEmpty ||
          _filterCity != null ||
          _statusFilter != null,
      onClearFilters: () {
        _search.clear();
        setState(() {
          _searchQuery = '';
          _filterCity = null;
          _statusFilter = null;
          _currentPage = 1;
        });
        widget.onCityCleared();
        _load();
      },
      extraHeader: _CityDropdown(
        cities: _cities,
        selected: _filterCity,
        onChanged: (c) {
          setState(() {
            _filterCity = c;
            _currentPage = 1;
          });
          widget.onFilterCityChanged(c);
          _load();
        },
      ),
      child: Column(
        children: [
          _TableHeader(
            columns: const [
              _ColDef('#', width: 52),
              _ColDef('Location', flex: 3),
              _ColDef('Address', flex: 2),
              _ColDef('Capacity', width: 100),
              _ColDef('Status', width: 110),
              _ColDef('Actions', width: 100),
            ],
          ),
          if (_loading)
            _loadingWidget()
          else if (_items.isEmpty)
            _emptyWidget('No locations found')
          else
            ..._items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final isActive = item.isActive ?? true;
              return _HoverRow(
                isEven: idx % 2 == 0,
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: _numCell(
                        '${(_currentPage - 1) * _pageSize + idx + 1}',
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.locationName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _t1,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.address ?? 'N/A',
                        style: const TextStyle(fontSize: 12, color: _t2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Center(
                        child: Text(
                          '${item.capacity ?? 0}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _t1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Center(child: _StatusBadge(isActive: isActive)),
                    ),
                    SizedBox(
                      width: 100,
                      child: _ActionsRow(
                        isActive: isActive,
                        onEdit: () => _showAddEdit(location: item),
                        onDeactivate: () => _deactivate(item),
                        onRestore: () => _restore(item),
                      ),
                    ),
                  ],
                ),
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
            label: 'locations',
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final String title;
  final int totalCount;
  final VoidCallback onAdd;
  final String addLabel;
  final TextEditingController searchController;
  final String searchQuery;
  final void Function(String) onSearchChanged;
  final Widget child;
  final Widget? extraHeader;
  final VoidCallback? onClearFilters;
  final bool hasActiveFilters;
  final bool? statusFilter;
  final void Function(bool?)? onStatusChanged;

  const _TableCard({
    required this.title,
    required this.totalCount,
    required this.onAdd,
    required this.addLabel,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.child,
    this.extraHeader,
    this.onClearFilters,
    this.hasActiveFilters = false,
    this.statusFilter,
    this.onStatusChanged,
  });

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _t1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _navyMid.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$totalCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _navyMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              searchQuery.isNotEmpty && searchQuery.length < 3
                              ? _navyMid.withOpacity(0.4)
                              : _border,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
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
                          suffixIcon: searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    onSearchChanged('');
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty && searchQuery.length < 3)
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
                if (onStatusChanged != null) ...[
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    value: statusFilter,
                    onChanged: onStatusChanged!,
                  ),
                ],
                if (extraHeader != null) ...[
                  const SizedBox(width: 8),
                  extraHeader!,
                ],
                if (hasActiveFilters && onClearFilters != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onClearFilters,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_alt_off_rounded,
                              size: 14,
                              color: _t2,
                            ),
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onAdd,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 15,
                            color: _white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            addLabel,
                            style: const TextStyle(
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
          ),
          const Divider(height: 1, color: _border),
          child,
        ],
      ),
    );
  }
}

class _ColDef {
  final String label;
  final int? flex;
  final double? width;
  const _ColDef(this.label, {this.flex, this.width});
}

class _TableHeader extends StatelessWidget {
  final List<_ColDef> columns;
  const _TableHeader({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: columns.map((c) {
          final text = Text(
            c.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _t2,
            ),
          );
          if (c.flex != null) return Expanded(flex: c.flex!, child: text);
          return SizedBox(
            width: c.width,
            child: Center(child: text),
          );
        }).toList(),
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
        height: 54,
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

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _green : _red;
    final bg = isActive ? _green.withOpacity(0.1) : _red.withOpacity(0.08);
    final border = isActive ? _green.withOpacity(0.3) : _red.withOpacity(0.25);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback onDeactivate;
  final VoidCallback onRestore;

  const _ActionsRow({
    required this.isActive,
    required this.onEdit,
    required this.onDeactivate,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isActive)
          _IconBtn(icon: Icons.edit_rounded, color: _navyMid, onTap: onEdit!),
        if (isActive) const SizedBox(width: 6),
        isActive
            ? _IconBtn(
                icon: Icons.block_rounded,
                color: _red,
                onTap: onDeactivate,
              )
            : _IconBtn(
                icon: Icons.restore_rounded,
                color: _green,
                onTap: onRestore,
              ),
      ],
    );
  }
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
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
          duration: const Duration(milliseconds: 120),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? widget.color.withOpacity(0.3) : _border,
            ),
          ),
          child: Icon(widget.icon, size: 15, color: widget.color),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int from, to, total, currentPage, totalPages;
  final bool hasPrev, hasNext;
  final void Function(int) onPage;
  final String label;

  const _PaginationFooter({
    required this.from,
    required this.to,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrev,
    required this.hasNext,
    required this.onPage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (startPage + 4).clamp(1, totalPages);
    if (endPage - startPage < 4) startPage = (endPage - 4).clamp(1, totalPages);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $from to $to of $total $label',
            style: const TextStyle(fontSize: 12, color: _t2),
          ),
          const Spacer(),
          Row(
            children: [
              _PagArrow(
                icon: Icons.chevron_left_rounded,
                enabled: hasPrev,
                onTap: () => onPage(currentPage - 1),
              ),
              const SizedBox(width: 4),
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? _t1 : _t2.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}

class _TabBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;
  const _TabBtn({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_TabBtn> createState() => _TabBtnState();
}

class _TabBtnState extends State<_TabBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isActive
                ? _navyMid
                : (_hovered && !disabled ? _bg : Colors.transparent),
            borderRadius: BorderRadius.circular(9),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: _navyMid.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isActive
                    ? _white
                    : disabled
                    ? _t2.withOpacity(0.4)
                    : _t2,
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isActive
                      ? _white
                      : disabled
                      ? _t2.withOpacity(0.4)
                      : _t2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatefulWidget {
  final bool? value;
  final void Function(bool?) onChanged;

  const _StatusFilterChip({required this.value, required this.onChanged});

  @override
  State<_StatusFilterChip> createState() => _StatusFilterChipState();
}

class _StatusFilterChipState extends State<_StatusFilterChip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  bool _open = false;

  void _toggle() => _open ? _close() : _openOverlay();

  void _openOverlay() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
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
              link: _link,
              offset: const Offset(0, 42),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(6),
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
                      _option(null, 'All', Icons.tune_rounded, _t2),
                      _option(
                        true,
                        'Active',
                        Icons.check_circle_outline_rounded,
                        _green,
                      ),
                      _option(false, 'Inactive', Icons.cancel_outlined, _red),
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

  Widget _option(bool? val, String label, IconData icon, Color color) {
    final isSelected = widget.value == val;
    return GestureDetector(
      onTap: () {
        _close();
        widget.onChanged(val);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _bg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? _t1 : _t2,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 13, color: _navyMid),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.value != null;
    final label = widget.value == null
        ? 'Status'
        : widget.value!
        ? 'Active'
        : 'Inactive';
    final labelColor = widget.value == null
        ? _t1
        : widget.value!
        ? _green
        : _red;

    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _open || isActive ? const Color(0xFFE8EDFF) : _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _open || isActive ? _navyMid.withOpacity(0.4) : _border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? labelColor : _t1,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _open || isActive ? _navyMid : _t2,
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

class _CountryDropdown extends StatefulWidget {
  final List<Country> countries;
  final Country? selected;
  final void Function(Country?) onChanged;

  const _CountryDropdown({
    required this.countries,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<_CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<_CountryDropdown> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  bool _open = false;

  void _toggle() => _open ? _close() : _openOverlay();

  void _openOverlay() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
  }

  @override
  void didUpdateWidget(covariant _CountryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _overlay?.markNeedsBuild();
    }
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
              link: _link,
              offset: const Offset(0, 42),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  constraints: const BoxConstraints(maxHeight: 260),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dropItem(null, 'All Countries'),
                        ...widget.countries.map(
                          (c) => _dropItem(c, c.name ?? ''),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropItem(Country? value, String label) {
    final isSelected = widget.selected?.countryId == value?.countryId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _close();
        widget.onChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _bg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? _t1 : _t2,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 14, color: _navyMid),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected != null;
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _open || isActive ? const Color(0xFFE8EDFF) : _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _open || isActive ? _navyMid.withOpacity(0.4) : _border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selected?.name ?? 'All Countries',
                  style: TextStyle(
                    fontSize: 13,
                    color: _open || isActive ? _navyMid : _t1,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _open || isActive ? _navyMid : _t2,
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

class _CityDropdown extends StatefulWidget {
  final List<City> cities;
  final City? selected;
  final void Function(City?) onChanged;

  const _CityDropdown({
    required this.cities,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<_CityDropdown> createState() => _CityDropdownState();
}

class _CityDropdownState extends State<_CityDropdown> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  bool _open = false;

  void _toggle() => _open ? _close() : _openOverlay();

  void _openOverlay() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
  }

  @override
  void didUpdateWidget(covariant _CityDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _overlay?.markNeedsBuild();
    }
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
              link: _link,
              offset: const Offset(0, 42),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  constraints: const BoxConstraints(maxHeight: 260),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dropItem(null, 'All Cities'),
                        ...widget.cities.map((c) => _dropItem(c, c.name ?? '')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropItem(City? value, String label) {
    final isSelected = widget.selected?.cityId == value?.cityId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _close();
        widget.onChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _bg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? _t1 : _t2,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 14, color: _navyMid),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected != null;
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _open || isActive ? const Color(0xFFE8EDFF) : _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _open || isActive ? _navyMid.withOpacity(0.4) : _border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selected?.name ?? 'All Cities',
                  style: TextStyle(
                    fontSize: 13,
                    color: _open || isActive ? _navyMid : _t1,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _open || isActive ? _navyMid : _t2,
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

class _NameDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onSave, onCancel;

  const _NameDialog({
    required this.title,
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
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
                icon: widget.icon,
                onCancel: widget.onCancel,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(widget.label),
                      const SizedBox(height: 8),
                      _validatedField(
                        controller: widget.controller,
                        hint: widget.hint,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'This field is required';
                          if (v.trim().length < 2)
                            return 'Minimum 2 characters';
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

class _CityDialog extends StatefulWidget {
  final String title;
  final TextEditingController nameController;
  final List<Country> countries;
  final Country? selectedCountry;
  final void Function(Country?) onCountryChanged;
  final VoidCallback onSave, onCancel;

  const _CityDialog({
    required this.title,
    required this.nameController,
    required this.countries,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_CityDialog> createState() => _CityDialogState();
}

class _CityDialogState extends State<_CityDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _countryTouched = false;

  @override
  Widget build(BuildContext context) {
    final countryError = _countryTouched && widget.selectedCountry == null
        ? 'Please select a country'
        : null;

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
                icon: Icons.location_city_rounded,
                onCancel: widget.onCancel,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('City Name *'),
                      const SizedBox(height: 8),
                      _validatedField(
                        controller: widget.nameController,
                        hint: 'Enter city name...',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'City name is required';
                          if (v.trim().length < 2)
                            return 'Minimum 2 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel('Country *'),
                      const SizedBox(height: 8),
                      _DialogDropdown<Country>(
                        items: widget.countries,
                        selected: widget.selectedCountry,
                        placeholder: 'Select country...',
                        labelOf: (c) => c.name ?? '',
                        errorText: countryError,
                        onChanged: (c) {
                          setState(() => _countryTouched = true);
                          widget.onCountryChanged(c);
                        },
                      ),
                      if (countryError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            countryError,
                            style: const TextStyle(fontSize: 11, color: _red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _dialogFooter(
                onCancel: widget.onCancel,
                onSave: () {
                  setState(() => _countryTouched = true);
                  if ((_formKey.currentState?.validate() ?? false) &&
                      widget.selectedCountry != null) {
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

class _LocationDialog extends StatefulWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController capacityController;
  final List<City> cities;
  final City? selectedCity;
  final void Function(City?) onCityChanged;
  final VoidCallback onSave, onCancel;

  const _LocationDialog({
    required this.title,
    required this.nameController,
    required this.addressController,
    required this.capacityController,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _cityTouched = false;

  @override
  Widget build(BuildContext context) {
    final cityError = _cityTouched && widget.selectedCity == null
        ? 'Please select a city'
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
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
                icon: Icons.place_rounded,
                onCancel: widget.onCancel,
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Location Name *'),
                        const SizedBox(height: 8),
                        _validatedField(
                          controller: widget.nameController,
                          hint: 'Enter location name...',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Location name is required';
                            if (v.trim().length < 2)
                              return 'Minimum 2 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _fieldLabel('Address *'),
                        const SizedBox(height: 8),
                        _validatedField(
                          controller: widget.addressController,
                          hint: 'Enter address...',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Address is required';
                            if (v.trim().length < 5)
                              return 'Minimum 5 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _fieldLabel('Capacity *'),
                        const SizedBox(height: 8),
                        _validatedField(
                          controller: widget.capacityController,
                          hint: 'Enter capacity...',
                          inputType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Capacity is required';
                            final n = int.tryParse(v.trim());
                            if (n == null) return 'Must be a number';
                            if (n <= 0 || n > 100000)
                              return 'Capacity must be between 1 and 100 000';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _fieldLabel('City *'),
                        const SizedBox(height: 8),
                        _DialogDropdown<City>(
                          items: widget.cities,
                          selected:
                              widget.cities.any(
                                (c) => c.cityId == widget.selectedCity?.cityId,
                              )
                              ? widget.selectedCity
                              : null,
                          placeholder: 'Select city...',
                          labelOf: (c) => c.name ?? '',
                          errorText: cityError,
                          onChanged: (c) {
                            setState(() => _cityTouched = true);
                            widget.onCityChanged(c);
                          },
                        ),
                        if (cityError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              cityError,
                              style: const TextStyle(fontSize: 11, color: _red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              _dialogFooter(
                onCancel: widget.onCancel,
                onSave: () {
                  setState(() => _cityTouched = true);
                  if ((_formKey.currentState?.validate() ?? false) &&
                      widget.selectedCity != null) {
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

class _DialogDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? selected;
  final String placeholder;
  final String Function(T) labelOf;
  final void Function(T?) onChanged;
  final String? errorText;

  const _DialogDropdown({
    required this.items,
    required this.selected,
    required this.placeholder,
    required this.labelOf,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<_DialogDropdown<T>> createState() => _DialogDropdownState<T>();
}

class _DialogDropdownState<T> extends State<_DialogDropdown<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  bool _open = false;

  void _toggle() => _open ? _close() : _openOverlay();

  void _openOverlay() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
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
              link: _link,
              offset: const Offset(0, 46),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: 380,
                  ),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView(
                      padding: const EdgeInsets.all(6),
                      shrinkWrap: true,
                      children: widget.items.map((item) {
                        final label = widget.labelOf(item);
                        final isSelected =
                            widget.selected != null &&
                            widget.labelOf(widget.selected as T) == label;
                        return GestureDetector(
                          onTap: () {
                            _close();
                            widget.onChanged(item);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _navyMid.withOpacity(0.06)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected ? _navyMid : _t1,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: _navyMid,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.selected != null;
    final hasError = widget.errorText != null;

    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _open ? _navyMid.withOpacity(0.04) : _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? _red
                    : _open
                    ? _navyMid
                    : hasValue
                    ? _navyMid.withOpacity(0.4)
                    : _border,
                width: _open || hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasValue
                      ? Icons.check_circle_outline_rounded
                      : Icons.search_rounded,
                  size: 16,
                  color: hasValue ? _navyMid : _t2,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValue
                        ? widget.labelOf(widget.selected as T)
                        : widget.placeholder,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasValue ? _t1 : _t2,
                      fontWeight: hasValue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _open ? _navyMid : _t2,
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

Widget _fieldLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _t2,
    ),
  );
}

Widget _validatedField({
  required TextEditingController controller,
  required String hint,
  required String? Function(String?) validator,
  TextInputType? inputType,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    autofocus: true,
    cursorColor: _navy,
    cursorWidth: 1.0,
    keyboardType: inputType,
    maxLines: maxLines,
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
        Icon(Icons.inbox_rounded, size: 36, color: _t2.withOpacity(0.4)),
        const SizedBox(height: 10),
        Text(message, style: const TextStyle(fontSize: 13, color: _t2)),
      ],
    ),
  ),
);

Widget _numCell(String text) => Center(
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _t2,
    ),
  ),
);
