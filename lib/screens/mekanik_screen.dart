// lib/screens/mekanik_list_screen.dart
import 'package:bengkel/blocs/mekanik/mekanik_bloc.dart';
import 'package:bengkel/blocs/mekanik/mekanik_event.dart';
import 'package:bengkel/blocs/mekanik/mekanik_state.dart';
import 'package:bengkel/model/mekanik.dart';
import 'package:bengkel/screens/add_edit_mekanik_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import layar tambah/edit mekanik

class MekanikListScreen extends StatefulWidget {
  const MekanikListScreen({super.key});

  @override
  State<MekanikListScreen> createState() => _MekanikListScreenState();
}

class _MekanikListScreenState extends State<MekanikListScreen> {
  TextEditingController con = TextEditingController();
  List<Mekanik> sup = [];
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadMekanik saat layar pertama kali dibuat
    context.read<MekanikBloc>().add(const LoadMekanik());
  }

  // Fungsi untuk menavigasi ke layar tambah mekanik
  void _navigateToAddMekanik() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditMekanikScreen()),
    );
  }

  // Fungsi untuk menavigasi ke layar edit mekanik
  void _navigateToEditMekanik(Mekanik mekanik) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditMekanikScreen(mekanik: mekanik),
      ),
    );
  }

  // Fungsi untuk menghapus mekanik
  void _deleteMekanik(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus mekanik ini?'),
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
      // Dispatch DeleteMekanik event
      context.read<MekanikBloc>().add(DeleteMekanik(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Mekanik')),
      body: BlocConsumer<MekanikBloc, MekanikState>(
        listener: (context, state) {
          // Digunakan untuk side-effects seperti menampilkan Snackbar
          if (state is MekanikError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
          // Anda bisa menambahkan notifikasi sukses di sini jika diperlukan
        },
        builder: (context, state) {
          if (state is MekanikLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MekanikLoaded) {
            if (state.mekanikList.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada mekanik. Tekan tombol + untuk menambah.',
                ),
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
                              labelText: 'Search by Nama, Alamat or Rule',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {
                                sup =
                                    state.mekanikList
                                        .where(
                                          (v) =>
                                              v.namaMekanik
                                                  .toLowerCase()
                                                  .contains(
                                                    value.toLowerCase(),
                                                  ) ||
                                              v.alamat!.toLowerCase().contains(
                                                value.toLowerCase(),
                                              ) ||
                                              v.rule!.toLowerCase().contains(
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
                              SizedBox(width: 360, child: Text('Nama Mekanik')),
                              SizedBox(
                                width: 360,
                                child: Text(
                                  'Alamat Mekanik',
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  'Telepon',
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text('Rule', textAlign: TextAlign.left),
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
                                  ? state.mekanikList.length
                                  : sup.length,
                          itemBuilder: (context, index) {
                            final jasa =
                                con.text.isEmpty
                                    ? state.mekanikList[index]
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
                                      width: 360,
                                      child: Text(jasa.namaMekanik),
                                    ),
                                    SizedBox(
                                      width: 360,
                                      child: Text(
                                        jasa.alamat ?? "",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        jasa.telepon ?? "",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        jasa.rule ?? "",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(width: 80),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _navigateToEditMekanik(
                                            jasa,
                                          ), // Panggil fungsi navigasi edit
                                    ),
                                    SizedBox(width: 20),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteMekanik(jasa.id!),
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
          } else if (state is MekanikError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Tekan tombol + untuk menambah mekanik.'),
          ); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMekanik,
        backgroundColor: Colors.lightBlue, // Panggil fungsi navigasi tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
