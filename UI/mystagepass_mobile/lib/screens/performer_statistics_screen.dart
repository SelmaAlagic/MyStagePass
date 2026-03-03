import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import '../models/Event/event.dart';
import '../models/PerformerStatistics/statistics.dart';
import '../providers/performer_provider.dart';
import 'package:open_file/open_file.dart';

class StatisticsScreen extends StatefulWidget {
  final int userId;

  const StatisticsScreen({super.key, required this.userId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final GlobalKey _monthKey = GlobalKey();
  final GlobalKey _eventKey = GlobalKey();

  List<Event> _myEvents = [];
  bool _isLoadingEvents = true;
  bool _isLoadingStats = false;

  int? _selectedMonth;
  Event? _selectedEvent;

  Statistics? _statistics;
  bool _noData = false;

  final Color _darkBlue = const Color(0xFF1D235D);
  final Color _darkText = const Color(0xFF1D2939);

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  Future<void> _loadMyEvents() async {
    try {
      final provider = Provider.of<PerformerProvider>(context, listen: false);
      final result = await provider.getMyEvents();
      setState(() {
        _myEvents = result.result;
        _isLoadingEvents = false;
      });
    } catch (e) {
      setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      _isLoadingStats = true;
      _statistics = null;
      _noData = false;
    });

    try {
      final provider = Provider.of<PerformerProvider>(context, listen: false);
      Statistics? stats;

      if (_selectedEvent != null) {
        stats = await provider.getMyStatistics(
          eventId: _selectedEvent!.eventID,
        );
      } else if (_selectedMonth != null) {
        final now = DateTime.now();
        if (_selectedMonth! > now.month) {
          setState(() {
            _noData = true;
            _isLoadingStats = false;
          });
          return;
        }
        stats = await provider.getMyStatistics(
          month: _selectedMonth,
          year: now.year,
        );
      }

      setState(() {
        _statistics = stats;
        _noData = stats == null || (stats.totalTicketsSold ?? 0) == 0;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
        _noData = true;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedMonth = null;
      _selectedEvent = null;
      _statistics = null;
      _noData = false;
    });
  }

  bool get _hasActiveFilter => _selectedMonth != null || _selectedEvent != null;

  Future<void> _exportPdf() async {
    if (_statistics == null) return;

    final stats = _statistics!;
    final totalRevenue = stats.totalRevenue ?? 0.0;
    final totalTickets = stats.totalTicketsSold ?? 0;
    final regularRevenue = stats.regularRevenue ?? 0.0;
    final vipRevenue = stats.vipRevenue ?? 0.0;
    final premiumRevenue = stats.premiumRevenue ?? 0.0;
    final regularTickets = stats.regularTicketsSold ?? 0;
    final vipTickets = stats.vipTicketsSold ?? 0;
    final premiumTickets = stats.premiumTicketsSold ?? 0;

    final filterLabel = _selectedEvent != null
        ? 'Event: ${_selectedEvent!.eventName ?? ''}'
        : _selectedMonth != null
        ? 'Month: ${_months[_selectedMonth! - 1]} ${DateTime.now().year}'
        : 'All';

    double regularPercent = totalRevenue > 0
        ? (regularRevenue / totalRevenue * 100)
        : 0;
    double vipPercent = totalRevenue > 0
        ? (vipRevenue / totalRevenue * 100)
        : 0;
    double premiumPercent = totalRevenue > 0
        ? (premiumRevenue / totalRevenue * 100)
        : 0;

    final boldFont = pw.Font.timesBold();
    final regularFont = pw.Font.times();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF1D235D),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MyStagePass',
                      style: pw.TextStyle(
                        font: boldFont,
                        color: PdfColors.white,
                        fontSize: 22,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Statistics Report',
                      style: pw.TextStyle(
                        font: regularFont,
                        color: PdfColors.white,
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      filterLabel,
                      style: pw.TextStyle(
                        font: regularFont,
                        color: PdfColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _pdfMetricCard(
                      'Total Tickets Sold',
                      '$totalTickets',
                      const PdfColor.fromInt(0xFF1D235D),
                      boldFont,
                      regularFont,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _pdfMetricCard(
                      'Total Revenue',
                      '${totalRevenue.toStringAsFixed(0)} KM',
                      const PdfColor.fromInt(0xFF2E7D32),
                      boldFont,
                      regularFont,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Revenue by Ticket Type',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: const PdfColor.fromInt(0xFF1D235D),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(color: const PdfColor.fromInt(0xFFEAECF0)),
              pw.SizedBox(height: 16),
              _pdfLegendRow(
                'Regular',
                regularRevenue,
                regularPercent,
                regularTickets,
                const PdfColor.fromInt(0xFF1D235D),
                boldFont,
                regularFont,
              ),
              pw.SizedBox(height: 8),
              _pdfLegendRow(
                'VIP',
                vipRevenue,
                vipPercent,
                vipTickets,
                const PdfColor.fromInt(0xFF6A1B9A),
                boldFont,
                regularFont,
              ),
              pw.SizedBox(height: 8),
              _pdfLegendRow(
                'Premium',
                premiumRevenue,
                premiumPercent,
                premiumTickets,
                const PdfColor.fromInt(0xFF2E7D32),
                boldFont,
                regularFont,
              ),
              pw.SizedBox(height: 32),
              pw.Divider(color: const PdfColor.fromInt(0xFFEAECF0)),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated by MyStagePass · ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      final fileName =
          'mystagepass_statistics_${DateTime.now().millisecondsSinceEpoch}.pdf';

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Could not find storage directory"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "PDF saved to Downloads",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    OpenFile.open(file.path);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text(
                    "OPEN",
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE8F5E9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF2E7D32), width: 1),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _pdfMetricCard(
    String title,
    String value,
    PdfColor color,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFEAECF0)),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 32,
            height: 32,
            decoration: pw.BoxDecoration(
              color: PdfColor(color.red, color.green, color.blue, 0.1),
              borderRadius: pw.BorderRadius.circular(8),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: const PdfColor.fromInt(0xFF1D2939),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                value,
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfLegendRow(
    String label,
    double revenue,
    double percent,
    int tickets,
    PdfColor color,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFEAECF0)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(6),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(font: boldFont, fontSize: 12),
            ),
          ),
          pw.Text(
            '$tickets tickets',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 11,
              color: PdfColors.grey,
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Text(
            '${revenue.toStringAsFixed(0)} KM',
            style: pw.TextStyle(font: boldFont, fontSize: 12, color: color),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              color: PdfColor(color.red, color.green, color.blue, 0.1),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              '${percent.toStringAsFixed(1)}%',
              style: pw.TextStyle(font: boldFont, fontSize: 10, color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthDropdown() async {
    final now = DateTime.now();
    final RenderBox? buttonBox =
        _monthKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final offset = buttonBox.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + buttonBox.size.height,
        offset.dx + buttonBox.size.width,
        0,
      ),
      elevation: 8,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return SizedBox(
                width: buttonBox.size.width,
                height: 220,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: now.month,
                        itemBuilder: (ctx, index) {
                          final monthNum = index + 1;
                          final isSelected = _selectedMonth == monthNum;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMonth = monthNum;
                                _selectedEvent = null;
                                _statistics = null;
                                _noData = false;
                              });
                              Navigator.pop(context);
                              _fetchStatistics();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              color: isSelected
                                  ? _darkBlue.withOpacity(0.07)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 16,
                                    color: isSelected
                                        ? _darkBlue
                                        : Colors.grey[500],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _months[index],
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: isSelected
                                            ? _darkBlue
                                            : _darkText,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: _darkBlue,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Done",
                        style: GoogleFonts.nunito(
                          color: _darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEventDropdown() async {
    final RenderBox? buttonBox =
        _eventKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final offset = buttonBox.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + buttonBox.size.height,
        offset.dx + buttonBox.size.width,
        0,
      ),
      elevation: 8,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return SizedBox(
                width: buttonBox.size.width,
                height: 220,
                child: _myEvents.isEmpty
                    ? Center(
                        child: Text(
                          "No events found",
                          style: GoogleFonts.nunito(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _myEvents.length,
                              itemBuilder: (ctx, index) {
                                final event = _myEvents[index];
                                final isSelected =
                                    _selectedEvent?.eventID == event.eventID;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedEvent = event;
                                      _selectedMonth = null;
                                      _statistics = null;
                                      _noData = false;
                                    });
                                    Navigator.pop(context);
                                    _fetchStatistics();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    color: isSelected
                                        ? _darkBlue.withOpacity(0.07)
                                        : Colors.transparent,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.event_rounded,
                                          size: 16,
                                          color: isSelected
                                              ? _darkBlue
                                              : Colors.grey[500],
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            event.eventName ?? '',
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? _darkBlue
                                                  : _darkText,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: _darkBlue,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Done",
                              style: GoogleFonts.nunito(
                                color: _darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF5F6F8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1D235D),
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Statistics",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                  const Spacer(),
                  if (_statistics != null) ...[
                    GestureDetector(
                      onTap: _exportPdf,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _darkBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _darkBlue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 14,
                              color: _darkBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Export",
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_hasActiveFilter)
                    GestureDetector(
                      onTap: _clearFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.red[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Clear",
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Filter by Month"),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: _selectedEvent != null ? 0.4 : 1.0,
                      child: IgnorePointer(
                        ignoring: _selectedEvent != null,
                        child: GestureDetector(
                          key: _monthKey,
                          onTap: _showMonthDropdown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedEvent != null
                                  ? const Color(0xFFF0F0F0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEAECF0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  color: _darkBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedMonth != null
                                        ? _months[_selectedMonth! - 1]
                                        : "Select month",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: _selectedMonth != null
                                          ? _darkText
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: _darkBlue),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader("Filter by Event"),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: _selectedMonth != null ? 0.4 : 1.0,
                      child: IgnorePointer(
                        ignoring: _selectedMonth != null,
                        child: GestureDetector(
                          key: _eventKey,
                          onTap: _isLoadingEvents ? null : _showEventDropdown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedMonth != null
                                  ? const Color(0xFFF0F0F0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEAECF0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_rounded,
                                  color: _darkBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _isLoadingEvents
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              height: 14,
                                              width: 14,
                                              child: CircularProgressIndicator(
                                                color: _darkBlue,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "Loading events...",
                                              style: GoogleFonts.nunito(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          _selectedEvent?.eventName ??
                                              "Select event",
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            color: _selectedEvent != null
                                                ? _darkText
                                                : Colors.grey[400],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                                Icon(Icons.arrow_drop_down, color: _darkBlue),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoadingStats)
                      Center(child: CircularProgressIndicator(color: _darkBlue))
                    else if (_noData)
                      _buildNoDataCard()
                    else if (_statistics != null)
                      _buildStatisticsContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _darkBlue,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Color(0xFFEAECF0), thickness: 1)),
      ],
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _darkBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bar_chart_rounded, size: 36, color: _darkBlue),
          ),
          const SizedBox(height: 12),
          Text(
            "No statistics available",
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _darkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedMonth != null && _selectedMonth! > DateTime.now().month
                ? "This month hasn't passed yet."
                : "No ticket sales found for the selected filter.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent() {
    final stats = _statistics!;
    final totalRevenue = stats.totalRevenue ?? 0.0;
    final totalTickets = stats.totalTicketsSold ?? 0;
    final regularRevenue = stats.regularRevenue ?? 0.0;
    final vipRevenue = stats.vipRevenue ?? 0.0;
    final premiumRevenue = stats.premiumRevenue ?? 0.0;
    final regularTickets = stats.regularTicketsSold ?? 0;
    final vipTickets = stats.vipTicketsSold ?? 0;
    final premiumTickets = stats.premiumTicketsSold ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Tickets Sold",
                "$totalTickets",
                Icons.confirmation_number_rounded,
                _darkBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                "Total Revenue",
                "${totalRevenue.toStringAsFixed(0)} KM",
                Icons.attach_money_rounded,
                const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader("Revenue by Ticket Type"),
        const SizedBox(height: 16),
        if (totalRevenue > 0)
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(
                painter: PieChartPainter(
                  regularRevenue: regularRevenue,
                  vipRevenue: vipRevenue,
                  premiumRevenue: premiumRevenue,
                  total: totalRevenue,
                ),
              ),
            ),
          )
        else
          Center(
            child: Text(
              "No revenue data",
              style: GoogleFonts.nunito(color: Colors.grey[400]),
            ),
          ),
        const SizedBox(height: 20),
        _buildLegendItem(
          "Regular",
          regularRevenue,
          totalRevenue,
          const Color(0xFF1D235D),
          regularTickets,
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          "VIP",
          vipRevenue,
          totalRevenue,
          const Color(0xFF6A1B9A),
          vipTickets,
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          "Premium",
          premiumRevenue,
          totalRevenue,
          const Color(0xFF2E7D32),
          premiumTickets,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    double revenue,
    double total,
    Color color,
    int ticketCount,
  ) {
    final percent = total > 0 ? (revenue / total * 100) : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _darkText,
              ),
            ),
          ),
          Text(
            "$ticketCount tickets",
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(width: 12),
          Text(
            "${revenue.toStringAsFixed(0)} KM",
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${percent.toStringAsFixed(1)}%",
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double regularRevenue;
  final double vipRevenue;
  final double premiumRevenue;
  final double total;

  PieChartPainter({
    required this.regularRevenue,
    required this.vipRevenue,
    required this.premiumRevenue,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final data = [
      {
        'value': regularRevenue,
        'color': const Color(0xFF1D235D),
        'label': 'Regular',
      },
      {'value': vipRevenue, 'color': const Color(0xFF6A1B9A), 'label': 'VIP'},
      {
        'value': premiumRevenue,
        'color': const Color(0xFF2E7D32),
        'label': 'Premium',
      },
    ];

    double startAngle = -pi / 2;

    for (final item in data) {
      final value = item['value'] as double;
      final color = item['color'] as Color;
      final label = item['label'] as String;
      if (value <= 0) continue;

      final sweepAngle = (value / total) * 2 * pi;
      final percent = (value / total * 100);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      if (percent >= 8) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.65;
        final labelX = center.dx + labelRadius * cos(labelAngle);
        final labelY = center.dy + labelRadius * sin(labelAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$label\n',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '${percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelX - textPainter.width / 2,
            labelY - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle;
    }

    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()
        ..color = const Color(0xFFF8F9FB)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
