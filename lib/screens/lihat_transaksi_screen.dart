import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_bloc.dart';
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_event.dart';
import 'package:bengkel/blocs/transaksi_servis/transaksi_servis_state.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:bengkel/screens/add_edit_transaksi_servis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class LihatTransaksi extends StatefulWidget {
  const LihatTransaksi({super.key});

  @override
  State<LihatTransaksi> createState() => _LihatTransaksiState();
}

class _LihatTransaksiState extends State<LihatTransaksi> {
  final TextEditingController _noTransaksi = TextEditingController();
  List<TransaksiServis> list = [], list1 = [];

  @override
  void initState() {
    context.read<TransaksiServisBloc>().add(const LoadTransaksiServis());
    super.initState();
  }

  void _searchVehicle() {
    final platNumber = _noTransaksi.text.trim();

    if (platNumber.isNotEmpty) {
      setState(() {
        list = list1.where((v) => v.idpkb == int.parse(platNumber)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lihat Transaksi')),
      body: BlocBuilder<TransaksiServisBloc, TransaksiServisState>(
        builder: (context, state) {
          if (state is TransaksiServisLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransaksiServisLoaded) {
            if (state.transaksiServisList.isEmpty) {
              return const Center(child: Text('Tidak ada transaksi service.'));
            }

            list1 = state.transaksiServisList;
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
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
                          controller: _noTransaksi,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Transaksi',
                            hintText: 'Masukkan nomor Transaksi',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.car_rental),
                          ),
                          onSubmitted: (v) {
                            _searchVehicle();
                          },
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
                  Divider(color: Colors.black),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 4,
                          top: 0,
                        ),
                        child: SizedBox(
                          width: 1620,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              list.isEmpty
                                  ? SizedBox()
                                  : Card(
                                    color: Colors.amber[100],
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8,
                                        top: 16,
                                        bottom: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            child: Text('No.'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('No.Transaksi'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('Tgl.Transaksi'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('Status'),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('No. Plat'),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: Text('No. Rangka'),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            child: Text('Km'),
                                          ),
                                          SizedBox(
                                            width: 260,
                                            child: Text('Nama Pelanggan'),
                                          ),
                                          SizedBox(
                                            width: 360,
                                            child: Text('Alamat Pelanggan'),
                                          ),
                                          SizedBox(
                                            width: 160,
                                            child: Text('Telepon Pelanggan'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    final transaksi = list[index];
                                    final f = state.kendServiceList.firstWhere(
                                      (v) => v.id == transaksi.kendaraanId,
                                    );
                                    final cust = state.pelangganList.firstWhere(
                                      (v) => v.id == f.pelangganId,
                                    );
                                    return InkWell(
                                      onDoubleTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AddEditTransaksiServisScreen(
                                                        transaksiServis:
                                                            transaksi,
                                                        kendaraan: f,
                                                        pelanggan: cust,
                                                      ),
                                            ),
                                          ),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 60,
                                                child: Text('${index + 1}'),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(
                                                  '${transaksi.idpkb}',
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(
                                                  DateFormat(
                                                    "dd-MM-yyyy",
                                                  ).format(
                                                    transaksi.tanggalMasuk,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(transaksi.status),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Text(f.platNomor),
                                              ),
                                              SizedBox(
                                                width: 180,
                                                child: Text(f.nomorRangka!),
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: Text(
                                                  transaksi.km.toString(),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 260,
                                                child: Text(cust.nama),
                                              ),
                                              SizedBox(
                                                width: 360,
                                                child: Text(cust.alamat!),
                                              ),
                                              SizedBox(
                                                width: 160,
                                                child: Text(cust.telepon),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  list.isNotEmpty ? Text('Total : ${list.length}') : SizedBox(),
                ],
              ),
            );
          } else if (state is TransaksiServisError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(child: Text('Silakan muat ulang halaman.'));
        },
      ),
    );
  }
}
