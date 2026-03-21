import 'package:flutter/material.dart';
import '../models/creator.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final CreatorStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, icon, bg, fg) = switch (status) {
      CreatorStatus.verified => ('Verified', Icons.check_circle, KeleleColors.greenGlow, KeleleColors.green),
      CreatorStatus.verifiedEmerging => ('Emerging', Icons.trending_up, const Color(0xFFE0F7FA), const Color(0xFF00897B)),
      CreatorStatus.pending => ('Pending', Icons.access_time, KeleleColors.orangeGlow, KeleleColors.orange),
      CreatorStatus.notYet => ('Not Yet', Icons.pause_circle, KeleleColors.orangeGlow, KeleleColors.orange),
      CreatorStatus.rejected => ('Rejected', Icons.cancel, KeleleColors.redGlow, KeleleColors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
