import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/Ticket/ticket.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:printing/printing.dart';

class TicketsScreen extends StatefulWidget {
  final int userId;
  final List<Ticket>? preloadedTickets;

  const TicketsScreen({super.key, required this.userId, this.preloadedTickets});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool get _isPreloaded => widget.preloadedTickets != null;

  @override
  void initState() {
    super.initState();
    if (_isPreloaded) {
      _tickets = widget.preloadedTickets!
          .where((t) => t.isDeleted != true)
          .toList();
      _isLoading = false;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.currentUser == null) await auth.fetchMyProfile();
        if (auth.profileImageBytes == null) await auth.fetchMyProfile();
        _loadTickets();
      });
    }
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final provider = Provider.of<TicketProvider>(context, listen: false);
      final result = await provider.get(filter: {'Page': 0, 'PageSize': 100});
      if (!mounted) return;
      setState(() {
        _tickets = result.result.where((t) => t.isDeleted != true).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load tickets";
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "—";
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "—";
    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }

  String _getTicketTypeLabel(int? type) {
    switch (type) {
      case 2:
        return "VIP";
      case 3:
        return "PREMIUM";
      default:
        return "REGULAR";
    }
  }

  Color _getTicketTypeColor(int? type) {
    switch (type) {
      case 2:
        return const Color(0xFF7B1FA2);
      case 3:
        return const Color(0xFFE65100);
      default:
        return const Color.fromARGB(255, 75, 163, 204);
    }
  }

  PdfColor _getTicketTypePdfColor(int? type) {
    switch (type) {
      case 2:
        return const PdfColor.fromInt(0xFF7B1FA2);
      case 3:
        return const PdfColor.fromInt(0xFFE65100);
      default:
        return const PdfColor.fromInt(0xFF4BA3CC);
    }
  }

  Future<void> _downloadTicketPdf(Ticket ticket) async {
    final event = ticket.event;
    final typeLabel = _getTicketTypeLabel(ticket.ticketType);
    final typePdfColor = _getTicketTypePdfColor(ticket.ticketType);
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    final qrValidationResult = QrValidator.validate(
      data: ticket.ticketID.toString(),
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    pw.MemoryImage? qrImage;
    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );
      final picData = await painter.toImageData(300);
      if (picData != null) {
        qrImage = pw.MemoryImage(picData.buffer.asUint8List());
      }
    }

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
                            fontSize: 22,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Your Ticket',
                          style: pw.TextStyle(
                            font: regularFont,
                            color: PdfColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: typePdfColor,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        typeLabel,
                        style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                event?.eventName ?? 'Event',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                  color: const PdfColor.fromInt(0xFF1D235D),
                ),
              ),
              pw.SizedBox(height: 4),
              if (event?.performer?.artistName != null)
                pw.Text(
                  event!.performer!.artistName!,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 13,
                    color: PdfColors.grey,
                  ),
                ),
              pw.SizedBox(height: 20),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF5F6F8),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFFEAECF0),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfDetailRow(
                      boldFont,
                      regularFont,
                      'Location',
                      [
                        event?.location?.locationName,
                        event?.location?.city?.name,
                      ].where((s) => s != null && s.isNotEmpty).join(', '),
                    ),
                    pw.SizedBox(height: 8),
                    _pdfDetailRow(
                      boldFont,
                      regularFont,
                      'Address',
                      event?.location?.address ?? '—',
                    ),
                    pw.SizedBox(height: 8),
                    _pdfDetailRow(
                      boldFont,
                      regularFont,
                      'Date',
                      _formatDate(event?.eventDate),
                    ),
                    pw.SizedBox(height: 8),
                    _pdfDetailRow(
                      boldFont,
                      regularFont,
                      'Start Time',
                      _formatTime(event?.eventDate),
                    ),
                    pw.SizedBox(height: 8),
                    _pdfDetailRow(
                      boldFont,
                      regularFont,
                      'Price',
                      ticket.price != null ? '${ticket.price} KM' : '—',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              if (qrImage != null) ...[
                pw.Text(
                  'Your QR Code',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 14,
                    color: const PdfColor.fromInt(0xFF1D235D),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Divider(color: const PdfColor.fromInt(0xFFEAECF0)),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(
                        color: const PdfColor.fromInt(0xFFEAECF0),
                      ),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Image(qrImage, width: 150, height: 150),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Show this code at the event entrance',
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 10,
                            color: PdfColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),
              ],
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
      const fileName = 'ticket.pdf';

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
                    "Ticket PDF saved",
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

  pw.Widget _pdfDetailRow(
    pw.Font boldFont,
    pw.Font regularFont,
    String label,
    String value,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 11,
              color: const PdfColor.fromInt(0xFF555555),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 11,
              color: const PdfColor.fromInt(0xFF2D3142),
            ),
          ),
        ),
      ],
    );
  }

  void _showTicketDetailsModal(BuildContext context, Ticket ticket) {
    final typeLabel = _getTicketTypeLabel(ticket.ticketType);
    final typeColor = _getTicketTypeColor(ticket.ticketType);
    final event = ticket.event;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF1D235D),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Ticket Details",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D235D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event?.eventName ?? "Event",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D235D),
                      ),
                    ),
                  ),
                  if (event?.performer?.artistName != null) ...[
                    const SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        event!.performer!.artistName!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(
                          Icons.location_on_rounded,
                          "Location",
                          [
                            event?.location?.locationName,
                            event?.location?.city?.name,
                          ].where((s) => s != null && s.isNotEmpty).join(", "),
                        ),
                        const SizedBox(height: 8),
                        _detailRow(
                          Icons.directions_rounded,
                          "Address",
                          event?.location?.address ?? "—",
                        ),
                        const SizedBox(height: 8),
                        _detailRow(
                          Icons.calendar_today_rounded,
                          "Date",
                          _formatDate(event?.eventDate),
                        ),
                        const SizedBox(height: 8),
                        _detailRow(
                          Icons.access_time_rounded,
                          "Start time",
                          _formatTime(event?.eventDate),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.payments_rounded,
                              size: 14,
                              color: Color(0xFF1D235D),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Ticket",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF555555),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: typeColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          typeLabel,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ticket.price != null
                                            ? "${ticket.price} KM"
                                            : "—",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF2D3142),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Your QR Code",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: ticket.ticketID.toString(),
                          version: QrVersions.auto,
                          size: 120,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 12,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "Show this code at the event entrance",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _downloadTicketPdf(ticket);
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 15,
                          ),
                          label: const Text(
                            "Download PDF",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            side: const BorderSide(color: Color(0xFF1D235D)),
                            foregroundColor: const Color(0xFF1D235D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final address = event?.location?.locationName ?? '';
                            final city = event?.location?.city?.name ?? '';
                            final query = Uri.encodeComponent(
                              '$address, $city',
                            );
                            final url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$query',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const Icon(Icons.map_rounded, size: 15),
                          label: const Text(
                            "Get Directions",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            backgroundColor: const Color(0xFF1D235D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1D235D)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTickets = _tickets.length;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _isPreloaded
          ? null
          : BottomNavBar(selected: NavItem.purchases, userId: widget.userId),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Container(
                    color: const Color(0xFFF5F6F8),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Row(
                      children: [
                        if (_isPreloaded)
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
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1D235D),
                                width: 1.2,
                              ),
                            ),
                            child: ClipOval(
                              child: authProvider.profileImageBytes != null
                                  ? Image.memory(
                                      authProvider.profileImageBytes!,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(
                                        'assets/images/NoProfileImage.png',
                                      ),
                                    ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Text(
                              "My Tickets",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            if (totalTickets > 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                "· $totalTickets ${totalTickets == 1 ? 'ticket' : 'tickets'}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D235D),
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTickets,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D235D),
                              ),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : _tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1D235D,
                                ).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.confirmation_number_rounded,
                                size: 48,
                                color: Color(0xFF1D235D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No tickets yet",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Your purchased tickets will appear here",
                              style: TextStyle(
                                color: Color(0xFF1D235D),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _isPreloaded ? () async {} : _loadTickets,
                        color: const Color(0xFF1D235D),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(25, 14, 25, 24),
                          itemCount: _tickets.length,
                          itemBuilder: (context, index) =>
                              _buildTicketCard(_tickets[index]),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final typeLabel = _getTicketTypeLabel(ticket.ticketType);
    final typeColor = _getTicketTypeColor(ticket.ticketType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/my-events.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.82),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.event?.eventName ?? "Event",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 4),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              ticket.event?.performer?.artistName ?? "",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (ticket.event?.eventDate != null)
                              Text(
                                "${_formatDate(ticket.event!.eventDate)}  ·  ${_formatTime(ticket.event!.eventDate)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    typeLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                if (ticket.price != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${ticket.price} KM",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: QrImageView(
                            data: ticket.ticketID.toString(),
                            version: QrVersions.auto,
                            size: 70,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => _showTicketDetailsModal(context, ticket),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "View ticket details",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
  }
}
