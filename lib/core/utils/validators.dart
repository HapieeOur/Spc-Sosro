import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }

    return null;
  }

  static String? validatePositiveInt(String? value,
      {String fieldName = 'Nilai'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '$fieldName harus berupa angka positif';
    }

    return null;
  }

  static String? validateCorrectionReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alasan koreksi wajib diisi';
    }

    if (value.trim().length < AppConstants.minCorrectionReasonLength) {
      return 'Alasan koreksi minimal ${AppConstants.minCorrectionReasonLength} karakter';
    }

    return null;
  }
}
