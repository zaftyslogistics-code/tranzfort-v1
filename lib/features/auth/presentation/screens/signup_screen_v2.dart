import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_validator.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../../../../shared/widgets/flat_input.dart';
import '../providers/auth_provider.dart';

/// Signup Screen v0.02
/// - NO logo (logo only on splash)
/// - Email/Phone toggle
/// - Max 3 fields (Name + Email/Phone + Password)
/// - Flat design
class SignupScreenV2 extends ConsumerStatefulWidget {
  const SignupScreenV2({super.key});

  @override
  ConsumerState<SignupScreenV2> createState() => _SignupScreenV2State();
}

class _SignupScreenV2State extends ConsumerState<SignupScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isEmailMode = true; // true = email, false = phone
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    bool success;
    if (_isEmailMode) {
      success = await ref
          .read(authNotifierProvider.notifier)
          .signUpWithEmail(identifier, password, name);
    } else {
      // Phone signup - will need OTP verification
      success = await ref
          .read(authNotifierProvider.notifier)
          .signUpWithPhone(identifier, password, name);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      final error = ref.read(authNotifierProvider).error;
      setState(() => _errorMessage = error ?? 'Signup failed');
      return;
    }

    // Navigate to OTP verification if phone mode
    if (!_isEmailMode && mounted) {
      context.go('/otp-verification', extra: identifier);
    } else if (mounted) {
      context.go('/intent-selection');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
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

                // Name Input (Field 1 of 3)
                FlatInput(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email/Phone Input (Field 2 of 3)
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
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Input (Field 3 of 3)
                FlatInput(
                  label: 'Password',
                  hint: 'At least 6 characters',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

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

                // Signup Button
                PrimaryButton(
                  text: 'Create Account',
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                // Terms & Conditions
                Text(
                  'By signing up, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Sign In',
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
