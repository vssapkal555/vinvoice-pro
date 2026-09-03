import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & User Guide'), toolbarHeight: 54),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: -0.48,
                  child: Opacity(
                    opacity: 0.035,
                    child: Image.asset(
                      'assets/branding/vinvoice_pro_logo.png',
                      width: 310,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _HelpHero(scheme: scheme),
              const SizedBox(height: 14),
              Text(
                'Quick guide',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Open a section below whenever you need help using a module.',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 12),
              const _HelpSection(
                icon: Icons.rocket_launch_outlined,
                title: 'Getting Started',
                points: [
                  'Sign in, then create your company profile first.',
                  'Add at least one party/customer before creating invoices.',
                  'Configure vendor code, site/plant, units and tax rates as required.',
                  'Use the selected company as the working business for invoices and reports.',
                ],
              ),
              const _HelpSection(
                icon: Icons.dashboard_outlined,
                title: 'Dashboard',
                points: [
                  'Use the Dashboard for a quick view of invoiced, collected, outstanding, profitability and payment status.',
                  'Active Invoices and Parties provide shortcuts to the related modules.',
                  'The account button gives access to themes, Help, sharing, subscription information and logout.',
                ],
              ),
              const _HelpSection(
                icon: Icons.apartment_outlined,
                title: 'Companies',
                points: [
                  'My Company stores the seller name, address, GSTIN, PAN, logo and invoice settings.',
                  'You can maintain more than one company and switch the active company.',
                  'Company signature and logo are used in supported invoice PDF output.',
                ],
              ),
              const _HelpSection(
                icon: Icons.groups_outlined,
                title: 'Parties / Customers',
                points: [
                  'Create customer records with billing address, GSTIN and PAN.',
                  'Invoices are created for a party under the currently selected company.',
                  'Open a party to review or update its saved information.',
                ],
              ),
              const _HelpSection(
                icon: Icons.numbers_outlined,
                title: 'Vendor Codes',
                points: [
                  'Vendor Code is mapped to a Company + Party combination.',
                  'A party can have a different vendor code under another company.',
                  'When you select the party on an invoice, its mapped vendor code is selected automatically.',
                ],
              ),
              const _HelpSection(
                icon: Icons.location_on_outlined,
                title: 'Sites / Plants',
                points: [
                  'Sites and plants are maintained for the relevant party.',
                  'Only matching sites are shown while creating an invoice.',
                  'If only one site is available, VInvoice can select it automatically.',
                ],
              ),
              const _HelpSection(
                icon: Icons.straighten_outlined,
                title: 'Units',
                points: [
                  'Maintain commonly used units such as EA, Days, Months and KM.',
                  'Configured units become available in invoice line items.',
                ],
              ),
              const _HelpSection(
                icon: Icons.percent_outlined,
                title: 'GST / Tax',
                points: [
                  'For taxable invoices, use either CGST + SGST together or IGST as applicable.',
                  'Non-taxable invoices keep GST amounts at zero.',
                  'Always verify the tax type and rates before issuing the invoice.',
                ],
              ),
              const _HelpSection(
                icon: Icons.post_add_outlined,
                title: 'Creating an Invoice',
                points: [
                  'Select company, party, site and service period, then enter PO and service details.',
                  'Add service description, HSN/SAC, quantity, unit and rate for each line.',
                  'VInvoice calculates line amount, taxable amount, GST and grand total from the entered values.',
                  'Review all details before saving or issuing.',
                ],
              ),
              const _HelpSection(
                icon: Icons.edit_note_outlined,
                title: 'Draft & Issue Workflow',
                points: [
                  'Save Draft when the invoice is not final.',
                  'Issue Invoice when required billing details are complete.',
                  'Issued invoices can be edited only while payment rules permit it.',
                  'Invoices with recorded payment are protected from actions that could invalidate payment history.',
                ],
              ),
              const _HelpSection(
                icon: Icons.receipt_long_outlined,
                title: 'Invoice Details',
                points: [
                  'Open an invoice to review party, invoice, seller, line-item and summary information.',
                  'Expandable sections keep the screen compact while preserving full detail.',
                  'Available actions depend on invoice status and payment state.',
                ],
              ),
              const _HelpSection(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Preview, Print & Share',
                points: [
                  'Preview the generated PDF before printing or sharing.',
                  'Normal mode prints the saved company header and branding.',
                  'Print and Share allow you to choose the appropriate paper mode for that output.',
                ],
              ),
              const _HelpSection(
                icon: Icons.print_outlined,
                title: 'Preprinted Letterhead',
                points: [
                  'Enable Preprinted Letterhead when printing on paper that already contains your company letterhead.',
                  'VInvoice hides its company header and reserves blank space at the top of page 1.',
                  'The financial values and invoice content remain unchanged.',
                ],
              ),
              const _HelpSection(
                icon: Icons.payments_outlined,
                title: 'Payments',
                points: [
                  'Record payments against an issued invoice.',
                  'Payment status is reflected in invoice controls, reports and collection summaries.',
                  'Check payment information before attempting invoice changes.',
                ],
              ),
              const _HelpSection(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Expenses',
                points: [
                  'Record business expenses with date, category and amounts.',
                  'Expenses are used in profitability reporting.',
                  'Review or update expense records when business costs change.',
                ],
              ),
              const _HelpSection(
                icon: Icons.analytics_outlined,
                title: 'Reports',
                points: [
                  'Financial Reports summarize invoiced value, collections, outstanding amounts, GST and invoice lifecycle.',
                  'Detailed reports provide focused invoice, payment, outstanding and GST views.',
                  'Use the available period filters before reviewing or exporting report information.',
                ],
              ),
              const _HelpSection(
                icon: Icons.upload_file_outlined,
                title: 'Excel Import',
                points: [
                  'Use the supported VInvoice Excel structure when importing historical invoices.',
                  'Review validation results, warnings and preview information before importing.',
                  'Duplicate handling options should be selected carefully so existing invoices are not unintentionally replaced.',
                ],
              ),
              const _HelpSection(
                icon: Icons.note_alt_outlined,
                title: 'Notes',
                points: [
                  'Use Notes for business reminders and useful internal information.',
                  'Notes are separate from invoice financial values.',
                ],
              ),
              const _HelpSection(
                icon: Icons.palette_outlined,
                title: 'Themes',
                points: [
                  'Open the account menu and choose Theme / Appearance.',
                  'Professional Blue, Teal Sky and Indigo Lavender change the app interface accents.',
                  'Semantic success, warning and error colors remain consistent for clarity.',
                ],
              ),
              const _HelpSection(
                icon: Icons.person_outline_rounded,
                title: 'Account & Trial',
                points: [
                  'The profile menu shows the signed-in account and current entitlement status.',
                  'Trial time is controlled by your account entitlement.',
                  'Purchase / Subscription is shown as a planned commercial option until payment integration is completed.',
                ],
              ),
              const _HelpSection(
                icon: Icons.cloud_outlined,
                title: 'Local Data & Cloud Status',
                points: [
                  'Operational invoice data currently remains local/offline-first on the device.',
                  'Sign-in and trial entitlement use the connected cloud account service.',
                  'Full business-data cloud backup and synchronization are not yet enabled.',
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/branding/vinvoice_pro_logo.png',
                      width: 180,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Simple. Smart. Professional invoicing.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'by V. S. S.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpHero extends StatelessWidget {
  const _HelpHero({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.62)!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: .14),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 116,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/branding/vinvoice_pro_logo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help & User Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'A practical module-by-module guide',
                  style: TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.icon,
    required this.title,
    required this.points,
  });
  final IconData icon;
  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: scheme.primary, size: 19),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        children: [
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 5, color: scheme.primary),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
