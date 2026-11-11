
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color warna;

    switch (status) {
      case 'Siaga':
        warna = Colors.red;
        break;

      case 'Waspada':
        warna = Colors.orange;
        break;

      default:
        warna = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: warna,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
