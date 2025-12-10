// lib/screens/jasa_list_screen.dart
import 'package:bengkel/blocs/jasa/jasa_bloc.dart';
import 'package:bengkel/blocs/jasa/jasa_event.dart';
import 'package:bengkel/blocs/jasa/jasa_state.dart';
import 'package:bengkel/model/jasa.dart';
import 'package:bengkel/screens/add_edit_jasa_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// Import layar tambah/edit jasa

class JasaListScreen extends StatefulWidget {
  const JasaListScreen({super.key});

  @override
  State<JasaListScreen> createState() => _JasaListScreenState();
}

class _JasaListScreenState extends State<JasaListScreen> {
  TextEditingController con = TextEditingController();
  List<Jasa> sup = [];
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadJasa saat layar pertama kali dibuat
    context.read<JasaBloc>().add(const LoadJasa());
  }

  // Fungsi untuk menavigasi ke layar tambah jasa
  void _navigateToAddJasa() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddEditJasaScreen()));
  }

  // Fungsi untuk menavigasi ke layar edit jasa
  void _navigateToEditJasa(Jasa jasa) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEditJasaScreen(jasa: jasa)),
    );
  }

  // Fungsi untuk menghapus jasa
  void _deleteJasa(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus jasa ini?'),
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
      // Dispatch DeleteJasa event
      context.read<JasaBloc>().add(DeleteJasa(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Jasa')),
      body: BlocConsumer<JasaBloc, JasaState>(
        listener: (context, state) {
          // Digunakan untuk side-effects seperti menampilkan Snackbar
          if (state is JasaError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
          // Anda bisa menambahkan notifikasi sukses di sini jika diperlukan
        },
        builder: (context, state) {
          if (state is JasaLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JasaLoaded) {
            if (state.jasaList.isEmpty) {
              return const Center(
                child: Text('Tidak ada jasa. Tekan tombol + untuk menambah.'),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1350,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextField(
                            controller: con,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Search by Name',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {
                                sup =
                                    state.jasaList
                                        .where(
                                          (v) => v.namaJasa
                                              .toLowerCase()
                                              .contains(value.toLowerCase()),
                                        )
                                        .toList();
                              });
                            },
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.blueGrey[100],

                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text('No.', textAlign: TextAlign.center),
                              ),
                              SizedBox(width: 380, child: Text('Nama Jasa')),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  'Harga Beli',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  'Harga Jual',
                                  textAlign: TextAlign.right,
                                ),
                              ),

                              SizedBox(width: 80),
                              Text(
                                'Edit',
                                style: TextStyle(color: Colors.blue),
                              ),
                              SizedBox(width: 40),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount:
                              con.text.isEmpty
                                  ? state.jasaList.length
                                  : sup.length,
                          itemBuilder: (context, index) {
                            final jasa =
                                con.text.isEmpty
                                    ? state.jasaList[index]
                                    : sup[index];
                            return Card(
                              color: Colors.cyan[50],

                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        '${index + 1}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 380,
                                      child: Text(jasa.namaJasa),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        NumberFormat(
                                          '#,###',
                                        ).format(jasa.hargaBeli),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        NumberFormat(
                                          '#,###',
                                        ).format(jasa.hargaJual),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),

                                    SizedBox(width: 80),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _navigateToEditJasa(
                                            jasa,
                                          ), // Panggil fungsi navigasi edit
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteJasa(jasa.id!),
                                    ),
                                  ],
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
            );
          } else if (state is JasaError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Tekan tombol + untuk menambah jasa.'),
          ); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: _navigateToAddJasa, // Panggil fungsi navigasi tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
