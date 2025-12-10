import 'dart:typed_data';
import 'package:printing/printing.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> printHistory(
  List<Map<String, dynamic>> list,
  List<Map<String, dynamic>> jasas,
  List<Map<String, dynamic>> parts,
) async {
  final pdf = pw.Document();
  DateFormat df = DateFormat('dd-MM-yyyy');
  NumberFormat nf = NumberFormat('#,###');
  var width = 200.0;
  pw.TextStyle style = pw.TextStyle(
    fontWeight: pw.FontWeight.normal,
    fontSize: 6,
  );
  pw.TextStyle underbold = pw.TextStyle(
    fontSize: 6,
    fontWeight: pw.FontWeight.normal,
    decoration: pw.TextDecoration.underline,
  );
  pw.Widget textList(
    String title,
    String content,
    double? width, {
    int? maxline,
  }) {
    pw.TextStyle style = const pw.TextStyle(fontSize: 6);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(title, style: style, maxLines: maxline),
        ),
        pw.SizedBox(
          width: 10,
          child: pw.Text(':', style: style, maxLines: maxline),
        ),
        pw.SizedBox(child: pw.Text(content, style: style, maxLines: maxline)),
      ],
    );
  }

  header1() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(
          width: width,
          child: textList('No. Chasis', list.first['nomor_rangka'], 130),
        ),
        pw.SizedBox(
          width: width,
          child: textList('Nama Pelanggan', list.first['nama_pelanggan'], 130),
        ),
      ],
    );
  }

  header2() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(
          width: width,
          child: textList('No. Mesin', list.first['nomor_mesin'], 130),
        ),
        pw.SizedBox(
          width: width,
          child: textList(
            'Alamat Pelanggan',
            list.first['alamat'],
            130,
            maxline: 2,
          ),
        ),
      ],
    );
  }

  header3() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(
          width: width,
          child: textList('No. Polisi', list.first['plat_nomor'], 130),
        ),
        pw.SizedBox(),
      ],
    );
  }

  header4() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(
          width: width,
          child: textList('Type', list.first['model'], 130),
        ),
        pw.SizedBox(
          width: width,
          child: textList('Telepon', list.first['telepon'], 130),
        ),
      ],
    );
  }

  header5() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(
          width: width,
          child: textList('Merk', list.first['merk'], 130),
        ),
        pw.SizedBox(
          width: width,
          child: textList('Tahun', list.first['tahun'].toString(), 130),
        ),
      ],
    );
  }

  padding() {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4.0),
      child: pw.Divider(
        thickness: 0.1,
        height: 0.2,
        color: const PdfColor(0, 0, 0, 0.5),
      ),
    );
  }

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(20),
      //pageTheme: pw.PageTheme(),
      pageFormat: const PdfPageFormat(
        21.0 * PdfPageFormat.cm,
        29.7 * PdfPageFormat.cm,
        marginAll: 2.0 * PdfPageFormat.cm,
      ),
      orientation: pw.PageOrientation.portrait,
      header:
          (context) => pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "History Kendaraan",
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
                pw.SizedBox(height: 20),
                header1(),
                header2(),
                header3(),
                header4(),
                header5(),
                padding(),
              ],
            ),
          ),
      footer:
          (context) => pw.Center(
            child: pw.Text(
              '${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(fontSize: 6, fontStyle: pw.FontStyle.italic),
            ),
          ),
      build: (pw.Context context) {
        List<pw.Widget> ff = [];
        pw.Widget gg = pw.Container();
        int index = 0;
        for (var e in list) {
          gg = pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 220,
                      child: pw.Text(
                        'Tanggal. PKB : ${df.format(DateTime.parse(e['tanggal_masuk'].toString()))}',
                        style: style,
                      ),
                    ),
                    pw.SizedBox(
                      width: 180,
                      child: pw.Text(
                        'No. PKB : ${e['ids'].toString()}',
                        style: style,
                      ),
                    ),
                    pw.SizedBox(
                      width: 120,
                      child: pw.Text(
                        'Km : ${e['km'].toString()}',
                        style: style,
                      ),
                    ),
                  ],
                ),
                padding(),
                pw.Text('Keluhan :', style: underbold),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10.0),
                  child: pw.Text(
                    list.first['catatan'] ?? "",
                    maxLines: 5,
                    style: style,
                  ),
                ),
                pw.Row(
                  children: [
                    pw.SizedBox(width: 50, child: pw.Text('No', style: style)),
                    pw.Expanded(
                      child: pw.SizedBox(
                        width: 120,
                        child: pw.Text('Pekerjaan', style: style),
                      ),
                    ),
                    pw.SizedBox(
                      width: 210,
                      child: pw.Text(
                        'Harga',
                        textAlign: pw.TextAlign.right,
                        style: style,
                      ),
                    ),
                  ],
                ),
                for (
                  var j = 0;
                  jasas.where((v) => v['ids'] == e['ids']).length > j;
                  j++
                )
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 50,
                        child: pw.Text('${j + 1}', style: style),
                      ),
                      pw.Expanded(
                        child: pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            jasas
                                .where((v) => v['ids'] == e['ids'])
                                .toList()[j]['nama_jasa'],
                            style: style,
                          ),
                        ),
                      ),
                      pw.SizedBox(
                        width: 210,
                        child: pw.Text(
                          nf.format(
                            double.parse(
                              jasas
                                  .where((v) => v['ids'] == e['ids'])
                                  .toList()[j]['harga_jual']
                                  .toString(),
                            ),
                          ),
                          textAlign: pw.TextAlign.right,
                          style: style,
                        ),
                      ),
                    ],
                  ),
                padding(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 50, child: pw.Text('', style: style)),
                    pw.Expanded(
                      child: pw.SizedBox(
                        width: 120,
                        child: pw.Text('TOTAL JASA', style: style),
                      ),
                    ),
                    pw.SizedBox(
                      width: 210,
                      child: pw.Text(
                        nf.format(e['total_biaya_jasa']),
                        textAlign: pw.TextAlign.right,
                        style: style,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 30, child: pw.Text('No', style: style)),
                    pw.SizedBox(
                      width: 100,
                      child: pw.Text('No. Part', style: style),
                    ),
                    pw.SizedBox(
                      width: 200,
                      child: pw.Text('Nama Part', style: style),
                    ),
                    pw.SizedBox(width: 50, child: pw.Text('Qty', style: style)),
                    pw.SizedBox(
                      width: 80,
                      child: pw.Text(
                        'Harga',
                        textAlign: pw.TextAlign.right,
                        style: style,
                      ),
                    ),
                    pw.SizedBox(
                      width: 80,
                      child: pw.Text(
                        'Total',
                        textAlign: pw.TextAlign.right,
                        style: style,
                      ),
                    ),
                  ],
                ),
                for (
                  var p = 0;
                  parts.where((v) => v['ids'] == e['ids']).length > p;
                  p++
                )
                  pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 30,
                        child: pw.Text('${p + 1}', style: style),
                      ),
                      pw.SizedBox(
                        width: 100,
                        child: pw.Text(
                          parts
                              .where((v) => v['ids'] == e['ids'])
                              .toList()[p]['kode_part'],
                          style: style,
                        ),
                      ),
                      pw.SizedBox(
                        width: 200,
                        child: pw.Text(
                          parts
                              .where((v) => v['ids'] == e['ids'])
                              .toList()[p]['nama_part'],
                          style: style,
                        ),
                      ),
                      pw.SizedBox(
                        width: 50,
                        child: pw.Text(
                          parts
                              .where((v) => v['ids'] == e['ids'])
                              .toList()[p]['jumlah']
                              .toString(),
                          style: style,
                        ),
                      ),
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          nf.format(
                            double.parse(
                              parts
                                  .where((v) => v['ids'] == e['ids'])
                                  .toList()[p]['harga_jual']
                                  .toString(),
                            ),
                          ),
                          textAlign: pw.TextAlign.right,
                          style: style,
                        ),
                      ),
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          nf.format(
                            double.parse(
                                  parts
                                      .where((v) => v['ids'] == e['ids'])
                                      .toList()[p]['harga_jual']
                                      .toString(),
                                ) *
                                double.parse(
                                  parts
                                      .where((v) => v['ids'] == e['ids'])
                                      .toList()[p]['jumlah']
                                      .toString(),
                                ),
                          ),
                          textAlign: pw.TextAlign.right,
                          style: style,
                        ),
                      ),
                    ],
                  ),
                padding(),
                pw.Row(
                  children: [
                    pw.SizedBox(width: 50, child: pw.Text('', style: style)),
                    pw.SizedBox(width: 120, child: pw.Text('', style: style)),
                    pw.Expanded(
                      child: pw.SizedBox(
                        width: 300,
                        child: pw.Text('TOTAL PART', style: style),
                      ),
                    ),
                    pw.SizedBox(width: 80, child: pw.Text('', style: style)),
                    pw.SizedBox(
                      width: 100,
                      child: pw.Text(
                        '',
                        textAlign: pw.TextAlign.right,
                        style: style,
                      ),
                    ),
                    pw.SizedBox(
                      width: 100,
                      child: pw.Text(
                        nf.format(
                          double.parse(e['total_biaya_suku_cadang'].toString()),
                        ),
                        textAlign: pw.TextAlign.right,
                        style: style,
                      ),
                    ),
                  ],
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 170.0, top: 20),
                  child: pw.Divider(),
                ),
                pw.Row(
                  children: [
                    pw.SizedBox(width: 170),
                    pw.Expanded(
                      child: pw.SizedBox(
                        child: pw.Text('SUB TOTAL', style: style),
                      ),
                    ),
                    pw.SizedBox(
                      child: pw.Text(
                        nf.format(double.parse(e['total_final'].toString())),
                        style: style,
                      ),
                    ),
                  ],
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 170.0),
                  child: pw.Divider(),
                ),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Text('* * *', style: style)),
                pw.SizedBox(height: 20),
                //for (var r = 0; r < 100; r++) pw.Text("e$r"),
              ],
            ),
          );
          ff.insert(index, gg);
          index += 1;
        }
        return ff;
      },
    ),
  );
  var savedFile = await pdf.save();
  return savedFile;
}

class HistoryPDF extends StatefulWidget {
  final List<Map<String, dynamic>> list;
  final List<Map<String, dynamic>> jasa;
  final List<Map<String, dynamic>> part;
  const HistoryPDF({
    required this.list,
    required this.jasa,
    required this.part,
    super.key,
  });

  @override
  State<HistoryPDF> createState() => _HistoryPDFState();
}

class _HistoryPDFState extends State<HistoryPDF> {
  bool dapat = false;
  Uint8List lists = Uint8List.fromList([0]);
  @override
  void initState() {
    super.initState();
    start();
  }

  start() async {
    setState(() {
      dapat = true;
    });
    await printHistory(widget.list, widget.jasa, widget.part).then((v) {
      setState(() {
        lists = v;
        dapat = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body:
          dapat
              ? const Center(child: CircularProgressIndicator())
              : PdfPreview(build: (format) => lists),
    );
  }
}
