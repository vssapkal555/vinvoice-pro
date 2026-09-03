import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/company/screens/company_screen.dart';
import '../../features/dashboard/screens/app_shell.dart';
import '../../features/onboarding/screens/onboarding_gate.dart';
import '../../features/expenses/screens/expenses_screen.dart';
import '../../features/imports/screens/import_excel_screen.dart';
import '../../features/help/screens/help_screen.dart';
import '../../features/invoices/screens/create_invoice_screen.dart';
import '../../features/invoices/screens/edit_invoice_screen.dart';
import '../../features/invoices/screens/invoice_detail_screen.dart';
import '../../features/masters/screens/sites_screen.dart';
import '../../features/masters/screens/tax_rates_screen.dart';
import '../../features/masters/screens/units_screen.dart';
import '../../features/masters/screens/vendor_codes_screen.dart';
import '../../features/parties/screens/parties_screen.dart';
import '../../features/pdf/screens/invoice_pdf_preview_screen.dart';
import '../../features/payments/screens/record_payment_screen.dart';

bool _hasActiveSupabaseSession() {
  try {
    return Supabase.instance.client.auth.currentSession != null;
  } catch (_) {
    // Supabase may intentionally be unavailable in widget tests
    // or in a misconfigured startup. Fail closed as signed out.
    return false;
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final signedIn = _hasActiveSupabaseSession();
    final onLogin = state.matchedLocation == '/login';

    if (!signedIn && !onLogin) {
      return '/login';
    }

    if (signedIn && onLogin) {
      return '/app';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/app',
      builder: (context, state) => const OnboardingGate(child: AppShell()),
    ),
    GoRoute(
      path: '/invoices/new',
      builder: (context, state) => const CreateInvoiceScreen(),
    ),
    GoRoute(
      path: '/invoices/:id/edit',
      builder: (context, state) =>
          EditInvoiceScreen(invoiceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/invoices/:id/payment',
      builder: (context, state) =>
          RecordPaymentScreen(invoiceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/invoices/:id/pdf',
      builder: (context, state) =>
          InvoicePdfPreviewScreen(invoiceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/invoices/:id',
      builder: (context, state) =>
          InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
    GoRoute(
      path: '/company',
      builder: (context, state) => const CompanyScreen(),
    ),
    GoRoute(
      path: '/company/new',
      builder: (context, state) => const CompanyScreen(createNew: true),
    ),
    GoRoute(
      path: '/parties',
      builder: (context, state) => const PartiesScreen(),
    ),
    GoRoute(
      path: '/vendor-codes',
      builder: (context, state) => const VendorCodesScreen(),
    ),
    GoRoute(path: '/sites', builder: (context, state) => const SitesScreen()),
    GoRoute(path: '/units', builder: (context, state) => const UnitsScreen()),
    GoRoute(
      path: '/tax-rates',
      builder: (context, state) => const TaxRatesScreen(),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpensesScreen(),
    ),
    GoRoute(
      path: '/import-excel',
      builder: (context, state) => const ImportExcelScreen(),
    ),
  ],
);
