import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/features/reports/models/report_date_range.dart';
import 'package:vinvoice_pro/features/reports/models/report_models.dart';
import 'package:vinvoice_pro/features/reports/services/report_service.dart';

void main() {
  group('ReportService profitabilitySummary', () {
    final range = ReportDateRange.fromPreset(ReportDatePreset.allTime);

    test('calculates revenue expenses profit and margin', () {
      final invoices = [
        ReportInvoiceRecord(
          id: 'issued-1',
          invoiceDate: DateTime(2026, 8, 1),
          status: 'issued',
          grandTotalPaise: 100000,
          taxableAmountPaise: 0,
          cgstAmountPaise: 0,
          sgstAmountPaise: 0,
          igstAmountPaise: 0,
          partyName: 'Party A',
        ),
        ReportInvoiceRecord(
          id: 'cancelled-1',
          invoiceDate: DateTime(2026, 8, 1),
          status: 'cancelled',
          grandTotalPaise: 50000,
          taxableAmountPaise: 0,
          cgstAmountPaise: 0,
          sgstAmountPaise: 0,
          igstAmountPaise: 0,
          partyName: 'Party B',
        ),
      ];

      final expenses = [
        ReportExpenseRecord(
          id: 'expense-1',
          expenseDate: DateTime(2026, 8, 2),
          category: 'Fuel',
          baseAmountPaise: 20000,
          gstAmountPaise: 3600,
          totalAmountPaise: 23600,
        ),
        ReportExpenseRecord(
          id: 'expense-2',
          expenseDate: DateTime(2026, 8, 3),
          category: 'Office',
          baseAmountPaise: 10000,
          gstAmountPaise: 1800,
          totalAmountPaise: 11800,
        ),
      ];

      final summary = ReportService.profitabilitySummary(
        invoices: invoices,
        expenses: expenses,
        range: range,
      );

      expect(summary.revenuePaise, 100000);
      expect(summary.expenseBasePaise, 30000);
      expect(summary.expenseGstPaise, 5400);
      expect(summary.expensePaise, 35400);
      expect(summary.operatingProfitPaise, 64600);
      expect(summary.expenseCount, 2);

      expect(summary.netMarginPercentage, closeTo(64.6, 0.001));

      expect(summary.isProfitable, isTrue);
    });

    test('groups expense categories by total descending', () {
      final summary = ReportService.profitabilitySummary(
        invoices: const [],
        expenses: [
          ReportExpenseRecord(
            id: '1',
            expenseDate: DateTime(2026, 8, 1),
            category: 'Fuel',
            baseAmountPaise: 10000,
            gstAmountPaise: 0,
            totalAmountPaise: 10000,
          ),
          ReportExpenseRecord(
            id: '2',
            expenseDate: DateTime(2026, 8, 2),
            category: 'Office',
            baseAmountPaise: 30000,
            gstAmountPaise: 0,
            totalAmountPaise: 30000,
          ),
          ReportExpenseRecord(
            id: '3',
            expenseDate: DateTime(2026, 8, 3),
            category: 'Fuel',
            baseAmountPaise: 15000,
            gstAmountPaise: 0,
            totalAmountPaise: 15000,
          ),
        ],
        range: range,
      );

      expect(summary.categoryBreakdown.length, 2);

      expect(summary.categoryBreakdown.first.category, 'Office');

      expect(summary.categoryBreakdown.first.totalPaise, 30000);

      expect(summary.categoryBreakdown[1].category, 'Fuel');

      expect(summary.categoryBreakdown[1].totalPaise, 25000);

      expect(summary.categoryBreakdown[1].count, 2);
    });

    test('supports operating loss without altering revenue', () {
      final summary = ReportService.profitabilitySummary(
        invoices: [
          ReportInvoiceRecord(
            id: 'invoice',
            invoiceDate: DateTime(2026, 8, 1),
            status: 'issued',
            grandTotalPaise: 10000,
            taxableAmountPaise: 0,
            cgstAmountPaise: 0,
            sgstAmountPaise: 0,
            igstAmountPaise: 0,
            partyName: 'Party',
          ),
        ],
        expenses: [
          ReportExpenseRecord(
            id: 'expense',
            expenseDate: DateTime(2026, 8, 2),
            category: 'Rent',
            baseAmountPaise: 15000,
            gstAmountPaise: 0,
            totalAmountPaise: 15000,
          ),
        ],
        range: range,
      );

      expect(summary.revenuePaise, 10000);
      expect(summary.expensePaise, 15000);
      expect(summary.operatingProfitPaise, -5000);

      expect(summary.netMarginPercentage, closeTo(-50.0, 0.001));

      expect(summary.isProfitable, isFalse);
    });

    test('returns zero margin when revenue is zero', () {
      final summary = ReportService.profitabilitySummary(
        invoices: const [],
        expenses: [
          ReportExpenseRecord(
            id: 'expense',
            expenseDate: DateTime(2026, 8, 1),
            category: 'Other',
            baseAmountPaise: 5000,
            gstAmountPaise: 0,
            totalAmountPaise: 5000,
          ),
        ],
        range: range,
      );

      expect(summary.revenuePaise, 0);
      expect(summary.expensePaise, 5000);
      expect(summary.operatingProfitPaise, -5000);
      expect(summary.netMarginPercentage, 0);
    });
  });
}
