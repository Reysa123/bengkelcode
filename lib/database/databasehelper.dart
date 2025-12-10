import 'package:bengkel/model/bengkel.dart';
import 'package:path/path.dart' as p; // Required for 'join' function
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Required for 'getDatabasesPath'

class DatabaseHelper {
  // Static instance to ensure only one instance of the database helper is created
  // static final DatabaseHelper _instance = DatabaseHelper._internal();
  // factory DatabaseHelper() => _instance;
  // DatabaseHelper._internal();

  Database? _database; // The actual database instance

  // Database version (important for upgrades)
  static const int _databaseVersion = 1;
  // Database name
  static const String _databaseName = "finance_app.db";

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> initDatabase() async {
    // Get the default databases directory for the platform
    // For iOS and Android, this will be the application's documents directory
    final databaseFactory = databaseFactoryFfi;
    var databasePath = await getDatabasesPath();

    var path = p.join(databasePath, _databaseName);
    // final documentsDirectory = await getApplicationDocumentsDirectory();
    // final path = join(documentsDirectory.path, _databaseName);

    // Open the database or create it if it doesn't exist
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  // Create tables when the database is first created
  Future _onCreate(Database db, int version) async {
    // Accounts Table
    await db.execute('''
CREATE TABLE Akun (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    'nama_akun' TEXT UNIQUE NOT NULL,
    'jenis_akun' TEXT NOT NULL -- Contoh: 'Kas', 'Piutang', 'Persediaan', 'Pendapatan Servis', 'Beban Pembelian', 'Modal'
)
    ''');
    //-- Tabel Pelanggan
    await db.execute('''
CREATE TABLE Pelanggan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    alamat TEXT,
    telepon TEXT UNIQUE NOT NULL,
    email TEXT
)
''');

    //-- Tabel Kendaraan
    await db.execute('''
CREATE TABLE Kendaraan (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pelanggan_id INTEGER NOT NULL,
    merk TEXT NOT NULL,
    model TEXT NOT NULL,
    tahun INTEGER,
    plat_nomor TEXT UNIQUE NOT NULL,
    nomor_rangka TEXT UNIQUE,
    nomor_mesin TEXT UNIQUE,
    km INTEGER DEFAULT 0,
    FOREIGN KEY (pelanggan_id) REFERENCES Pelanggan (id) ON DELETE CASCADE
)
''');
    //--Tabel Suplier
    await db.execute('''
CREATE TABLE Supplier (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_supplier TEXT NOT NULL,
    alamat TEXT,
    telepon TEXT UNIQUE NOT NULL,
    email TEXT
)
''');
    //Tabel Type
    await db.execute('''
      CREATE TABLE type_kendaraan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_tipe TEXT NOT NULL UNIQUE,
        merk_id INTEGER NOT NULL,
        FOREIGN KEY(merk_id) REFERENCES merk_kendaraan(id) ON DELETE CASCADE
      )
    ''');
    //Tabel Model Kendaraan
    await db.execute('''
      CREATE TABLE merk_kendaraan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_merk TEXT NOT NULL UNIQUE
      )
    ''');
    //--Tabel Suku Cadang
    await db.execute('''
CREATE TABLE SukuCadang (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_part TEXT NOT NULL,
    kode_part TEXT UNIQUE,
    deskripsi TEXT,
    harga_beli REAL NOT NULL,
    harga_jual REAL NOT NULL,
    stok INTEGER NOT NULL DEFAULT 0
)
''');

    // Akun Table
    await db.execute('''
CREATE TABLE Jurnal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tanggal TEXT NOT NULL, -- Format YYYY-MM-DD HH:MM:SS
    deskripsi TEXT NOT NULL,
    referensi_transaksi_id INTEGER, -- ID transaksi terkait (Servis, Penjualan, Pembelian)
    tipe_referensi TEXT, -- 'Servis', 'Penjualan', 'Pembelian'
    debit REAL NOT NULL DEFAULT 0.0,
    kredit REAL NOT NULL DEFAULT 0.0,
    akun_id INTEGER NOT NULL,
    FOREIGN KEY (akun_id) REFERENCES Akun (id) ON DELETE RESTRICT
)
    ''');

    // TransaksiServis Table
    await db.execute('''
    CREATE TABLE TransaksiServis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idpkb INTEGER NOT NULL,
    km INTEGER NOT NULL,
    kendaraan_id INTEGER NOT NULL,
    mekanik_id INTEGER,
    tanggal_masuk TEXT NOT NULL, -- Format YYYY-MM-DD HH:MM:SS
    tanggal_selesai TEXT,
    status TEXT NOT NULL, -- Contoh: 'Pending', 'In Progress', 'Completed', 'Cancelled'
    total_biaya_jasa REAL NOT NULL DEFAULT 0.0,
    total_biaya_suku_cadang REAL NOT NULL DEFAULT 0.0,
    total_final REAL NOT NULL DEFAULT 0.0, -- Total keseluruhan termasuk layanan dan suku cadang
    catatan TEXT,
    FOREIGN KEY (kendaraan_id) REFERENCES Kendaraan (id) ON DELETE CASCADE,
    FOREIGN KEY (mekanik_id) REFERENCES Mekanik (id) ON DELETE SET NULL
)
    ''');

    // Nomor Table
    await db.execute('''
CREATE TABLE Nomor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_pkb INTEGER NOT NULL,
    id_kwt INTEGER NOT NULL,
    id_otr INTEGER NOT NULL
)
    ''');
    // Jasa Table
    await db.execute('''
CREATE TABLE Jasa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_jasa TEXT UNIQUE NOT NULL,
    harga_beli REAL DEFAULT 0 ,
    harga_jual REAL DEFAULT 0
)
    ''');
    // bengkel Table
    await db.execute('''
      CREATE TABLE Bengkel (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    alamat TEXT,
    telepon TEXT UNIQUE,
    email TEXT,
    logo TEXT,
    kode TEXT
)
    ''');
    // Mekanik Table
    await db.execute('''
      CREATE TABLE Mekanik (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_mekanik TEXT NOT NULL,
    alamat TEXT,
    telepon TEXT UNIQUE,
    rule TEXT
)
    ''');

    // DetailTransaksiLayanan Table
    await db.execute('''
      CREATE TABLE DetailTransaksiService (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaksi_servis_id INTEGER NOT NULL,
    jasa_id INTEGER NOT NULL,
    jumlah INTEGER NOT NULL DEFAULT 1,
    harga_jasa_saat_itu REAL NOT NULL, -- Simpan harga layanan saat transaksi terjadi
    sub_total REAL NOT NULL,
    catatan_layanan TEXT,
    disc REAL DEFAULT 0,
    status TEXT DEFAULT "In Proses",
    FOREIGN KEY (transaksi_servis_id) REFERENCES TransaksiServis (idpkb) ON DELETE CASCADE,
    FOREIGN KEY (jasa_id) REFERENCES Jasa (id) ON DELETE RESTRICT
)
    ''');

    // -- Tabel DetailTransaksiSukuCadangServis (Diubah nama, suku cadang untuk layanan servis)
    await db.execute('''
CREATE TABLE DetailTransaksiSukuCadangServis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaksi_servis_id INTEGER NOT NULL,
    suku_cadang_id INTEGER NOT NULL,
    jumlah INTEGER NOT NULL DEFAULT 1,
    harga_jual_saat_itu REAL NOT NULL,
    sub_total REAL NOT NULL,
    status TEXT DEFAULT "In Proses",
    disc REAL DEFAULT 0,
    FOREIGN KEY (transaksi_servis_id) REFERENCES TransaksiServis (idpkb) ON DELETE CASCADE,
    FOREIGN KEY (suku_cadang_id) REFERENCES SukuCadang (id) ON DELETE RESTRICT
)
    ''');

    //-- Tabel PenjualanSukuCadang (BARU: Untuk penjualan suku cadang terpisah dari layanan servis)
    await db.execute('''
CREATE TABLE PenjualanSukuCadang (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaksi_id INTEGER,
    pelanggan_id INTEGER, -- Bisa null jika pelanggan tidak terdaftar (penjualan tunai)
    tanggal_penjualan TEXT NOT NULL, -- Format YYYY-MM-DD HH:MM:SS
    total_penjualan REAL NOT NULL DEFAULT 0.0,
    status TEXT,
    catatan TEXT,
    FOREIGN KEY (pelanggan_id) REFERENCES Pelanggan (id) ON DELETE SET NULL
)
    ''');
    await db.execute('''
CREATE TABLE InOutSukuCadang (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    trkid INTEGER NOT NULL,
    suku_cadang_id INTEGER NOT NULL,
    masuk INTEGER DEFAULT 0,
    keluar INTEGER DEFAULT 0
)
    ''');
    //-- Tabel DetailPenjualanSukuCadang (BARU: Detail suku cadang dalam penjualan terpisah)
    await db.execute('''
CREATE TABLE DetailPenjualanSukuCadang (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    penjualan_id INTEGER NOT NULL,
    suku_cadang_id INTEGER NOT NULL,
    jumlah INTEGER NOT NULL,
    harga_jual_saat_itu REAL NOT NULL,
    sub_total REAL NOT NULL,
    FOREIGN KEY (penjualan_id) REFERENCES PenjualanSukuCadang (transaksi_id) ON DELETE CASCADE,
    FOREIGN KEY (suku_cadang_id) REFERENCES SukuCadang (id) ON DELETE RESTRICT
)
    ''');

    //-- Tabel PembelianSukuCadang (BARU: Untuk pembelian suku cadang dari supplier)
    await db.execute('''
CREATE TABLE PembelianSukuCadang (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier_id INTEGER NOT NULL,
    tanggal_pembelian TEXT NOT NULL, -- Format YYYY-MM-DD HH:MM:SS
    total_pembelian REAL NOT NULL DEFAULT 0.0,
    status TEXT,
    catatan TEXT,
    FOREIGN KEY (supplier_id) REFERENCES Supplier (id) ON DELETE RESTRICT
)
    ''');

    //-- Tabel DetailPembelianSukuCadang (BARU: Detail suku cadang dalam pembelian)
    await db.execute('''
CREATE TABLE DetailPembelianSukuCadang (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pembelian_id INTEGER NOT NULL,
    suku_cadang_id INTEGER NOT NULL,
    jumlah INTEGER NOT NULL,
    harga_beli_saat_itu REAL NOT NULL, -- Simpan harga beli saat transaksi terjadi
    sub_total REAL NOT NULL,
    FOREIGN KEY (pembelian_id) REFERENCES PembelianSukuCadang (id) ON DELETE CASCADE,
    FOREIGN KEY (suku_cadang_id) REFERENCES SukuCadang (id) ON DELETE RESTRICT
)
    ''');

    // Optional: Seed initial data (e.g., default accounts)
    await _seedInitialData(db);
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement migration logic here if your database schema changes in future versions.
    // Example: if (oldVersion < 2) { await db.execute("ALTER TABLE ..."); }
    // For simplicity, we'll just drop and recreate for now in a dev environment.
    // In a production app, you'd want proper migration.
    await db.execute('DROP TABLE IF EXISTS DetailPembelianSukuCadang'); //
    await db.execute('DROP TABLE IF EXISTS PembelianSukuCadang'); //
    await db.execute('DROP TABLE IF EXISTS DetailPenjualanSukuCadang'); //
    await db.execute('DROP TABLE IF EXISTS PenjualanSukuCadang'); //
    await db.execute('DROP TABLE IF EXISTS DetailTransaksiSukuCadangServis'); //
    await db.execute('DROP TABLE IF EXISTS DetailTransaksiService'); //
    await db.execute('DROP TABLE IF EXISTS Mekanik'); //
    await db.execute('DROP TABLE IF EXISTS Jasa'); //
    await db.execute('DROP TABLE IF EXISTS TransaksiServis'); //
    await db.execute('DROP TABLE IF EXISTS Jurnal'); //
    await db.execute('DROP TABLE IF EXISTS SukuCadang'); //
    await db.execute('DROP TABLE IF EXISTS Supplier'); //
    await db.execute('DROP TABLE IF EXISTS Kendaraan'); //
    await db.execute('DROP TABLE IF EXISTS Pelanggan'); //
    await db.execute('DROP TABLE IF EXISTS Akun'); //
    await db.execute('DROP TABLE IF EXISTS Nomor'); //
    await db.execute('DROP TABLE IF EXISTS Bengkel');
    await _onCreate(db, newVersion);
  }

  // Optional: Seed initial data
  Future<void> _seedInitialData(Database db) async {
    // Example: Insert some default accounts
    // {'nama_akun': 'Kas', 'jenis_akun': 'Aset'},//
    //   {'nama_akun': 'Persediaan Suku Cadang', 'jenis_akun': 'Aset'},//
    //   {'nama_akun': 'Piutang Usaha', 'jenis_akun': 'Aset'},//
    //   {'nama_akun': 'Pendapatan Servis', 'jenis_akun': 'Pendapatan'},//
    //   {'nama_akun': 'Pendapatan Penjualan', 'jenis_akun': 'Pendapatan'},
    //   {'nama_akun': 'Beban Pokok Penjualan', 'jenis_akun': 'Beban'},
    //   {'nama_akun': 'Beban Gaji Mekanik', 'jenis_akun': 'Beban'},
    //   {'nama_akun': 'Utang Usaha', 'jenis_akun': 'Kewajiban'},//
    //   {'nama_akun': 'Modal', 'jenis_akun': 'Ekuitas'},//

    await db.insert('Nomor', {
      'id_pkb': 2025000,
      'id_kwt': 7000000,
      'id_otr': 8000000,
    });
    await db.insert('Akun', {
      'nama_akun': 'Pendapatan Penjualan',
      'jenis_akun': 'Revenue',
    });

    await db.insert('Akun', {'nama_akun': 'Kas', 'jenis_akun': 'Asset'});
    await db.insert('Akun', {
      'nama_akun': 'Bank',
      'jenis_akun': 'Asset', // Assuming 'Kas' has ID 1 if inserted first
    });

    await db.insert('Akun', {
      'nama_akun': 'Utang Usaha',
      'jenis_akun': 'Liability',
    });
    await db.insert('Akun', {'nama_akun': 'Modal', 'jenis_akun': 'Equity'});

    await db.insert('Akun', {
      'nama_akun': 'Pendapatan Jasa Servis',
      'jenis_akun': 'Revenue',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Akun', {
      'nama_akun': 'Beban Pembelian Suku Cadang',
      'jenis_akun': 'Expense',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Akun', {
      'nama_akun': 'Piutang Usaha',
      'jenis_akun': 'Asset',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Akun', {
      'nama_akun': 'Beban Jasa Perbaikan',
      'jenis_akun': 'Expense',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Akun', {
      'nama_akun': 'Laba Ditahan',
      'jenis_akun': 'Equity',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Akun', {
      'nama_akun': 'Persediaan Suku Cadang',
      'jenis_akun': 'Asset',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('Akun', {
      'nama_akun': 'Pendapatan Suku Cadang Servis',
      'jenis_akun': 'Revenue',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Add more default accounts as needed (e.g., fixed assets, other expenses)
  }

  // --- Utility methods (optional, but good to have for testing/debugging) ---

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Delete the database (for development/testing)
  Future<void> deleteDatabaseFile() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, _databaseName);
    if (await databaseFactory.databaseExists(path)) {
      await deleteDatabase(path);
      _database = null; // Clear the instance after deleting
    }
  }

  Future<Bengkel?> getBengkels() async {
    final db = await database;
    final map = await db.query('Bengkel');
    if (map.isNotEmpty) {
      return Bengkel.fromMap(map.first);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAkunByName(String namaAkun) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Akun',
      where: 'nama_akun = ?',
      whereArgs: [namaAkun],
      limit: 1, // Hanya perlu satu hasil
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
