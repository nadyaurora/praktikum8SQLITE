
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  // 1. Membuat instance Singleton
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  // Constructor private
  DatabaseHelper._internal();

  // Menyimpan koneksi database
  static Database? _database;

  // 2. Mengakses database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // 3. Membuka database
  Future<Database> _initDatabase() async {
    String lokasiDatabase = await getDatabasesPath();

    String pathDatabase = join(
      lokasiDatabase,
      'aiot_bencana.db',
    );

    return await openDatabase(
      pathDatabase,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 4. Membuat tabel
  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE pembacaan_sensor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis_sensor TEXT NOT NULL,
        nilai REAL NOT NULL,
        lokasi_pos TEXT NOT NULL,
        waktu TEXT NOT NULL
      )
    ''');
  }

  // 5. CREATE: Menambahkan pembacaan sensor
  Future<int> insertPembacaan(
    PembacaanSensor pembacaan,
  ) async {
    final db = await database;

    return await db.insert(
      'pembacaan_sensor',
      pembacaan.toMap(),
    );
  }

  // 6. READ: Mengambil seluruh riwayat
  Future<List<PembacaanSensor>> getAllPembacaan() async {
    final db = await database;

    final hasil = await db.query(
      'pembacaan_sensor',
      orderBy: 'waktu DESC, id DESC',
    );

    return hasil.map((data) {
      return PembacaanSensor.fromMap(data);
    }).toList();
  }

  // 7. UPDATE: Mengoreksi nilai pembacaan
  Future<int> updatePembacaan(
    int id,
    double nilaiBaru,
  ) async {
    final db = await database;

    return await db.update(
      'pembacaan_sensor',
      {'nilai': nilaiBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 8. DELETE: Menghapus satu pembacaan
  Future<int> deletePembacaan(int id) async {
    final db = await database;

    return await db.delete(
      'pembacaan_sensor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 9. Mengambil pembacaan terbaru setiap jenis sensor
  Future<List<PembacaanSensor>>
      getPembacaanTerbaruPerSensor() async {
    final db = await database;

    final hasil = await db.rawQuery('''
      SELECT p.*
      FROM pembacaan_sensor p
      INNER JOIN (
        SELECT jenis_sensor, MAX(id) AS id_terbaru
        FROM pembacaan_sensor
        GROUP BY jenis_sensor
      ) terbaru
      ON p.id = terbaru.id_terbaru
    ''');

    return hasil.map((data) {
      return PembacaanSensor.fromMap(data);
    }).toList();
  }
}
