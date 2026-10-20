import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(
    String message, {
    String name = 'APP',
    Object? error,
    StackTrace? stackTrace,
    int level = 0,
  }) {
    if (kDebugMode) {
      dev.log(
        message,
        name: name,
        error: error,
        stackTrace: stackTrace,
        level: level,
      );
    }
  }

  static void request(String message, {String name = 'NETWORK', Object? data}) {
    final payload = data != null ? '\nPayload: $data' : '';
    log('[REQUEST] $message$payload', name: name, level: 500);
  }

  static void response(
    String message, {
    String name = 'NETWORK',
    Object? data,
  }) {
    final payload = data != null ? '\nData: $data' : '';
    log('[RESPONSE] $message$payload', name: name, level: 700);
  }

  static void debug(String message, {String name = 'DEBUG'}) {
    log('[DEBUG] $message', name: name, level: 300);
  }

  static void error(
    String message, {
    String name = 'ERROR',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      '[ERROR] $message',
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
