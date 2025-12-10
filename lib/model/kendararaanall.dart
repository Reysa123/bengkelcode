import 'package:equatable/equatable.dart'; // Import Equatable

class KendaraanAll extends Equatable {
  final int? ids;
  final String nama;
  final String alamat;
  final String telepon;
  final String merk;
  final String model;
  final int? tahun;
  final String platNomor;
  final String? nomorRangka;
  final String? nomorMesin;
  final int km;

  const KendaraanAll({
    this.ids,
    required this.nama,
    required this.alamat,
    required this.telepon,
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
      'ids': ids,
      'nama': nama,
      'alamat': alamat,
      'telepon': telepon,
      'merk': merk,
      'model': model,
      'tahun': tahun,
      'plat_nomor': platNomor,
      'nomor_rangka': nomorRangka,
      'nomor_mesin': nomorMesin,
      'km': km,
    };
  }

  factory KendaraanAll.fromMap(Map<String, dynamic> map) {
    return KendaraanAll(
      ids: map['ids'],
      nama: map['nama'],
      alamat: map['alamat'],
      telepon: map['telepon'],
      merk: map['merk'],
      model: map['model'],
      tahun: map['tahun'],
      platNomor: map['plat_nomor'],
      nomorRangka: map['nomor_rangka'],
      nomorMesin: map['nomor_mesin'],
      km: map['km'],
    );
  }

  KendaraanAll copyWith({
    int? ids,
    String? nama,
    String? alamat,
    String? telepon,
    String? merk,
    String? model,
    int? tahun,
    String? platNomor,
    String? nomorRangka,
    String? nomorMesin,
    int? km,
  }) {
    return KendaraanAll(
      ids: ids ?? this.ids,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      telepon: telepon ?? this.telepon,
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
    ids,
    nama,
    alamat,
    telepon,
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
    return 'KendaraanAll(ids: $ids, nama: $nama,alamat:$alamat,telepn:$telepon,nomorMesin:$nomorMesin,nomorRangka:$nomorRangka,platNomor: $platNomor, merk: $merk, model: $model,tahun:$tahun,km:$km)';
  }
}
