import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Listens for service worker updates and exposes state to the app.
class SwUpdateService {
  SwUpdateService._();
  static final instance = SwUpdateService._();

  final _controller = StreamController<bool>.broadcast();

  /// Emits `true` when a new service worker version is waiting.
  Stream<bool> get onUpdateAvailable => _controller.stream;

  bool _updateAvailable = false;
  bool get updateAvailable => _updateAvailable;

  /// Call once at app startup (web only).
  void init() {
    if (!kIsWeb) return;

    // Register callback that JS bridge in index.html will invoke
    web.window.setProperty(
      '_flutter_sw_update_cb'.toJS,
      (() {
        _updateAvailable = true;
        _controller.add(true);
      }).toJS,
    );

    // Check if update was already detected before Dart loaded
    final ready = web.window.getProperty('_swUpdateReady'.toJS);
    if (ready.dartify() == true) {
      _updateAvailable = true;
      _controller.add(true);
    }
  }

  /// Tell the waiting service worker to activate immediately.
  void applyUpdate() {
    if (!kIsWeb) return;
    final fn = web.window.getProperty('_flutter_sw_skip_waiting'.toJS);
    if (fn.typeofEquals('function')) {
      (fn as JSFunction).callAsFunction();
    }
    // Page will reload via controllerchange listener in index.html
  }
}
