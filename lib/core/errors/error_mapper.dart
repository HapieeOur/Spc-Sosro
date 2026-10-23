import 'dart:io';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'app_exception.dart';

class ErrorMapper {
  ErrorMapper._();

  static AppException mapSupabaseError(dynamic error) {
    if (error is supabase.PostgrestException) {
      return _mapPostgrestCode(error);
    }

    if (error is supabase.AuthException) {
      return AuthException(error.message, code: 'AUTH');
    }

    if (error is SocketException) {
      return const NetworkException('Tidak dapat terhubung ke server',
          code: 'SOCKET');
    }

    if (error is TimeoutException) {
      return const NetworkException('Koneksi ke server timeout',
          code: 'TIMEOUT');
    }

    final message =
        error is Exception ? error.toString() : 'Terjadi kesalahan';
    return UnknownException(message, code: 'UNKNOWN');
  }

  static AppException _mapPostgrestCode(supabase.PostgrestException error) {
    final code = error.code;

    return switch (code) {
      'SPC01' => AuthException(error.message, code: code),
      'SPC02' => PermissionException(error.message, code: code),
      'SPC03' => AuthException(error.message, code: code),
      'SPC04' => ValidationException(error.message, code: code),
      'SPC05' => StockException(error.message, code: code),
      'SPC06' => ValidationException(error.message, code: code),
      'SPC07' => ValidationException(error.message, code: code),
      'SPC08' => ConflictException(error.message, code: code),
      _ => UnknownException(error.message, code: code),
    };
  }
}
