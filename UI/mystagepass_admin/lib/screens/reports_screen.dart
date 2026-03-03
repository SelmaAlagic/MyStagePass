import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mystagepass_admin/providers/report_provider.dart';
import 'package:mystagepass_admin/models/Chart/chart.dart';
import 'package:mystagepass_admin/widgets/base_layout.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

const _kPrimary = Color(0xFF1D235D);
const _kBorder = Color(0xFFEAECF0);

const _kChartPerformer = Color(0xFF1D235D);
const _kChartLocation = Color(0xFF076E3D);

const _kSnackBg = Color(0xFFDCF5E7);
const _kSnackBorder = Color(0xFF1B5E20);
const _kSnackText = Color(0xFF1B5E20);
const _kSnackIcon = Color(0xFF1B5E20);
const _kSnackAction = Color(0xFF2E7D32);

const _kPdfPrimary = PdfColor.fromInt(0xFF1D235D);
const _kPdfPrimaryLight = PdfColor.fromInt(0xFF2E3A8C);
const _kPdfGrey = PdfColor.fromInt(0xFF4A5568);
const _kPdfBorder = PdfColor.fromInt(0xFFEAECF0);

class ReportsScreen extends StatefulWidget {
  final int userId;
  const ReportsScreen({super.key, required this.userId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  Future<void> _loadReport() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    await provider.fetchMonthlyReport(_selectedMonth, _selectedYear);
  }

  void _showMonthPicker() {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select Period',
          style: TextStyle(fontWeight: FontWeight.bold, color: _kPrimary),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown<int>(
                label: 'Month',
                value: tempMonth,
                items: List.generate(
                  12,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text(_months[i])),
                ),
                onChanged: (v) => setDialogState(() => tempMonth = v!),
              ),
              const SizedBox(height: 16),
              _buildDropdown<int>(
                label: 'Year',
                value: tempYear,
                items: List.generate(5, (i) {
                  final y = DateTime.now().year - i;
                  return DropdownMenuItem(value: y, child: Text(y.toString()));
                }),
                onChanged: (v) => setDialogState(() => tempYear = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedMonth = tempMonth;
                _selectedYear = tempYear;
              });
              Navigator.pop(context);
              _loadReport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      icon: const Icon(Icons.arrow_drop_down, color: _kPrimary),
      items: items,
      onChanged: onChanged,
    );
  }

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
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
                color: _kSnackIcon,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'PDF saved successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _kSnackText,
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
                    color: _kSnackAction,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: _kSnackBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _kSnackBorder, width: 1.5),
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  pw.Widget _pdfSectionTitle(String text, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _kPdfPrimary,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _pdfEmptyRow(pw.Font regularFont) {
    return pw.Container(
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
  }

  pw.Widget _pdfMetricCard(
    String label,
    String value,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Container(
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
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 7,
              color: _kPdfGrey,
            ),
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
  }

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
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 9 : 8,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      userId: widget.userId,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 5, 40, 0),
            child: _buildHeader(),
          ),
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _kPrimary),
                  );
                }
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _kPrimary,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final data = provider.reportData;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _showMonthPicker,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
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
                                    color: _kPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${_months[_selectedMonth - 1]} $_selectedYear',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _kPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: _kPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (data != null)
                            ElevatedButton.icon(
                              onPressed: _exportPdf,
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 18,
                                color: _kPrimary,
                              ),
                              label: const Text(
                                'Export to PDF',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _kPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _kPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: _kBorder),
                                ),
                                elevation: 3,
                                shadowColor: Colors.black.withOpacity(0.06),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      if (data == null)
                        _buildNoData()
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Total Tickets Sold',
                                '${data.totalTicketsSold ?? 0}',
                                Icons.confirmation_number_outlined,
                                const Color.fromARGB(255, 29, 35, 93),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Total Revenue',
                                '${(data.totalRevenue ?? 0).toStringAsFixed(0)} KM',
                                Icons.attach_money_rounded,
                                const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Top Performer',
                                data.topPerformer ?? 'N/A',
                                Icons.star_rounded,
                                const Color(0xFF6A1B9A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Top Location',
                                data.topLocation ?? 'N/A',
                                Icons.location_on_rounded,
                                const Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildChartCard(
                                title: 'Top Performers by Ticket Sales',
                                accentColor: _kChartPerformer,
                                child: _buildBarChart(
                                  data: (data.performerSales ?? [])
                                      .where((e) => (e.value ?? 0) > 0)
                                      .toList(),
                                  xLabel: 'Performer',
                                  yLabel: 'Tickets Sold',
                                  color: _kChartPerformer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildChartCard(
                                title: 'Top Locations by Ticket Sales',
                                accentColor: _kChartLocation,
                                child: _buildBarChart(
                                  data: (data.locationSales ?? [])
                                      .where((e) => (e.value ?? 0) > 0)
                                      .toList(),
                                  xLabel: 'Location',
                                  yLabel: 'Tickets Sold',
                                  color: _kChartLocation,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(40, 8, 40, 50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                label: const Text(
                  'Back to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _kPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart_rounded, size: 36, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Sales Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No data available for this period',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required Widget child,
    Color accentColor = _kPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 280, child: child),
        ],
      ),
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
            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    final maxValue = data
        .map((e) => e.value ?? 0)
        .reduce((a, b) => a > b ? a : b);
    final double maxY = (maxValue * 1.2).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY == 0 ? 10 : maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => color.withOpacity(0.9),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${data[group.x].name ?? ''}\n${rod.toY.toInt()} tickets',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                xLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            axisNameSize: 28,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                String label = data[index].name ?? '';
                if (label.length > 8) label = '${label.substring(0, 7)}..';
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                yLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            axisNameSize: 24,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY == 0 ? 2 : maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value.value ?? 0).toDouble(),
                width: 28,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.55), color],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
