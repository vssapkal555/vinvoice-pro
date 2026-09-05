import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _rememberedEmailKey = 'vinvoice_remembered_email';

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadRememberedEmail();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasActiveSession() && mounted) {
        context.go('/app');
      }
    });
  }

  bool _hasActiveSession() {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadRememberedEmail() async {
    final preferences = await SharedPreferences.getInstance();

    final rememberedEmail = preferences.getString(_rememberedEmailKey)?.trim();

    if (!mounted || rememberedEmail == null || rememberedEmail.isEmpty) {
      return;
    }

    _emailController.text = rememberedEmail;

    _emailController.selection = TextSelection.collapsed(
      offset: rememberedEmail.length,
    );
  }

  Future<void> _rememberEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_rememberedEmailKey, email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authServiceProvider);

      if (_isSignUp) {
        final response = await auth.signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        await _rememberEmail();

        if (!mounted) {
          return;
        }

        if (response.session == null) {
          TextInput.finishAutofillContext(shouldSave: true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created. Please verify your email before signing in.',
              ),
            ),
          );

          setState(() {
            _isSignUp = false;
          });

          return;
        }

        TextInput.finishAutofillContext(shouldSave: true);

        context.go('/app');
      } else {
        await auth.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await _rememberEmail();

        if (!mounted) {
          return;
        }

        TextInput.finishAutofillContext(shouldSave: true);

        context.go('/app');
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to continue right now. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchMode() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'VInvoice Pro',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkText,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Simple. Smart. Professional Invoicing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 36),

                      Text(
                        _isSignUp ? 'Start your free trial' : 'Welcome back',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _isSignUp
                            ? 'Create your account and start your 14-day trial.'
                            : 'Sign in to manage your business.',
                        style: const TextStyle(color: AppTheme.secondaryText),
                      ),

                      const SizedBox(height: 24),

                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (!_isSignUp) {
                              return null;
                            }

                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your full name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                      ],

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Enter your email address';
                          }

                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: _isSignUp
                            ? const [AutofillHints.newPassword]
                            : const [AutofillHints.password],
                        onFieldSubmitted: (_) {
                          if (!_isLoading) {
                            _submit();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your password';
                          }

                          if (_isSignUp && value.length < 6) {
                            return 'Use at least 6 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      if (!_isSignUp)
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 15,
                              color: AppTheme.secondaryText,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Your email is remembered. Password autofill uses your device password manager.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 18),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isSignUp ? 'Start Free Trial' : 'Sign In'),
                      ),

                      const SizedBox(height: 14),

                      TextButton(
                        onPressed: _isLoading ? null : _switchMode,
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign in'
                              : 'New customer? Start free trial',
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        _isSignUp
                            ? '14-day trial. Your local business data remains available on this device.'
                            : 'Secure cloud account powered by Supabase.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
