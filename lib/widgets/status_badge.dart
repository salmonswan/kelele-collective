import 'package:flutter/material.dart';
import '../models/creator.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final CreatorStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      CreatorStatus.verified => ('Verified', KeleleColors.greenGlow, KeleleColors.green),
      CreatorStatus.pending => ('Pending', KeleleColors.orangeGlow, KeleleColors.orange),
      CreatorStatus.notYet => ('Not Yet', KeleleColors.redGlow, KeleleColors.red),
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
          Icon(
            status == CreatorStatus.verified
                ? Icons.check_circle
                : status == CreatorStatus.pending
                    ? Icons.access_time
                    : Icons.cancel,
            size: 12,
            color: fg,
          ),
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
