// lib/screens/kendaraan_history_screen.dart
import 'package:bengkel/blocs/jasa/jasa_event.dart';
import 'package:bengkel/blocs/mekanik/mekanik_event.dart';
import 'package:bengkel/blocs/part/part_event.dart';
import 'package:bengkel/model/part.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal

import '../model/kendaraan.dart';

import '../model/jasa.dart'; // Untuk resolusi nama jasa
// Untuk resolusi nama suku cadang
import '../model/mekanik.dart'; // Untuk resolusi nama mekanik

import '../blocs/transaksi_servis/transaksi_servis_bloc.dart';
import '../blocs/transaksi_servis/transaksi_servis_event.dart';
import '../blocs/transaksi_servis/transaksi_servis_state.dart';
import '../blocs/jasa/jasa_bloc.dart';
import '../blocs/jasa/jasa_state.dart';
import '../blocs/part/part_bloc.dart';
import '../blocs/part/part_state.dart';
import '../blocs/mekanik/mekanik_bloc.dart';
import '../blocs/mekanik/mekanik_state.dart';

class KendaraanHistoryScreen extends StatefulWidget {
  final Kendaraan kendaraan;

  const KendaraanHistoryScreen({super.key, required this.kendaraan});

  @override
  State<KendaraanHistoryScreen> createState() => _KendaraanHistoryScreenState();
}

class _KendaraanHistoryScreenState extends State<KendaraanHistoryScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy HH:mm');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Muat riwayat servis untuk kendaraan ini
    // context.read<TransaksiServisBloc>().add(
    //   LoadTransaksiServisByKendaraanId(widget.kendaraan.id!),
    // );
    // Muat semua jasa, suku cadang, dan mekanik untuk resolusi nama
    context.read<JasaBloc>().add(const LoadJasa());
    context.read<SukuCadangBloc>().add(const LoadParts());
    context.read<MekanikBloc>().add(const LoadMekanik());
  }

  // Helper untuk mendapatkan nama jasa
  String _getJasaName(int jasaId, List<Jasa> jasaList) {
    try {
      return jasaList.firstWhere((j) => j.id == jasaId).namaJasa;
    } catch (_) {
      return 'Jasa Tidak Dikenal';
    }
  }

  // Helper untuk mendapatkan nama suku cadang
  String _getSukuCadangName(int sukuCadangId, List<SukuCadang> sukuCadangList) {
    try {
      return sukuCadangList.firstWhere((sc) => sc.id == sukuCadangId).namaPart;
    } catch (_) {
      return 'Suku Cadang Tidak Dikenal';
    }
  }

  // Helper untuk mendapatkan nama mekanik
  String _getMekanikName(int? mekanikId, List<Mekanik> mekanikList) {
    if (mekanikId == null) return '-';
    try {
      return mekanikList.firstWhere((m) => m.id == mekanikId).namaMekanik;
    } catch (_) {
      return 'Mekanik Tidak Dikenal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Servis: ${widget.kendaraan.platNomor}'),
      ),
      // Menggunakan BlocBuilder bersarang untuk mendengarkan beberapa BLoC
      body: BlocBuilder<TransaksiServisBloc, TransaksiServisState>(
        builder: (context, transaksiServisState) {
          return BlocBuilder<JasaBloc, JasaState>(
            builder: (context, jasaState) {
              return BlocBuilder<SukuCadangBloc, PartState>(
                builder: (context, sukuCadangState) {
                  return BlocBuilder<MekanikBloc, MekanikState>(
                    builder: (context, mekanikState) {
                      // Logika loading dan error handling
                      if (transaksiServisState is TransaksiServisLoading ||
                          jasaState is JasaLoading ||
                          sukuCadangState is PartLoading ||
                          mekanikState is MekanikLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (transaksiServisState is TransaksiServisError) {
                        return Center(
                          child: Text('Error: ${transaksiServisState.message}'),
                        );
                      }
                      if (jasaState is JasaError) {
                        return Center(
                          child: Text(
                            'Error memuat jasa: ${jasaState.message}',
                          ),
                        );
                      }
                      if (sukuCadangState is PartError) {
                        return Center(
                          child: Text(
                            'Error memuat suku cadang: ${sukuCadangState.message}',
                          ),
                        );
                      }
                      if (mekanikState is MekanikError) {
                        return Center(
                          child: Text(
                            'Error memuat mekanik: ${mekanikState.message}',
                          ),
                        );
                      }

                      if (transaksiServisState is TransaksiServisLoaded) {
                        final List<TransaksiServis> history =
                            transaksiServisState.transaksiServisList;
                        final List<Jasa> allJasa =
                            jasaState is JasaLoaded ? jasaState.jasaList : [];
                        final List<SukuCadang> allSukuCadang =
                            sukuCadangState is PartsLoaded
                                ? sukuCadangState.parts
                                : [];
                        final List<Mekanik> allMekanik =
                            mekanikState is MekanikLoaded
                                ? mekanikState.mekanikList
                                : [];

                        if (history.isEmpty) {
                          return const Center(
                            child: Text(
                              'Tidak ada riwayat servis untuk kendaraan ini.',
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final transaksi = history[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Servis #${transaksi.idpkb} - ${_dateFormat.format(transaksi.tanggalMasuk.toLocal())}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Status: ${transaksi.status}'),
                                    Text(
                                      'Mekanik: ${_getMekanikName(transaksi.mekanikId, allMekanik)}',
                                    ),
                                    Text(
                                      'Total Biaya: ${_currencyFormat.format(transaksi.totalFinal)}',
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal Selesai: ${transaksi.tanggalSelesai != null ? _dateFormat.format(transaksi.tanggalSelesai!.toLocal()) : '-'}',
                                        ),
                                        Text(
                                          'Catatan: ${transaksi.catatan ?? '-'}',
                                        ),
                                        const SizedBox(height: 10),
                                        // Detail Jasa
                                        Text(
                                          'Detail Jasa:',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleSmall,
                                        ),
                                        BlocBuilder<
                                          TransaksiServisBloc,
                                          TransaksiServisState
                                        >(
                                          builder: (context, detailState) {
                                            if (detailState
                                                    is TransaksiServisDetailLoaded &&
                                                detailState
                                                        .transaksiServis
                                                        .id ==
                                                    transaksi.id) {
                                              if (detailState
                                                  .detailJasa
                                                  .isEmpty) {
                                                return const Text(
                                                  'Tidak ada jasa yang tercatat.',
                                                );
                                              }
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children:
                                                    detailState.detailJasa.map((
                                                      detail,
                                                    ) {
                                                      return Text(
                                                        '- ${_getJasaName(detail.jasaId, allJasa)} (${detail.jumlah}x) : ${_currencyFormat.format(detail.subTotal)}',
                                                      );
                                                    }).toList(),
                                              );
                                            }
                                            // Memicu pemuatan detail saat tile diperluas
                                            // Pastikan ini hanya dipanggil sekali per ekspansi
                                            // dan tidak menyebabkan loop tak terbatas
                                            return const CircularProgressIndicator(); // Tampilkan loading saat detail dimuat
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        // Detail Suku Cadang
                                        Text(
                                          'Detail Suku Cadang:',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleSmall,
                                        ),
                                        BlocBuilder<
                                          TransaksiServisBloc,
                                          TransaksiServisState
                                        >(
                                          builder: (context, detailState) {
                                            if (detailState
                                                    is TransaksiServisDetailLoaded &&
                                                detailState
                                                        .transaksiServis
                                                        .id ==
                                                    transaksi.id) {
                                              if (detailState
                                                  .detailSukuCadang
                                                  .isEmpty) {
                                                return const Text(
                                                  'Tidak ada suku cadang yang digunakan.',
                                                );
                                              }
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children:
                                                    detailState.detailSukuCadang
                                                        .map((detail) {
                                                          return Text(
                                                            '- ${_getSukuCadangName(detail.sukuCadangId, allSukuCadang)} (${detail.jumlah}x) : ${_currencyFormat.format(detail.subTotal)}',
                                                          );
                                                        })
                                                        .toList(),
                                              );
                                            }
                                            // Memicu pemuatan detail saat tile diperluas
                                            // Pastikan ini hanya dipanggil sekali per ekspansi
                                            // dan tidak menyebabkan loop tak terbatas
                                            return const SizedBox.shrink(); // Hide during initial load or if not the current expanded tile
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onExpansionChanged: (isExpanded) {
                                  if (isExpanded) {
                                    // Muat detail hanya ketika tile diperluas
                                    context.read<TransaksiServisBloc>().add(
                                      LoadTransaksiServisDetail(transaksi.id!),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('Terjadi kesalahan yang tidak terduga.'),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
