import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../invoices/screens/invoice_list_screen.dart';
import '../../parties/screens/parties_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../reports/screens/reports_screen.dart';
import 'dashboard_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<_AppDestination> _destinations = [
    _AppDestination(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _AppDestination(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _AppDestination(
      label: 'Parties',
      icon: Icons.business_outlined,
      selectedIcon: Icons.business_rounded,
    ),
    _AppDestination(
      label: 'Reports',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
    ),
    _AppDestination(
      label: 'More',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
  ];

  static const List<Widget> _pages = [
    DashboardScreen(),
    InvoiceListScreen(),
    PartiesScreen(),
    ReportsScreen(),

    MorePage(),
  ];

  void _selectPage(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail =
            constraints.maxWidth >= 800 && constraints.maxHeight >= 650;

        if (useRail) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: SafeArea(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                    child: _DesktopNavigation(
                      selectedIndex: _selectedIndex,
                      destinations: _destinations,
                      onSelected: _selectPage,
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _pages,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          extendBody: false,
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _MobileNavigationDock(
              selectedIndex: _selectedIndex,
              destinations: _destinations,
              onSelected: _selectPage,
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// MOBILE NAVIGATION
// ============================================================================

class _MobileNavigationDock extends StatelessWidget {
  const _MobileNavigationDock({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_AppDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandNavy.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(destinations.length, (index) {
          final destination = destinations[index];
          final selected = selectedIndex == index;

          return Expanded(
            child: _MobileNavigationItem(
              destination: destination,
              selected: selected,
              onTap: () => onSelected(index),
            ),
          );
        }),
      ),
    );
  }
}

class _MobileNavigationItem extends StatelessWidget {
  const _MobileNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 36,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: selected ? 20 : 21,
                  color: selected ? Colors.white : AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? AppTheme.primary : AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TABLET / WIDE NAVIGATION
// ============================================================================

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_AppDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandNavy.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),

          const _BrandMark(),

          const SizedBox(height: 9),

          const Text(
            'VInvoice',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: AppTheme.border,
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final destination = destinations[index];
                final selected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _DesktopNavigationItem(
                    destination: destination,
                    selected: selected,
                    onTap: () => onSelected(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopNavigationItem extends StatelessWidget {
  const _DesktopNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: selected ? Colors.white : AppTheme.secondaryText,
                size: 21,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              destination.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppTheme.primary : AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BRAND
// ============================================================================

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(
        Icons.receipt_long_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _AppDestination {
  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

// ============================================================================
// MORE
// ============================================================================

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const _MoreHero(),

          const SizedBox(height: 18),

          const _MoreSectionHeading(
            title: 'Business Setup',
            subtitle: 'Company identity and customer-specific master data',
          ),

          const SizedBox(height: 9),

          _MoreGroup(
            items: [
              _MoreEntry(
                icon: Icons.apartment_rounded,
                title: 'My Company',
                subtitle: 'Letterhead, GST, PAN, address and contacts',
                onTap: () => context.push('/company'),
              ),
              _MoreEntry(
                icon: Icons.numbers_rounded,
                title: 'Vendor Codes',
                subtitle: 'Customer billing reference codes',
                onTap: () => context.push('/vendor-codes'),
              ),
              _MoreEntry(
                icon: Icons.location_on_outlined,
                title: 'Sites / Plants',
                subtitle: 'Customer sites and service locations',
                onTap: () => context.push('/sites'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _MoreSectionHeading(
            title: 'Invoice Masters',
            subtitle: 'Values used while creating invoice services and tax',
          ),

          const SizedBox(height: 9),

          _MoreGroup(
            items: [
              _MoreEntry(
                icon: Icons.straighten_rounded,
                title: 'Units',
                subtitle: 'EA, Days, Months, KM and custom units',
                onTap: () => context.push('/units'),
              ),
              _MoreEntry(
                icon: Icons.percent_rounded,
                title: 'GST & Tax',
                subtitle: 'CGST, SGST, IGST and custom tax rates',
                onTap: () => context.push('/tax-rates'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _MoreSectionHeading(
            title: 'Business Operations',
            subtitle: 'Track day-to-day business spending and costs',
          ),

          const SizedBox(height: 9),

          _MoreGroup(
            items: [
              _MoreEntry(
                icon: Icons.receipt_long_outlined,
                title: 'Expenses',
                subtitle: 'Record, review and manage business expenses',
                onTap: () => context.push('/expenses'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _MoreSectionHeading(
            title: 'Data Tools',
            subtitle: 'Bring historical invoice data into VInvoice',
          ),

          const SizedBox(height: 9),

          _MoreGroup(
            items: [
              _MoreEntry(
                icon: Icons.upload_file_rounded,
                title: 'Import Excel',
                subtitle: 'Validate and import historical invoices',
                onTap: () => context.push('/import-excel'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _MoreSectionHeading(
            title: 'Application',
            subtitle: 'Additional preferences and configuration',
          ),

          const SizedBox(height: 9),

          _MoreGroup(
            items: [
              _MoreEntry(
                icon: Icons.note_alt_outlined,
                title: 'Notes',
                subtitle: 'Business reminders and important information',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotesScreen(),
                    ),
                  );
                },
              ),
              _MoreEntry(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'More application preferences coming later',
                badge: 'SOON',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Additional settings will be available in a future milestone.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _MoreFooter(),
        ],
      ),
    );
  }
}

class _MoreHero extends StatelessWidget {
  const _MoreHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: .15),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        children: [
          _BrandMark(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VInvoice Control Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Business setup, masters and data tools',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreSectionHeading extends StatelessWidget {
  const _MoreSectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _MoreGroup extends StatelessWidget {
  const _MoreGroup({required this.items});

  final List<_MoreEntry> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            items[index],
            if (index < items.length - 1)
              const Divider(height: 1, indent: 70, endIndent: 14),
          ],
        ],
      ),
    );
  }
}

class _MoreEntry extends StatelessWidget {
  const _MoreEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppTheme.darkText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceMuted,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.tertiaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreFooter extends StatelessWidget {
  const _MoreFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.storage_rounded, color: AppTheme.secondaryText, size: 18),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'VInvoice currently stores your invoicing data locally on this device.',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
