import 'package:bengkel/blocs/part/part_bloc.dart';
import 'package:bengkel/blocs/part/part_event.dart';
import 'package:bengkel/blocs/part/part_state.dart';
import 'package:bengkel/model/part.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// lib/screens/suku_cadang_list_screen.dart
// Import flutter_bloc

// Import States
import 'add_edit_suku_cadang_screen.dart'; // Import layar tambah/edit suku cadang

class SukuCadangListScreen extends StatefulWidget {
  final bool? select;
  const SukuCadangListScreen({super.key, this.select});

  @override
  State<SukuCadangListScreen> createState() => _SukuCadangListScreenState();
}

class _SukuCadangListScreenState extends State<SukuCadangListScreen> {
  List<SukuCadang> part = [];
  TextEditingController con = TextEditingController();
  String? noPart;
  int a = -1;
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadSukuCadang saat layar pertama kali dibuat
    // Menggunakan `read` karena tidak perlu membangun ulang widget saat init
    context.read<SukuCadangBloc>().add(const LoadParts());
  }

  // Fungsi untuk menavigasi ke layar tambah suku cadang
  void _navigateToAddSukuCadang() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditSukuCadangScreen()),
    );
  }

  // Fungsi untuk menavigasi ke layar edit suku cadang
  void _navigateToEditSukuCadang(SukuCadang sukuCadang) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditSukuCadangScreen(sukuCadang: sukuCadang),
      ),
    );
  }

  // Fungsi untuk menghapus suku cadang
  void _deleteSukuCadang(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus suku cadang ini?',
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
      // Dispatch DeleteSukuCadang event
      context.read<SukuCadangBloc>().add(DeletePart(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Suku Cadang')),
      body: BlocConsumer<SukuCadangBloc, PartState>(
        listener: (context, state) {
          // Digunakan untuk side-effects seperti menampilkan Snackbar
          if (state is PartError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          } else if (state is PartLoading && state.props.isNotEmpty) {
            // Contoh notifikasi saat data berhasil dimuat setelah operasi CRUD
            // Atau Anda bisa menambahkan event spesifik untuk notifikasi sukses
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Daftar suku cadang diperbarui!')),
            // );
          }
        },
        builder: (context, state) {
          if (state is PartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PartsLoaded) {
            if (state.parts.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada suku cadang. Tekan tombol + untuk menambah.',
                ),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: 1350,
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
                              labelText: 'Search by Nama and Kode Part',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {
                                part =
                                    state.parts
                                        .where(
                                          (v) =>
                                              v.namaPart.toLowerCase().contains(
                                                value.toLowerCase(),
                                              ) ||
                                              v.kodePart!
                                                  .toLowerCase()
                                                  .contains(
                                                    value.toLowerCase(),
                                                  ),
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
                              SizedBox(width: 180, child: Text('Kode Part')),
                              SizedBox(width: 380, child: Text('Nama Part')),
                              SizedBox(width: 100, child: Text('Stok')),
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
                                  ? state.parts.length
                                  : part.length,
                          itemBuilder: (context, index) {
                            final sukuCadang =
                                con.text.isEmpty
                                    ? state.parts[index]
                                    : part[index];
                            return InkWell(
                              onTap:
                                  widget.select == true
                                      ? () {
                                        setState(() {
                                          a = index;
                                          noPart = sukuCadang.kodePart;
                                        });
                                        // ScaffoldMessenger.of(
                                        //   context,
                                        // ).showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //       '$a dan index:$index $noPart',
                                        //     ),
                                        //   ),
                                        // );
                                      }
                                      : null,
                              child: Card(
                                color:
                                    a == index
                                        ? Colors.blue[300]
                                        : Colors.amber[100],

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
                                      width: 180,
                                      child: Text(sukuCadang.kodePart ?? '-'),
                                    ),
                                    SizedBox(
                                      width: 380,
                                      child: Text(sukuCadang.namaPart),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(sukuCadang.stok.toString()),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        NumberFormat(
                                          '#,###',
                                        ).format(sukuCadang.hargaBeli),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        NumberFormat(
                                          '#,###',
                                        ).format(sukuCadang.hargaJual),
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
                                          () => _navigateToEditSukuCadang(
                                            sukuCadang,
                                          ), // Panggil fungsi navigasi edit
                                    ),
                                    SizedBox(width: 40),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () =>
                                              _deleteSukuCadang(sukuCadang.id!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      widget.select == true
                          ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shadowColor: Colors.yellow,
                              elevation: 4,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pop(context, noPart);
                            },
                            label: Text("Pilih"),
                            icon: Icon(Icons.select_all),
                          )
                          : Container(),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is PartError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Tekan tombol + untuk menambah suku cadang.'),
          ); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: _navigateToAddSukuCadang, // Panggil fungsi navigasi tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
