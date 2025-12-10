// lib/screens/dashboard_screen.dart
import 'dart:io';

import 'package:bengkel/blocs/bengkel/bengkel_bloc.dart';
import 'package:bengkel/blocs/bengkel/bengkel_event.dart';
import 'package:bengkel/blocs/bengkel/bengkel_state.dart';
import 'package:bengkel/screens/bengkel_screen.dart';
import 'package:bengkel/screens/cetak_kuitansi.dart';
import 'package:bengkel/screens/cetakpart.dart';
import 'package:bengkel/screens/account_screen.dart';
import 'package:bengkel/screens/input_pemasukan.dart';
import 'package:bengkel/screens/input_pengeluaran.dart';
import 'package:bengkel/screens/jurnal_list_screen.dart';
import 'package:bengkel/screens/lihat_transaksi_screen.dart';
import 'package:bengkel/screens/mekanik_screen.dart';
import 'package:bengkel/screens/merk_kendaraan_screen.dart';
import 'package:bengkel/screens/neraca_screen.dart';
import 'package:bengkel/screens/payment_pembelian_suku_cadang.dart';
import 'package:bengkel/screens/payment_screen.dart';
import 'package:bengkel/screens/transaksi_service_list_screen.dart';
import 'package:bengkel/screens/type_kendaraan_screen.dart';
import 'package:bengkel/screens/vehicle_search_screen.dart';
import 'package:bengkel/screens/vendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import semua layar daftar modul yang sudah ada atau diasumsikan ada
import 'jasa_screen.dart';
import 'pelanggan_list_screen.dart';
import 'kendaraan_list_screen.dart';
import 'suku_cadang_list_screen.dart.dart'; //Asumsi: Anda memiliki layar ini
import 'pembelian_suku_cadang_list_screen.dart'; // Asumsi: Anda memiliki layar ini
import 'penjualan_suku_cadang_list_screen.dart'; // Asumsi: Anda akan membuat layar ini

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Helper method untuk membangun setiap item menu
  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 36.0, color: Theme.of(context).primaryColor),
              const SizedBox(width: 20.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<BengkelBloc>().add(const LoadBengkels());

    return BlocBuilder<BengkelBloc, BengkelState>(
      builder: (context, state) {
        if (state is BengkelInitial) {
          return Scaffold(body: Center(child: Text('Wait')));
        }
        if (state is BengkelLoading) {
          return Scaffold(body: Center(child: Text('Proses..')));
        }
        if (state is BengkelError) {
          return Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BengkelScreen()),
                  );
                },
                child: Text('Click this to go to Bengkel initial'),
              ),
            ),
          );
        }
        if (state is BengkelsLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Dashboard ${state.bengkels.nama}'),
              leading:
                  state.bengkels.logo!.isEmpty
                      ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/example.png'),
                          ),
                        ),
                      )
                      : Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(state.bengkels.logo!)),
                          ),
                        ),
                      ),
              centerTitle: true,
            ),

            body: ListView(
              padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                // Bagian Manajemen Data Master
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Manajemen Data Master',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                _buildMenuItem(
                  context,
                  'Bengkel',
                  Icons.car_repair,
                  const BengkelScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Pelanggan',
                  Icons.people,
                  const PelangganListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Merk Kendaraan',
                  Icons.directions_car,
                  const MerkKendaraanScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Tipe Kendaraan',
                  Icons.directions_car,
                  const TypeKendaraanScreen(),
                ),

                _buildMenuItem(
                  context,
                  'Kendaraan',
                  Icons.directions_car,
                  const KendaraanListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Mekanik',
                  Icons.engineering,
                  const MekanikListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Jasa',
                  Icons.build,
                  const JasaListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Suku Cadang',
                  Icons.precision_manufacturing,
                  const SukuCadangListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Supplier',
                  Icons.local_shipping,
                  const VendorScreen(),
                ),
                const Divider(height: 30, thickness: 1),

                // Bagian Manajemen Transaksi
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Manajemen Transaksi',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  'Buat Perintah Kerja Bengkel',
                  Icons.assignment,
                  const VehicleSearchScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Lihat Perintah Kerja Bengkel',
                  Icons.assignment,
                  const LihatTransaksi(),
                ),
                _buildMenuItem(
                  context,
                  'Daftar Perintah Kerja Bengkel',
                  Icons.assignment,
                  const TransaksiServiceListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Daftar Perintah Kerja Bengkel Work In Proses',
                  Icons.assignment,
                  const TransaksiServiceListScreen(sts: 'in proses'),
                ),
                _buildMenuItem(
                  context,
                  'History Kendaraan',
                  Icons.assignment,
                  const VehicleSearchScreen(his: "his"),
                ),
                _buildMenuItem(
                  context,
                  'Penjualan Suku Cadang',
                  Icons.shopping_cart,
                  const PenjualanSukuCadangListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Terima Pembayaran Penjualan Suku Cadang',
                  Icons.payment_sharp,
                  const PaymentPembelianSukuCadang(),
                ),
                _buildMenuItem(
                  context,
                  'Pembelian Suku Cadang',
                  Icons.receipt,
                  const PembelianSukuCadangListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Cetak Suku Cadang',
                  Icons.shopping_cart,
                  const CetakPart(),
                ),
                //_buildMenuItem(context, 'Order Pekerjaan Luar', Icons.handyman, const OrderPekerjaanLuarListScreen()),
                const Divider(height: 30, thickness: 1),

                // Bagian Laporan & Akuntansi
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Laporan & Akuntansi',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context,
                  'Cetak Kwitansi Service',
                  Icons.menu_book,
                  const CetakKuitansi(),
                ),
                _buildMenuItem(
                  context,
                  'Pembayaran Service',
                  Icons.payment,
                  const PaymentScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Input Pemasukan',
                  Icons.addchart,
                  const InputPemasukan(),
                ),
                _buildMenuItem(
                  context,
                  'Input Pengeluaran',
                  Icons.reduce_capacity_sharp,
                  const InputPengeluaran(),
                ),
                _buildMenuItem(
                  context,
                  'Jurnal Akuntansi',
                  Icons.menu_book,
                  const JurnalListScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Daftar Akun',
                  Icons.account_balance,
                  const AccountScreen(),
                ),
                _buildMenuItem(
                  context,
                  'Neraca',
                  Icons.account_balance,
                  const NeracaScreen(),
                ),
                // Anda bisa menambahkan laporan lain di sini
              ],
            ),
          );
        }
        return Center(child: Text("Data tidak tampil dengan sempurna"));
      },
    );
  }
}
