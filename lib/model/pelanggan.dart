import 'package:equatable/equatable.dart';

class Pelanggan extends Equatable {
  final int? id;
  final String nama;
  final String? alamat;
  final String telepon;
  final String? email;

  const Pelanggan({
    this.id,
    required this.nama,
    this.alamat,
    required this.telepon,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'telepon': telepon,
      'email': email,
    };
  }

  factory Pelanggan.fromMap(Map<String, dynamic> map) {
    return Pelanggan(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      telepon: map['telepon'],
      email: map['email'],
    );
  }

  Pelanggan copyWith({
    int? id,
    String? nama,
    String? alamat,
    String? telepon,
    String? email,
  }) {
    return Pelanggan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      telepon: telepon ?? this.telepon,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [id, nama, alamat, telepon, email];

  @override
  String toString() {
    return 'Pelanggan(id: $id, nama: $nama, telepon: $telepon)';
  }
}
