import 'package:flutter/foundation.dart';

/// Simple logger; in production you might use logging package.
void appLog(String message, {String? tag}) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[${tag ?? 'App'}] $message');
  }
}
