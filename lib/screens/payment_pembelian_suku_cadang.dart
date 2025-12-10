import 'package:bengkel/blocs/payment/payment_bloc.dart';
import 'package:bengkel/blocs/payment/payment_event.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_bloc.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_event.dart';
import 'package:bengkel/blocs/pelanggan/pelanggan_state.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_bloc.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_event.dart';
import 'package:bengkel/blocs/penjualan_suku_cadang/penjualan_suku_cadang_state.dart';
import 'package:bengkel/model/pelanggan.dart';

import 'package:bengkel/model/penjualansukucadang.dart';
import 'package:bengkel/util/print_penjualan_part.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class PaymentPembelianSukuCadang extends StatefulWidget {
  const PaymentPembelianSukuCadang({super.key});

  @override
  State<PaymentPembelianSukuCadang> createState() =>
      _PaymentPembelianSukuCadangState();
}

class _PaymentPembelianSukuCadangState
    extends State<PaymentPembelianSukuCadang> {
  final TextEditingController _jumlahBayarController = TextEditingController();
  final TextEditingController _idTransaksi = TextEditingController();
  final TextEditingController _discController = TextEditingController();
  PenjualanSukuCadang? list;
  List<Pelanggan>? plg;
  bool lunas = false;
  double _kembalian = 0, bayar = 0, disc = 0;

  getList(List<PenjualanSukuCadang> v) {
    if (v.isNotEmpty) {
      context.read<PelangganBloc>().add(LoadPelanggan());
      _jumlahBayarController.clear();
      _discController.clear();
      _kembalian = 0;
      setState(() {
        list = v.first;
        bayar = v.first.totalPenjualan;
        _kembalian = v.first.totalPenjualan;
      });
      list!.status == 'Lunas'
          ? setState(() {
            lunas = true;
          })
          : setState(() {
            lunas = false;
          });

      setState(() {});
    }
  }

  void _searchId() {
    if (_idTransaksi.text.trim().isNotEmpty) {
      context.read<PenjualanSukuCadangBloc>().add(
        LoadPenjualanSukuCadangById(int.parse(_idTransaksi.text.trim())),
      );
    }
  }

  @override
  void initState() {
    _jumlahBayarController.addListener(_hitungKembalian);
    _discController.addListener(_hitdisc);
    super.initState();
  }

  @override
  void dispose() {
    _discController.removeListener(_hitdisc);
    _jumlahBayarController.removeListener(_hitungKembalian);
    _jumlahBayarController.dispose();
    _idTransaksi.dispose();
    super.dispose();
  }

  void _hitdisc() {
    final a = list?.totalPenjualan ?? 0;
    final jumlahBayar = int.tryParse(_jumlahBayarController.text) ?? 0;
    final discs = double.tryParse(_discController.text) ?? 0;
    final jml = a * discs / 100;
    setState(() {
      disc = jml;
      bayar = a - jml;
      _kembalian = jumlahBayar - bayar;
    });
  }

  void _hitungKembalian() {
    final jumlahBayar = int.tryParse(_jumlahBayarController.text) ?? 0;
    setState(() {
      _kembalian = jumlahBayar - bayar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kwitansi Pembayaran'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              controller: _idTransaksi,
              decoration: const InputDecoration(
                labelText: 'Nomor Transaksi',
                hintText: 'Masukkan nomor transaksi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.car_rental),
              ),
              onSubmitted: (value) => _searchId(),
            ),

            const SizedBox(width: 16),

            BlocListener<PenjualanSukuCadangBloc, PenjualanSukuCadangState>(
              listener: (context, state) {
                // print(' ssss: $state');
                if (state is PenjualanSukuCadangLoaded) {
                  getList(state.penjualanSukuCadangList);
                }
                if (state is PenjualanSukuCadangError) {
                  setState(() {
                    list = null;
                  });
                }
              },

              child: BlocListener<PelangganBloc, PelangganState>(
                listener: (context, state) {
                  if (state is PelangganLoaded) {
                    plg =
                        state.pelangganList
                            .where((v) => v.id == list!.pelangganId)
                            .toList();
                  }
                },
                child:
                    list == null
                        ? Expanded(
                          child: Center(child: Text('Tidak ditemukan data!')),
                        )
                        : lunas
                        ? Expanded(
                          child: Center(child: Text('Pembayaran sudah lunas.')),
                        )
                        : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              spacing: 16,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text('Nama Pelanggan'),
                                    ),
                                    SizedBox(width: 10, child: Text(':')),
                                    Expanded(
                                      child: SizedBox(
                                        child: Text(
                                          plg?.firstOrNull?.nama ?? "",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text('Alamat Pelanggan'),
                                    ),
                                    SizedBox(width: 10, child: Text(':')),
                                    Expanded(
                                      child: SizedBox(
                                        child: Text(
                                          plg?.firstOrNull?.alamat ?? "",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text('No Telepon'),
                                    ),
                                    SizedBox(width: 10, child: Text(':')),
                                    Expanded(
                                      child: SizedBox(
                                        child: Text(
                                          plg?.firstOrNull?.telepon ?? "",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 18,
                                  children: [
                                    Text(
                                      'Total Tagihan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Text(
                                      ':',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat('#,###').format(bayar),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                list!.totalPenjualan > (0)
                                    ? TextField(
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      autofocus: true,
                                      controller: _discController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Discount',
                                        border: OutlineInputBorder(),
                                      ),
                                    )
                                    : SizedBox(),

                                const Divider(height: 32),
                                list!.totalPenjualan > (0)
                                    ? TextField(
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      autofocus: true,
                                      controller: _jumlahBayarController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Jumlah Bayar',
                                        border: OutlineInputBorder(),
                                      ),
                                    )
                                    : SizedBox(),
                                const SizedBox(height: 16),
                                list!.totalPenjualan > (0)
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Kembalian:',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat('#,###').format(_kembalian)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                    : SizedBox(),
                                const SizedBox(height: 16),
                                list!.totalPenjualan > (0)
                                    ? SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            list!.status == 'Lunas'
                                                ? null
                                                : () async {
                                                  try {
                                                    final a = context
                                                        .read<PaymentBloc>()
                                                        .add(
                                                          PenjualanPayment(
                                                            idTransaksi:
                                                                int.parse(
                                                                  _idTransaksi
                                                                      .text
                                                                      .trim(),
                                                                ),
                                                            totalHarga:
                                                                list!
                                                                    .totalPenjualan,
                                                            jumlahBayar: bayar,
                                                            catatan:
                                                                _jumlahBayarController
                                                                    .text,
                                                            disc: disc,
                                                          ),
                                                        );
                                                    try {
                                                      final pdfBytes =
                                                          await PdfGenerator.generateTandaTerimaPdf(
                                                            judul: '',
                                                            transaksiId:
                                                                int.parse(
                                                                  _idTransaksi
                                                                      .text,
                                                                ),
                                                            nama:
                                                                plg
                                                                    ?.firstOrNull
                                                                    ?.nama ??
                                                                '',
                                                            alamat:
                                                                plg
                                                                    ?.firstOrNull
                                                                    ?.alamat ??
                                                                '',
                                                            telepon:
                                                                plg
                                                                    ?.firstOrNull
                                                                    ?.telepon ??
                                                                "",
                                                            nopol: '',
                                                            jumlahBayar: bayar,
                                                            kasir: '',
                                                            // Kirim semua suku cadang untuk resolusi nama
                                                          );

                                                      await Printing.sharePdf(
                                                        bytes: pdfBytes,
                                                        filename:
                                                            'penjualan_${_idTransaksi.text}.pdf',
                                                      );
                                                      // Atau gunakan Printing.layoutPdf untuk pratinjau langsung
                                                      // await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).hideCurrentSnackBar(); // Sembunyikan loading
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'PDF berhasil dibuat!',
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).hideCurrentSnackBar();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Gagal membuat PDF: ${e.toString()}',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    Exception(e.toString());
                                                  }
                                                  Navigator.pop(context);
                                                },
                                        icon: const Icon(Icons.payment),
                                        label: const Text(
                                          'Bayar & Cetak Bukti Pembayaran',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
