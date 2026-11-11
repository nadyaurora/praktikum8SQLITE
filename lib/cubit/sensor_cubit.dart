
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/sensor.dart';
import '../models/pembacaan_sensor.dart';
import '../database/database_helper.dart';

class SensorCubit extends Cubit<List<Sensor>> {

  SensorCubit() : super([
    Sensor(
      jenisSensor: 'ketinggian_air',
      nilai: 120,
      lokasiPos: 'Pos Sungai Cikapundung',
      satuan: 'cm',
    ),
    Sensor(
      jenisSensor: 'pergeseran_tanah',
      nilai: 2.5,
      lokasiPos: 'Pos Lereng Dago',
      satuan: 'mm',
    ),
    Sensor(
      jenisSensor: 'curah_hujan',
      nilai: 35,
      lokasiPos: 'Pos BMKG Bandung',
      satuan: 'mm/jam',
    ),
  ]);

  // Menambahkan pembacaan baru
  Future<void> tambahPembacaan({
    required String jenisSensor,
    required double nilai,
    required String lokasiPos,
    required String satuan,
  }) async {

    // Membuat objek pembacaan
    final pembacaan = PembacaanSensor(
      jenisSensor: jenisSensor,
      nilai: nilai,
      lokasiPos: lokasiPos,
      waktu: DateTime.now().toIso8601String(),
    );

    // Menyimpan data ke SQLite
    await DatabaseHelper.instance.insertPembacaan(
      pembacaan,
    );

    // Memperbarui nilai sensor pada dashboard
    final sensorBaru = state.map((sensor) {
      if (sensor.jenisSensor == jenisSensor) {
        return sensor.copyWith(nilai: nilai);
      }

      return sensor;
    }).toList();

    emit(sensorBaru);
  }
}
