import 'package:bengkel/blocs/payment/payment_bloc.dart';
import 'package:bengkel/blocs/payment/payment_event.dart';
import 'package:bengkel/blocs/payment/payment_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_event.dart';
import 'package:bengkel/screens/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _jumlahBayarController = TextEditingController();
  final TextEditingController _idTransaksi = TextEditingController();
  double _kembalian = 0;
  double _totalHarga = 0;
  NumberFormat nf = NumberFormat('#,###.##');
  @override
  void initState() {
    super.initState();

    _jumlahBayarController.addListener(_hitungKembalian);
  }

  @override
  void dispose() {
    _jumlahBayarController.removeListener(_hitungKembalian);
    _jumlahBayarController.dispose();
    _idTransaksi.dispose();
    super.dispose();
  }

  void _searchId() {
    if (_idTransaksi.text.trim().isNotEmpty) {
      context.read<TransaksiServiceDetailBloc>().add(
        LoadTransaksiServiceDetail(int.parse(_idTransaksi.text.trim())),
      );
    }
  }

  void _hitungKembalian() {
    final jumlahBayar = int.tryParse(_jumlahBayarController.text) ?? 0;
    setState(() {
      _kembalian = jumlahBayar - _totalHarga;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Kwitansi'),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TransaksiServiceDetailBloc, TransaksiServiceDetailState>(
            listener: (context, state) {
              if (state is TransaksiServiceDetailLoaded) {
                final transaksi = state.data.transaksi;
                transaksi.status.toLowerCase() == 'lunas'
                    ? setState(() {
                      _totalHarga = 0;
                    })
                    : transaksi.status.toLowerCase() != 'komplit' ||
                        transaksi.toString().isEmpty
                    ? setState(() {
                      _totalHarga = 0;
                    })
                    : setState(() {
                      _totalHarga = state.data.transaksi.totalFinal;
                    });
              }
              if (state is TransaksiServiceDetailError) {
                setState(() {
                  _totalHarga = 0;
                });
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentSuccess) {
                // Navigasi ke layar kwitansi
                final transaksiDetailState =
                    context.read<TransaksiServiceDetailBloc>().state;
                if (transaksiDetailState is TransaksiServiceDetailLoaded) {
                  
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (_) => ReceiptScreen(
                            transaksi: transaksiDetailState.data,
                            jumlahBayar: double.parse(
                              _jumlahBayarController.text,
                            ),
                            kembalian: state.kembalian,
                          ),
                    ),
                  );
                }
              } else if (state is PaymentError) {
                _showErrorSnackBar(state.message);
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              BlocBuilder<
                TransaksiServiceDetailBloc,
                TransaksiServiceDetailState
              >(
                builder: (context, state) {
                  if (state is TransaksiServiceDetailLoaded) {
                    final transaksi = state.data.transaksi;
                    return transaksi.status.toLowerCase() == 'lunas'
                        ? Center(child: Text('Pembayaran sudah lunas'))
                        : transaksi.status.toLowerCase() != 'komplit' ||
                            transaksi.toString().isEmpty
                        ? Center(
                          child: Text(
                            'Transaksi belum komplit, mohon diperiksa kembali !',
                          ),
                        )
                        : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Tagihan:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp ${nf.format(transaksi.totalFinal)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(height: 24),
                                Text(
                                  'Pelanggan: ${state.data.customer?.nama ?? 'Umum'}',
                                ),
                                Text(
                                  'Nomor Plat: ${state.data.vehicle?.platNomor ?? 'Tidak Ada'}',
                                ),
                              ],
                            ),
                          ),
                        );
                  }
                  return Expanded(
                    child: const Center(
                      child: Text('Tidak ada data yang ditemukan'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: BlocBuilder<
                      TransaksiServiceDetailBloc,
                      TransaksiServiceDetailState
                    >(
                      builder: (context, state) {
                        if (state is TransaksiServiceDetailLoaded) {
                          final transaksi = state.data.transaksi;
                          return transaksi.status.toLowerCase() == 'lunas'
                              ? Center(child: Text(''))
                              : transaksi.status.toLowerCase() != 'komplit'
                              ? Center(child: Text(''))
                              : Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: state.data.jasas.length,
                                    itemBuilder: (context, index) {
                                      final detail = state.data.jasas[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text('${detail.namaJasa}'),
                                            ),
                                            SizedBox(
                                              width: 120,
                                              child: Text('x${detail.jumlah}'),
                                            ),
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                '@ Rp ${nf.format(detail.hargaJasaSaatItu)}',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: Text(
                                                'Rp ${nf.format(detail.subTotal)}',
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: state.data.parts.length,
                                    itemBuilder: (context, index) {
                                      final detail = state.data.parts[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${detail.namaSukuCadang}',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 120,
                                              child: Text('x${detail.jumlah}'),
                                            ),
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                '@ Rp ${nf.format(detail.hargaJualSaatItu)}',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: Text(
                                                'Rp ${nf.format(detail.subTotal)}',
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
              const Divider(height: 32),
              _totalHarga > (0)
                  ? TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              _totalHarga > (0)
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian:', style: TextStyle(fontSize: 18)),
                      Text(
                        'Rp ${nf.format(_kembalian)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                  : SizedBox(),
              const SizedBox(height: 16),
              _totalHarga > (0)
                  ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<PaymentBloc>().add(
                          ProcessPayment(
                            transaksiId: int.parse(_idTransaksi.text.trim()),
                            totalHarga: _totalHarga,
                            jumlahBayar:
                                double.tryParse(_jumlahBayarController.text) ??
                                0,
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Bayar & Cetak Bukti Pembayaran'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
