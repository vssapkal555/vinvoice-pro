class AmountInWords {
  const AmountInWords._();

  static const List<String> _ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  static String fromPaise(int totalPaise) {
    if (totalPaise < 0) {
      throw ArgumentError('Invoice amount cannot be negative.');
    }

    final rupees = totalPaise ~/ 100;
    final paise = totalPaise % 100;

    if (rupees == 0 && paise == 0) {
      return 'Rupees Zero Only';
    }

    final parts = <String>[];

    if (rupees > 0) {
      parts.add('Rupees ${_convertNumber(rupees)}');
    } else {
      parts.add('Rupees Zero');
    }

    if (paise > 0) {
      parts.add('and ${_convertNumber(paise)} Paise');
    }

    return '${parts.join(' ')} Only';
  }

  static String _convertNumber(int number) {
    if (number == 0) {
      return 'Zero';
    }

    final words = <String>[];

    var remaining = number;

    final crore = remaining ~/ 10000000;

    if (crore > 0) {
      words.add('${_convertNumber(crore)} Crore');
      remaining %= 10000000;
    }

    final lakh = remaining ~/ 100000;

    if (lakh > 0) {
      words.add('${_convertBelowThousand(lakh)} Lakh');
      remaining %= 100000;
    }

    final thousand = remaining ~/ 1000;

    if (thousand > 0) {
      words.add('${_convertBelowThousand(thousand)} Thousand');
      remaining %= 1000;
    }

    if (remaining > 0) {
      words.add(_convertBelowThousand(remaining));
    }

    return words.join(' ').trim();
  }

  static String _convertBelowThousand(int number) {
    final words = <String>[];

    var remaining = number;

    final hundred = remaining ~/ 100;

    if (hundred > 0) {
      words.add('${_ones[hundred]} Hundred');
      remaining %= 100;
    }

    if (remaining > 0) {
      if (remaining < 20) {
        words.add(_ones[remaining]);
      } else {
        final ten = remaining ~/ 10;
        final one = remaining % 10;

        words.add(_tens[ten]);

        if (one > 0) {
          words.add(_ones[one]);
        }
      }
    }

    return words.join(' ');
  }
}
