// lib/screens/jurnal_list_screen.dart
import 'package:bengkel/blocs/account/account_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal dan mata uang

import '../model/account.dart'; // Import model Akun untuk resolusi nama
import '../blocs/jurnal/jurnal_bloc.dart';
import '../blocs/jurnal/jurnal_event.dart';
import '../blocs/jurnal/jurnal_state.dart';
import '../blocs/account/account_bloc.dart'; // Import AccountBloc untuk mendapatkan nama akun
import '../blocs/account/account_state.dart'; // Import AccountState

class JurnalListScreen extends StatefulWidget {
  const JurnalListScreen({super.key});

  @override
  State<JurnalListScreen> createState() => _JurnalListScreenState();
}

class _JurnalListScreenState extends State<JurnalListScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy HH:mm');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Muat semua jurnal saat layar pertama kali dibuka
    context.read<JurnalBloc>().add(const LoadJurnal());
    // Muat semua akun untuk resolusi nama
    context.read<AccountBloc>().add(const LoadAccounts());
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            0,
            0,
            0,
          ); // Awal hari
        } else {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            23,
            59,
            59,
          ); // Akhir hari
        }
      });
      // Jika kedua tanggal sudah dipilih, muat jurnal
      if (_startDate != null && _endDate != null) {
        context.read<JurnalBloc>().add(
          LoadJurnalByDateRange(startDate: _startDate!, endDate: _endDate!),
        );
      }
    }
  }

  // Fungsi untuk mereset filter tanggal
  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    context.read<JurnalBloc>().add(
      const LoadJurnal(),
    ); // Muat semua jurnal lagi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jurnal Akuntansi'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _startDate == null
                          ? 'Dari Tanggal'
                          : _dateFormat.format(_startDate!).split(' ')[0],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _endDate == null
                          ? 'Sampai Tanggal'
                          : _dateFormat.format(_endDate!).split(' ')[0],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _resetFilter,
                  tooltip: 'Reset Filter',
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<JurnalBloc, JurnalState>(
              builder: (context, jurnalState) {
                // Mendapatkan daftar akun dari AccountBloc
                final accountState = context.watch<AccountBloc>().state;
                List<Akun> allAccounts = [];
                if (accountState is AccountsLoaded) {
                  allAccounts = accountState.accounts;
                }

                if (jurnalState is JurnalLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (jurnalState is JurnalLoaded) {
                  if (jurnalState.jurnalList.isEmpty) {
                    return const Center(child: Text('Tidak ada entri jurnal.'));
                  }
                  return ListView.builder(
                    itemCount: jurnalState.jurnalList.length,
                    itemBuilder: (context, index) {
                      final jurnal = jurnalState.jurnalList[index];
                      // Cari nama akun berdasarkan akunId
                      final Akun? akun = allAccounts.firstWhere(
                        (a) => a.id == jurnal.akunId,
                        orElse:
                            () => Akun(
                              id: -1,
                              namaAkun: 'Akun Tidak Dikenal',
                              jenisAkun: 'Unknown',
                            ), // Fallback
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dateFormat.format(jurnal.tanggal.toLocal()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                jurnal.deskripsi,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Akun: ${akun?.namaAkun}'),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Debit: ${_currencyFormat.format(jurnal.debit)}',
                                        style: TextStyle(
                                          color:
                                              jurnal.debit > 0
                                                  ? Colors.green
                                                  : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Kredit: ${_currencyFormat.format(jurnal.kredit)}',
                                        style: TextStyle(
                                          color:
                                              jurnal.kredit > 0
                                                  ? Colors.red
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (jurnal.tipeReferensi != null &&
                                  jurnal.referensiTransaksiId != null)
                                Text(
                                  'Ref: ${jurnal.tipeReferensi} #${jurnal.referensiTransaksiId}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (jurnalState is JurnalError) {
                  return Center(
                    child: Text('Gagal memuat jurnal: ${jurnalState.message}'),
                  );
                }
                return const Center(
                  child: Text('Muat jurnal untuk melihat entri.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
