// lib/screens/receipt_screen.dart
import 'package:bengkel/blocs/bengkel/bengkel_bloc.dart';
import 'package:bengkel/blocs/bengkel/bengkel_event.dart';
import 'package:bengkel/blocs/bengkel/bengkel_state.dart';
import 'package:bengkel/model/detailsukucadangservice.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:bengkel/util/print_penjualan_part.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../model/transaksi_service_detail.dart';

class ReceiptScreen extends StatefulWidget {
  final TransaksiServiceDetail transaksi;
  final double jumlahBayar;
  final double kembalian;

  const ReceiptScreen({
    super.key,
    required this.transaksi,
    required this.jumlahBayar,
    required this.kembalian,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  String nbkl = "";
  String abkl = '';
  String tbkl = '';
  @override
  void initState() {
    super.initState();
    context.read<BengkelBloc>().add(const LoadBengkels());
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat nf = NumberFormat('#,###.##');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bukti Pembayaran'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final a = await PdfGenerator.generateTandaTerimaPdf(
                judul: 'Tanda Terima Pembayaran',
                transaksiId: widget.transaksi.transaksi.idpkb,
                nama: widget.transaksi.customer?.nama ?? "",
                alamat: widget.transaksi.customer?.alamat ?? "",
                telepon: widget.transaksi.customer?.telepon ?? "0",
                nopol: widget.transaksi.vehicle?.platNomor ?? "",
                kasir: 'Kasir',
                jumlahBayar: widget.transaksi.transaksi.totalFinal,
              );
              await Printing.layoutPdf(onLayout: (format) => a);
            },
            icon: Icon(Icons.print),
          ),
        ],
      ),

      body: BlocListener<BengkelBloc, BengkelState>(
        listener: (context, state) {
          if (state is BengkelsLoaded) {
            setState(() {
              nbkl = state.bengkels.nama ?? "";
              abkl = state.bengkels.alamat ?? "";
              tbkl = state.bengkels.telepon ?? '';
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    nbkl,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    abkl,
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tbkl,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    'Nomor Transaksi',
                    widget.transaksi.transaksi.idpkb.toString(),
                  ),
                  _buildInfoRow(
                    'Tanggal',
                    DateFormat(
                      'dd-MM-yyyy hh:mm',
                    ).format(widget.transaksi.transaksi.tanggalMasuk),
                  ),
                  _buildInfoRow(
                    'Pelanggan',
                    widget.transaksi.customer?.nama ?? 'Umum',
                  ),
                  _buildInfoRow(
                    'Kendaraan',
                    widget.transaksi.vehicle?.platNomor ?? 'Tidak Ada',
                  ),
                  const Divider(height: 32),
                  ...widget.transaksi.jasas.map(
                    (detail) => _buildDetailItemRow(detail),
                  ),
                  ...widget.transaksi.parts.map(
                    (detail) => _buildDetailItemRows(detail),
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    'Total Harga',
                    'Rp ${nf.format(widget.transaksi.transaksi.totalFinal)}',
                  ),
                  _buildInfoRow(
                    'Jumlah Bayar',
                    'Rp ${nf.format(widget.jumlahBayar)}',
                  ),
                  _buildInfoRow(
                    'Kembalian',
                    'Rp ${nf.format(widget.kembalian)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Terima kasih telah menggunakan jasa kami!',
                    style: TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItemRow(DetailTransaksiService detail) {
    NumberFormat nf = NumberFormat('#,###.##');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(detail.namaJasa.toString())),
          Text('x${detail.jumlah}'),
          const SizedBox(width: 16),
          Text('Rp ${nf.format(detail.subTotal)}'),
        ],
      ),
    );
  }

  Widget _buildDetailItemRows(DetailTransaksiSukuCadangServis detail) {
    NumberFormat nf = NumberFormat('#,###.##');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(detail.namaSukuCadang.toString())),
          Text('x${detail.jumlah}'),
          const SizedBox(width: 16),
          Text('Rp ${nf.format(detail.subTotal)}'),
        ],
      ),
    );
  }
}
