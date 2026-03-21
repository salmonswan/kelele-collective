import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// On Flutter web, the default ScrollBehavior doesn't include mouse
/// in its drag devices, causing gesture arena conflicts where buttons
/// inside scrollables need two clicks. This fixes that app-wide.
class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!useMockData) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  runApp(const ProviderScope(child: KeleleApp()));
}

class KeleleApp extends ConsumerWidget {
  const KeleleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kelele Collective',
      debugShowCheckedModeBanner: false,
      theme: KeleleTheme.lightTheme,
      scrollBehavior: kIsWeb ? _WebScrollBehavior() : null,
      routerConfig: router,
    );
  }
}
