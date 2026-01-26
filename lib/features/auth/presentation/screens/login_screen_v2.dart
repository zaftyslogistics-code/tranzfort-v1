import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_validator.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../../../../shared/widgets/flat_input.dart';
import '../providers/auth_provider.dart';

/// Login Screen v0.02
/// - NO logo (logo only on splash)
/// - Email/Phone toggle
/// - Flat design
/// - Max 2 fields (Email/Phone + Password)
class LoginScreenV2 extends ConsumerStatefulWidget {
  const LoginScreenV2({super.key});

  @override
  ConsumerState<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends ConsumerState<LoginScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isEmailMode = true; // true = email, false = phone
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    bool success;
    if (_isEmailMode) {
      success = await ref
          .read(authNotifierProvider.notifier)
          .signInWithEmailPassword(identifier, password);
    } else {
      // Phone login - implement when ready
      success = await ref
          .read(authNotifierProvider.notifier)
          .signInWithPhone(identifier, password);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      final error = ref.read(authNotifierProvider).error;
      setState(() => _errorMessage = error ?? 'Login failed');
      return;
    }

    // Check if admin (block in user app)
    final authState = ref.read(authNotifierProvider);
    if (authState.admin != null) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Admin accounts cannot use this app. Please use the Admin app.';
      });
      return;
    }

    if (mounted) {
      context.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Email/Phone Toggle
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isEmailMode = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isEmailMode ? AppColors.primary : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isEmailMode
                                    ? Colors.white
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isEmailMode = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_isEmailMode ? AppColors.primary : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Phone',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !_isEmailMode
                                    ? Colors.white
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Email/Phone Input
                FlatInput(
                  label: _isEmailMode ? 'Email' : 'Phone Number',
                  hint: _isEmailMode ? 'you@example.com' : '+91 98765 43210',
                  controller: _identifierController,
                  keyboardType: _isEmailMode
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ${_isEmailMode ? 'email' : 'phone number'}';
                    }
                    if (_isEmailMode) {
                      return InputValidator.validateEmail(value);
                    } else {
                      // Basic phone validation
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Input
                FlatInput(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 8),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Login Button
                PrimaryButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
