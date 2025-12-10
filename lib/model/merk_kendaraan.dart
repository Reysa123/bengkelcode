// lib/Merks/type_kendaraan.dart
import 'package:equatable/equatable.dart';

class MerkKendaraan extends Equatable {
  final int? id;
  final String namaMerk;

  const MerkKendaraan({
    this.id,
    required this.namaMerk,
  });

  // Factory method untuk membuat objek MerkKendaraan dari Map (dari database)
  factory MerkKendaraan.fromMap(Map<String, dynamic> map) {
    return MerkKendaraan(
      id: map['id'],
      namaMerk: map['nama_merk'],
    );
  }

  // Method untuk mengonversi objek MerkKendaraan ke Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_merk': namaMerk,
    };
  }

  // Method untuk membuat salinan objek dengan perubahan
  MerkKendaraan copyWith({
    int? id,
    String? namaMerk,
  }) {
    return MerkKendaraan(
      id: id ?? this.id,
      namaMerk: namaMerk ?? this.namaMerk,
    );
  }

  @override
  List<Object?> get props => [id, namaMerk];
}
