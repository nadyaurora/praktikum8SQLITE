class Sensor {
  final String jenisSensor;
  final double nilai;
  final String lokasiPos;
  final String satuan;

  Sensor({
    required this.jenisSensor,
    required this.nilai,
    required this.lokasiPos,
    required this.satuan,
  });

  Sensor copyWith({
    double? nilai,
  }) {
    return Sensor(
      jenisSensor: jenisSensor,
      nilai: nilai ?? this.nilai,
      lokasiPos: lokasiPos,
      satuan: satuan,
    );
  }
}
