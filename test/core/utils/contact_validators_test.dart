import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/core/utils/contact_validators.dart';

void main() {
  test('accepts and normalizes Indian mobile numbers', () {
    expect(ContactValidators.indianMobile('9876543210'), isNull);
    expect(ContactValidators.indianMobile('+91 98765 43210'), isNull);
    expect(
      ContactValidators.normalizeIndianMobile('+91 98765 43210'),
      '9876543210',
    );
    expect(ContactValidators.indianMobile('12345'), isNotNull);
  });

  test('validates email format', () {
    expect(ContactValidators.email('user@example.com'), isNull);
    expect(
      ContactValidators.normalizeEmail(' User@Example.COM '),
      'user@example.com',
    );
    expect(ContactValidators.email('bad-email'), isNotNull);
  });
}
