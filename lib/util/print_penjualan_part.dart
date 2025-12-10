// lib/utils/pdf_generator.dart
import 'dart:io';
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/detailpenjualansukucadang.dart';
import 'package:bengkel/model/part.dart';
import 'package:bengkel/model/penjualansukucadang.dart';
import 'package:bengkel/util/terbilang.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart'; // Untuk format tanggal dan mata uang

import '../model/pelanggan.dart';

String namabkl = '';
String alamatbkl = '';
String telpbkl = '';
String logo = '';

class PdfGenerator {
  static Future<Uint8List> generateTandaTerimaPdf({
    required String judul,
    required int transaksiId,
    required String nama,
    required String alamat,
    required String telepon,
    required String nopol,
    required String kasir,
    required double jumlahBayar,
  }) async {
    final bkl = await DatabaseHelper().getBengkels();
    namabkl = bkl?.nama ?? "";
    alamatbkl = bkl?.alamat ?? "";
    telpbkl = bkl?.telepon ?? "";
    logo = bkl?.logo ?? "";
    Uint8List imageData =
        logo.isNotEmpty
            ? await File(logo).readAsBytes()
            : (await rootBundle.load(
              'assets/images/example.png',
            )).buffer.asUint8List();

    final pdf = pw.Document();
    pw.TextStyle styleBkl = const pw.TextStyle(fontSize: 6);
    pw.TextStyle style = const pw.TextStyle(fontSize: 8);
    pw.TextStyle styleHeader = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );
    final formatCurrency = NumberFormat('#,###');
    final formatDate = DateFormat('dd MMMM yyyy HH:mm');
    TerbilangID terbilang = TerbilangID(
      number: int.parse(jumlahBayar.toStringAsFixed(0)),
    );
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        //pageTheme: pw.PageTheme(),
        pageFormat: const PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          14.8 * PdfPageFormat.cm,
          marginAll: 2.0 * PdfPageFormat.cm,
        ),
        orientation: pw.PageOrientation.landscape,
        build: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  image: pw.DecorationImage(image: pw.MemoryImage(imageData)),
                ),
                //child: Text(gambar),
              ),
              pw.Text(namabkl.toUpperCase(), style: styleBkl),
              pw.Text(alamatbkl, style: styleBkl),
              pw.Text('Telp. $telpbkl', style: styleBkl),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text(judul, style: styleHeader),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.SizedBox(
                      width: 40,
                      child: pw.Text('Nomor', style: style),
                    ),
                    pw.SizedBox(width: 10, child: pw.Text(':', style: style)),
                    pw.SizedBox(
                      width: 120,
                      child: pw.Text('$transaksiId', style: style),
                    ),
                  ],
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.SizedBox(
                      width: 40,
                      child: pw.Text('Tanggal', style: style),
                    ),
                    pw.SizedBox(width: 10, child: pw.Text(':', style: style)),
                    pw.SizedBox(
                      width: 120,
                      child: pw.Text(
                        formatDate.format(DateTime.now()),
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text(
                      'Telah terima dari',
                      style: style,
                      maxLines: 2,
                    ),
                  ),
                  pw.SizedBox(
                    width: 10,
                    child: pw.Text(':', style: style, maxLines: 2),
                  ),
                  pw.SizedBox(
                    width: 320,
                    child: pw.Text(
                      '$nama\n$alamat $telepon',
                      style: style,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text('Terbilang', style: style, maxLines: 2),
                  ),
                  pw.SizedBox(
                    width: 10,
                    child: pw.Text(':', style: style, maxLines: 2),
                  ),
                  pw.SizedBox(
                    width: 320,
                    child: pw.Text(
                      terbilang.results(),
                      style: style,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text('Uang Sejumlah', style: style, maxLines: 1),
                  ),
                  pw.SizedBox(
                    width: 10,
                    child: pw.Text(':', style: style, maxLines: 1),
                  ),
                  pw.SizedBox(
                    width: 320,
                    child: pw.Text(
                      'Rp. ${formatCurrency.format(jumlahBayar)}',
                      style: styleHeader,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 80,
                    child: pw.Text(
                      'Untuk Pembayaran',
                      style: style,
                      maxLines: 1,
                    ),
                  ),
                  pw.SizedBox(
                    width: 10,
                    child: pw.Text(':', style: style, maxLines: 1),
                  ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Row(
                children: [
                  pw.SizedBox(width: 30, child: pw.Text('No.', style: style)),
                  pw.SizedBox(
                    width: 330,
                    child: pw.Text('Keterangan', style: style),
                  ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Expanded(
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 30, child: pw.Text('1.', style: style)),
                    pw.SizedBox(
                      width: 330,
                      child: pw.Text(
                        'Transaksi No : $transaksiId  No. Polisi : $nopol',
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Footer(
                    trailing: pw.Column(
                      children: [
                        pw.Text('   Kasir   ', style: style),
                        pw.SizedBox(height: 30),
                        pw.Text('   $kasir   ', style: style),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> generatePenjualanSukuCadangPdf(
    PenjualanSukuCadang penjualan,
    List<DetailPenjualanSukuCadang> details,
    Pelanggan? pelanggan, // Pelanggan bisa null (untuk penjualan tunai)
    List<SukuCadang>
    allSukuCadang, // Daftar semua suku cadang untuk resolusi nama
  ) async {
    final bkl = await DatabaseHelper().getBengkels();
    namabkl = bkl?.nama ?? "";
    alamatbkl = bkl?.alamat ?? "";
    telpbkl = bkl?.telepon ?? "";
    logo = bkl?.logo ?? "";
    Uint8List imageData =
        logo.isNotEmpty
            ? await File(logo).readAsBytes()
            : (await rootBundle.load(
              'assets/images/example.png',
            )).buffer.asUint8List();
    final pdf = pw.Document();

    final formatCurrency = NumberFormat('#,###');
    final formatDate = DateFormat('dd MMMM yyyy HH:mm');

    // Buat map untuk mencari nama suku cadang berdasarkan ID
    final Map<int, String> sukuCadangNames = {
      for (var sc in allSukuCadang) sc.id!: sc.namaPart,
    };

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Faktur Penjualan Suku Cadang',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 80,
                        height: 80,
                        decoration: pw.BoxDecoration(
                          image: pw.DecorationImage(
                            image: pw.MemoryImage(imageData),
                          ),
                        ),
                        //child: Text(gambar),
                      ),
                      pw.Text(
                        namabkl,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(alamatbkl),
                      pw.Text(telpbkl),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Faktur No: #${penjualan.transaksiId}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Tanggal: ${formatDate.format(penjualan.tanggalPenjualan)}',
                      ),
                      pw.Text('Pelanggan: ${pelanggan?.nama ?? 'Tunai'}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              pw.TableHelper.fromTextArray(
                headers: ['Suku Cadang', 'Jumlah', 'Harga Satuan', 'Subtotal'],
                data:
                    details.map((detail) {
                      final namaSukuCadang =
                          sukuCadangNames[detail.sukuCadangId] ??
                          'Tidak Dikenal';
                      return [
                        namaSukuCadang,
                        detail.jumlah.toString(),
                        formatCurrency.format(detail.hargaJualSaatItu),
                        formatCurrency.format(detail.subTotal),
                      ];
                    }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(5),
              ),
              pw.SizedBox(height: 20),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total Penjualan: ${formatCurrency.format(penjualan.totalPenjualan)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              if (penjualan.catatan != null && penjualan.catatan!.isNotEmpty)
                pw.Text('Catatan: ${penjualan.catatan}'),

              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Terima kasih atas pembelian Anda!',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
