
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sensor_cubit.dart';
import '../models/sensor.dart';
import '../widgets/sensor_card.dart';
import 'riwayat_sensor_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _tambahPembacaan(BuildContext context) async {
    final nilaiController = TextEditingController();
    final lokasiController = TextEditingController();

    String jenisSensor = 'ketinggian_air';

    final berhasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Pembacaan Sensor'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: jenisSensor,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Sensor',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ketinggian_air',
                          child: Text('Ketinggian Air'),
                        ),
                        DropdownMenuItem(
                          value: 'pergeseran_tanah',
                          child: Text('Pergeseran Tanah'),
                        ),
                        DropdownMenuItem(
                          value: 'curah_hujan',
                          child: Text('Curah Hujan'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            jenisSensor = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: nilaiController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nilai Pembacaan',
                        hintText: 'Contoh: 120',
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: lokasiController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi Pos',
                        hintText: 'Contoh: Pos Sungai',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (berhasil == true) {
      final nilai = double.tryParse(
        nilaiController.text.replaceAll(',', '.'),
      );

      final lokasi = lokasiController.text.trim();

      if (nilai == null || nilai < 0 || lokasi.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masukkan nilai dan lokasi yang valid!'),
          ),
        );
      } else {
        String satuan;

        switch (jenisSensor) {
          case 'ketinggian_air':
            satuan = 'cm';
            break;
          case 'pergeseran_tanah':
            satuan = 'mm';
            break;
          default:
            satuan = 'mm/jam';
        }

        await context.read<SensorCubit>().tambahPembacaan(
          jenisSensor: jenisSensor,
          nilai: nilai,
          lokasiPos: lokasi,
          satuan: satuan,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pembacaan berhasil disimpan ke SQLite!',
              ),
            ),
          );
        }
      }
    }

    nilaiController.dispose();
    lokasiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIAGA BENCANA'),
      ),

      body: BlocBuilder<SensorCubit, List<Sensor>>(
        builder: (context, sensors) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Dashboard Pemantauan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Pantau kondisi sensor pada pos pemantauan bencana.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              const Text(
                'Kondisi Sensor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...sensors.map((sensor) {
                return SensorCard(sensor: sensor);
              }),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () => _tambahPembacaan(context),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Pembacaan Sensor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RiwayatSensorPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Lihat Riwayat Sensor'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
