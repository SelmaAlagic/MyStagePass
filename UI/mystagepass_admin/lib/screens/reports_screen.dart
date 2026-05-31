import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mystagepass_admin/models/Report/report.dart';
import 'package:mystagepass_admin/models/CancelledEventsReport/cancelled_events_report.dart';
import 'package:mystagepass_admin/models/CancelledEventItem/cancelled_event_item.dart';
import 'package:mystagepass_admin/models/City/city.dart';
import 'package:mystagepass_admin/utils/snack_helpers.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mystagepass_admin/providers/report_provider.dart';
import 'package:mystagepass_admin/providers/city_provider.dart';
import 'package:mystagepass_admin/providers/cancelled_events_report_provider.dart';
import 'package:mystagepass_admin/models/Chart/chart.dart';
import 'package:mystagepass_admin/widgets/sidebar_layout.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

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
const _kPdfRed = PdfColor.fromInt(0xFFDC2626);
const _kPdfRedLight = PdfColor.fromInt(0xFFFEF2F2);
const _kPdfOrange = PdfColor.fromInt(0xFFD97706);

class ReportsScreen extends StatefulWidget {
  final int userId;
  const ReportsScreen({super.key, required this.userId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _activeTab = 0;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  List<City> cities = [];
  bool _isLoadingCities = false;

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

  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
      _loadCities();
    });
  }

  Future<void> _loadReport() async {
    final p = Provider.of<ReportProvider>(context, listen: false);
    await p.fetchMonthlyReport(_selectedMonth, _selectedYear);
  }

  Future<void> _loadCities() async {
    setState(() => _isLoadingCities = true);
    final cityProvider = Provider.of<CityProvider>(context, listen: false);
    final result = await cityProvider.get(filter: {'PageSize': 200});
    setState(() {
      cities = result.result;
      _isLoadingCities = false;
    });
  }

  Future<void> _loadCancelledReport() async {
    if (_selectedCity == null) return;
    final p = Provider.of<CancelledEventsReportProvider>(
      context,
      listen: false,
    );
    await p.fetchCancelledReport(_selectedCity!.cityId!);
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
    pw.Font regularFont, {
    PdfColor? valueColor,
  }) => pw.Container(
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
            color: valueColor ?? _kPdfPrimary,
          ),
          maxLines: 2,
        ),
      ],
    ),
  );

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

  pw.Widget _pdfSalesTable(
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

  pw.Widget _buildSalesPdfPage(
    Report data,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font semiBoldFont,
  ) {
    final performerSales = (data.performerSales ?? [])
        .where((e) => (e.value ?? 0) > 0)
        .toList();
    final locationSales = (data.locationSales ?? [])
        .where((e) => (e.value ?? 0) > 0)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                '${(data.totalRevenue ?? 0).toStringAsFixed(0)} €',
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
          _pdfSalesTable(performerSales, boldFont, regularFont, semiBoldFont)
        else
          _pdfEmptyRow(regularFont),
        pw.SizedBox(height: 20),
        _pdfSectionTitle('Top Locations by Ticket Sales', boldFont),
        pw.SizedBox(height: 8),
        if (locationSales.isNotEmpty)
          _pdfSalesTable(locationSales, boldFont, regularFont, semiBoldFont)
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
    );
  }

  Future<void> _exportSalesPdf() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    final data = provider.reportData;
    if (data == null) return;

    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName:
          'sales_report_${_months[_selectedMonth - 1]}_$_selectedYear.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (outputPath == null) return;
    if (!mounted) return;

    _showLoadingDialog();
    try {
      final boldFont = await PdfGoogleFonts.nunitoBold();
      final regularFont = await PdfGoogleFonts.nunitoRegular();
      final semiBoldFont = await PdfGoogleFonts.nunitoSemiBold();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (ctx) =>
              _buildSalesPdfPage(data, boldFont, regularFont, semiBoldFont),
        ),
      );

      final bytes = await pdf.save();
      await File(outputPath).writeAsBytes(bytes);
      if (!mounted) return;
      Navigator.pop(context);
      SnackHelpers.showSuccess(context, 'PDF saved successfully!');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      SnackHelpers.showError(
        context,
        'Failed to export PDF. Please try again later.',
      );
    }
  }

  Future<void> _printSalesPdf() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    final data = provider.reportData;
    if (data == null) return;

    final boldFont = await PdfGoogleFonts.nunitoBold();
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final semiBoldFont = await PdfGoogleFonts.nunitoSemiBold();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) =>
            _buildSalesPdfPage(data, boldFont, regularFont, semiBoldFont),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'sales_report_${_months[_selectedMonth - 1]}_$_selectedYear.pdf',
    );
  }

  pw.Widget _buildCancelledPdfPage(
    CancelledEventsReport data,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font semiBoldFont,
  ) {
    final events = data.events ?? [];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                    'Cancelled Events & Refunds Report',
                    style: pw.TextStyle(
                      font: regularFont,
                      color: PdfColors.grey300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    data.cityName ?? 'N/A',
                    style: pw.TextStyle(
                      font: semiBoldFont,
                      color: PdfColors.white,
                      fontSize: 13,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Generated ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: regularFont,
                      color: PdfColors.grey300,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          children: [
            pw.Expanded(
              child: _pdfMetricCard(
                'Cancelled Events',
                '${data.totalCancelledEvents ?? 0}',
                boldFont,
                regularFont,
                valueColor: _kPdfRed,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _pdfMetricCard(
                'Tickets Sold',
                '${data.totalTicketsSold ?? 0}',
                boldFont,
                regularFont,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _pdfMetricCard(
                'Refunds Needed',
                '${data.totalRefundsNeeded ?? 0}',
                boldFont,
                regularFont,
                valueColor: _kPdfOrange,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _pdfMetricCard(
                'Total Refund Amount',
                '${events.fold<double>(0, (s, e) => s + (e.totalRefundAmount ?? 0)).toStringAsFixed(2)} €',
                boldFont,
                regularFont,
                valueColor: _kPdfRed,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        _pdfSectionTitle('Cancelled Events Details', boldFont),
        pw.SizedBox(height: 8),
        if (events.isNotEmpty)
          _pdfCancelledTable(events, boldFont, regularFont, semiBoldFont)
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
              DateFormat('dd.MM.yyyy').format(DateTime.now()),
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfCancelledTable(
    List<CancelledEventItem> items,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font semiBoldFont,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _kPdfBorder, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _kPdfPrimary),
          children: [
            _pdfCell('Event', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('Location', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('Date', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('Sold', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('Refunds', boldFont, PdfColors.white, isHeader: true),
            _pdfCell('Amount (€)', boldFont, PdfColors.white, isHeader: true),
          ],
        ),
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final rowBg = idx % 2 == 0
              ? const PdfColor.fromInt(0xFFFFF5F5)
              : PdfColors.white;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: rowBg),
            children: [
              _pdfCell(
                item.eventName ?? 'N/A',
                semiBoldFont,
                const PdfColor.fromInt(0xFF1D2939),
              ),
              _pdfCell(
                item.locationName ?? 'N/A',
                regularFont,
                PdfColors.grey700,
              ),
              _pdfCell(
                item.eventDate != null
                    ? DateFormat('dd.MM.yyyy').format(item.eventDate!)
                    : 'N/A',
                regularFont,
                PdfColors.grey700,
              ),
              _pdfCell('${item.ticketsSold ?? 0}', regularFont, _kPdfGrey),
              _pdfCell('${item.refundsNeeded ?? 0}', boldFont, _kPdfOrange),
              _pdfCell(
                '${(item.totalRefundAmount ?? 0).toStringAsFixed(2)}',
                boldFont,
                _kPdfRed,
              ),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _exportCancelledPdf() async {
    final provider = Provider.of<CancelledEventsReportProvider>(
      context,
      listen: false,
    );
    final data = provider.reportData;
    if (data == null) return;

    final citySlug = (data.cityName ?? 'report').toLowerCase().replaceAll(
      ' ',
      '_',
    );
    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName:
          'cancelled_events_${citySlug}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (outputPath == null) return;
    if (!mounted) return;

    _showLoadingDialog();
    try {
      final boldFont = await PdfGoogleFonts.nunitoBold();
      final regularFont = await PdfGoogleFonts.nunitoRegular();
      final semiBoldFont = await PdfGoogleFonts.nunitoSemiBold();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (ctx) =>
              _buildCancelledPdfPage(data, boldFont, regularFont, semiBoldFont),
        ),
      );

      final bytes = await pdf.save();
      await File(outputPath).writeAsBytes(bytes);
      if (!mounted) return;
      Navigator.pop(context);
      SnackHelpers.showSuccess(context, 'PDF saved successfully!');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      SnackHelpers.showError(
        context,
        'Failed to export PDF. Please try again later.',
      );
    }
  }

  Future<void> _printCancelledPdf() async {
    final provider = Provider.of<CancelledEventsReportProvider>(
      context,
      listen: false,
    );
    final data = provider.reportData;
    if (data == null) return;

    final boldFont = await PdfGoogleFonts.nunitoBold();
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final semiBoldFont = await PdfGoogleFonts.nunitoSemiBold();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) =>
            _buildCancelledPdfPage(data, boldFont, regularFont, semiBoldFont),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'cancelled_events_${data.cityName ?? 'report'}.pdf',
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: _white)),
    );
  }

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
                _buildHeader(),
                const SizedBox(height: 20),
                _buildTabBar(),
                const SizedBox(height: 24),
                if (_activeTab == 0) _buildSalesTab() else _buildCancelledTab(),
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
          'Reports',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Analytics and reports for your events.',
          style: TextStyle(fontSize: 13, color: _t2),
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
          _TabButton(
            label: 'Sales Overview',
            icon: Icons.bar_chart_rounded,
            isActive: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
          const SizedBox(width: 4),
          _TabButton(
            label: 'Cancelled Events',
            icon: Icons.cancel_outlined,
            isActive: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    return Column(
      children: [
        Row(
          children: [
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
              builder: (_, p, __) => _ActionButton(
                label: 'Export PDF',
                icon: Icons.download_rounded,
                filled: true,
                enabled: p.reportData != null,
                onTap: p.reportData != null ? _exportSalesPdf : null,
              ),
            ),
            const SizedBox(width: 10),
            Consumer<ReportProvider>(
              builder: (_, p, __) => _ActionButton(
                label: 'Print',
                icon: Icons.print_rounded,
                filled: false,
                enabled: p.reportData != null,
                onTap: p.reportData != null ? _printSalesPdf : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Consumer<ReportProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return _buildLoading();
            if (provider.error != null)
              return _buildError(provider.error!, _loadReport);
            final data = provider.reportData;
            if (data == null) return _buildNoData();
            return _buildSalesDashboard(data);
          },
        ),
      ],
    );
  }

  Widget _buildSalesDashboard(Report data) {
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
              value: '${(data.totalRevenue ?? 0).toStringAsFixed(0)} €',
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
                  color: _chartLocation,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart({required List<Chart> data, required Color color}) {
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

  Widget _buildCancelledTab() {
    return Consumer<CancelledEventsReportProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_isLoadingCities)
                  const SizedBox(
                    width: 220,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: _navyMid,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else
                  _CityDropdown(
                    cities: cities,
                    selected: _selectedCity,
                    onChanged: (city) {
                      setState(() => _selectedCity = city);
                      if (city != null) {
                        Provider.of<CancelledEventsReportProvider>(
                          context,
                          listen: false,
                        ).fetchCancelledReport(city.cityId!);
                      }
                    },
                  ),
                const Spacer(),
                _ActionButton(
                  label: 'Export PDF',
                  icon: Icons.download_rounded,
                  filled: true,
                  enabled: provider.reportData != null,
                  onTap: provider.reportData != null
                      ? _exportCancelledPdf
                      : null,
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  label: 'Print',
                  icon: Icons.print_rounded,
                  filled: false,
                  enabled: provider.reportData != null,
                  onTap: provider.reportData != null
                      ? _printCancelledPdf
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_selectedCity == null)
              _buildSelectCityPrompt()
            else if (provider.isLoadingReport)
              _buildLoading()
            else if (provider.error != null)
              _buildError(provider.error!, _loadCancelledReport)
            else if (provider.reportData == null)
              _buildNoData()
            else
              _buildCancelledDashboard(provider.reportData!),
          ],
        );
      },
    );
  }

  Widget _buildSelectCityPrompt() {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _navyMid.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_city_rounded,
              size: 32,
              color: _navyMid,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select a city to view the report',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _t1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose a city from the dropdown above',
            style: TextStyle(fontSize: 13, color: _t2.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledDashboard(CancelledEventsReport data) {
    final events = data.events ?? [];
    final totalRefundAmount = events.fold<double>(
      0,
      (s, e) => s + (e.totalRefundAmount ?? 0),
    );

    return Column(
      children: [
        Row(
          children: [
            _MetricCard(
              label: 'Cancelled Events',
              value: '${data.totalCancelledEvents ?? 0}',
              icon: Icons.cancel_outlined,
              accentColor: const Color(0xFFDC2626),
            ),
            const SizedBox(width: 14),
            _MetricCard(
              label: 'Tickets Sold',
              value: '${data.totalTicketsSold ?? 0}',
              icon: Icons.confirmation_number_outlined,
              accentColor: _navyMid,
            ),
            const SizedBox(width: 14),
            _MetricCard(
              label: 'Refunds Needed',
              value: '${data.totalRefundsNeeded ?? 0}',
              icon: Icons.refresh_rounded,
              accentColor: const Color(0xFFD97706),
            ),
            const SizedBox(width: 14),
            _MetricCard(
              label: 'Total Refund Amount',
              value: '${totalRefundAmount.toStringAsFixed(2)} €',
              icon: Icons.payments_outlined,
              accentColor: const Color(0xFFDC2626),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancelled Events',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                        const Text(
                          'details per event',
                          style: TextStyle(fontSize: 11, color: _t2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: _border,
                margin: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
              ),

              if (events.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Center(
                    child: Text(
                      'No cancelled events for ${data.cityName}',
                      style: const TextStyle(color: _t2, fontSize: 13),
                    ),
                  ),
                )
              else
                _buildCancelledEventsTable(events),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledEventsTable(List<CancelledEventItem> events) {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _t2,
    );
    const colPad = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.8),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.2),
          5: FlexColumnWidth(1.8),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: _bg),
            children: [
              Padding(
                padding: colPad,
                child: const Text('Event', style: headerStyle),
              ),
              Padding(
                padding: colPad,
                child: const Text('Location', style: headerStyle),
              ),
              Padding(
                padding: colPad,
                child: const Text('Date', style: headerStyle),
              ),
              Padding(
                padding: colPad,
                child: const Text('Sold', style: headerStyle),
              ),
              Padding(
                padding: colPad,
                child: const Text('Refunds', style: headerStyle),
              ),
              Padding(
                padding: colPad,
                child: const Text('Amount (€)', style: headerStyle),
              ),
            ],
          ),
          ...events.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final rowBg = idx % 2 == 0 ? _card : const Color(0xFFFFFAFA);
            return TableRow(
              decoration: BoxDecoration(
                color: rowBg,
                border: const Border(
                  top: BorderSide(color: _border, width: 0.5),
                ),
              ),
              children: [
                Padding(
                  padding: colPad,
                  child: Text(
                    item.eventName ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _t1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: colPad,
                  child: Text(
                    item.locationName ?? 'N/A',
                    style: const TextStyle(fontSize: 12, color: _t2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: colPad,
                  child: Text(
                    item.eventDate != null
                        ? DateFormat('dd.MM.yyyy').format(item.eventDate!)
                        : 'N/A',
                    style: const TextStyle(fontSize: 12, color: _t2),
                  ),
                ),
                Padding(
                  padding: colPad,
                  child: Text(
                    '${item.ticketsSold ?? 0}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _navyMid,
                    ),
                  ),
                ),
                Padding(
                  padding: colPad,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.refundsNeeded ?? 0}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: colPad,
                  child: Text(
                    '${(item.totalRefundAmount ?? 0).toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoading() => const SizedBox(
    height: 400,
    child: Center(
      child: CircularProgressIndicator(color: _navyMid, strokeWidth: 2),
    ),
  );

  Widget _buildNoData() => Container(
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

  Widget _buildError(String message, VoidCallback onRetry) => Container(
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
          onPressed: onRetry,
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

class _TabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isActive
                ? _navyMid
                : (_hovered ? _bg : Colors.transparent),
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
                color: widget.isActive ? _white : _t2,
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isActive ? _white : _t2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.enabled,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.filled ? _navyMid : _card,
              borderRadius: BorderRadius.circular(10),
              border: widget.filled ? null : Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: widget.filled
                      ? _navy.withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 15,
                  color: widget.filled ? _white : _navyMid,
                ),
                const SizedBox(width: 7),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.filled ? _white : _navyMid,
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

  OverlayEntry _buildOverlay() => OverlayEntry(
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
              child: Container(
                width: 260,
                constraints: const BoxConstraints(maxHeight: 240),
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
                      children: widget.cities.map((city) {
                        final isSelected =
                            widget.selected?.cityId == city.cityId;
                        return _DropdownItem(
                          label: city.name ?? 'Unknown',
                          isSelected: isSelected,
                          onTap: () {
                            _close();
                            widget.onChanged(city);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _overlay?.remove();
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
            height: 40,
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _isOpen ? const Color(0xFFE8EDFF) : _card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOpen ? _navyMid.withOpacity(0.4) : _border,
              ),
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
                const Icon(
                  Icons.location_city_rounded,
                  size: 15,
                  color: _navyMid,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.selected?.name ?? 'Select city',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.selected != null ? _t1 : _t2,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _DropdownItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _DropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.isSelected)
      bg = const Color(0xFFE8EDFF);
    else if (_hovered)
      bg = const Color(0xFFF4F6FB);
    else
      bg = Colors.transparent;

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

class _MetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
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

class _ChartCard extends StatelessWidget {
  final String title, subtitle;
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
  Widget build(BuildContext context) => Container(
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

  OverlayEntry _buildOverlay() => OverlayEntry(
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

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
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
  Widget build(BuildContext context) => Container(
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
            return _DropdownItem(
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
