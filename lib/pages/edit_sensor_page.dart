
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/pembacaan_sensor.dart';

class EditSensorPage extends StatefulWidget {
  final PembacaanSensor pembacaan;

  const EditSensorPage({
    super.key,
    required this.pembacaan,
  });

  @override
  State<EditSensorPage> createState() =>
      _EditSensorPageState();
}

class _EditSensorPageState extends State<EditSensorPage> {
  late TextEditingController nilaiController;

  @override
  void initState() {
    super.initState();

    nilaiController = TextEditingController(
      text: widget.pembacaan.nilai.toString(),
    );
  }

  Future<void> simpanPerubahan() async {
    final nilaiBaru = double.tryParse(
      nilaiController.text.replaceAll(',', '.'),
    );

    if (nilaiBaru == null || nilaiBaru < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nilai yang valid!'),
        ),
      );
      return;
    }

    await DatabaseHelper.instance.updatePembacaan(
      widget.pembacaan.id!,
      nilaiBaru,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil diperbarui!'),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nilaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koreksi Pembacaan'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Sensor: ${widget.pembacaan.jenisSensor}',
            ),

            const SizedBox(height: 10),

            Text(
              'Lokasi: ${widget.pembacaan.lokasiPos}',
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nilaiController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Nilai Pembacaan Baru',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: simpanPerubahan,
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
