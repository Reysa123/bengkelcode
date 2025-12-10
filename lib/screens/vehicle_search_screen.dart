// lib/screens/vehicle_search_screen.dart
import 'package:bengkel/blocs/vehicle/kendaraan_bloc.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/screens/add_edit_kendaraan_screen.dart';
import 'package:bengkel/screens/add_edit_transaksi_servis_screen.dart';
import 'package:bengkel/screens/history_vehicle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/vehicle/kendaraan_event.dart';
import '../blocs/vehicle/kendaraan_state.dart';

class VehicleSearchScreen extends StatefulWidget {
  final String? his;
  const VehicleSearchScreen({this.his, super.key});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  final TextEditingController _platNumberController = TextEditingController();
  bool dapat = false;
  @override
  void dispose() {
    _platNumberController.dispose();
    super.dispose();
  }

  void _searchVehicle() {
    final platNumber = _platNumberController.text.trim();
    if (platNumber.isNotEmpty) {
      context.read<KendaraanBloc>().add(LoadKendaraanById(platNumber));
      setState(() {
        dapat = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Kendaraan'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 500,
                  child: TextField(
                    autofocus: true,
                    controller: _platNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Plat (VIN)',
                      hintText: 'Masukkan nomor plat atau VIN kendaraan',
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
                  child: const Text('Cari Kendaraan'),
                ),
                const SizedBox(width: 16),
                widget.his == null
                    ? ElevatedButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        elevation: 5,
                        shadowColor: Colors.amber,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditKendaraanScreen(),
                          ),
                        ).then((v) {
                          if (v != null) {
                            setState(() {
                              _platNumberController.text = v;
                              _searchVehicle();
                            });
                          }
                          return;
                        });
                      },
                      child: const Text('Tambah Kendaraan'),
                    )
                    : SizedBox(),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<KendaraanBloc, KendaraanState>(
                builder: (context, state) {
                  if (state is KendaraanInitial) {
                    return const Center(
                      child: Text(
                        'Masukkan nomor plat untuk memulai pencarian.',
                      ),
                    );
                  } else if (state is KendaraanLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is KendaraanLoadedById) {
                    final vehicle = state.kendaraanList;
                    bool ada = state.ada ?? false;
                    return !dapat
                        ? Center(
                          child: Text(
                            'Masukkan nomor plat untuk memulai pencarian.',
                          ),
                        )
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1280,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: vehicle.length,
                                    itemBuilder: (_, i) {
                                      final pelanggan =
                                          state.pelangganList
                                              .where(
                                                (v) =>
                                                    v.id ==
                                                    vehicle[i].pelangganId,
                                              )
                                              .toList();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Card(
                                          elevation: 4,
                                          margin: EdgeInsets.zero,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: _buildDetailRow(
                                              vehicle,
                                              i,
                                              pelanggan,
                                              ada,
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
                        );
                  } else if (state is KendaraanError) {
                    return Center(
                      child: Text(
                        'Terjadi kesalahan: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    List<Kendaraan> list,
    int i,

    List<Pelanggan> pelanggan,
    ada,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 60,
              child: Text('${i + 1}', textAlign: TextAlign.center),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(width: 120, child: Text(list[i].platNomor)),
                  SizedBox(width: 220, child: Text(list[i].nomorRangka ?? "")),
                  SizedBox(width: 150, child: Text(list[i].nomorMesin ?? "")),
                  SizedBox(width: 150, child: Text(list[i].merk)),
                  SizedBox(width: 150, child: Text(list[i].model)),
                  SizedBox(width: 120, child: Text(list[i].tahun.toString())),
                  SizedBox(width: 120, child: Text(list[i].km.toString())),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: Container(
                  height: 1,
                  width: 950,
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
                  SizedBox(width: 360, child: Text(pelanggan.first.nama)),
                  SizedBox(
                    width: 480,
                    child: Text(pelanggan.first.alamat ?? ""),
                  ),
                  SizedBox(width: 120, child: Text(pelanggan.first.telepon)),
                ],
              ),
            ],
          ),
          widget.his == null
              ? IconButton(
                onPressed:
                    ada
                        ? () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  content: Text(
                                    'Kendaraan ini masih ada outstanding transaksi!',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Keluar'),
                                    ),
                                  ],
                                ),
                          );
                        }
                        : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => AddEditTransaksiServisScreen(
                                    kendaraan: list[i],
                                    pelanggan: pelanggan.first,
                                  ),
                            ),
                          );
                        },
                icon: Icon(Icons.car_repair, color: Colors.deepOrange),
              )
              : SizedBox(),
          widget.his == null
              ? Expanded(child: SizedBox())
              : SizedBox(width: 18),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          HistoryVehicleScreen(norangka: list[i].nomorRangka),
                ),
              );
            },
            icon: Icon(Icons.history, color: Colors.blueAccent),
          ),
          SizedBox(width: 20),
        ],
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
          Center(
            child: SizedBox(
              width: 60,
              child: Text('No.', textAlign: TextAlign.center),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(width: 120, child: Text('No. Plat')),
                  SizedBox(width: 220, child: Text('No. Rangka')),
                  SizedBox(width: 150, child: Text('No. Mesin')),
                  SizedBox(width: 150, child: Text('Merk')),
                  SizedBox(width: 150, child: Text('Tipe')),
                  SizedBox(width: 120, child: Text('Tahun')),
                  SizedBox(width: 120, child: Text('Km')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: Container(
                  height: 1,
                  width: 950,
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
                  SizedBox(width: 360, child: Text('Nama Pelanggan')),
                  SizedBox(width: 480, child: Text('Alamat Pelanggan')),
                  SizedBox(width: 120, child: Text('No. Telepon')),
                ],
              ),
            ],
          ),
          widget.his == null
              ? SizedBox(
                child: Text(
                  'Buat PKB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepOrange,
                  ),
                ),
              )
              : SizedBox(),
          widget.his == null
              ? Expanded(child: SizedBox())
              : SizedBox(width: 18),
          SizedBox(
            child: Text(
              'Histori',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
