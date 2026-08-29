import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/core/utils/amount_in_words.dart';

void main() {
  group('AmountInWords', () {
    test('zero amount', () {
      expect(AmountInWords.fromPaise(0), 'Rupees Zero Only');
    });

    test('simple rupees', () {
      expect(
        AmountInWords.fromPaise(118000),
        'Rupees One Thousand One Hundred Eighty Only',
      );
    });

    test('rupees and paise', () {
      expect(
        AmountInWords.fromPaise(12345678),
        'Rupees One Lakh Twenty Three Thousand Four Hundred Fifty Six and Seventy Eight Paise Only',
      );
    });

    test('crore amount', () {
      expect(AmountInWords.fromPaise(1000000000), 'Rupees One Crore Only');
    });
  });
}
