// lib/screens/penjualan_suku_cadang_list_screen.dart
import 'package:bengkel/blocs/part/part_bloc.dart';
import 'package:bengkel/blocs/part/part_event.dart';
import 'package:bengkel/blocs/part/part_state.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_bloc.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_event.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_state.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_bloc.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_event.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_state.dart';
import 'package:bengkel/model/part.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/penjualansukucadang.dart';
import 'package:bengkel/util/print_penjualan_part.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import 'add_edit_penjualan_suku_cadang_screen.dart'; // Import layar tambah/edit penjualan suku cadang

class PenjualanSukuCadangListScreen extends StatefulWidget {
  const PenjualanSukuCadangListScreen({super.key});

  @override
  State<PenjualanSukuCadangListScreen> createState() =>
      _PenjualanSukuCadangListScreenState();
}

class _PenjualanSukuCadangListScreenState
    extends State<PenjualanSukuCadangListScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch event LoadPenjualanSukuCadang saat layar pertama kali dibuat
    context.read<PenjualanSukuCadangBloc>().add(
      const LoadPenjualanSukuCadang(),
    );
    // Muat juga data pelanggan dan suku cadang untuk resolusi nama di daftar dan PDF
    context.read<PelangganBloc>().add(const LoadPelanggan());
    context.read<SukuCadangBloc>().add(const LoadParts());
  }

  // Fungsi untuk menavigasi ke layar tambah penjualan suku cadang
  void _navigateToAddPenjualanSukuCadang() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditPenjualanSukuCadangScreen(),
      ),
    );
  }

  // Fungsi untuk menavigasi ke layar edit penjualan suku cadang
  void _navigateToEditPenjualanSukuCadang(PenjualanSukuCadang penjualan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AddEditPenjualanSukuCadangScreen(
              penjualanSukuCadang: penjualan,
            ),
      ),
    );
  }

  // Fungsi untuk menghapus penjualan suku cadang
  void _deletePenjualanSukuCadang(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus penjualan suku cadang ini?',
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
      // Dispatch DeletePenjualanSukuCadang event
      codialog(id);
    }
  }

  codialog(int id) {
    context.read<PenjualanSukuCadangBloc>().add(DeletePenjualanSukuCadang(id));
  }

  // Fungsi untuk mencetak PDF penjualan suku cadang
  void _printPenjualanSukuCadang(int penjualanId) {
    // Tampilkan indikator loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mempersiapkan PDF...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Dispatch event untuk memuat detail penjualan
    context.read<PenjualanSukuCadangBloc>().add(
      LoadPenjualanSukuCadangDetail(penjualanId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Penjualan Suku Cadang')),
      body: MultiBlocListener(
        listeners: [
          // Listener untuk PenjualanSukuCadangBloc (error handling dan PDF generation)
          BlocListener<PenjualanSukuCadangBloc, PenjualanSukuCadangState>(
            listener: (context, state) async {
              if (state is PenjualanSukuCadangError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              } else if (state is PenjualanSukuCadangDetailLoaded) {
                // Ambil data pelanggan dan suku cadang yang sudah dimuat
                final pelangganState = context.read<PelangganBloc>().state;
                final sukuCadangState = context.read<SukuCadangBloc>().state;

                List<Pelanggan> allPelanggan = [];
                if (pelangganState is PelangganLoaded) {
                  allPelanggan = pelangganState.pelangganList;
                }

                List<SukuCadang> allSukuCadang = [];
                if (sukuCadangState is PartsLoaded) {
                  allSukuCadang = sukuCadangState.parts;
                }

                // Resolusi nama pelanggan
                Pelanggan? pelangganTerpilih;
                if (state.penjualanSukuCadang.pelangganId != null) {
                  try {
                    pelangganTerpilih = allPelanggan.firstWhere(
                      (p) => p.id == state.penjualanSukuCadang.pelangganId,
                    );
                  } catch (_) {
                    pelangganTerpilih = null; // Pelanggan tidak ditemukan
                  }
                }

                try {
                  final pdfBytes =
                      await PdfGenerator.generatePenjualanSukuCadangPdf(
                        state.penjualanSukuCadang,
                        state.detailSukuCadang,
                        pelangganTerpilih,
                        allSukuCadang, // Kirim semua suku cadang untuk resolusi nama
                      );

                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'penjualan_${state.penjualanSukuCadang.id}.pdf',
                  );
                  // Atau gunakan Printing.layoutPdf untuk pratinjau langsung
                  // await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);

                  ScaffoldMessenger.of(
                    context,
                  ).hideCurrentSnackBar(); // Sembunyikan loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF berhasil dibuat!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal membuat PDF: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
          ),
        ],
        child: BlocBuilder<PenjualanSukuCadangBloc, PenjualanSukuCadangState>(
          builder: (context, state) {
            if (state is PenjualanSukuCadangLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PenjualanSukuCadangLoaded) {
              if (state.penjualanSukuCadangList.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada penjualan suku cadang. Tekan tombol + untuk menambah.',
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.penjualanSukuCadangList.length,
                itemBuilder: (context, index) {
                  final penjualan = state.penjualanSukuCadangList[index];
                  // Ambil nama pelanggan dan suku cadang untuk ditampilkan di daftar
                  final pelangganState = context.watch<PelangganBloc>().state;
                  Pelanggan? pelangganDisplay;
                  if (pelangganState is PelangganLoaded &&
                      penjualan.pelangganId != null) {
                    try {
                      pelangganDisplay = pelangganState.pelangganList
                          .firstWhere((p) => p.id == penjualan.pelangganId);
                    } catch (_) {
                      pelangganDisplay = null; // Pelanggan tidak ditemukan
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text('Penjualan #${penjualan.transaksiId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 140, child: Text('Tanggal')),
                              SizedBox(width: 10, child: Text(':')),
                              Text(
                                DateFormat(
                                  'dd-MM-yyyy',
                                ).format(penjualan.tanggalPenjualan),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 140, child: Text('Pelanggan')),
                              SizedBox(width: 10, child: Text(':')),
                              Text(pelangganDisplay?.nama ?? 'Tunai'),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 140, child: Text('Total')),
                              SizedBox(width: 10, child: Text(':')),

                              Text(
                                'Rp ${NumberFormat('#,###').format(double.parse(penjualan.totalPenjualan.toStringAsFixed(2)))}',
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 140, child: Text('Status')),
                              SizedBox(width: 10, child: Text(':')),

                              Text(penjualan.status ?? '-'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print),
                            onPressed:
                                () => _printPenjualanSukuCadang(
                                  penjualan.transaksiId!,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed:
                                penjualan.status == 'In Proses'
                                    ? () => _navigateToEditPenjualanSukuCadang(
                                      penjualan,
                                    )
                                    : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                penjualan.status == 'In Proses'
                                    ? () => _deletePenjualanSukuCadang(
                                      penjualan.transaksiId!,
                                    )
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is PenjualanSukuCadangError) {
              return Center(child: Text('Gagal memuat: ${state.message}'));
            }
            return const Center(
              child: Text(
                'Tekan tombol + untuk menambah penjualan suku cadang.',
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: _navigateToAddPenjualanSukuCadang,
        child: const Icon(Icons.add),
      ),
    );
  }
}
