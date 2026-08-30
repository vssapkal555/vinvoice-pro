import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/features/reports/models/report_date_range.dart';
import 'package:vinvoice_pro/features/reports/models/report_models.dart';
import 'package:vinvoice_pro/features/reports/services/report_service.dart';

void main() {
  group('ReportDateRange', () {
    final now = DateTime(2026, 8, 30);

    test('financial year starts on 1 April', () {
      final range = ReportDateRange.fromPreset(
        ReportDatePreset.thisFinancialYear,
        now: now,
      );

      expect(range.start, DateTime(2026, 4, 1));

      expect(range.end, DateTime(2026, 8, 30));
    });

    test('last 30 days includes today', () {
      final range = ReportDateRange.fromPreset(
        ReportDatePreset.last30Days,
        now: now,
      );

      expect(range.start, DateTime(2026, 8, 1));

      expect(range.end, DateTime(2026, 8, 30));
    });
  });

  group('ReportService', () {
    test('draft and cancelled invoices do not count as revenue', () {
      final range = ReportDateRange.fromPreset(
        ReportDatePreset.allTime,
        now: DateTime(2026, 8, 30),
      );

      final result = ReportService.financialSummary(
        invoices: [
          ReportInvoiceRecord(
            id: 'issued',
            invoiceDate: DateTime(2026, 8, 1),
            status: 'issued',
            grandTotalPaise: 118000,
            taxableAmountPaise: 100000,
            cgstAmountPaise: 9000,
            sgstAmountPaise: 9000,
            igstAmountPaise: 0,
            partyName: 'Customer A',
          ),
          ReportInvoiceRecord(
            id: 'draft',
            invoiceDate: DateTime(2026, 8, 2),
            status: 'draft',
            grandTotalPaise: 500000,
            taxableAmountPaise: 500000,
            cgstAmountPaise: 0,
            sgstAmountPaise: 0,
            igstAmountPaise: 0,
            partyName: 'Customer B',
          ),
          ReportInvoiceRecord(
            id: 'cancelled',
            invoiceDate: DateTime(2026, 8, 3),
            status: 'cancelled',
            grandTotalPaise: 900000,
            taxableAmountPaise: 900000,
            cgstAmountPaise: 0,
            sgstAmountPaise: 0,
            igstAmountPaise: 0,
            partyName: 'Customer C',
          ),
        ],
        payments: const [],
        range: range,
      );

      expect(result.invoicedPaise, 118000);
      expect(result.issuedCount, 1);
      expect(result.draftCount, 1);
      expect(result.cancelledCount, 1);
    });

    test('calculates paid partial and unpaid invoices', () {
      final range = ReportDateRange.fromPreset(
        ReportDatePreset.allTime,
        now: DateTime(2026, 8, 30),
      );

      final invoices = [
        ReportInvoiceRecord(
          id: 'paid',
          invoiceDate: DateTime(2026, 8, 1),
          status: 'issued',
          grandTotalPaise: 10000,
          taxableAmountPaise: 10000,
          cgstAmountPaise: 0,
          sgstAmountPaise: 0,
          igstAmountPaise: 0,
          partyName: 'A',
        ),
        ReportInvoiceRecord(
          id: 'partial',
          invoiceDate: DateTime(2026, 8, 2),
          status: 'issued',
          grandTotalPaise: 20000,
          taxableAmountPaise: 20000,
          cgstAmountPaise: 0,
          sgstAmountPaise: 0,
          igstAmountPaise: 0,
          partyName: 'B',
        ),
        ReportInvoiceRecord(
          id: 'unpaid',
          invoiceDate: DateTime(2026, 8, 3),
          status: 'issued',
          grandTotalPaise: 30000,
          taxableAmountPaise: 30000,
          cgstAmountPaise: 0,
          sgstAmountPaise: 0,
          igstAmountPaise: 0,
          partyName: 'C',
        ),
      ];

      final payments = [
        ReportPaymentRecord(
          invoiceId: 'paid',
          paymentDate: DateTime(2026, 8, 10),
          amountPaise: 10000,
        ),
        ReportPaymentRecord(
          invoiceId: 'partial',
          paymentDate: DateTime(2026, 8, 11),
          amountPaise: 5000,
        ),
      ];

      final result = ReportService.financialSummary(
        invoices: invoices,
        payments: payments,
        range: range,
      );

      expect(result.invoicedPaise, 60000);
      expect(result.collectedPaise, 15000);
      expect(result.outstandingPaise, 45000);

      expect(result.paidCount, 1);
      expect(result.partiallyPaidCount, 1);
      expect(result.unpaidCount, 1);
    });

    test('collections follow payment date rather than invoice date', () {
      final august = ReportDateRange(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 31),
        preset: ReportDatePreset.custom,
      );

      final result = ReportService.financialSummary(
        invoices: [
          ReportInvoiceRecord(
            id: 'old-invoice',
            invoiceDate: DateTime(2026, 7, 15),
            status: 'issued',
            grandTotalPaise: 100000,
            taxableAmountPaise: 100000,
            cgstAmountPaise: 0,
            sgstAmountPaise: 0,
            igstAmountPaise: 0,
            partyName: 'A',
          ),
        ],
        payments: [
          ReportPaymentRecord(
            invoiceId: 'old-invoice',
            paymentDate: DateTime(2026, 8, 20),
            amountPaise: 25000,
          ),
        ],
        range: august,
      );

      expect(result.invoicedPaise, 0);
      expect(result.collectedPaise, 25000);
    });
  });
}
