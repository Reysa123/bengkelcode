// lib/screens/kendaraan_list_screen.dart
import 'package:bengkel/blocs/vehicle/kendaraan_bloc.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_event.dart';
import 'package:bengkel/blocs/vehicle/kendaraan_state.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/screens/add_edit_kendaraan_screen.dart';
import 'package:bengkel/screens/kendaraan_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import layar tambah/edit kendaraan

class KendaraanListScreen extends StatefulWidget {
  const KendaraanListScreen({super.key});

  @override
  State<KendaraanListScreen> createState() => _KendaraanListScreenState();
}

class _KendaraanListScreenState extends State<KendaraanListScreen> {
  List<Kendaraan> kend = [];
  TextEditingController con = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadKendaraan saat layar pertama kali dibuat
    context.read<KendaraanBloc>().add(const LoadKendaraan());
  }

  // Fungsi baru untuk menavigasi ke layar riwayat kendaraan
  void _navigateToKendaraanHistory(Kendaraan kendaraan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KendaraanHistoryScreen(kendaraan: kendaraan),
      ),
    );
  }

  // Fungsi untuk menavigasi ke layar tambah kendaraan
  void _navigateToAddKendaraan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditKendaraanScreen()),
    );
  }

  // Fungsi untuk menavigasi ke layar edit kendaraan
  void _navigateToEditKendaraan(Kendaraan kendaraan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditKendaraanScreen(kendaraan: kendaraan),
      ),
    );
  }

  // Fungsi untuk menghapus kendaraan
  void _deleteKendaraan(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus kendaraan ini?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.orangeAccent[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Colors.red[200],
                  foregroundColor: Colors.black,
                  shadowColor: Colors.yellow,
                  elevation: 5,
                ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Dispatch DeleteKendaraan event
      context.read<KendaraanBloc>().add(DeleteKendaraan(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kendaraan')),
      body: BlocConsumer<KendaraanBloc, KendaraanState>(
        listener: (context, state) {
          // Digunakan untuk side-effects seperti menampilkan Snackbar
          if (state is KendaraanError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
          // Anda bisa menambahkan notifikasi sukses di sini jika diperlukan
        },
        builder: (context, state) {
          if (state is KendaraanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KendaraanLoaded) {
            if (state.kendaraanList.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada kendaraan. Tekan tombol + untuk menambah.',
                ),
              );
            }
            //kend = state.kendaraanList;
            List<Kendaraan> kend1 = state.kendaraanList;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1200,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextField(
                          autofocus: true,
                          controller: con,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Search',
                          ),
                          onChanged: (value) {
                            //print(value);
                            setState(() {
                              kend =
                                  kend1
                                      .where(
                                        (v) =>
                                            v.platNomor.toLowerCase().contains(
                                              value.toLowerCase(),
                                            ) ||
                                            v.nomorRangka!
                                                .toLowerCase()
                                                .contains(value.toLowerCase()),
                                      )
                                      .toList();
                            });
                          },
                        ),
                      ),
                    ),
                    kend.isEmpty
                        ? SizedBox()
                        : Card(
                          color: Colors.amber[300],
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 50, child: Text('No.')),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: Text('No. Plat'),
                                        ),
                                        SizedBox(
                                          width: 180,
                                          child: Text('No. Chassis'),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Text('No. Mesin'),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text('Merk'),
                                        ),
                                        SizedBox(
                                          width: 150,
                                          child: Text('Model'),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Text('Tahun'),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text('Id Pelanggan'),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 8,
                                      ),
                                      child: Container(
                                        height: 1,
                                        width: 900,
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          shape: BoxShape.rectangle,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 220,
                                          child: Text('Nama Pelanggan'),
                                        ),
                                        SizedBox(
                                          width: 380,
                                          child: Text('Alamat'),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Text('Telepon'),
                                        ),
                                        SizedBox(
                                          width: 180,
                                          child: Text('Email'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                TextButton(
                                  onPressed: null,
                                  child: Text(
                                    'History',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                TextButton(
                                  onPressed: null,
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                TextButton(
                                  onPressed: null,
                                  child: Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //     ),
                          //   ],
                          // ),
                        ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount:
                            con.text.isEmpty
                                ? state.kendaraanList.length
                                : kend.length,
                        itemBuilder: (context, index) {
                          final kendaraan =
                              con.text.isEmpty
                                  ? state.kendaraanList[index]
                                  : kend[index];
                          final pelanggan =
                              state.pelangganList
                                  .where((v) => v.id == kendaraan.pelangganId)
                                  .toList();
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Text('${index + 1}'),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(kendaraan.platNomor),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              kendaraan.nomorRangka ?? "-",
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              kendaraan.nomorMesin ?? '-',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(kendaraan.merk),
                                          ),
                                          SizedBox(
                                            width: 150,
                                            child: Text(kendaraan.model),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              kendaraan.tahun.toString(),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              kendaraan.pelangganId.toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8,
                                        ),
                                        child: Container(
                                          height: 1,
                                          width: 900,
                                          decoration: BoxDecoration(
                                            color: Colors.black12,
                                            shape: BoxShape.rectangle,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 220,
                                            child: Text(
                                              pelanggan.firstOrNull?.nama ??
                                                  '-',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 380,
                                            child: Text(
                                              pelanggan.firstOrNull?.alamat ??
                                                  "-",
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              pelanggan.firstOrNull?.telepon ??
                                                  '-',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              pelanggan.firstOrNull?.email ??
                                                  '-',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.history,
                                      color: Colors.green,
                                    ), // Ikon riwayat
                                    onPressed:
                                        () => _navigateToKendaraanHistory(
                                          kendaraan,
                                        ),
                                  ),
                                  SizedBox(width: 27),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => _navigateToEditKendaraan(
                                          kendaraan,
                                        ), // Panggil fungsi navigasi edit
                                  ),
                                  SizedBox(width: 25),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _deleteKendaraan(kendaraan.id!),
                                  ),
                                ],
                              ),
                            ),
                            //     ),
                            //   ],
                            // ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is KendaraanError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Tekan tombol + untuk menambah kendaraan.'),
          ); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: _navigateToAddKendaraan, // Panggil fungsi navigasi tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
