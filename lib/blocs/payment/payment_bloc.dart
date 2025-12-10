// lib/bloc/payment/payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/payment_repository.dart';

import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;

  PaymentBloc(this._repository) : super(PaymentInitial()) {
    on<ProcessPayment>(_onProcessPayment);
    on<PenjualanPayment>(_onPenjualanPayment);
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<PaymentState> emit,
  ) async {
    if (event.jumlahBayar < event.totalHarga) {
      emit(const PaymentError('Jumlah bayar tidak mencukupi.'));
      return;
    }

    emit(PaymentProcessing());
    try {
      await _repository.updatePaymentStatus(
        event.transaksiId,
        'Lunas',
        event.jumlahBayar,
      );
      final kembalian = event.jumlahBayar - event.totalHarga;

      emit(PaymentSuccess(kembalian));
    } catch (e) {
      emit(PaymentError('Gagal memproses pembayaran: ${e.toString()}'));
    }
  }

  Future<void> _onPenjualanPayment(
    PenjualanPayment event,
    Emitter<PaymentState> emit,
  ) async {
    if (event.jumlahBayar < (event.totalHarga - event.disc)) {
      emit(const PaymentError('Jumlah bayar tidak mencukupi.'));
      return;
    }

    emit(PaymentProcessing());
    try {
      await _repository.updatePembelianPaymentStatus(
        event.idTransaksi,
        event.jumlahBayar,
        event.totalHarga,
        event.catatan,
        event.disc,
      );
      final kembalian = event.jumlahBayar - event.totalHarga;

      emit(PaymentSuccess(kembalian));
    } catch (e) {
      emit(PaymentError('Gagal memproses pembayaran: ${e.toString()}'));
    }
  }
}
