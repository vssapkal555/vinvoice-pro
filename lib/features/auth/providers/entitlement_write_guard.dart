import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

Future<bool> requireEntitlementWriteAccess(
  BuildContext context,
  WidgetRef ref, {
  String action = 'change business data',
}) async {
  try {
    final entitlement = await ref.read(entitlementProvider.future);

    if (entitlement?.canWrite == true) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    final expired = entitlement?.isExpired == true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          expired ? Icons.lock_clock_rounded : Icons.lock_outline_rounded,
        ),
        title: Text(expired ? 'Trial Expired' : 'Subscription Required'),
        content: Text(
          expired
              ? 'Your trial or subscription has ended. Existing data remains '
                    'available in read-only mode, but you cannot $action until '
                    'the account is activated.'
              : 'An active trial or subscription is required to $action. '
                    'Existing data remains available in read-only mode.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return false;
  } catch (_) {
    if (!context.mounted) {
      return false;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.cloud_off_rounded),
        title: const Text('Unable to Verify Access'),
        content: const Text(
          'VInvoice Pro could not verify the current trial or subscription. '
          'Connect to the internet and try again. Existing local data remains '
          'available to view.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return false;
  }
}
