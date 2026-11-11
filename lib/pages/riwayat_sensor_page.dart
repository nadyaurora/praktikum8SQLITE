
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/status_badge.dart';
import 'edit_sensor_page.dart';

class RiwayatSensorPage extends StatefulWidget {
  const RiwayatSensorPage({super.key});

  @override
  State<RiwayatSensorPage> createState() =>
      _RiwayatSensorPageState();
}

class _RiwayatSensorPageState
    extends State<RiwayatSensorPage> {

  late Future<List<PembacaanSensor>> futureRiwayat;
  late Future<List<PembacaanSensor>> futureStatus;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  // Memuat ulang data dari SQLite
  void refreshData() {
    futureRiwayat =
        DatabaseHelper.instance.getAllPembacaan();

    futureStatus =
        DatabaseHelper.instance.getPembacaanTerbaruPerSensor();
  }

  // Menentukan status berdasarkan nilai sensor
  String tentukanStatus(PembacaanSensor data) {
    switch (data.jenisSensor) {
      case 'ketinggian_air':
        if (data.nilai >= 150) return 'Siaga';
        if (data.nilai >= 100) return 'Waspada';
        return 'Aman';

      case 'pergeseran_tanah':
        if (data.nilai >= 10) return 'Siaga';
        if (data.nilai >= 5) return 'Waspada';
        return 'Aman';

      case 'curah_hujan':
        if (data.nilai >= 50) return 'Siaga';
        if (data.nilai >= 20) return 'Waspada';
        return 'Aman';

      default:
        return 'Aman';
    }
  }

  // Mengambil status paling tinggi dari seluruh sensor
  String statusKeseluruhan(
    List<PembacaanSensor> data,
  ) {
    if (data.isEmpty) return 'Belum ada data';

    int tingkatTertinggi = 0;

    for (final sensor in data) {
      final status = tentukanStatus(sensor);

      int tingkat = 0;

      if (status == 'Waspada') {
        tingkat = 1;
      } else if (status == 'Siaga') {
        tingkat = 2;
      }

      if (tingkat > tingkatTertinggi) {
        tingkatTertinggi = tingkat;
      }
    }

    if (tingkatTertinggi == 2) return 'Siaga';
    if (tingkatTertinggi == 1) return 'Waspada';

    return 'Aman';
  }

  // Format waktu pembacaan
  String formatWaktu(String waktu) {
    final tanggal = DateTime.tryParse(waktu);

    if (tanggal == null) return waktu;

    final lokal = tanggal.toLocal();

    String duaDigit(int angka) =>
        angka.toString().padLeft(2, '0');

    return '${duaDigit(lokal.day)}/'
        '${duaDigit(lokal.month)}/'
        '${lokal.year} '
        '${duaDigit(lokal.hour)}:'
        '${duaDigit(lokal.minute)}';
  }

  // Mengoreksi pembacaan
  Future<void> editData(
    PembacaanSensor data,
  ) async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditSensorPage(
          pembacaan: data,
        ),
      ),
    );

    if (hasil == true && mounted) {
      setState(() {
        refreshData();
      });
    }
  }

  // Menghapus pembacaan
  Future<void> hapusData(int id) async {
    await DatabaseHelper.instance.deletePembacaan(id);

    if (!mounted) return;

    setState(() {
      refreshData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembacaan berhasil dihapus!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Sensor'),

        // Status diambil langsung dari SQLite
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: FutureBuilder<List<PembacaanSensor>>(
                future: futureStatus,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Text(
                      'Belum ada data',
                      style: TextStyle(fontSize: 11),
                    );
                  }

                  final status = statusKeseluruhan(
                    snapshot.data!,
                  );

                  return StatusBadge(status: status);
                },
              ),
            ),
          ),
        ],
      ),

      body: FutureBuilder<List<PembacaanSensor>>(
        future: futureRiwayat,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat pembacaan sensor.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,

            itemBuilder: (context, index) {
              final sensor = data[index];

              return Dismissible(
                key: ValueKey(sensor.id),

                direction: DismissDirection.horizontal,

                background: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),

                secondaryBackground: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),

                onDismissed: (_) {
                  hapusData(sensor.id!);
                },

                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(
                        Icons.sensors,
                        color: Colors.blue,
                      ),
                    ),

                    title: Text(
                      sensor.jenisSensor.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        Text(
                          'Nilai: ${sensor.nilai}',
                        ),

                        Text(
                          'Lokasi: ${sensor.lokasiPos}',
                        ),

                        Text(
                          'Waktu: ${formatWaktu(sensor.waktu)}',
                        ),

                        const SizedBox(height: 6),

                        StatusBadge(
                          status: tentukanStatus(sensor),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        editData(sensor);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
