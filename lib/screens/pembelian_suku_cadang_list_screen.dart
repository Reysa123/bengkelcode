// lib/screens/pembelian_suku_cadang_list_screen.dart
import 'package:bengkel/blocs/pembelian_suku_cadang/pembelian_suku_cadang_bloc.dart';
import 'package:bengkel/blocs/pembelian_suku_cadang/pembelian_suku_cadang_event.dart';
import 'package:bengkel/blocs/pembelian_suku_cadang/pembelian_suku_cadang_state.dart';

import 'package:bengkel/model/pembelian_suku_cadang.dart';
import 'package:bengkel/screens/add_edit_pembelian_suku_cadang_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PembelianSukuCadangListScreen extends StatefulWidget {
  const PembelianSukuCadangListScreen({super.key});

  @override
  State<PembelianSukuCadangListScreen> createState() =>
      _PembelianSukuCadangListScreenState();
}

class _PembelianSukuCadangListScreenState
    extends State<PembelianSukuCadangListScreen> {
  DateFormat df = DateFormat('dd-MM-yyyy HH:mm:ss');
  NumberFormat nf = NumberFormat('#,###');
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadPembelianSukuCadang saat layar pertama kali dibuat
    context.read<PembelianSukuCadangBloc>().add(
      const LoadPembelianSukuCadangDetail(),
    );
  }

  // Fungsi untuk menavigasi ke layar tambah pembelian suku cadang
  void _navigateToAddPembelianSukuCadang() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditPembelianSukuCadangScreen(),
      ),
    );
  }

  // Fungsi untuk menavigasi ke layar edit pembelian suku cadang
  void _navigateToEditPembelianSukuCadang(PembelianSukuCadang pembelian) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AddEditPembelianSukuCadangScreen(
              pembelianSukuCadang: pembelian,
            ),
      ),
    );
  }

  // Fungsi untuk menghapus pembelian suku cadang
  void _deletePembelianSukuCadang(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus pembelian suku cadang ini?',
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
      // Dispatch DeletePembelianSukuCadang event
      context.read<PembelianSukuCadangBloc>().add(
        DeletePembelianSukuCadang(id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pembelian Suku Cadang')),
      body: BlocConsumer<PembelianSukuCadangBloc, PembelianSukuCadangState>(
        listener: (context, state) {
          // Digunakan untuk side-effects seperti menampilkan Snackbar
          if (state is PembelianSukuCadangError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
          // Anda bisa menambahkan notifikasi sukses di sini jika diperlukan
        },
        builder: (context, state) {
          if (state is PembelianSukuCadangLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PembelianSukuCadangDetailLoaded) {
            if (state.pembelianSukuCadangList.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada pembelian suku cadang. Tekan tombol + untuk menambah.',
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: state.pembelianSukuCadangList.length,
              itemBuilder: (context, index) {
                final pembelian = state.pembelianSukuCadangList[index];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1350,
                    child: Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Pembelian #${pembelian.id}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanggal: ${df.format(pembelian.tanggalPembelian)}',
                                    ),
                                    Text(
                                      'Total: Rp ${nf.format(pembelian.totalPembelian)}',
                                    ),
                                    Text(
                                      'Nama Supplier: ${pembelian.namaSupplier}',
                                    ), // Seharusnya nama supplier
                                    Text(
                                      'Catatan: ${pembelian.catatan ?? '-'}',
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () =>
                                              _navigateToEditPembelianSukuCadang(
                                                pembelian,
                                              ), // Panggil fungsi navigasi edit
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _deletePembelianSukuCadang(
                                            pembelian.id!,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                color: Colors.amber[200],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 50, child: Text('No')),
                                      SizedBox(
                                        width: 250,
                                        child: Text('No Part'),
                                      ),
                                      SizedBox(
                                        width: 350,
                                        child: Text('Nama Part'),
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Text('Jumlah'),
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          'Harga',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          'Total',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    state.detailSukuCadang
                                        .where(
                                          (e) => e.pembelianId == pembelian.id,
                                        )
                                        .toList()
                                        .length,
                                itemBuilder: (_, j) {
                                  final detailPembelian =
                                      state.detailSukuCadang
                                          .where(
                                            (e) =>
                                                e.pembelianId == pembelian.id,
                                          )
                                          .toList()[j];
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            child: Text('${j + 1}'),
                                          ),
                                          SizedBox(
                                            width: 250,
                                            child: Text(
                                              '${detailPembelian.nomorPart}',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 350,
                                            child: Text(
                                              detailPembelian.namaPart!,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              '${detailPembelian.jumlah}',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              'Rp ${nf.format(detailPembelian.hargaBeliSaatItu)}',
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              'Rp ${nf.format(detailPembelian.subTotal)}',
                                              textAlign: TextAlign.right,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is PembelianSukuCadangError) {
            return Center(child: Text('Gagal memuat: ${state.message}'));
          }
          return const Center(
            child: Text('Tekan tombol + untuk menambah pembelian suku cadang.'),
          ); // Fallback
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed:
            _navigateToAddPembelianSukuCadang, // Panggil fungsi navigasi tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
