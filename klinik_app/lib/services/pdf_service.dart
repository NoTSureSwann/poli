import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateStrukPDF(Map<String, dynamic> resepData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('KLINIK SEHAT BERSAMA', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Jl. Kesehatan No. 123, Kota Sehat', style: const pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Data Pasien
              pw.Text('DATA PASIEN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Nama      : ${resepData['nama'] ?? '-'}'),
              pw.Text('NIK       : ${resepData['nik'] ?? '-'}'),
              pw.Text('Tanggal   : ${resepData['tanggal'] ?? '-'}'),
              pw.Text('Dokter    : ${resepData['dokter'] ?? '-'}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              
              // Data Resep / Antrian
              pw.SizedBox(height: 10),
              pw.Text('ITEM / TINDAKAN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              if (resepData['items'] != null)
                ...((resepData['items'] as List).map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('- ${item['nama_obat']} | ${item['dosis']} | Qty: ${item['qty']} | Aturan: ${item['aturan']}'),
                  );
                }).toList())
              else
                pw.Text('No Antrian : ${resepData['no_antrian'] ?? '-'}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    resepData['jenis'] == 'BPJS' ? 'Rp 0,- (BPJS)' : 'Rp ${(resepData['total'] ?? 0)}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Harap habiskan obat sesuai petunjuk dokter.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
