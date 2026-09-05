import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  const AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const AuthServiceException(
        'Unable to connect to VInvoice Pro. Check your internet connection and try again.',
      );
    } catch (error) {
      throw AuthServiceException(_friendlyNetworkMessage(error));
    }
  }

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const AuthServiceException(
        'Unable to connect to VInvoice Pro. Check your internet connection and try again.',
      );
    } catch (error) {
      throw AuthServiceException(_friendlyNetworkMessage(error));
    }
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  static String _friendlyNetworkMessage(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('failed host lookup') ||
        text.contains('socketexception') ||
        text.contains('clientexception') ||
        text.contains('network is unreachable') ||
        text.contains('connection refused') ||
        text.contains('connection timed out')) {
      return 'Unable to reach the VInvoice Pro server. Check Wi-Fi/mobile data and try again.';
    }

    return 'Unable to continue right now. Please try again in a moment.';
  }
}
