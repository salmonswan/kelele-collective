import 'package:flutter/material.dart';
import '../services/sw_update_service.dart';
import '../theme/app_theme.dart';

/// Shows a banner when a new app version is available.
/// Placed as a top-level overlay in AppShell.
class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final svc = SwUpdateService.instance;
    if (svc.updateAvailable) {
      _visible = true;
    }
    svc.onUpdateAvailable.listen((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: KeleleColors.yellow,
      content: const Text(
        'A new version is available.',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _visible = false),
          child: const Text('Later', style: TextStyle(color: Colors.black54)),
        ),
        FilledButton(
          onPressed: () => SwUpdateService.instance.applyUpdate(),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
          ),
          child: const Text('Refresh'),
        ),
      ],
    );
  }
}
