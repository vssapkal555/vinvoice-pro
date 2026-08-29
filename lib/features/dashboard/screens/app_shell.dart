import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../parties/screens/parties_screen.dart';
import '../../invoices/screens/invoice_list_screen.dart';
import 'dashboard_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: 'Invoices',
    ),
    NavigationDestination(
      icon: Icon(Icons.business_outlined),
      selectedIcon: Icon(Icons.business_rounded),
      label: 'Parties',
    ),
    NavigationDestination(
      icon: Icon(Icons.note_alt_outlined),
      selectedIcon: Icon(Icons.note_alt_rounded),
      label: 'Notes',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'More',
    ),
  ];

  Widget _currentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();

      case 1:
        return const InvoiceListScreen();

      case 2:
        return const PartiesScreen();

      case 3:
        return const PlaceholderPage(
          icon: Icons.note_alt_rounded,
          title: 'Notes',
          subtitle: 'Keep important business notes in one place.',
        );

      case 4:
        return const MorePage();

      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail =
            constraints.maxWidth >= 800 && constraints.maxHeight >= 650;

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _BrandMark(),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long_rounded),
                      label: Text('Invoices'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.business_outlined),
                      selectedIcon: Icon(Icons.business_rounded),
                      label: Text('Parties'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.note_alt_outlined),
                      selectedIcon: Icon(Icons.note_alt_rounded),
                      label: Text('Notes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: Text('More'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _currentPage()),
              ],
            ),
          );
        }

        return Scaffold(
          body: _currentPage(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: _destinations,
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlaceholderPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 70, color: AppTheme.primary),
                    const SizedBox(height: 18),
                    const Text(
                      'Coming in the next development stage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.apartment_rounded, 'My Company', 'Letterhead & company profile'),
      (Icons.numbers_rounded, 'Vendor Codes', 'Manage vendor codes'),
      (Icons.location_on_outlined, 'Sites / Plants', 'Manage sites and plants'),
      (Icons.straighten_rounded, 'Units', 'EA, Days, Months, KM and more'),
      (Icons.percent_rounded, 'GST & Tax', 'Tax rates and tax settings'),
      (Icons.upload_file_rounded, 'Import Excel', 'Import previous invoices'),
      (Icons.settings_outlined, 'Settings', 'Application preferences'),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'More',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masters, import tools and business settings.',
            style: TextStyle(color: AppTheme.secondaryText),
          ),
          const SizedBox(height: 24),

          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1, color: AppTheme.primary),
                ),
                title: Text(
                  item.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(item.$3),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  switch (item.$2) {
                    case 'My Company':
                      context.push('/company');
                      break;

                    case 'Vendor Codes':
                      context.push('/vendor-codes');
                      break;

                    case 'Sites / Plants':
                      context.push('/sites');
                      break;

                    case 'Units':
                      context.push('/units');
                      break;

                    case 'GST & Tax':
                      context.push('/tax-rates');
                      break;

                    case 'Import Excel':
                      context.push('/import-excel');
                      break;

                    case 'Settings':
                      break;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
