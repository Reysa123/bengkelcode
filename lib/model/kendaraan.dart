import 'package:equatable/equatable.dart'; // Import Equatable

class Kendaraan extends Equatable {
  final int? id;
  final int pelangganId;
  final String merk;
  final String model;
  final int? tahun;
  final String platNomor;
  final String? nomorRangka;
  final String? nomorMesin;
  final int km;

  const Kendaraan({
    this.id,
    required this.pelangganId,
    required this.merk,
    required this.model,
    this.tahun,
    required this.platNomor,
    this.nomorRangka,
    this.nomorMesin,
    required this.km,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pelanggan_id': pelangganId,
      'merk': merk,
      'model': model,
      'tahun': tahun,
      'plat_nomor': platNomor,
      'nomor_rangka': nomorRangka,
      'nomor_mesin': nomorMesin,
      'km': km,
    };
  }

  factory Kendaraan.fromMap(Map<String, dynamic> map) {
    return Kendaraan(
      id: map['id'],
      pelangganId: map['pelanggan_id'],
      merk: map['merk'],
      model: map['model'],
      tahun: map['tahun'],
      platNomor: map['plat_nomor'],
      nomorRangka: map['nomor_rangka'],
      nomorMesin: map['nomor_mesin'],
      km: map['km'],
    );
  }

  Kendaraan copyWith({
    int? id,
    int? pelangganId,
    String? merk,
    String? model,
    int? tahun,
    String? platNomor,
    String? nomorRangka,
    String? nomorMesin,
    int? km,
  }) {
    return Kendaraan(
      id: id ?? this.id,
      pelangganId: pelangganId ?? this.pelangganId,
      merk: merk ?? this.merk,
      model: model ?? this.model,
      tahun: tahun ?? this.tahun,
      platNomor: platNomor ?? this.platNomor,
      nomorRangka: nomorRangka ?? this.nomorRangka,
      nomorMesin: nomorMesin ?? this.nomorMesin,
      km: km ?? this.km,
    );
  }

  @override
  List<Object?> get props => [
    id,
    pelangganId,
    merk,
    model,
    tahun,
    platNomor,
    nomorRangka,
    nomorMesin,
    km,
  ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'Kendaraan(id: $id, platNomor: $platNomor, merk: $merk, model: $model)';
  }
}
