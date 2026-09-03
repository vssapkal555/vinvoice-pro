import '../../../core/database/app_database.dart';

class InvoiceNumberService {
  final AppDatabase database;

  const InvoiceNumberService(this.database);

  Future<String> generateNext({
    Company? company,
    String? companyId,
    DateTime? date,
  }) async {
    final resolvedCompanyId = company?.id ?? companyId;
    if (resolvedCompanyId == null || resolvedCompanyId.isEmpty) {
      throw ArgumentError('Company is required for invoice numbering.');
    }

    final invoiceDate = date ?? DateTime.now();
    final existingNumbers = await database.getInvoiceNumbersForCompany(
      resolvedCompanyId,
    );

    if (company != null &&
        company.invoiceNumberMode.toLowerCase() == 'custom') {
      return buildNextCustomInvoiceNumber(
        existingNumbers: existingNumbers,
        prefix: company.customInvoicePrefix ?? '',
        startingSeries: company.customInvoiceSeries ?? '',
      );
    }

    return buildNextInvoiceNumber(
      existingNumbers: existingNumbers,
      date: invoiceDate,
    );
  }

  static String buildNextCustomInvoiceNumber({
    required Iterable<String> existingNumbers,
    required String prefix,
    required String startingSeries,
  }) {
    final p = prefix.trim().toUpperCase();
    final s = startingSeries.trim();
    if (p.isEmpty || p.length > 8 || !RegExp(r'^[A-Z0-9]+$').hasMatch(p)) {
      throw StateError(
        'Custom invoice prefix must contain 1 to 8 letters or numbers.',
      );
    }
    if (s.isEmpty || s.length > 4 || !RegExp(r'^\d+$').hasMatch(s)) {
      throw StateError('Custom invoice series must contain 1 to 4 digits.');
    }

    final start = int.parse(s);
    var highest = start - 1;
    for (final number in existingNumbers) {
      if (!number.startsWith(p)) continue;
      final suffix = number.substring(p.length);
      if (suffix.isEmpty ||
          suffix.length > 4 ||
          !RegExp(r'^\d+$').hasMatch(suffix)) {
        continue;
      }
      final value = int.parse(suffix);
      if (value > highest) highest = value;
    }

    final next = highest + 1;
    if (next > 9999) {
      throw StateError(
        'Custom invoice series has reached 9999. Change numbering settings.',
      );
    }
    final nextText = next.toString().padLeft(s.length, '0');
    if (nextText.length > 4) {
      throw StateError('Custom invoice series cannot exceed 4 digits.');
    }
    return '$p$nextText';
  }

  static String buildNextInvoiceNumber({
    required Iterable<String> existingNumbers,
    required DateTime date,
  }) {
    final financialYear = financialYearFor(date);

    final prefix = 'INV/$financialYear/';

    var highestSequence = 0;

    for (final invoiceNumber in existingNumbers) {
      if (!invoiceNumber.startsWith(prefix)) {
        continue;
      }

      final sequenceText = invoiceNumber.substring(prefix.length);

      final sequence = int.tryParse(sequenceText);

      if (sequence != null && sequence > highestSequence) {
        highestSequence = sequence;
      }
    }

    final nextSequence = highestSequence + 1;

    return '$prefix'
        '${nextSequence.toString().padLeft(4, '0')}';
  }

  static String financialYearFor(DateTime date) {
    final startYear = date.month >= 4 ? date.year : date.year - 1;

    final endYear = (startYear + 1) % 100;

    return '$startYear-'
        '${endYear.toString().padLeft(2, '0')}';
  }
}
