// lib/utils/validation_helper.dart
class ValidationHelper {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (value.length < 10 || value.length > 15) {
      return 'Nomor telepon harus antara 10-15 angka';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? validatePasswordConfirmation(
      String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (password != confirmation) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Harga harus angka positif';
    }
    return null;
  }

  static String? validateRating(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Rating is optional or has a default
    }
    final rating = double.tryParse(value);
    if (rating == null || rating < 0 || rating > 5) {
      return 'Rating harus antara 0 dan 5';
    }
    return null;
  }
}
