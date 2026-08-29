import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/company/screens/company_screen.dart';
import '../../features/dashboard/screens/app_shell.dart';
import '../../features/imports/screens/import_excel_screen.dart';
import '../../features/invoices/screens/create_invoice_screen.dart';
import '../../features/invoices/screens/edit_invoice_screen.dart';
import '../../features/invoices/screens/invoice_detail_screen.dart';
import '../../features/masters/screens/sites_screen.dart';
import '../../features/masters/screens/tax_rates_screen.dart';
import '../../features/masters/screens/units_screen.dart';
import '../../features/masters/screens/vendor_codes_screen.dart';
import '../../features/parties/screens/parties_screen.dart';
import '../../features/pdf/screens/invoice_pdf_preview_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/app', builder: (context, state) => const AppShell()),
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
      path: '/invoices/:id/pdf',
      builder: (context, state) =>
          InvoicePdfPreviewScreen(invoiceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/invoices/:id',
      builder: (context, state) =>
          InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/company',
      builder: (context, state) => const CompanyScreen(),
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
      path: '/import-excel',
      builder: (context, state) => const ImportExcelScreen(),
    ),
  ],
);
