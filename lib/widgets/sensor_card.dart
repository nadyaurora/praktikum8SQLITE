
import 'package:flutter/material.dart';
import '../models/sensor.dart';

class SensorCard extends StatelessWidget {
  final Sensor sensor;

  const SensorCard({
    super.key,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    IconData ikon;
    String nama;

    switch (sensor.jenisSensor) {
      case 'ketinggian_air':
        ikon = Icons.water;
        nama = 'Ketinggian Air';
        break;

      case 'pergeseran_tanah':
        ikon = Icons.landscape;
        nama = 'Pergeseran Tanah';
        break;

      default:
        ikon = Icons.cloud;
        nama = 'Curah Hujan';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ikon,
                  color: Colors.blue,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              '${sensor.nilai} ${sensor.satuan}',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              sensor.lokasiPos,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
