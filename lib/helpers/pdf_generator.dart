import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/struk_model.dart';

class PdfGenerator {
  static final PdfColor primary = PdfColor.fromHex('#C62828');

  static String _formatTanggal(String tanggal) {
    try {
      // backend return: 2026-05-10T10:30:00
      final dt = DateTime.tryParse(tanggal);
      if (dt == null) return tanggal;
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return tanggal;
    }
  }

  static String _formatRupiah(int value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  static Future<String> _saveDoc(pw.Document doc, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final outDir = Directory('${dir.path}/klinik_pdf');
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }
    final file = File('${outDir.path}/$filename');
    final bytes = await doc.save();
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Generate PDF struk pembayaran (pembayaran jasa+obat) + barcode sebagai teks.
  static Future<String> generateStrukPembayaran(StrukModel struk) async {
    final doc = pw.Document();

    final barcodeText = struk.noStruk;
    final tanggalText = _formatTanggal(struk.tanggal);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // HEADER
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 34,
                      height: 34,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: primary,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'KMP',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Klinik Merah Putih',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            struk.klinik.alamat,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            '${struk.klinik.telepon} • ${struk.klinik.email}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: primary),
                pw.SizedBox(height: 12),

                // INFO STRUK
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'No. Struk: ${struk.noStruk}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Tanggal: $tanggalText',
                          style: pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Kasir: ${struk.kasir}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Metode: ${struk.metodeBayar.toUpperCase()}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // BARCODE STRUK (placeholder text)
                pw.Text(
                  'Barcode: $barcodeText',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  height: 18,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: primary, width: 1),
                    color: PdfColors.white,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      barcodeText,
                      style: pw.TextStyle(fontSize: 9, color: primary),
                    ),
                  ),
                ),

                pw.SizedBox(height: 12),

                // PASIEN
                pw.Text(
                  'Data Pasien',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Nama: ${struk.pasien.nama}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'No. RM: ${struk.pasien.noRm}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'NIK: ${struk.pasien.nik}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 10),

                // DOKTER & DIAGNOSA
                pw.Text(
                  'Dokter & Diagnosa',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Dokter: ${struk.dokter.nama}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Poli: ${struk.dokter.poli} • ${struk.dokter.spesialisasi}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                if (struk.diagnosa != null && struk.diagnosa!.trim().isNotEmpty)
                  pw.Text(
                    'Diagnosa: ${struk.diagnosa}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                pw.SizedBox(height: 10),

                // TABEL JASA
                pw.Text(
                  'Detail Jasa',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.black.withAlpha(60),
                    width: 0.4,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.16),
                    1: const pw.FlexColumnWidth(0.42),
                    2: const pw.FlexColumnWidth(0.16),
                    3: const pw.FlexColumnWidth(0.24),
                    4: const pw.FlexColumnWidth(0.24),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'No',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Nama Layanan',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Harga Satuan',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Subtotal',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < struk.detailJasa.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${i + 1}',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              struk.detailJasa[i].namaItem,
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${struk.detailJasa[i].qty}',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatRupiah(struk.detailJasa[i].hargaSatuan),
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatRupiah(struk.detailJasa[i].subtotal),
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Subtotal Jasa: ${_formatRupiah(struk.subtotalJasa)}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 12),

                // TABEL OBAT
                pw.Text(
                  'Detail Obat',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.black.withAlpha(60),
                    width: 0.4,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.14),
                    1: const pw.FlexColumnWidth(0.34),
                    2: const pw.FlexColumnWidth(0.14),
                    3: const pw.FlexColumnWidth(0.19),
                    4: const pw.FlexColumnWidth(0.19),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'No',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Nama Obat',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Harga/Satuan',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Subtotal',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < struk.detailObat.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${i + 1}',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              struk.detailObat[i].namaObat,
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${struk.detailObat[i].qty}',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatRupiah(struk.detailObat[i].hargaSatuan),
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatRupiah(struk.detailObat[i].subtotal),
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Subtotal Obat: ${_formatRupiah(struk.subtotalObat)}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 14),
                pw.Divider(
                  thickness: 1.5,
                  color: PdfColors.black.withAlpha(60),
                ),

                // RINGKASAN BIAYA
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Diskon:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      _formatRupiah(struk.diskon),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _formatRupiah(struk.total),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // FOOTER
                pw.Divider(thickness: 1, color: PdfColors.black.withAlpha(60)),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Terima kasih telah mempercayakan kesehatan Anda kepada kami',
                  style: pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Simpan struk ini sebagai bukti pembayaran',
                  style: pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 10),

                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Container(
                    width: 64,
                    height: 64,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primary, width: 1),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'QR\n$barcodeText',
                        style: pw.TextStyle(fontSize: 7, color: primary),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final filename = '${struk.noStruk}_pembayaran.pdf';
    return _saveDoc(doc, filename);
  }

  /// Generate PDF struk obat (resep) + barcode/QR placeholder.
  static Future<String> generateStrukObat(StrukModel struk) async {
    final doc = pw.Document();
    final barcodeText = struk.noStruk;
    final tanggalText = _formatTanggal(struk.tanggal);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // HEADER
                pw.Row(
                  children: [
                    pw.Text(
                      'Klinik Merah Putih',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'APOTEK',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(struk.klinik.alamat, style: pw.TextStyle(fontSize: 10)),
                pw.Text(
                  struk.klinik.telepon,
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2, color: primary),
                pw.SizedBox(height: 12),

                // INFO RESEP
                pw.Text(
                  'Info Resep',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'No. Resep: $barcodeText',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Tanggal resep: $tanggalText',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Dokter: ${struk.dokter.nama}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Pasien: ${struk.pasien.nama}',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 10),

                // BARCODE
                pw.Text(
                  'Barcode: $barcodeText',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  height: 18,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: primary, width: 1),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      barcodeText,
                      style: pw.TextStyle(fontSize: 9, color: primary),
                    ),
                  ),
                ),

                pw.SizedBox(height: 12),

                // TABLE OBAT DETAIL
                pw.Text(
                  'Detail Obat',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.black.withAlpha(60),
                    width: 0.4,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.10),
                    1: const pw.FlexColumnWidth(0.28),
                    2: const pw.FlexColumnWidth(0.14),
                    3: const pw.FlexColumnWidth(0.12),
                    4: const pw.FlexColumnWidth(0.14),
                    5: const pw.FlexColumnWidth(0.14),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'No',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Nama Obat',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Jenis',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Harga',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < struk.detailObat.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${i + 1}',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              struk.detailObat[i].namaObat,
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              'Sesuai petunjuk dokter',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${struk.detailObat[i].qty}',
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatRupiah(struk.detailObat[i].hargaSatuan),
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatRupiah(struk.detailObat[i].subtotal),
                              style: pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total Biaya Obat: ${_formatRupiah(struk.subtotalObat)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.Spacer(),

                // FOOTER + QR placeholder
                pw.Divider(thickness: 1, color: PdfColors.black.withAlpha(60)),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Resep ini hanya berlaku 3x penebusan',
                  style: pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 6),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Container(
                    width: 64,
                    height: 64,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primary, width: 1),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'QR\n$barcodeText',
                        style: pw.TextStyle(fontSize: 7, color: primary),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final filename = '${struk.noStruk}_obat.pdf';
    return _saveDoc(doc, filename);
  }
}
