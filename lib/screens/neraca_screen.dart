// lib/screens/neraca_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/neraca/neraca_bloc.dart';
import '../blocs/neraca/neraca_event.dart';
import '../blocs/neraca/neraca_state.dart';

class NeracaScreen extends StatefulWidget {
  const NeracaScreen({super.key});

  @override
  State<NeracaScreen> createState() => _NeracaScreenState();
}

class _NeracaScreenState extends State<NeracaScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Muat neraca pada tanggal saat ini saat layar pertama kali dibuka
    _loadNeracaForDate(_selectedDate);
  }

  void _loadNeracaForDate(DateTime date) {
    context.read<NeracaBloc>().add(LoadNeraca(asOfDate: date));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadNeracaForDate(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neraca (Balance Sheet)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Posisi per: '),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    _dateFormat.format(_selectedDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NeracaBloc, NeracaState>(
              builder: (context, state) {
                if (state is NeracaLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NeracaLoaded) {
                  final neraca = state.neracaData;
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildSectionHeader(
                        'ASET',
                        neraca.grandTotalAset,
                        Colors.blue,
                      ),
                      _buildAccountList(neraca.totalAset),
                      const SizedBox(height: 20),

                      _buildSectionHeader(
                        'KEWAJIBAN',
                        neraca.grandTotalKewajiban,
                        Colors.orange,
                      ),
                      _buildAccountList(neraca.totalKewajiban),
                      const SizedBox(height: 20),

                      _buildSectionHeader(
                        'EKUITAS',
                        neraca.grandTotalEkuitas,
                        Colors.purple,
                      ),
                      _buildAccountList(neraca.totalEkuitas),
                      const SizedBox(height: 20),

                      const Divider(thickness: 2),
                      _buildTotalRow(
                        'TOTAL KEWAJIBAN + EKUITAS',
                        neraca.grandTotalKewajiban + neraca.grandTotalEkuitas,
                        Colors.green,
                      ),
                      const SizedBox(height: 10),
                      if (neraca.grandTotalAset !=
                          (neraca.grandTotalKewajiban +
                              neraca.grandTotalEkuitas))
                        Text(
                          'Peringatan: Neraca tidak seimbang! Selisih: ${_currencyFormat.format(neraca.grandTotalAset - (neraca.grandTotalKewajiban + neraca.grandTotalEkuitas))}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  );
                } else if (state is NeracaError) {
                  return Center(
                    child: Text('Gagal memuat neraca: ${state.message}'),
                  );
                }
                return const Center(
                  child: Text('Pilih tanggal untuk melihat neraca.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, double total, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Divider(color: Colors.grey),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total $title',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _currencyFormat.format(total),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAccountList(Map<String, double> accounts) {
    if (accounts.isEmpty) {
      return const Text(
        'Tidak ada akun dalam kategori ini.',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          accounts.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(_currencyFormat.format(entry.value)),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTotalRow(String title, double total, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          _currencyFormat.format(total),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
