import 'package:flutter/material.dart';
import '../../../data/models/alarm_model.dart';

/// Reusable status badge displaying the current state of an Alarm.
class AlarmStatusBadge extends StatelessWidget {
  final AlarmModel alarm;
  final bool isLarge;

  const AlarmStatusBadge({
    super.key,
    required this.alarm,
    this.isLarge = false,
  });

  IconData _getIcon() {
    switch (alarm.statusAlarm.toLowerCase()) {
      case 'diverifikasi':
        return Icons.check_circle_outline_rounded;
      case 'ditolak':
        return Icons.cancel_outlined;
      case 'selesai':
        return Icons.task_alt_rounded;
      case 'menunggu':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = alarm.statusColor;
    final bgColor = alarm.statusBackgroundColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: isLarge ? 16 : 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            alarm.statusDisplay,
            style: TextStyle(
              color: color,
              fontSize: isLarge ? 13 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
