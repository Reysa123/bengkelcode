import 'package:equatable/equatable.dart'; // Import Equatable

class Jasa extends Equatable {
  final int? id;
  final String namaJasa;
  final double hargaBeli;
  final double hargaJual;

  const Jasa({
    this.id,
    required this.namaJasa,
    this.hargaBeli = 0.0,
    this.hargaJual = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_jasa': namaJasa,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
    };
  }

  factory Jasa.fromMap(Map<String, dynamic> map) {
    return Jasa(
      id: map['id'],
      namaJasa: map['nama_jasa'],
      hargaBeli: map['harga_beli'] ?? 0.0,
      hargaJual: map['harga_jual'] ?? 0.0,
    );
  }

  Jasa copyWith({
    int? id,
    String? namaJasa,
    double? hargaBeli,
    double? hargaJual,
  }) {
    return Jasa(
      id: id ?? this.id,
      namaJasa: namaJasa ?? this.namaJasa,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaJasa,
        hargaBeli,
        hargaJual,
      ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'Jasa(id: $id, namaJasa: $namaJasa, hargaJual: $hargaJual)';
  }
}
