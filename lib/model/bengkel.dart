class Bengkel {
  final int? id;
  final String? nama;
  final String? alamat;
  final String? telepon;
  final String? email;
  final String? logo;
  final String? kode;
  const Bengkel({
    this.id,
    this.nama,
    this.alamat,
    this.telepon,
    this.email,
    this.logo,
    this.kode,
  });
  factory Bengkel.fromMap(Map<String, dynamic> map) {
    return (Bengkel(
      nama: map['nama'],
      alamat: map['alamat'],
      telepon: map['telepon'],
      email: map['email'],
      logo: map['logo'],
      kode: map['kode'],
    ));
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'telepon': telepon,
      'email': email,
      'logo': logo,
      'kode': kode,
    };
  }
}
