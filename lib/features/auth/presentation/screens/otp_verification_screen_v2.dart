import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../providers/auth_provider.dart';

/// OTP Verification Screen v0.02
/// - 6-digit input boxes
/// - Resend button with cooldown
/// - Flat design
class OtpVerificationScreenV2 extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreenV2({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreenV2> createState() => _OtpVerificationScreenV2State();
}

class _OtpVerificationScreenV2State extends ConsumerState<OtpVerificationScreenV2> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  String? _errorMessage;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      setState(() => _errorMessage = 'Please enter complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(authNotifierProvider.notifier)
        .verifyOtp(widget.phoneNumber, _otp);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      final error = ref.read(authNotifierProvider).error;
      setState(() => _errorMessage = error ?? 'Invalid OTP');
      return;
    }

    if (mounted) {
      context.go('/intent-selection');
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;

    setState(() => _errorMessage = null);

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resendOtp(widget.phoneNumber);

    if (!mounted) return;

    if (success) {
      _startResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );
    } else {
      final error = ref.read(authNotifierProvider).error;
      setState(() => _errorMessage = error ?? 'Failed to resend OTP');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 32),

              // 6-digit OTP input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Auto-verify when all 6 digits entered
                        if (index == 5 && value.isNotEmpty) {
                          _verifyOtp();
                        }
                      },
                    ),
                  );
                }),
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

              // Verify Button
              PrimaryButton(
                text: 'Verify',
                onPressed: _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  if (_resendCooldown > 0)
                    Text(
                      'Resend in ${_resendCooldown}s',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _resendOtp,
                      child: const Text(
                        'Resend',
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
    );
  }
}
