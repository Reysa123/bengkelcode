import 'dart:io';
import 'dart:typed_data';

import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_event.dart';
import 'package:bengkel/database/databasehelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<Uint8List> printPKB(
  List<Map<String, dynamic>> list,
  List<Map<String, dynamic>> jasa,
  List<Map<String, dynamic>> part,
) async {
  final sql = DatabaseHelper();

  var bengkel = await sql.getBengkels();
  String? namabkl = bengkel?.nama ?? "";
  String? alamatbkl = bengkel?.alamat ?? "";
  String? telpbkl = bengkel?.telepon ?? "";
  final pdf = pw.Document();
  NumberFormat nf = NumberFormat('#,###');
  DateFormat df = DateFormat('dd-MM-yyyy');

  //

  String nama = list.first['nama_pelanggan'];
  String tlp = list.first['telepon'];
  String nopol = list.first['plat_nomor'];
  String nora = list.first['nomor_rangka'];
  String merk = list.first['merk'];
  String tipe = list.first['model'];
  //String kota = list.first['telepon'];
  String alamat = list.first['alamat'];
  String km = list.first['km'].toString();
  String noeg = list.first['nomor_mesin'];
  String nopkb = list.first['idpkb'].toString();
  String kel = list.first['catatan'];
  String tglpkb = df.format(
    DateTime.parse(list.first['tanggal_masuk'].toString()),
  );
  // String sa = list.first.sa;

  String? logo = bengkel?.logo ?? "";
  Uint8List imageData =
      logo.isNotEmpty
          ? await File(logo).readAsBytes()
          : (await rootBundle.load(
            'assets/images/example.png',
          )).buffer.asUint8List();
  pw.TextStyle styleBkl = const pw.TextStyle(fontSize: 6);
  pw.TextStyle style = const pw.TextStyle(fontSize: 8);
  pw.TextStyle styleHeader = pw.TextStyle(
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
  );
  List<List<dynamic>> jasas = [];
  jasa.asMap().entries.forEach((v) {
    Map<String, dynamic> map = v.value; // Get the map at the current index
    int index = v.key + 1;
    // Create a new list from the map's values
    List<dynamic> innerList = [
      index,
      map['nama_jasa'],
      nf.format(map['harga_jual']),
    ];

    // Add the inner list to the result list
    jasas.add(innerList);
  });
  pw.Widget listJasa() {
    return pw.TableHelper.fromTextArray(
      data: jasas,
      headerStyle: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 6),
      border: const pw.TableBorder(verticalInside: pw.BorderSide.none),
      cellAlignments: {
        0: pw.Alignment.topLeft,
        1: pw.Alignment.topLeft,
        2: pw.Alignment.topRight,
      },
      headers: ['No.', 'Nama Pekerjaan', 'Total Harga'],
      columnWidths: {
        0: const pw.FixedColumnWidth(20),
        1: const pw.FixedColumnWidth(120),
        2: const pw.FixedColumnWidth(50),
      },
      headerAlignments: {
        0: pw.Alignment.topLeft,
        1: pw.Alignment.topLeft,
        2: pw.Alignment.topRight,
      },
    );
  }

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(20),
      //pageTheme: pw.PageTheme(),
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      build: (context) {
        return pw.SizedBox(
          //height: 1800,
          child: pw.Column(
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
                child: pw.Text('Perintah Kerja Bengkel', style: styleHeader),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Align(
                      child: pw.Text(nopol, style: styleHeader),
                      alignment: pw.Alignment.bottomCenter,
                    ),
                  ),
                  pw.Column(
                    children: [
                      pw.Align(
                        alignment: pw.Alignment.topRight,
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.SizedBox(
                              width: 60,
                              child: pw.Text('Nomor PKB', style: style),
                            ),
                            pw.SizedBox(
                              width: 10,
                              child: pw.Text(':', style: style),
                            ),
                            pw.SizedBox(
                              width: 120,
                              child: pw.Text(nopkb, style: style),
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
                              width: 60,
                              child: pw.Text('Tanggal PKB', style: style),
                            ),
                            pw.SizedBox(
                              width: 10,
                              child: pw.Text(':', style: style),
                            ),
                            pw.SizedBox(
                              width: 120,
                              child: pw.Text(tglpkb, style: style),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('ID Pelanggan', style: style),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(
                              list.first['pelanggan_id'].toString(),
                              style: style,
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('Nama Pelanggan', style: style),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(nama, style: style),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.max,
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text(
                              'Alamat Pelanggan',
                              style: style,
                              maxLines: 2,
                            ),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style, maxLines: 2),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(alamat, style: style, maxLines: 2),
                          ),
                        ],
                      ),
                      // pw.Row(
                      //   children: [
                      //     pw.SizedBox(
                      //       width: 80,
                      //       child: pw.Text('Kota', style: style),
                      //     ),
                      //     pw.SizedBox(
                      //       width: 10,
                      //       child: pw.Text(':', style: style),
                      //     ),
                      //     pw.SizedBox(
                      //       width: 200,
                      //       child: pw.Text(kota, style: style),
                      //     ),
                      //   ],
                      // ),
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('Telp. Pelanggan', style: style),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(tlp, style: style),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('No. Rangka', style: style),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(nora, style: style),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('No. Mesin', style: style),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(noeg, style: style),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('Merk', style: style, maxLines: 2),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style, maxLines: 2),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(merk, style: style, maxLines: 2),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('Tipe', style: style),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(tipe, style: style),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text('Kilometer', style: style),
                          ),
                          pw.SizedBox(
                            width: 10,
                            child: pw.Text(':', style: style),
                          ),
                          pw.SizedBox(
                            width: 200,
                            child: pw.Text(km, style: style),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Text('Keluhan :', style: style),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    height: 100,
                    width: 280,
                    child: pw.Text(kel, style: style, maxLines: 10),
                  ),
                  // pw.SizedBox(
                  //   height: 100,
                  //   width: 280,
                  //   child: pw.Text(kel2, style: style, maxLines: 10),
                  // ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Text('Pekerjaan :', style: style),
              pw.SizedBox(height: 10),
              pw.SizedBox(height: 280, child: pw.Expanded(child: listJasa())),
              pw.Expanded(child: pw.Text('')),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: pw.Divider(height: 0.5),
              ),
              pw.Text('Keterangan :', style: style),
              pw.SizedBox(height: 10),
              pw.SizedBox(height: 100),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8.0, bottom: 8.0),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Footer(
                    trailing: pw.Column(
                      children: [
                        pw.Text('   Pelanggan   ', style: style),
                        pw.SizedBox(height: 30),
                        pw.Text('   $nama   ', style: style),
                      ],
                    ),
                  ),
                  pw.Footer(
                    trailing: pw.Column(
                      children: [
                        pw.Text('   Service Advisor   ', style: style),
                        pw.SizedBox(height: 30),
                        pw.Text('   sa   ', style: style),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],
          ),
        );
      },
    ),
  );
  var savedFile = await pdf.save();
  return savedFile;
}

class PrintPKBPdf extends StatefulWidget {
  final int transaksiId;
  const PrintPKBPdf({required this.transaksiId, super.key});

  @override
  State<PrintPKBPdf> createState() => _PrintPKBPdfState();
}

class _PrintPKBPdfState extends State<PrintPKBPdf> {
  bool dapat = false;
  @override
  void initState() {
    super.initState();
    start();
  }

  Uint8List printpkb = Uint8List(0);
  start() async {
    setState(() {
      dapat = true;
    });
    context.read<TransaksiServiceDetailBloc>().add(
      LoadTransaksiService(transaksiId: widget.transaksiId),
    );
  }

  printss(
    List<Map<String, dynamic>> list,
    List<Map<String, dynamic>> jasa,
    List<Map<String, dynamic>> part,
  ) async {
    final d = await printPKB(list, jasa, part);
    setState(() {
      printpkb = d;
      dapat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
      ),
      body:
          BlocListener<TransaksiServiceDetailBloc, TransaksiServiceDetailState>(
            listener: (context, state) {
              if (state is TransaksiServiceLoaded) {
                printss(state.data, state.jasa, state.part);
              }
            },
            child:
                dapat
                    ? const Center(child: CircularProgressIndicator())
                    : PdfPreview(build: (format) => printpkb),
          ),
    );
  }
}
