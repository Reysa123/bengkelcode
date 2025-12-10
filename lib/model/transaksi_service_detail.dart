// lib/models/transaksi_service_detail.dart
import 'package:bengkel/model/detailsukucadangservice.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:equatable/equatable.dart';

class TransaksiServiceDetail extends Equatable {
  final TransaksiServis transaksi;
  final Pelanggan? customer;
  final Kendaraan? vehicle;
  final List<DetailTransaksiService> jasas;
  final List<DetailTransaksiSukuCadangServis> parts;

  const TransaksiServiceDetail({
    required this.transaksi,
    this.customer,
    this.vehicle,
    required this.jasas,
    required this.parts
  });

  @override
  List<Object?> get props => [transaksi, customer, vehicle, jasas,parts];
}
