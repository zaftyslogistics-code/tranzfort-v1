import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';

class DevEmailOtpScreen extends ConsumerStatefulWidget {
  final String email;

  const DevEmailOtpScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<DevEmailOtpScreen> createState() => _DevEmailOtpScreenState();
}

class _DevEmailOtpScreenState extends ConsumerState<DevEmailOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _otpController.text.trim();
    if (token.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the OTP from Mailpit')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: token,
        type: OtpType.email,
      );

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email OTP')),
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
                      'Enter OTP',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Sent to ${widget.email}\n\nOpen Mailpit: http://127.0.0.1:54324',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    TextField(
                      controller: _otpController,
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        hintText: '6-digit code',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    GlassmorphicButton(
                      variant: GlassmorphicButtonVariant.primary,
                      onPressed: _isLoading ? null : _verify,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify'),
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
