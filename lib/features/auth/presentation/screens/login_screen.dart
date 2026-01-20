import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/cyan_glow_container.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/error_display.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _countryCode = AppConfig.defaultCountryCode;
  bool _acceptedTerms = false;
  String? _mobileError;
  String? _generalError;
  Timer? _otpCooldownTimer;
  int _otpCooldownSeconds = 0;
  bool _canSendOtp = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpCooldownTimer?.cancel();
    super.dispose();
  }

  void _startOtpCooldown() {
    setState(() {
      _canSendOtp = false;
      _otpCooldownSeconds = 30; // 30 second cooldown
    });

    _otpCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _otpCooldownSeconds--;
        if (_otpCooldownSeconds <= 0) {
          _canSendOtp = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    if (!_canSendOtp) {
      setState(() {
        _generalError = 'Please wait ${_otpCooldownSeconds}s before requesting another OTP';
      });
      return;
    }

    setState(() {
      _mobileError = Validators.validateMobileNumber(_mobileController.text);
      _generalError = null;
    });

    if (_mobileError != null) return;

    if (!_acceptedTerms) {
      setState(() {
        _generalError = 'Please accept Terms & Conditions';
      });
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).sendOtp(
          _mobileController.text,
          _countryCode,
        );

    if (success && mounted) {
      _startOtpCooldown(); // Start cooldown after successful send
      context.push('/otp', extra: {
        'mobileNumber': _mobileController.text,
        'countryCode': _countryCode,
      });
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).error;
      setState(() {
        _generalError = error ?? 'Failed to send OTP';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
          const Positioned(
            top: -140,
            right: -120,
            child: _GlowOrb(
              size: 280,
              color: AppColors.cyanGlowStrong,
            ),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(
              size: 320,
              color: AppColors.primary,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.lg,
                AppDimensions.xl,
                AppDimensions.lg,
                AppDimensions.xl + MediaQuery.of(context).viewInsets.bottom,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CyanGlowContainer(
                          padding: EdgeInsets.all(AppDimensions.sm),
                          borderRadius: AppDimensions.radiusFull,
                          backgroundColor: AppColors.glassSurfaceStrong,
                          borderColor: AppColors.glassBorderStrong,
                          child: Image(
                            image: AssetImage('logo full.png'),
                            width: 180,
                            height: 56,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          AppConfig.appTagline,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  GlassmorphicCard(
                    showGlow: true,
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome to Transfort',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Row(
                            children: [
                              Icon(Icons.lock_outline, 
                                size: 14, 
                                color: AppColors.textSecondary
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Secure Login',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.lg),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mobile Number',
                                style:
                                    Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                              ),
                              const SizedBox(height: AppDimensions.xs),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 90,
                                    height: AppDimensions.buttonHeight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassSurfaceStrong,
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd,
                                      ),
                                    ),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _countryCode,
                                          isExpanded: true,
                                          iconEnabledColor: AppColors.textSecondary,
                                          dropdownColor: AppColors.darkSurface,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: '+91',
                                              child: Text('+91'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() => _countryCode = value);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.sm),
                                  Expanded(
                                    child: TextField(
                                      controller: _mobileController,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      maxLength: 10,
                                      onChanged: (value) {
                                        if (_mobileError != null) {
                                          setState(() {
                                            _mobileError = Validators.validateMobileNumber(value);
                                            _generalError = null;
                                          });
                                        }
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                      decoration: InputDecoration(
                                        hintText: '9876543210',
                                        errorText: _mobileError,
                                        counterText: '',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  if (_generalError != null) ...[
                    ErrorDisplay(
                      message: _generalError!,
                      onRetry: _canSendOtp ? _sendOtp : null,
                      retryText: 'Retry',
                    ),
                    const SizedBox(height: AppDimensions.md),
                  ],
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                        side: const BorderSide(color: AppColors.glassBorder),
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                            _generalError = null;
                          });
                        },
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I accept the ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            children: const [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  GlassmorphicButton(
                    variant: GlassmorphicButtonVariant.primary,
                    onPressed: authState.isLoading || !_canSendOtp ? null : _sendOtp,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_canSendOtp
                            ? 'Send OTP'
                            : 'Send OTP (${_otpCooldownSeconds}s)'),
                  ),
                  if (EnvConfig.useMockAuth) ...[
                    const SizedBox(height: AppDimensions.sm),
                    GlassmorphicButton(
                      showGlow: false,
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              setState(() {
                                _mobileError = Validators
                                    .validateMobileNumber(_mobileController.text);
                              });

                              if (_mobileError != null) return;

                              if (!_acceptedTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please accept Terms & Conditions'),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                                return;
                              }

                              final messenger = ScaffoldMessenger.of(context);
                              final success = await ref
                                  .read(authNotifierProvider.notifier)
                                  .verifyOtp(_mobileController.text, '123456');

                              if (!mounted) return;

                              if (!success) {
                                final error =
                                    ref.read(authNotifierProvider).error;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(error ?? 'Mock login failed'),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            },
                      child: const Text('Continue without OTP (Mock)'),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.sm),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => context.push('/dev-email-login'),
                    child: const Text(
                      'Dev: Login with Email OTP (Mailpit)',
                    ),
                  ),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => context.push('/admin-login'),
                    child: const Text(
                      'Admin: Login with Email & Password',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withAlpha((0.35 * 255).round()),
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}
