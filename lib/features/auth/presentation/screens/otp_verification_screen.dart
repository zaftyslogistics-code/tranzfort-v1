import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/cyan_glow_container.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String mobileNumber;
  final String countryCode;

  const OtpVerificationScreen({
    super.key,
    required this.mobileNumber,
    required this.countryCode,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = AppConfig.otpResendSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = AppConfig.otpResendSeconds;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != AppConfig.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).verifyOtp(
          widget.mobileNumber,
          _otpController.text,
        );

    if (!success && mounted) {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Invalid OTP'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    final success = await ref.read(authNotifierProvider.notifier).sendOtp(
          widget.mobileNumber,
          widget.countryCode,
        );

    if (success && mounted) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
                            Icons.lock_outline,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        GradientText(
                          'Verify OTP',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'Enter the 6-digit code sent to',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${widget.countryCode} ${widget.mobileNumber}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
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
                        PinCodeTextField(
                          appContext: context,
                          length: AppConfig.otpLength,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          textStyle: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                          cursorColor: AppColors.primary,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSm),
                            fieldHeight: 56,
                            fieldWidth: 48,
                            activeFillColor: AppColors.glassSurfaceStrong,
                            selectedFillColor: AppColors.glassSurfaceStrong,
                            inactiveFillColor: AppColors.glassSurface,
                            activeColor: AppColors.primary,
                            selectedColor: AppColors.primary,
                            inactiveColor: AppColors.glassBorder,
                          ),
                          animationDuration:
                              const Duration(milliseconds: 160),
                          enableActiveFill: true,
                          onCompleted: (_) => _verifyOtp(),
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        if (!_canResend)
                          Text(
                            'Resend OTP in $_remainingSeconds seconds',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                            textAlign: TextAlign.center,
                          )
                        else
                          GlassmorphicButton(
                            showGlow: false,
                            onPressed: authState.isLoading ? null : _resendOtp,
                            child: const Text('Resend OTP'),
                          ),
                        const SizedBox(height: AppDimensions.lg),
                        GlassmorphicButton(
                          variant: GlassmorphicButtonVariant.primary,
                          onPressed: authState.isLoading ? null : _verifyOtp,
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
                              : const Text('Verify OTP'),
                        ),
                        if (EnvConfig.useMockAuth) ...[
                          const SizedBox(height: AppDimensions.lg),
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.md),
                            decoration: BoxDecoration(
                              color: AppColors.glassSurface,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: AppDimensions.sm),
                                Expanded(
                                  child: Text(
                                    'MOCK MODE: Enter any 6-digit code to continue',
                                    style:
                                        Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
