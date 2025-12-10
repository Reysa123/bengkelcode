// lib/models/type_kendaraan.dart
import 'package:equatable/equatable.dart';
//import 'package:flutter/src/material/dropdown.dart';

class TypeKendaraan extends Equatable {
  final int? id;
  final String namaTipe;
  final int merkId;
  const TypeKendaraan({this.id, required this.namaTipe, required this.merkId});

  // Factory method untuk membuat objek TypeKendaraan dari Map (dari database)
  factory TypeKendaraan.fromMap(Map<String, dynamic> map) {
    return TypeKendaraan(
      id: map['id'],
      namaTipe: map['nama_tipe'],
      merkId: map['merk_id'],
    );
  }

  // Method untuk mengonversi objek TypeKendaraan ke Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {'id': id, 'nama_tipe': namaTipe, 'merk_id': merkId};
  }

  // Method untuk membuat salinan objek dengan perubahan
  TypeKendaraan copyWith({int? id, String? namaTipe, int? merkId}) {
    return TypeKendaraan(
      id: id ?? this.id,
      namaTipe: namaTipe ?? this.namaTipe,
      merkId: merkId ?? this.merkId,
    );
  }

  @override
  List<Object?> get props => [id, namaTipe, merkId];
}
