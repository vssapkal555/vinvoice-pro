import '../../../core/database/app_database.dart';

class InvoiceNumberService {
  final AppDatabase database;

  const InvoiceNumberService(this.database);

  Future<String> generateNext({
    required String companyId,
    DateTime? date,
  }) async {
    final invoiceDate = date ?? DateTime.now();

    final existingNumbers = await database.getInvoiceNumbersForCompany(
      companyId,
    );

    return buildNextInvoiceNumber(
      existingNumbers: existingNumbers,
      date: invoiceDate,
    );
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
