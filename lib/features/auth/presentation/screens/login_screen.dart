import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/cyan_glow_container.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

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

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _mobileError = Validators.validateMobileNumber(_mobileController.text);
    });

    if (_mobileError != null) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms & Conditions'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).sendOtp(
          _mobileController.text,
          _countryCode,
        );

    if (success && mounted) {
      context.push('/otp', extra: {
        'mobileNumber': _mobileController.text,
        'countryCode': _countryCode,
      });
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to send OTP'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
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
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg,
                AppDimensions.xl,
                AppDimensions.lg,
                AppDimensions.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CyanGlowContainer(
                          padding: EdgeInsets.all(AppDimensions.md),
                          borderRadius: AppDimensions.radiusFull,
                          backgroundColor: AppColors.glassSurfaceStrong,
                          borderColor: AppColors.glassBorderStrong,
                          child: Icon(
                            Icons.local_shipping,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        GradientText(
                          AppConfig.appName,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.xs),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Login with Mobile Number',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        Form(
                          key: _formKey,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 90,
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
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _countryCode,
                                    isExpanded: true,
                                    iconEnabledColor: AppColors.textSecondary,
                                    dropdownColor: AppColors.darkSurface,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: AppColors.textPrimary),
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
                              const SizedBox(width: AppDimensions.sm),
                              Expanded(
                                child: AuthTextField(
                                  controller: _mobileController,
                                  label: 'Mobile Number',
                                  hint: '9876543210',
                                  errorText: _mobileError,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) {
                                    if (_mobileError != null) {
                                      setState(() => _mobileError = null);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              side: const BorderSide(color: AppColors.glassBorder),
                              onChanged: (value) {
                                setState(() => _acceptedTerms = value ?? false);
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
                          onPressed: authState.isLoading ? null : _sendOtp,
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
                              : const Text('Send OTP'),
                        ),
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
                        const SizedBox(height: AppDimensions.sm),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.push('/dev-email-login'),
                          child: const Text(
                            'Dev: Login with Email OTP (Mailpit)',
                          ),
                        ),
                      ],
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
