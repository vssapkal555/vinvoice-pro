import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupAsync = ref.watch(setupStepProvider);

    return setupAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Unable to check account setup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(setupStepProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (step) {
        if (step == SetupStep.complete) {
          return child;
        }

        return _SetupPage(step: step);
      },
    );
  }
}

class _SetupPage extends ConsumerWidget {
  const _SetupPage({required this.step});

  final SetupStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = switch (step) {
      SetupStep.company => const _StepConfig(
        number: 1,
        title: 'Create your company profile',
        description:
            'Add the business identity and address that will appear on your invoices.',
        button: 'Create Company',
        route: '/company/new',
        icon: Icons.apartment_rounded,
      ),
      SetupStep.party => const _StepConfig(
        number: 2,
        title: 'Add your first customer',
        description:
            'Each customer / party belongs to the currently selected company.',
        button: 'Add Customer / Party',
        route: '/parties',
        icon: Icons.business_rounded,
      ),
      SetupStep.vendorCode => const _StepConfig(
        number: 3,
        title: 'Map the vendor code',
        description:
            'Choose the customer and enter the single vendor code for this company + customer relationship.',
        button: 'Create Vendor Code',
        route: '/vendor-codes',
        icon: Icons.numbers_rounded,
      ),
      SetupStep.complete => throw StateError('Complete setup should show app.'),
    };

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('VInvoice Pro Setup')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        config.icon,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'STEP ${config.number} OF 3',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      config.title,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      config.description,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () async {
                        await context.push(config.route);
                        ref.invalidate(companiesProvider);
                        ref.invalidate(primaryCompanyProvider);
                        ref.invalidate(setupStepProvider);
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(config.button),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Complete this step and return here. VInvoice Pro will automatically continue to the next required setup step.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepConfig {
  const _StepConfig({
    required this.number,
    required this.title,
    required this.description,
    required this.button,
    required this.route,
    required this.icon,
  });

  final int number;
  final String title;
  final String description;
  final String button;
  final String route;
  final IconData icon;
}
