class ContactValidators {
  const ContactValidators._();

  static String normalizeIndianMobile(String value) {
    var text = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (text.startsWith('+91')) {
      text = text.substring(3);
    }
    if (text.startsWith('91') && text.length == 12) {
      text = text.substring(2);
    }
    return text;
  }

  static String normalizeEmail(String value) => value.trim().toLowerCase();

  static String? indianMobile(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final mobile = normalizeIndianMobile(raw);
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  static String? email(String? value) {
    final email = normalizeEmail(value ?? '');
    if (email.isEmpty) {
      return null;
    }
    if (!RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
    ).hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
