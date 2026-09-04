import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/features/auth/providers/auth_providers.dart';

void main() {
  group('AccountEntitlement write access', () {
    test('active trial can write', () {
      final entitlement = AccountEntitlement(
        planCode: 'trial',
        billingType: 'trial',
        status: 'trial',
        trialEndsAt: DateTime.now().toUtc().add(const Duration(days: 1)),
        expiresAt: null,
      );
      expect(entitlement.canWrite, isTrue);
      expect(entitlement.isExpired, isFalse);
    });

    test('expired trial is read only', () {
      final entitlement = AccountEntitlement(
        planCode: 'trial',
        billingType: 'trial',
        status: 'trial',
        trialEndsAt: DateTime.now().toUtc().subtract(
          const Duration(minutes: 1),
        ),
        expiresAt: null,
      );
      expect(entitlement.canWrite, isFalse);
      expect(entitlement.isExpired, isTrue);
    });

    test('active subscription can write', () {
      final entitlement = AccountEntitlement(
        planCode: 'pro',
        billingType: 'subscription',
        status: 'active',
        trialEndsAt: null,
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
      );
      expect(entitlement.canWrite, isTrue);
    });

    test('non-active account states are read only', () {
      for (final status in ['cancelled', 'suspended', 'expired']) {
        final entitlement = AccountEntitlement(
          planCode: 'pro',
          billingType: 'subscription',
          status: status,
          trialEndsAt: null,
          expiresAt: null,
        );
        expect(entitlement.canWrite, isFalse, reason: status);
      }
    });
  });
}
