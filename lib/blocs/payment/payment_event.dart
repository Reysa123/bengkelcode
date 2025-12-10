// lib/bloc/payment/payment_event.dart
import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class PenjualanPayment extends PaymentEvent {
  final int idTransaksi;
  final double totalHarga;
  final double jumlahBayar;
  final String catatan;
  final double disc;
  const PenjualanPayment({
    required this.idTransaksi,
    required this.totalHarga,
    required this.jumlahBayar,
    required this.catatan,
    required this.disc,
  });
  @override
  List<Object> get props => [idTransaksi, totalHarga, jumlahBayar, catatan];
}

class ProcessPayment extends PaymentEvent {
  final int transaksiId;
  final double totalHarga;
  final double jumlahBayar;

  const ProcessPayment({
    required this.transaksiId,
    required this.totalHarga,
    required this.jumlahBayar,
  });

  @override
  List<Object> get props => [transaksiId, totalHarga, jumlahBayar];
}
