import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class CetakKuitansi extends StatefulWidget {
  const CetakKuitansi({super.key});

  @override
  State<CetakKuitansi> createState() => _CetakKuitansiState();
}

class _CetakKuitansiState extends State<CetakKuitansi> {
  final TextEditingController _noTransaksi = TextEditingController();
  final TextEditingController con = TextEditingController();
  bool dapat = true;
  List<Map<String, dynamic>> _transaksiServis = [];
  List<Map<String, dynamic>> _detailJasa = [];
  List<Map<String, dynamic>> _detailPart = [];
  NumberFormat nf = NumberFormat('#,###');
  double total = 0, totals = 0;
  Map<String, dynamic> jasas = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    con.dispose();
    _noTransaksi.dispose();

    super.dispose();
  }

  void _searchVehicle() {
    setState(() {
      dapat = false;
    });
    final platNumber = _noTransaksi.text.trim();
    if (platNumber.isNotEmpty) {
      context.read<TransaksiServiceDetailBloc>().add(
        LoadTransaksiService(transaksiId: int.parse(platNumber)),
      );
    }
  }

  void loadTransaksi(
    List<Map<String, dynamic>> tran,
    List<Map<String, dynamic>> djasa,
    List<Map<String, dynamic>> dpart,
  ) {
    setState(() {
      _transaksiServis = tran.where((v) => v['status'] != 'Lunas').toList();
      if (_transaksiServis.isNotEmpty) {
        //total = double.parse(_transaksiServis.first['total_final'].toString());
        _detailJasa =
            djasa
                .map((j) {
                  return {
                    'ids': j['ids'],
                    'id': j['id'],
                    'id_jasa': j['id_jasa'],
                    'disc': double.parse(j['disc'].toString()),
                    'nama_jasa': j['nama_jasa'],
                    'harga_jasa_saat_itu': j['harga_jasa_saat_itu'],
                    'harga_beli': j['harga_beli'],
                    'harga_jual': j['harga_jual'],
                    'jumlah': j['jumlah'],
                    'sub_total': j['sub_total'],
                  };
                })
                .toList()
                .where(
                  (v) =>
                      int.parse(v['ids'].toString()) ==
                      int.parse(_noTransaksi.text.trim()),
                )
                .toList();

        _detailPart =
            dpart
                .map((j) {
                  return {
                    'ids': j['ids'],
                    'id': j['id'],
                    'id_part': j['id_part'],
                    'kode_part': j['kode_part'],
                    'disc': double.parse(j['disc'].toString()),
                    'stok': j['stok'],
                    'nama_part': j['nama_part'],
                    'harga_jual_saat_itu': j['harga_jual_saat_itu'],
                    'harga_beli': j['harga_beli'],
                    'harga_jual': j['harga_jual'],
                    'jumlah': j['jumlah'],
                    'sub_total': j['sub_total'],
                  };
                })
                .toList()
                .where(
                  (v) =>
                      int.parse(v['ids'].toString()) ==
                      int.parse(_noTransaksi.text.trim()),
                )
                .toList();
        calculateJasa();
        dapat = true;
      } else {
        setState(() {
          dapat = true;
        });
      }
    });
  }

  calculateJasa() {
    total = 0;
    for (var e in _detailJasa) {
      total += double.parse(e['sub_total'].toString());
    }
    for (var e in _detailPart) {
      total += double.parse(e['sub_total'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cetak Kwitansi')),
      body: SizedBox(
        width: 1350,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 500,
                    child: TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autofocus: true,
                      controller: _noTransaksi,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Transaksi',
                        hintText: 'Masukkan nomor Transaksi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.car_rental),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      elevation: 5,
                      shadowColor: Colors.blue,
                    ),
                    onPressed: _searchVehicle,
                    child: const Text('Cari'),
                  ),
                ],
              ),
              Expanded(
                child: BlocConsumer<
                  TransaksiServiceDetailBloc,
                  TransaksiServiceDetailState
                >(
                  listener: (context, state) {
                    if (state is TransaksiServiceLoaded) {
                      //print(state);
                      setState(() {
                        loadTransaksi(state.data, state.jasa, state.part);
                      });
                    }
                  },
                  builder:
                      (context, state) =>
                          !dapat
                              ? Center(child: CircularProgressIndicator())
                              : _transaksiServis.isEmpty
                              ? Center(child: Text('Tidak ditemukan data!'))
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _transaksiServis.length,
                                itemBuilder: (_, i) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 8,
                                        ),
                                        child: Card(
                                          color: Colors.amber[100],
                                          elevation: 4,
                                          margin: EdgeInsets.zero,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: _buildDetailRows(),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8,
                                        ),
                                        child: Container(
                                          height: 2,
                                          width: 1280,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.rectangle,
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SizedBox(
                                            width: 1350,
                                            //height: 1300,
                                            child: Form(
                                              key: _formKey,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                          bottom: 4,
                                                        ),
                                                    child: Text(
                                                      'Detail Jasa',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        _detailJasa.length,
                                                    itemBuilder: (_, j) {
                                                      var jasa = _detailJasa[j];
                                                      jasas = jasa;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Row(
                                                          spacing: 8,
                                                          children: [
                                                            textField(
                                                              con: con,
                                                              title:
                                                                  "Nama Jasa",
                                                              width: 320,
                                                              value:
                                                                  jasa['nama_jasa']
                                                                      .toString(),
                                                            ),
                                                            textField(
                                                              con: con,
                                                              title:
                                                                  "Harga Jasa",
                                                              width: 220,
                                                              value: nf.format(
                                                                double.parse(
                                                                  jasa['harga_jual']
                                                                      .toString(),
                                                                ),
                                                              ),
                                                            ),
                                                            textField(
                                                              con: con,
                                                              readOnly: false,
                                                              title: "Disc",
                                                              width: 100,
                                                              value:
                                                                  jasa['disc']
                                                                      .toString(),
                                                              onSubmitted: (v) {
                                                                if (v
                                                                    .isNotEmpty) {
                                                                  setState(() {
                                                                    jasa['disc'] =
                                                                        v;
                                                                    double
                                                                    disc =
                                                                        (double.parse(
                                                                              jasa['harga_jual'].toString(),
                                                                            ) *
                                                                            double.parse(
                                                                              jasa['jumlah'].toString(),
                                                                            ) *
                                                                            double.parse(
                                                                              v,
                                                                            ) /
                                                                            100);
                                                                    jasa['sub_total'] =
                                                                        (double.parse(
                                                                              jasa['harga_jual'].toString(),
                                                                            ) *
                                                                            double.parse(
                                                                              jasa['jumlah'].toString(),
                                                                            )) -
                                                                        disc;
                                                                    calculateJasa();
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            textField(
                                                              con: con,

                                                              title: "Total",
                                                              width: 100,
                                                              value: nf.format(
                                                                double.parse(
                                                                  jasa['sub_total']
                                                                      .toString(),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                          bottom: 4,
                                                        ),
                                                    child: Text(
                                                      'Detail Part',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        _detailPart.length,
                                                    itemBuilder: (_, p) {
                                                      var jasa = _detailPart[p];
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Row(
                                                          spacing: 8,
                                                          children: [
                                                            textField(
                                                              con: con,
                                                              title:
                                                                  "Nama Suku Cadang",
                                                              width: 320,
                                                              value:
                                                                  jasa['nama_part']
                                                                      .toString(),
                                                            ),
                                                            textField(
                                                              con: con,
                                                              title:
                                                                  "Harga Suku Cadang",
                                                              width: 220,
                                                              value: nf.format(
                                                                double.parse(
                                                                  jasa['harga_jual']
                                                                      .toString(),
                                                                ),
                                                              ),
                                                            ),
                                                            textField(
                                                              textInputFormter: [
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly,
                                                              ],
                                                              con: con,
                                                              readOnly: false,
                                                              title: "Disc",
                                                              width: 100,
                                                              value:
                                                                  jasa['disc']
                                                                      .toString(),
                                                              onSubmitted: (v) {
                                                                if (v
                                                                    .isNotEmpty) {
                                                                  setState(() {
                                                                    jasa['disc'] =
                                                                        v;
                                                                    double
                                                                    disc =
                                                                        (double.parse(
                                                                              jasa['harga_jual'].toString(),
                                                                            ) *
                                                                            double.parse(
                                                                              jasa['jumlah'].toString(),
                                                                            ) *
                                                                            double.parse(
                                                                              v,
                                                                            ) /
                                                                            100);
                                                                    jasa['sub_total'] =
                                                                        (double.parse(
                                                                              jasa['harga_jual'].toString(),
                                                                            ) *
                                                                            double.parse(
                                                                              jasa['jumlah'].toString(),
                                                                            )) -
                                                                        disc;
                                                                    calculateJasa();
                                                                  });
                                                                }
                                                                return;
                                                              },
                                                            ),
                                                            textField(
                                                              con: con,

                                                              title: "Total",
                                                              width: 100,
                                                              value: nf.format(
                                                                double.parse(
                                                                  jasa['sub_total']
                                                                      .toString(),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(height: 16),
                                                  Row(
                                                    children: [
                                                      Center(
                                                        child: SizedBox(
                                                          width: 674,
                                                          child: Text(
                                                            'Sub Total ',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      textField(
                                                        con: con,

                                                        title: "Sub Total",
                                                        width: 100,
                                                        value: nf.format(total),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 16),
                                                  Center(
                                                    child: ElevatedButton(
                                                      style: IconButton.styleFrom(
                                                        backgroundColor:
                                                            _transaksiServis.first['status'] ==
                                                                        'Komplit' ||
                                                                    _transaksiServis
                                                                            .first['status'] ==
                                                                        'Lunas'
                                                                ? Colors.yellow
                                                                : Colors.blue,
                                                        foregroundColor:
                                                            Colors.black,
                                                        elevation: 5,
                                                        shadowColor:
                                                            Colors.yellow,
                                                      ),
                                                      onPressed:
                                                          _transaksiServis.first['status'] ==
                                                                      'Komplit' ||
                                                                  _transaksiServis
                                                                          .first['status'] ==
                                                                      'Lunas'
                                                              ? () async {
                                                                await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (
                                                                        BuildContext
                                                                        context,
                                                                      ) => StatefulBuilder(
                                                                        builder: (
                                                                          context,
                                                                          setState,
                                                                        ) {
                                                                          return AlertDialog(
                                                                            backgroundColor:
                                                                                Colors.yellow,
                                                                            title: Text(
                                                                              'Apakah anda ingin membatalkan proses kwitansi ini?',
                                                                            ),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  'Batal',
                                                                                ),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  context
                                                                                      .read<
                                                                                        TransaksiServiceDetailBloc
                                                                                      >()
                                                                                      .add(
                                                                                        BatalCetakKwitansi(
                                                                                          _transaksiServis.first,
                                                                                        ),
                                                                                      );

                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  'Proses',
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                                ).then(
                                                                  (onValue) =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                                );
                                                              }
                                                              : () async {
                                                                List<
                                                                  Map<
                                                                    String,
                                                                    dynamic
                                                                  >
                                                                >
                                                                listJ = [];
                                                                List<
                                                                  Map<
                                                                    String,
                                                                    dynamic
                                                                  >
                                                                >
                                                                listP = [];
                                                                double totalJ =
                                                                    0;
                                                                double totalP =
                                                                    0;
                                                                double
                                                                totalLaba = 0;
                                                                double
                                                                beliJasa = 0;
                                                                double
                                                                beliPart = 0;
                                                                for (var e
                                                                    in _detailJasa) {
                                                                  listJ.add({
                                                                    "id":
                                                                        e['id'],
                                                                    "disc":
                                                                        e['disc'],
                                                                    "sub_total":
                                                                        e['sub_total'],
                                                                    "status":
                                                                        "Komplit",
                                                                  });
                                                                  totalJ += double.parse(
                                                                    e['sub_total']
                                                                        .toString(),
                                                                  );
                                                                  double
                                                                  lb = (double.parse(
                                                                    e['harga_jual']
                                                                        .toString(),
                                                                  ));
                                                                  double
                                                                  jml = double.parse(
                                                                    e['jumlah']
                                                                        .toString(),
                                                                  );
                                                                  double tlb =
                                                                      (lb -
                                                                          double.parse(
                                                                            e['harga_beli'].toString(),
                                                                          )) *
                                                                      jml;
                                                                  double dsc =
                                                                      (double.parse(
                                                                            e['disc'].toString(),
                                                                          ) /
                                                                          100);
                                                                  totalLaba +=
                                                                      (tlb) -
                                                                      (lb *
                                                                          jml *
                                                                          dsc);

                                                                  beliJasa += double.parse(
                                                                    e['harga_beli']
                                                                        .toString(),
                                                                  );
                                                                }
                                                                for (var es
                                                                    in _detailPart) {
                                                                  listP.add({
                                                                    "id":
                                                                        es['id'],
                                                                    "disc":
                                                                        es['disc'],
                                                                    "sub_total":
                                                                        es['sub_total'],
                                                                    "status":
                                                                        "Komplit",
                                                                  });
                                                                  totalP += double.parse(
                                                                    es['sub_total']
                                                                        .toString(),
                                                                  );
                                                                  beliPart += double.parse(
                                                                    es['harga_beli']
                                                                        .toString(),
                                                                  );
                                                                  double
                                                                  lb = (double.parse(
                                                                    es['harga_jual']
                                                                        .toString(),
                                                                  ));
                                                                  double
                                                                  jml = double.parse(
                                                                    es['jumlah']
                                                                        .toString(),
                                                                  );
                                                                  double tlb =
                                                                      (lb -
                                                                          double.parse(
                                                                            es['harga_beli'].toString(),
                                                                          )) *
                                                                      jml;
                                                                  double dsc =
                                                                      (double.parse(
                                                                            es['disc'].toString(),
                                                                          ) /
                                                                          100);
                                                                  totalLaba +=
                                                                      (tlb) -
                                                                      (lb *
                                                                          jml *
                                                                          dsc);
                                                                }
                                                                Map<
                                                                  String,
                                                                  dynamic
                                                                >
                                                                lists = {
                                                                  'id':
                                                                      _transaksiServis
                                                                          .first['idpkb'],
                                                                  'total_jasa':
                                                                      totalJ,
                                                                  'total_laba':
                                                                      totalLaba,
                                                                  'total_belijasa':
                                                                      beliJasa,
                                                                  'total_part':
                                                                      totalP,
                                                                  'sub_total':
                                                                      total,
                                                                  'total_belipart':
                                                                      beliPart,
                                                                };
                                                                await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (
                                                                        BuildContext
                                                                        context,
                                                                      ) => StatefulBuilder(
                                                                        builder: (
                                                                          context,
                                                                          setState,
                                                                        ) {
                                                                          return AlertDialog(
                                                                            title: Text(
                                                                              'Apakah anda ingin proses kwitansi ini?',
                                                                            ),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  'Batal',
                                                                                ),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  context
                                                                                      .read<
                                                                                        TransaksiServiceDetailBloc
                                                                                      >()
                                                                                      .add(
                                                                                        CetakKwitansi(
                                                                                          lists,
                                                                                          listJ,
                                                                                          listP,
                                                                                        ),
                                                                                      );
                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  'Proses',
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                                ).then(
                                                                  (onValue) =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                                );
                                                              },
                                                      child:
                                                          _transaksiServis
                                                                      .first['status'] ==
                                                                  'Lunas'
                                                              ? null
                                                              : _transaksiServis
                                                                      .first['status'] ==
                                                                  'Komplit'
                                                              ? Text(
                                                                'Batal Cetak Kwitansai',
                                                              )
                                                              : Text(
                                                                'Cetak Kwitansai',
                                                              ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  SizedBox(height: 16),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRows() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(width: 360, child: Text('Nama Pelanggan')),
                  SizedBox(width: 380, child: Text('Alamat Pelanggan')),
                  SizedBox(width: 120, child: Text('No. Telepon')),
                  SizedBox(width: 120, child: Text('No. Plat')),
                  SizedBox(width: 220, child: Text('No. Rangka')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: Container(
                  height: 1,
                  width: 1150,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 360,
                    child: Text(
                      _transaksiServis.first['nama_pelanggan'].toString(),
                    ),
                  ),
                  SizedBox(
                    width: 380,
                    child: Text(_transaksiServis.first['alamat'].toString()),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(_transaksiServis.first['telepon'].toString()),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      _transaksiServis.first['plat_nomor'].toString(),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: Text(
                      _transaksiServis.first['nomor_rangka'].toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textField({
    List<TextInputFormatter>? textInputFormter,
    String? title,
    double? width,
    String? value,
    TextAlign? align,
    FocusNode? focusNode,
    bool? readOnly,
    bool? enabled,
    FormFieldValidator<String>? validator,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    TextEditingController? con,
  }) {
    con = TextEditingController(text: value);

    return SizedBox(
      width: width,
      child: TextFormField(
        inputFormatters: textInputFormter,
        readOnly: readOnly ?? true,
        focusNode: focusNode,
        enabled: _transaksiServis.first['status'] == 'Komplit' ? false : true,
        controller: con,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        textAlign: align ?? TextAlign.start,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, style: BorderStyle.none),
          ),
          filled:
              readOnly == false
                  ? true
                  : enabled == false
                  ? true
                  : false,
          fillColor: enabled == true ? Colors.yellow[200] : Colors.grey[100],
          labelText: title,
        ),
        style: TextStyle(color: Colors.black),
        validator: validator,
      ),
    );
  }
}
