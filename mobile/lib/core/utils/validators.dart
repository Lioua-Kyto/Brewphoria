abstract final class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 7 || cleaned.length > 15) return 'Enter a valid phone number';
    return null;
  }

  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) return 'Postal code is required';
    if (value.trim().length < 3) return 'Enter a valid postal code';
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < min) return '$fieldName must be at least $min characters';
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    final n = num.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return '$fieldName must be greater than 0';
    return null;
  }
}
