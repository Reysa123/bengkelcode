import 'package:equatable/equatable.dart'; // Import Equatable

class Supplier extends Equatable {
  final int? id;
  final String namaSupplier;
  final String? alamat;
  final String telepon;
  final String? email;

  const Supplier({
    this.id,
    required this.namaSupplier,
    this.alamat,
    required this.telepon,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_supplier': namaSupplier,
      'alamat': alamat,
      'telepon': telepon,
      'email': email,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      namaSupplier: map['nama_supplier'],
      alamat: map['alamat'],
      telepon: map['telepon'],
      email: map['email'],
    );
  }

  Supplier copyWith({
    int? id,
    String? namaSupplier,
    String? alamat,
    String? telepon,
    String? email,
  }) {
    return Supplier(
      id: id ?? this.id,
      namaSupplier: namaSupplier ?? this.namaSupplier,
      alamat: alamat ?? this.alamat,
      telepon: telepon ?? this.telepon,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaSupplier,
        alamat,
        telepon,
        email,
      ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'Supplier(id: $id, namaSupplier: $namaSupplier, telepon: $telepon)';
  }
}
