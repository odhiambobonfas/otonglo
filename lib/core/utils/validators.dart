class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(cleaned)) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? tillNumber(String? value) {
    if (value == null || value.isEmpty) return 'Till number is required';
    if (!RegExp(r'^[0-9]{5,8}$').hasMatch(value)) {
      return 'Invalid till number';
    }
    return null;
  }

  static String? paybillNumber(String? value) {
    if (value == null || value.isEmpty) return 'Paybill number is required';
    if (!RegExp(r'^[0-9]{5,10}$').hasMatch(value)) {
      return 'Invalid paybill number';
    }
    return null;
  }
}
