import 'package:equatable/equatable.dart'; // Import Equatable

class SukuCadang extends Equatable {
  final int? id;
  final String namaPart;
  final String? kodePart;
  final String? deskripsi;
  final double hargaBeli;
  final double hargaJual;
  final int stok;

  const SukuCadang({
    this.id,
    required this.namaPart,
    this.kodePart,
    this.deskripsi,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_part': namaPart,
      'kode_part': kodePart,
      'deskripsi': deskripsi,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
    };
  }

  factory SukuCadang.fromMap(Map<String, dynamic> map) {
    return SukuCadang(
      id: map['id'],
      namaPart: map['nama_part'],
      kodePart: map['kode_part'],
      deskripsi: map['deskripsi'],
      hargaBeli: map['harga_beli'],
      hargaJual: map['harga_jual'],
      stok: map['stok'],
    );
  }

  SukuCadang copyWith({
    int? id,
    String? namaPart,
    String? kodePart,
    String? deskripsi,
    double? hargaBeli,
    double? hargaJual,
    int? stok,
  }) {
    return SukuCadang(
      id: id ?? this.id,
      namaPart: namaPart ?? this.namaPart,
      kodePart: kodePart ?? this.kodePart,
      deskripsi: deskripsi ?? this.deskripsi,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      stok: stok ?? this.stok,
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaPart,
        kodePart,
        deskripsi,
        hargaBeli,
        hargaJual,
        stok,
      ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'SukuCadang(id: $id, namaPart: $namaPart, stok: $stok)';
  }
}
