import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/input_validator.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = InputValidator.sanitize(_emailController.text.trim());
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _error = null;
    });

    // Validate and sanitize email
    final emailError = InputValidator.validateEmail(email);
    if (emailError != null) {
      setState(() => _error = emailError);
      return;
    }

    // Check for malicious input
    if (!InputValidator.isSafeInput(email)) {
      InputValidator.logSuspiciousInput(email, 'signup_email');
      setState(() => _error = 'Invalid input detected');
      return;
    }

    if (password.isEmpty || password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      setState(
          () => _error = 'Password must contain at least one uppercase letter');
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      setState(() => _error = 'Password must contain at least one number');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(authNotifierProvider.notifier)
        .signUpWithEmailPassword(email, password);

    if (!mounted) return;

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (!success) {
      final err = ref.read(authNotifierProvider).error;
      if (mounted) {
        setState(() => _error = err ?? 'Signup failed');
      }
      return;
    }

    context.go('/splash');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBackground,
                    AppColors.secondaryBackground,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                showGlow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradientText(
                      'Create your account',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) => _signup(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppDimensions.md),
                      Text(
                        _error!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.danger),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.lg),
                    GlassmorphicButton(
                      variant: GlassmorphicButtonVariant.primary,
                      onPressed: _isLoading ? null : _signup,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
