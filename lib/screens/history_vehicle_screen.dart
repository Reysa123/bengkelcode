// lib/screens/transaksi_servis_list_screen.dart
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_event.dart';
import 'package:bengkel/print/printhistori.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// Import layar tambah/edit transaksi servis

class HistoryVehicleScreen extends StatefulWidget {
  final String? norangka;
  const HistoryVehicleScreen({super.key, required this.norangka});

  @override
  State<HistoryVehicleScreen> createState() => _HistoryVehicleScreenState();
}

class _HistoryVehicleScreenState extends State<HistoryVehicleScreen> {
  List<Map<String, dynamic>> list = [];
  List<Map<String, dynamic>> jasas = [];
  List<Map<String, dynamic>> parts = [];
  TextStyle style = const TextStyle(fontWeight: FontWeight.bold);
  TextStyle underbold = const TextStyle(
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );
  DateFormat df = DateFormat('dd-MM-yyyy');
  NumberFormat nf = NumberFormat('#,###');
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadTransaksiServis saat layar pertama kali dibuat
    context.read<TransaksiServiceDetailBloc>().add(
      LoadTransaksiService(noc: widget.norangka!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Kendaraan'),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.black,
              elevation: 5,
              shadowColor: Colors.amber,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          HistoryPDF(list: list, part: parts, jasa: jasas),
                ),
              );
            },
            icon: Icon(Icons.print),
          ),
        ],
      ),
      body: BlocListener<
        TransaksiServiceDetailBloc,
        TransaksiServiceDetailState
      >(
        listener: (context, state) {
          // Digunakan untuk side-effects seperti menampilkan Snackba
          if (state is TransaksiServiceLoaded) {
            setState(() {
              list = [];

              list = state.his;
              jasas = state.jasa;
              parts = state.part;
            });
          }
        },
        child:
            list.isEmpty
                ? Center(child: Text("Tidak ada histori kendaraan"))
                : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1350,
                    height: 800,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(
                            'No. Polisi',
                            list.firstOrNull?['plat_nomor'] ?? "",
                            "Nama Pelanggan",
                            list.firstOrNull?['nama_pelanggan'] ?? "",
                          ),
                          _buildHeader(
                            "No. Mesin",
                            list.firstOrNull?['nomor_mesin'] ?? "",

                            "Alamat Pelanggan",
                            list.firstOrNull?['alamat'] ?? "",
                          ),
                          _buildHeader(
                            'Merk',
                            list.firstOrNull?['merk'] ?? "",

                            "Telepon",
                            list.firstOrNull?['telepon'] ?? "",
                          ),
                          _buildHeader(
                            'Tipe',
                            list.firstOrNull?['model'] ?? "",
                            'Tahun',
                            list.firstOrNull?['tahun'].toString() ??
                                "".toString(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Divider(
                              color: Colors.black,
                              height: 1,
                              thickness: 1,
                            ),
                          ),

                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SizedBox(
                                // height: 400,
                                width: 1350,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    itemBuilder: (_, i) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 220,
                                                child: Text(
                                                  'Tanggal. PKB : ${df.format(DateTime.parse(list[i]['tanggal_masuk']))}',
                                                  style: style,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 180,
                                                child: Text(
                                                  'No. PKB : ${list[i]['idpkb'].toString()}',
                                                  style: style,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(
                                                  'Km : ${list[i]['km'].toString()}',
                                                  style: style,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          Text('Keluhan :', style: underbold),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10.0,
                                            ),
                                            child: Text(
                                              list[i]['catatan'] ?? "",
                                              maxLines: 5,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 50,
                                                child: Text('No', style: style),
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    'Pekerjaan',
                                                    style: style,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 210,
                                                child: Text(
                                                  'Harga',
                                                  textAlign: TextAlign.right,
                                                  style: style,
                                                ),
                                              ),
                                              const SizedBox(width: 80),
                                            ],
                                          ),
                                          const Divider(),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                jasas
                                                    .where(
                                                      (v) =>
                                                          v['ids'] ==
                                                          list[i]['ids'],
                                                    )
                                                    .length,
                                            itemBuilder: (_, j) {
                                              var jasa =
                                                  jasas
                                                      .where(
                                                        (v) =>
                                                            v['ids'] ==
                                                            list[i]['ids'],
                                                      )
                                                      .toList();

                                              return Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 50,
                                                        child: Text('${j + 1}'),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(
                                                          width: 120,
                                                          child: Text(
                                                            jasa[j]['nama_jasa'],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 210,
                                                        child: Text(
                                                          nf.format(
                                                            double.parse(
                                                              jasa[j]['harga_jual']
                                                                  .toString(),
                                                            ),
                                                          ),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 80),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          const Divider(),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 50,
                                                child: Text('', style: style),
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    'TOTAL JASA',
                                                    style: style,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 210,
                                                child: Text(
                                                  nf.format(
                                                    list[i]['total_biaya_jasa'],
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  style: style,
                                                ),
                                              ),
                                              const SizedBox(width: 80),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 50,
                                                child: Text('No', style: style),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(
                                                  'No. Part',
                                                  style: style,
                                                ),
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  width: 300,
                                                  child: Text(
                                                    'Nama Part',
                                                    style: style,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  'Qty',
                                                  style: style,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  'Harga',
                                                  textAlign: TextAlign.right,
                                                  style: style,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  'Total',
                                                  textAlign: TextAlign.right,
                                                  style: style,
                                                ),
                                              ),
                                              const SizedBox(width: 80),
                                            ],
                                          ),
                                          const Divider(),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                parts
                                                    .where(
                                                      (v) =>
                                                          v['ids'] ==
                                                          list[i]['ids'],
                                                    )
                                                    .length,
                                            itemBuilder: (_, p) {
                                              var part =
                                                  parts
                                                      .where(
                                                        (v) =>
                                                            v['ids'] ==
                                                            list[i]['ids'],
                                                      )
                                                      .toList();
                                              return Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 50,
                                                        child: Text('${p + 1}'),
                                                      ),
                                                      SizedBox(
                                                        width: 120,
                                                        child: Text(
                                                          part[p]['kode_part'],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(
                                                          width: 300,
                                                          child: Text(
                                                            part[p]['nama_part'],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 80,
                                                        child: Text(
                                                          part[p]['jumlah']
                                                              .toString(),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 100,
                                                        child: Text(
                                                          nf.format(
                                                            double.parse(
                                                              part[p]['harga_jual']
                                                                  .toString(),
                                                            ),
                                                          ),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 100,
                                                        child: Text(
                                                          nf.format(
                                                            double.parse(
                                                                  part[p]['harga_jual']
                                                                      .toString(),
                                                                ) *
                                                                double.parse(
                                                                  part[p]['jumlah']
                                                                      .toString(),
                                                                ),
                                                          ),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 80),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          const Divider(),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 50,
                                                child: Text('', style: style),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text('', style: style),
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  width: 300,
                                                  child: Text(
                                                    'TOTAL PART',
                                                    style: style,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Text('', style: style),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  '',
                                                  textAlign: TextAlign.right,
                                                  style: style,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  nf.format(
                                                    list[i]['total_biaya_suku_cadang'],
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  style: style,
                                                ),
                                              ),
                                              const SizedBox(width: 80),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(width: 170),
                                              Expanded(
                                                child: SizedBox(
                                                  child: Text(
                                                    'SUB TOTAL',
                                                    style: style,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                child: Text(
                                                  nf.format(
                                                    list[i]['total_final'],
                                                  ),
                                                  style: style,
                                                ),
                                              ),
                                              const SizedBox(width: 80),
                                            ],
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              left: 170.0,
                                            ),
                                            child: Divider(),
                                          ),
                                          const SizedBox(height: 20),
                                          const Center(child: Text('* * *')),
                                          const SizedBox(height: 20),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Kendaraan Dropdown
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Panggil fungsi navigasi tambah
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(String text, String value, String text1, String value2) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 130, child: Text(text)),
              SizedBox(width: 10, child: Text(':')),
              SizedBox(width: 330, child: Text(value)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 130, child: Text(text1)),
              SizedBox(width: 10, child: Text(':')),
              SizedBox(width: 330, child: Text(value2)),
            ],
          ),
        ],
      ),
    );
  }
}
