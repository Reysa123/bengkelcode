// lib/bloc/transaksi_service_detail/transaksi_service_detail_event.dart
import 'package:equatable/equatable.dart';

abstract class TransaksiServiceDetailEvent extends Equatable {
  const TransaksiServiceDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadTransaksiServiceDetail extends TransaksiServiceDetailEvent {
  final int transaksiId;

  const LoadTransaksiServiceDetail(this.transaksiId);

  @override
  List<Object> get props => [transaksiId];
}

class CetakKwitansi extends TransaksiServiceDetailEvent {
  final Map<String, dynamic> list;
  final List<Map<String, dynamic>> listJ;
  final List<Map<String, dynamic>> listP;
  const CetakKwitansi(this.list,this.listJ,this.listP);

  @override
  List<Object> get props => [list,listJ,listP];
}
class BatalCetakKwitansi extends TransaksiServiceDetailEvent {
  final Map<String, dynamic> list;
  const BatalCetakKwitansi(this.list);

  @override
  List<Object> get props => [list];
}
class UpdateTransaksiServicePart extends TransaksiServiceDetailEvent {
  final int id;
  final int stok;
  final int idPart;
  const UpdateTransaksiServicePart({
    this.id = -1,
    this.stok = 0,
    this.idPart = -1,
  });
  @override
  List<Object> get props => [id, stok, idPart];
}

class BatalUpdateTransaksiServicePart extends TransaksiServiceDetailEvent {
  final int id;
  final int stok;
  final int idPart;
  const BatalUpdateTransaksiServicePart({
    this.id = -1,
    this.stok = 0,
    this.idPart = -1,
  });
  @override
  List<Object> get props => [id, stok, idPart];
}

class LoadTransaksiService extends TransaksiServiceDetailEvent {
  final int transaksiId;
  final int cetakPart;
  final String noc;
  const LoadTransaksiService({
    this.transaksiId = -1,
    this.noc = "",
    this.cetakPart = -1,
  });

  @override
  List<Object> get props => [transaksiId, noc, cetakPart];
}

class LoadTransaksiServiceDetailJasa extends TransaksiServiceDetailEvent {
  final int transaksiId;

  const LoadTransaksiServiceDetailJasa({this.transaksiId = 0});

  @override
  List<int> get props => [transaksiId];
}

class LoadTransaksiServiceDetailPart extends TransaksiServiceDetailEvent {
  final int transaksiId;

  const LoadTransaksiServiceDetailPart({this.transaksiId = 0});

  @override
  List<int> get props => [transaksiId];
}
