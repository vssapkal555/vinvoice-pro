import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);

  return ref.watch(authServiceProvider).currentUser;
});

class AccountEntitlement {
  const AccountEntitlement({
    required this.planCode,
    required this.billingType,
    required this.status,
    required this.trialEndsAt,
    required this.expiresAt,
  });

  final String planCode;
  final String billingType;
  final String status;
  final DateTime? trialEndsAt;
  final DateTime? expiresAt;

  bool get isTrial => status == 'trial';

  bool get isActive => status == 'active';

  bool get canWrite => !isExpired && (isTrial || isActive);

  bool get isExpired {
    if (status == 'expired' || status == 'cancelled' || status == 'suspended') {
      return true;
    }

    if (isTrial && trialEndsAt != null) {
      return DateTime.now().toUtc().isAfter(trialEndsAt!.toUtc());
    }

    if (isActive && expiresAt != null) {
      return DateTime.now().toUtc().isAfter(expiresAt!.toUtc());
    }

    return false;
  }

  int get trialDaysRemaining {
    if (!isTrial || trialEndsAt == null) {
      return 0;
    }

    final difference = trialEndsAt!.toUtc().difference(DateTime.now().toUtc());

    if (difference.isNegative) {
      return 0;
    }

    return (difference.inMinutes / 1440).ceil();
  }

  String get displayStatus {
    switch (status) {
      case 'trial':
        return isExpired ? 'Trial Expired' : 'Free Trial';
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      case 'suspended':
        return 'Suspended';
      default:
        return status;
    }
  }

  factory AccountEntitlement.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) {
        return null;
      }

      return DateTime.tryParse(value.toString());
    }

    return AccountEntitlement(
      planCode: map['plan_code']?.toString() ?? 'trial',
      billingType: map['billing_type']?.toString() ?? 'trial',
      status: map['status']?.toString() ?? 'trial',
      trialEndsAt: parseDate(map['trial_ends_at']),
      expiresAt: parseDate(map['expires_at']),
    );
  }
}

final entitlementProvider = FutureProvider<AccountEntitlement?>((ref) async {
  ref.watch(authStateProvider);

  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return null;
  }

  final client = ref.watch(supabaseClientProvider);

  final data = await client
      .from('user_entitlements')
      .select('plan_code,billing_type,status,trial_ends_at,expires_at')
      .eq('user_id', user.id)
      .maybeSingle();

  if (data == null) {
    return null;
  }

  return AccountEntitlement.fromMap(data);
});
