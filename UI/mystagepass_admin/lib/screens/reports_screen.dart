import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mystagepass_admin/models/Report/report.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mystagepass_admin/providers/report_provider.dart';
import 'package:mystagepass_admin/models/Chart/chart.dart';
import 'package:mystagepass_admin/widgets/sidebar_layout.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);

const _chartPerformer = Color(0xFF2D3A8C);
const _chartLocation = Color(0xFF0891B2);

const _kPdfPrimary = PdfColor.fromInt(0xFF1D2359);
const _kPdfPrimaryLight = PdfColor.fromInt(0xFF2D3A8C);
const _kPdfGrey = PdfColor.fromInt(0xFF4A5568);
const _kPdfBorder = PdfColor.fromInt(0xFFECEFF8);

class ReportsScreen extends StatefulWidget {
  final int userId;
  const ReportsScreen({super.key, required this.userId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  static const _months = [
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  Future<void> _loadReport() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    await provider.fetchMonthlyReport(_selectedMonth, _selectedYear);
  }

  void _showPeriodPicker() {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
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
                            Icons.calendar_month_rounded,
                            color: _white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Select Period',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _white,
                          ),
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

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _pickerLabel('Month'),
                        const SizedBox(height: 8),
                        _PeriodDropdown<int>(
                          value: tempMonth,
                          label: _months[tempMonth - 1],
                          options: List.generate(
                            12,
                            (i) =>
                                _PeriodOption(label: _months[i], value: i + 1),
                          ),
                          onChanged: (v) => setD(() => tempMonth = v),
                        ),
                        const SizedBox(height: 16),
                        _pickerLabel('Year'),
                        const SizedBox(height: 8),
                        _PeriodDropdown<int>(
                          value: tempYear,
                          label: tempYear.toString(),
                          options: List.generate(5, (i) {
                            final y = DateTime.now().year - i;
                            return _PeriodOption(label: y.toString(), value: y);
                          }),
                          onChanged: (v) => setD(() => tempYear = v),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                              padding: const EdgeInsets.symmetric(vertical: 13),
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
                            onPressed: () {
                              setState(() {
                                _selectedMonth = tempMonth;
                                _selectedYear = tempYear;
                              });
                              Navigator.pop(ctx);
                              _loadReport();
                            },
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
                              'Apply',
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
        ),
      ),
    );
  }

  Widget _pickerLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _t2,
      ),
    ),
  );

  Future<void> _exportPdf() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    final data = provider.reportData;
    if (data == null) return;

    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName: 'report_${_months[_selectedMonth - 1]}_$_selectedYear.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (outputPath == null) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: _white)),
    );

    try {
      final boldFont = await PdfGoogleFonts.nunitoBold();
      final regularFont = await PdfGoogleFonts.nunitoRegular();
      final semiBoldFont = await PdfGoogleFonts.nunitoSemiBold();

      final performerSales = (data.performerSales ?? [])
          .where((e) => (e.value ?? 0) > 0)
          .toList();
      final locationSales = (data.locationSales ?? [])
          .where((e) => (e.value ?? 0) > 0)
          .toList();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: pw.BoxDecoration(
                  color: _kPdfPrimary,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MyStagePass',
                          style: pw.TextStyle(
                            font: boldFont,
                            color: PdfColors.white,
                            fontSize: 20,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Sales Overview Report',
                          style: pw.TextStyle(
                            font: regularFont,
                            color: PdfColors.grey300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      '${_months[_selectedMonth - 1]} $_selectedYear',
                      style: pw.TextStyle(
                        font: semiBoldFont,
                        color: PdfColors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _pdfMetricCard(
                      'Total Tickets Sold',
                      '${data.totalTicketsSold ?? 0}',
                      boldFont,
                      regularFont,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _pdfMetricCard(
                      'Total Revenue',
                      '${(data.totalRevenue ?? 0).toStringAsFixed(0)} KM',
                      boldFont,
                      regularFont,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _pdfMetricCard(
                      'Top Performer',
                      data.topPerformer ?? 'N/A',
                      boldFont,
                      regularFont,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _pdfMetricCard(
                      'Top Location',
                      data.topLocation ?? 'N/A',
                      boldFont,
                      regularFont,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              _pdfSectionTitle('Top Performers by Ticket Sales', boldFont),
              pw.SizedBox(height: 8),
              if (performerSales.isNotEmpty)
                _pdfTable(performerSales, boldFont, regularFont, semiBoldFont)
              else
                _pdfEmptyRow(regularFont),
              pw.SizedBox(height: 20),
              _pdfSectionTitle('Top Locations by Ticket Sales', boldFont),
              pw.SizedBox(height: 8),
              if (locationSales.isNotEmpty)
                _pdfTable(locationSales, boldFont, regularFont, semiBoldFont)
              else
                _pdfEmptyRow(regularFont),
              pw.Spacer(),
              pw.Divider(color: _kPdfBorder),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated by MyStagePass',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final bytes = await pdf.save();
      await File(outputPath).writeAsBytes(bytes);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF15803D),
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'PDF saved successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF14532D),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  OpenFile.open(outputPath);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'OPEN',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDCFCE7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF86EFAC), width: 1.5),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving PDF: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  pw.Widget _pdfSectionTitle(String text, pw.Font boldFont) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: pw.BoxDecoration(
      color: _kPdfPrimary,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.white),
    ),
  );

  pw.Widget _pdfEmptyRow(pw.Font regularFont) => pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _kPdfBorder, width: 0.5),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Text(
      'No data available',
      style: pw.TextStyle(
        font: regularFont,
        fontSize: 9,
        color: PdfColors.grey,
      ),
    ),
  );

  pw.Widget _pdfMetricCard(
    String label,
    String value,
    pw.Font boldFont,
    pw.Font regularFont,
  ) => pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: const PdfColor.fromInt(0xFFF0F2FA),
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _kPdfBorder, width: 0.5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: regularFont, fontSize: 7, color: _kPdfGrey),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 12,
            color: _kPdfPrimary,
          ),
          maxLines: 2,
        ),
      ],
    ),
  );

  pw.Widget _pdfTable(
    List<Chart> items,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font semiBoldFont,
  ) {
    final totalValue = items.fold<num>(0, (sum, e) => sum + (e.value ?? 0));
    return pw.Table(
      border: pw.TableBorder.all(color: _kPdfBorder, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.8),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _kPdfPrimary),
          children: [
            _pdfCell('#', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('Name', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('Tickets', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('% of Total', boldFont, PdfColors.white, isHeader: true),
          ],
        ),
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final pct = totalValue > 0 ? (item.value ?? 0) / totalValue : 0.0;
          final rowBg = idx % 2 == 0
              ? const PdfColor.fromInt(0xFFF7F8FC)
              : PdfColors.white;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: rowBg),
            children: [
              _pdfCell('${idx + 1}', regularFont, PdfColors.grey600),
              _pdfCell(
                item.name ?? 'N/A',
                semiBoldFont,
                const PdfColor.fromInt(0xFF1D2939),
              ),
              _pdfCell('${item.value ?? 0}', boldFont, _kPdfPrimary),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 7,
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      height: 7,
                      width: 70 * pct,
                      decoration: pw.BoxDecoration(
                        color: _kPdfPrimaryLight,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfCell(
    String text,
    pw.Font font,
    PdfColor color, {
    bool isHeader = false,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: isHeader ? 9 : 8, color: color),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      userId: widget.userId,
      activeRouteKey: SidebarRoutes.reports,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 24),
                Consumer<ReportProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const SizedBox(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _navyMid,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    if (provider.error != null) {
                      return _buildError(provider.error!);
                    }
                    final data = provider.reportData;
                    if (data == null) return _buildNoData();
                    return _buildDashboard(data);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Sales Overview',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _t1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Monthly ticket sales and revenue analytics.',
              style: TextStyle(fontSize: 13, color: _t2),
            ),
          ],
        ),
        const Spacer(),

        GestureDetector(
          onTap: _showPeriodPicker,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10),
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
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 15,
                    color: _navyMid,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_months[_selectedMonth - 1]} $_selectedYear',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _t1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _t2,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Consumer<ReportProvider>(
          builder: (_, provider, __) => Opacity(
            opacity: provider.reportData != null ? 1.0 : 0.4,
            child: GestureDetector(
              onTap: provider.reportData != null ? _exportPdf : null,
              child: MouseRegion(
                cursor: provider.reportData != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: Container(
                  height: 40,
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
                      Icon(Icons.download_rounded, size: 15, color: _white),
                      SizedBox(width: 7),
                      Text(
                        'Export PDF',
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
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(Report data) {
    return Column(
      children: [
        Row(
          children: [
            _MetricCard(
              label: 'Total Tickets Sold',
              value: '${data.totalTicketsSold ?? 0}',
              icon: Icons.confirmation_number_outlined,
              accentColor: _navyMid,
            ),
            const SizedBox(width: 14),
            _MetricCard(
              label: 'Total Revenue',
              value: '${(data.totalRevenue ?? 0).toStringAsFixed(0)} KM',
              icon: Icons.payments_outlined,
              accentColor: const Color(0xFF059669),
            ),
            const SizedBox(width: 14),
            _MetricCard(
              label: 'Top Performer',
              value: data.topPerformer ?? 'N/A',
              icon: Icons.mic_rounded,
              accentColor: const Color(0xFF7C3AED),
            ),
            const SizedBox(width: 14),
            _MetricCard(
              label: 'Top Location',
              value: data.topLocation ?? 'N/A',
              icon: Icons.location_on_outlined,
              accentColor: const Color(0xFFD97706),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ChartCard(
                title: 'Top Performers',
                subtitle: 'by ticket sales',
                icon: Icons.mic_rounded,
                accentColor: _chartPerformer,
                child: _buildBarChart(
                  data: (data.performerSales ?? [])
                      .where((e) => (e.value ?? 0) > 0)
                      .toList(),
                  xLabel: 'Performer',
                  yLabel: 'Tickets',
                  color: _chartPerformer,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _ChartCard(
                title: 'Top Locations',
                subtitle: 'by ticket sales',
                icon: Icons.location_on_outlined,
                accentColor: _chartLocation,
                child: _buildBarChart(
                  data: (data.locationSales ?? [])
                      .where((e) => (e.value ?? 0) > 0)
                      .toList(),
                  xLabel: 'Location',
                  yLabel: 'Tickets',
                  color: _chartLocation,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart({
    required List<Chart> data,
    required String xLabel,
    required String yLabel,
    required Color color,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: _t2.withOpacity(0.3),
            ),
            const SizedBox(height: 10),
            Text(
              'No data available',
              style: TextStyle(color: _t2.withOpacity(0.6), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final maxValue = data
        .map((e) => e.value ?? 0)
        .reduce((a, b) => a > b ? a : b);
    final double maxY = (maxValue * 1.25).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY == 0 ? 10 : maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => _navy.withOpacity(0.92),
            tooltipRoundedRadius: 10,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${data[group.x].name ?? ''}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: '${rod.toY.toInt()} tickets',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                String label = data[index].name ?? '';
                if (label.length > 9) label = '${label.substring(0, 8)}..';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: maxY == 0 ? 2 : maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: _t2),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY == 0 ? 2 : maxY / 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: _border, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: _border),
            left: BorderSide(color: _border),
          ),
        ),
        barGroups: data
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: (entry.value.value ?? 0).toDouble(),
                    width: 26,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.45), color],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildNoData() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: _t2.withOpacity(0.3)),
          const SizedBox(height: 14),
          const Text(
            'No data available for this period',
            style: TextStyle(fontSize: 14, color: _t2),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFFB91C1C)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navyMid,
              foregroundColor: _white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _t2,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: _t2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            color: _border,
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          SizedBox(height: 280, child: child),
        ],
      ),
    );
  }
}

class _PeriodOption<T> {
  final String label;
  final T value;
  const _PeriodOption({required this.label, required this.value});
}

class _PeriodDropdown<T> extends StatefulWidget {
  final T value;
  final String label;
  final List<_PeriodOption<T>> options;
  final void Function(T) onChanged;

  const _PeriodDropdown({
    required this.value,
    required this.label,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_PeriodDropdown<T>> createState() => _PeriodDropdownState<T>();
}

class _PeriodDropdownState<T> extends State<_PeriodDropdown<T>> {
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
              offset: const Offset(0, 46),
              child: Material(
                color: Colors.transparent,
                child: _PeriodDropdownMenu<T>(
                  options: widget.options,
                  selectedValue: widget.value,
                  onSelect: (val) {
                    _close();
                    widget.onChanged(val);
                  },
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
    _overlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _isOpen ? const Color(0xFFE8EDFF) : _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOpen ? _navyMid.withOpacity(0.4) : _border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isOpen ? _navyMid : _t1,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _isOpen ? _navyMid : _t2,
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

class _PeriodDropdownMenu<T> extends StatelessWidget {
  final List<_PeriodOption<T>> options;
  final T selectedValue;
  final void Function(T) onSelect;

  const _PeriodDropdownMenu({
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt.value == selectedValue;
              return _PeriodDropdownItem(
                label: opt.label,
                isSelected: isSelected,
                onTap: () => onSelect(opt.value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PeriodDropdownItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodDropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PeriodDropdownItem> createState() => _PeriodDropdownItemState();
}

class _PeriodDropdownItemState extends State<_PeriodDropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.isSelected) {
      bg = const Color(0xFFE8EDFF);
    } else if (_hovered) {
      bg = const Color(0xFFF4F6FB);
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected ? _navyMid : _t1,
                  ),
                ),
              ),
              if (widget.isSelected)
                const Icon(Icons.check_rounded, size: 14, color: _navyMid),
            ],
          ),
        ),
      ),
    );
  }
}
