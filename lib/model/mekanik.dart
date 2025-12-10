import 'package:equatable/equatable.dart'; // Import Equatable

class Mekanik extends Equatable {
  final int? id;
  final String namaMekanik;
  final String? alamat;
  final String? telepon;
  final String? rule; // Contoh: 'Senior', 'Junior', 'Kepala Bengkel'

  const Mekanik({
    this.id,
    required this.namaMekanik,
    this.alamat,
    this.telepon,
    this.rule,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_mekanik': namaMekanik,
      'alamat': alamat,
      'telepon': telepon,
      'rule': rule,
    };
  }

  factory Mekanik.fromMap(Map<String, dynamic> map) {
    return Mekanik(
      id: map['id'],
      namaMekanik: map['nama_mekanik'],
      alamat: map['alamat'],
      telepon: map['telepon'],
      rule: map['rule'],
    );
  }

  Mekanik copyWith({
    int? id,
    String? namaMekanik,
    String? alamat,
    String? telepon,
    String? rule,
  }) {
    return Mekanik(
      id: id ?? this.id,
      namaMekanik: namaMekanik ?? this.namaMekanik,
      alamat: alamat ?? this.alamat,
      telepon: telepon ?? this.telepon,
      rule: rule ?? this.rule,
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaMekanik,
        alamat,
        telepon,
        rule,
      ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'Mekanik(id: $id, namaMekanik: $namaMekanik, rule: $rule)';
  }
}
