// lib/screens/pelanggan_list_screen.dart
import 'package:bengkel/blocs/pelanggan/pelanggan_bloc.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_event.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_state.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/screens/add_edit_pelanggan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import layar tambah/edit pelanggan

class PelangganListScreen extends StatefulWidget {
  const PelangganListScreen({super.key});

  @override
  State<PelangganListScreen> createState() => _PelangganListScreenState();
}

class _PelangganListScreenState extends State<PelangganListScreen> {
  List<Pelanggan> cust = [];
  TextEditingController con = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadPelanggan saat layar pertama kali dibuat
    context.read<PelangganBloc>().add(const LoadPelanggan());
  }

  // Fungsi untuk menavigasi ke layar tambah pelanggan
  void _navigateToAddPelanggan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditPelangganScreen()),
    );
  }

  // Fungsi untuk menavigasi ke layar edit pelanggan
  void _navigateToEditPelanggan(Pelanggan pelanggan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditPelangganScreen(pelanggan: pelanggan),
      ),
    );
  }

  // Fungsi untuk menghapus pelanggan
  void _deletePelanggan(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[300],
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus pelanggan ini?',
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
      // Dispatch DeletePelanggan event
      context.read<PelangganBloc>().add(DeletePelanggan(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pelanggan')),
      body: BlocConsumer<PelangganBloc, PelangganState>(
        listener: (context, state) {
          // Digunakan untuk side-effects seperti menampilkan Snackbar
          if (state is PelangganError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
          // Anda bisa menambahkan notifikasi sukses di sini jika diperlukan
        },
        builder: (context, state) {
          if (state is PelangganLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PelangganLoaded) {
            if (state.pelangganList.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada pelanggan. Tekan tombol + untuk menambah.',
                ),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1200,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextField(
                          controller: con,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Search by Nama or Alamat',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              cust =
                                  state.pelangganList
                                      .where(
                                        (v) =>
                                            v.nama.toLowerCase().contains(
                                              value.toLowerCase(),
                                            ) ||
                                            v.alamat!.toLowerCase().contains(
                                              value.toLowerCase(),
                                            ),
                                      )
                                      .toList();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: Card(
                        color: Colors.amber[300],
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,

                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 80, child: Text('No')),
                              SizedBox(
                                width: 220,
                                child: Text('Nama Pelanggan'),
                              ),
                              SizedBox(width: 120, child: Text('Telepon')),
                              SizedBox(width: 380, child: Text('Alamat')),
                              SizedBox(width: 180, child: Text('Email')),
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
                              SizedBox(width: 74),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        //physics: BouncingScrollPhysics(),
                        itemCount:
                            con.text.isEmpty
                                ? state.pelangganList.length
                                : cust.length,
                        itemBuilder: (context, index) {
                          final pelanggan =
                              con.text.isEmpty
                                  ? state.pelangganList[index]
                                  : cust[index];
                          return SizedBox(
                            height: 40,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,

                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text('${index + 1}'),
                                    ),
                                    SizedBox(
                                      width: 220,
                                      child: Text(pelanggan.nama, maxLines: 2),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: Text(pelanggan.telepon),
                                    ),
                                    SizedBox(
                                      width: 380,
                                      child: Text(
                                        pelanggan.alamat ?? "-",
                                        maxLines: 2,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(pelanggan.email ?? "-"),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _navigateToEditPelanggan(
                                            pelanggan,
                                          ), // Panggil fungsi navigasi edit
                                    ),
                                    SizedBox(width: 20),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _deletePelanggan(pelanggan.id!),
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
            );
          } else if (state is PelangganError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Tekan tombol + untuk menambah pelanggan.'),
          ); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: _navigateToAddPelanggan, // Panggil fungsi navigasi tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
