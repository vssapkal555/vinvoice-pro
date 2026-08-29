import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../invoices/screens/invoice_list_screen.dart';
import '../../parties/screens/parties_screen.dart';
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
      label: 'Notes',
      icon: Icons.note_alt_outlined,
      selectedIcon: Icons.note_alt_rounded,
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
    PlaceholderPage(
      icon: Icons.note_alt_rounded,
      title: 'Notes',
      subtitle: 'Keep important business notes in one place.',
    ),
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
// NOTES PLACEHOLDER
// ============================================================================

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppTheme.primarySoft,
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: Icon(icon, size: 31, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Coming soon',
                        style: TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'This workspace will be available in a future development stage.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MORE
// ============================================================================

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.apartment_rounded,
        'My Company',
        'Letterhead & company profile',
        '/company',
      ),
      (
        Icons.numbers_rounded,
        'Vendor Codes',
        'Manage vendor codes',
        '/vendor-codes',
      ),
      (
        Icons.location_on_outlined,
        'Sites / Plants',
        'Manage sites and plants',
        '/sites',
      ),
      (
        Icons.straighten_rounded,
        'Units',
        'EA, Days, Months, KM and more',
        '/units',
      ),
      (
        Icons.percent_rounded,
        'GST & Tax',
        'Tax rates and tax settings',
        '/tax-rates',
      ),
      (
        Icons.upload_file_rounded,
        'Import Excel',
        'Import previous invoices',
        '/import-excel',
      ),
      (Icons.settings_outlined, 'Settings', 'Application preferences', ''),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          Text('More', style: Theme.of(context).textTheme.headlineMedium),

          const SizedBox(height: 5),

          const Text(
            'Masters, import tools and business settings.',
            style: TextStyle(color: AppTheme.secondaryText),
          ),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  _MoreItem(
                    icon: items[index].$1,
                    title: items[index].$2,
                    subtitle: items[index].$3,
                    onTap: () {
                      final route = items[index].$4;

                      if (route.isNotEmpty) {
                        context.push(route);
                      }
                    },
                  ),
                  if (index < items.length - 1)
                    const Divider(indent: 76, height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 21),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.tertiaryText,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}
