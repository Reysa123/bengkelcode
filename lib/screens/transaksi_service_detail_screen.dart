// lib/screens/transaksi_service_detail_screen.dart
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/transaksi_service_detail/transaksi_service_detail_bloc.dart';
import '../blocs/transaksi_service_detail/transaksi_service_detail_event.dart';

class TransaksiServicejasascreen extends StatelessWidget {
  final int transaksiId;

  const TransaksiServicejasascreen({super.key, required this.transaksiId});

  @override
  Widget build(BuildContext context) {
    // Muat detail transaksi saat layar pertama kali dibuat
    context.read<TransaksiServiceDetailBloc>().add(
      LoadTransaksiServiceDetail(transaksiId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi Service'),
        centerTitle: true,
      ),
      body:
     BlocBuilder<TransaksiServiceDetailBloc, TransaksiServiceDetailState>(
      builder: (context, state) {
        if (state is TransaksiServiceDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransaksiServiceDetailLoaded) {
          final data = state.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(
                  context,
                  'Transaksi #ID ${data.transaksi.id}',
                  //data.transaksi.status,
                  data.vehicle?.platNomor ?? "",
                ),
                const SizedBox(height: 16),
                _buildInfoCard(context, 'Informasi Pelanggan & Kendaraan', [
                  _buildDetailRow(
                    'Pelanggan',
                    data.customer?.nama ?? 'Tidak Ada',
                  ),
                  _buildDetailRow('Telepon', data.customer?.telepon ?? '-'),
                  const Divider(),
                  _buildDetailRow(
                    'Kendaraan',
                    '${data.vehicle?.merk ?? '-'} ${data.vehicle?.model ?? '-'}',
                  ),
                  _buildDetailRow('Nomor Plat', data.vehicle?.platNomor ?? '-'),
                ]),
                const SizedBox(height: 16),
                _buildInfoCard(context, 'Detail Item Service', [
                  if (data.jasas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Tidak ada detail item service.'),
                    ),
                  ...data.jasas
                      .map((detail) => _buildDetailItemRow(detail))
                      ,
                  const Divider(),
                  _buildDetailRow(
                    'Total Harga',
                    'Rp ${data.transaksi.totalBiayaJasa.toString()}',
                    isTotal: true,
                  ),
                ]),
              ],
            ),
          );
        } else if (state is TransaksiServiceDetailError) {
          return Center(
            child: Text(
              'Terjadi kesalahan: ${state.message}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }
        return const Center(child: Text('Data transaksi tidak tersedia.'));
      },
     ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, String title, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(detail.jasaId.toString())),
          Text('x${detail.jumlah}'),
          const SizedBox(width: 16),
          Text('Rp ${detail.subTotal}'),
        ],
      ),
    );
  }
}
