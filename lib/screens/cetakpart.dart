import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class CetakPart extends StatefulWidget {
  const CetakPart({super.key});

  @override
  State<CetakPart> createState() => _CetakPartState();
}

class _CetakPartState extends State<CetakPart> {
  final TextEditingController _platNumberController = TextEditingController();
  final TextEditingController _kodePart = TextEditingController();
  final TextEditingController _namaPart = TextEditingController();
  final TextEditingController _hargaPart = TextEditingController();
  final TextEditingController _jumlah = TextEditingController();
  final TextEditingController _total = TextEditingController();
  List<Map<String, dynamic>> listPart = [];
  bool kurang = false;
  List<Map<String, dynamic>> part = [];
  @override
  void dispose() {
    _platNumberController.dispose();
    _kodePart.dispose();
    _namaPart.dispose();
    _hargaPart.dispose();
    _jumlah.dispose();
    _total.dispose();
    super.dispose();
  }

  void _searchVehicle() {
    final platNumber = _platNumberController.text.trim();
    if (platNumber.isNotEmpty) {
      context.read<TransaksiServiceDetailBloc>().add(
        LoadTransaksiService(cetakPart: int.parse(platNumber)),
      );

      setState(() {
        kurang = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cetak Part')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1350,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 500,
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autofocus: true,
                        controller: _platNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Transaksi',
                          hintText: 'Masukkan nomor transaksi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.car_rental),
                        ),
                        onSubmitted: (value) => _searchVehicle(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.blue,
                      ),
                      onPressed: _searchVehicle,
                      child: const Text('Cari Transaksi'),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(8), child: Divider()),
                BlocListener<
                  TransaksiServiceDetailBloc,
                  TransaksiServiceDetailState
                >(
                  listener: (context, state) {
                    if (state is TransaksiServiceLoaded) {
                      setState(() {
                        part = [];
                        part =
                            state.part
                                .where((v) => v['status'] != 'Lunas')
                                .toList();
                        listPart =
                            part.map((detail) {
                              return {
                                'cb': false,
                                'id': detail['id'],
                                'id_part': detail['id'],
                                'kode_part': detail['kode_part'],
                                'nama_part': detail['nama_part'],
                                'stok': detail['stok'],
                                'harga_beli': detail['harga_beli'],
                                'harga_jual': detail['harga_jual'],
                                'jumlah': detail['jumlah'],
                                'sub_total': detail['sub_total'],
                                'status': detail['status'],
                              };
                            }).toList();
                      });
                    } else {
                      setState(() {
                        part = [];
                      });
                    }
                  },
                  child:
                      part.isEmpty
                          ? Expanded(
                            child: Center(child: Text('Tidak ada transaksi')),
                          )
                          : Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 1150,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Form(
                                          key: _formKey,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: listPart.length,
                                            itemBuilder: (_, i) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                  bottom: 4,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  spacing: 16,
                                                  children: [
                                                    Center(
                                                      child: Checkbox(
                                                        value:
                                                            listPart[i]['status'] ==
                                                                    'Lunas'
                                                                ? false
                                                                : listPart[i]['cb'],
                                                        onChanged:
                                                            listPart[i]['status'] ==
                                                                    'Lunas'
                                                                ? null
                                                                : (
                                                                  v,
                                                                ) => setState(() {
                                                                  listPart[i]['cb'] =
                                                                      v;
                                                                }),
                                                      ),
                                                    ),
                                                    textField(
                                                      enabled:
                                                          listPart[i]['status'] ==
                                                                  'Komplit'
                                                              ? false
                                                              : true,
                                                      title: 'Kode Suku Cadang',
                                                      width: 200,
                                                      con: _kodePart,
                                                      value:
                                                          listPart[i]['kode_part'],
                                                    ),
                                                    textField(
                                                      enabled:
                                                          listPart[i]['status'] ==
                                                                  'Komplit'
                                                              ? false
                                                              : true,
                                                      title: 'Nama Suku Cadang',
                                                      width: 380,
                                                      con: _kodePart,
                                                      value:
                                                          listPart[i]['nama_part'],
                                                    ),
                                                    textField(
                                                      enabled:
                                                          listPart[i]['status'] ==
                                                                  'Komplit'
                                                              ? false
                                                              : true,
                                                      title: 'Jumlah',
                                                      width: 80,
                                                      con: _kodePart,
                                                      readOnly:
                                                          listPart[i]['status'] ==
                                                                  'Komplit'
                                                              ? true
                                                              : false,
                                                      align: TextAlign.center,
                                                      value:
                                                          listPart[i]['jumlah']
                                                              .toString(),
                                                      onChanged: (p) {
                                                        if (p.isNotEmpty) {
                                                          setState(() {
                                                            listPart[i]['jumlah'] =
                                                                p;
                                                            listPart[i]['sub_total'] =
                                                                double.parse(
                                                                  p,
                                                                ) *
                                                                listPart[i]['harga_jual'];
                                                          });
                                                        }
                                                      },
                                                      validator: (c) {
                                                        if (int.parse(
                                                              listPart[i]['jumlah']
                                                                  .toString(),
                                                            ) >
                                                            int.parse(
                                                              listPart[i]['stok']
                                                                  .toString(),
                                                            )) {
                                                          setState(() {
                                                            kurang = true;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            kurang = false;
                                                          });
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    textField(
                                                      enabled:
                                                          listPart[i]['status'] ==
                                                                  'Komplit'
                                                              ? false
                                                              : true,
                                                      title: 'Harga',
                                                      width: 150,
                                                      con: _kodePart,
                                                      align: TextAlign.right,
                                                      value: NumberFormat(
                                                        '#,###',
                                                      ).format(
                                                        double.parse(
                                                          listPart[i]['harga_jual']
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                    textField(
                                                      enabled:
                                                          listPart[i]['status'] ==
                                                                  'Komplit'
                                                              ? false
                                                              : true,
                                                      title: 'Total',
                                                      width: 150,
                                                      con: _kodePart,
                                                      align: TextAlign.right,
                                                      value: NumberFormat(
                                                        '#,###',
                                                      ).format(
                                                        double.parse(
                                                          listPart[i]['sub_total']
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Row(
                                        spacing: 16,
                                        children: [
                                          ElevatedButton(
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  listPart
                                                          .map(
                                                            (v) => v['status'],
                                                          )
                                                          .contains('In Proses')
                                                      ? Colors.blue
                                                      : Colors.yellow,
                                              foregroundColor: Colors.black,
                                              elevation: 5,
                                              shadowColor: Colors.yellow,
                                            ),
                                            onPressed:
                                                listPart
                                                        .map((v) => v['status'])
                                                        .contains('In Proses')
                                                    ? () {
                                                      final form =
                                                          _formKey.currentState;

                                                      var data =
                                                          listPart
                                                              .where(
                                                                (d) =>
                                                                    d['cb'] ==
                                                                    true,
                                                              )
                                                              .toList();
                                                      if (data.isEmpty) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                Colors
                                                                    .yellow[100],
                                                            content: Text(
                                                              "Pilih salah satu item !!!",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      for (var e in listPart) {
                                                        int stok = 0;
                                                        if (e['cb'] == true) {
                                                          stok =
                                                              int.parse(
                                                                e['stok']
                                                                    .toString(),
                                                              ) -
                                                              int.parse(
                                                                e['jumlah']
                                                                    .toString(),
                                                              );
                                                        }
                                                        if (stok >= 0) {
                                                          if (e['cb'] == true) {
                                                            context
                                                                .read<
                                                                  TransaksiServiceDetailBloc
                                                                >()
                                                                .add(
                                                                  UpdateTransaksiServicePart(
                                                                    id: e['id'],
                                                                    stok: stok,
                                                                    idPart:
                                                                        e['id_part'],
                                                                  ),
                                                                );
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              content: Text(
                                                                "Stok ${e['nama_part']}, sisa : ${e['stok']} tidak mencukupi",
                                                              ),
                                                            ),
                                                          );
                                                          break;
                                                        }
                                                      }
                                                      _searchVehicle();
                                                    }
                                                    : listPart
                                                        .map((v) => v['status'])
                                                        .contains('Lunas')
                                                    ? null
                                                    : () {
                                                      var data =
                                                          listPart
                                                              .where(
                                                                (d) =>
                                                                    d['cb'] ==
                                                                    true,
                                                              )
                                                              .toList();
                                                      if (data.isEmpty) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                Colors
                                                                    .yellow[100],
                                                            content: Text(
                                                              "Pilih salah satu item !!!",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      for (var e in listPart) {
                                                        int stok = 0;
                                                        if (e['cb'] == true) {
                                                          stok =
                                                              int.parse(
                                                                e['stok']
                                                                    .toString(),
                                                              ) +
                                                              int.parse(
                                                                e['jumlah']
                                                                    .toString(),
                                                              );

                                                          if (e['cb'] == true) {
                                                            context
                                                                .read<
                                                                  TransaksiServiceDetailBloc
                                                                >()
                                                                .add(
                                                                  BatalUpdateTransaksiServicePart(
                                                                    id: e['id'],
                                                                    stok: stok,
                                                                    idPart:
                                                                        e['id_part'],
                                                                  ),
                                                                );
                                                          }
                                                        }
                                                      }
                                                    },
                                            child:
                                                listPart
                                                        .map((v) => v['status'])
                                                        .contains('In Proses')
                                                    ? Text('Proses')
                                                    : Text('Batal Proses'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textField({
    String? title,
    double? width,
    String? value,
    TextAlign? align,
    bool? readOnly,
    bool? enabled,
    FormFieldValidator<String>? validator,
    Function(String)? onChanged,
    TextEditingController? con,
  }) {
    con = TextEditingController(text: value);

    return SizedBox(
      width: width,
      child: TextFormField(
        readOnly: readOnly ?? true,
        controller: con,
        onChanged: onChanged,
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
        style: TextStyle(color: kurang ? Colors.red : Colors.black),
        validator: validator,
      ),
    );
  }
}
