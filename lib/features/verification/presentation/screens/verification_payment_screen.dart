import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/payments/razorpay_compat.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import 'verification_success_screen.dart';

class VerificationPaymentScreen extends ConsumerStatefulWidget {
  final String roleType;
  final String verificationRequestId;

  const VerificationPaymentScreen({
    super.key,
    required this.roleType,
    required this.verificationRequestId,
  });

  @override
  ConsumerState<VerificationPaymentScreen> createState() =>
      _VerificationPaymentScreenState();
}

class _VerificationPaymentScreenState
    extends ConsumerState<VerificationPaymentScreen> {
  late final Razorpay _razorpay;
  bool _isCreatingPayment = false;
  String? _paymentRowId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onSuccess(PaymentSuccessResponse response) {
    _updatePayment(
      status: 'success',
      paymentId: response.paymentId,
      orderId: response.orderId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment success: ${response.paymentId ?? ''}'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationSuccessScreen(
          roleType: widget.roleType,
          verificationRequestId: widget.verificationRequestId,
        ),
      ),
    );
  }

  void _onError(PaymentFailureResponse response) {
    _updatePayment(
      status: 'failed',
      paymentId: null,
      orderId: null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? ''}'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet: ${response.walletName ?? ''}'),
      ),
    );
  }

  Future<void> _createPaymentRowIfNeeded() async {
    if (_paymentRowId != null) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception(
          'No Supabase session found. Use Dev Email OTP login to create a payment record.');
    }

    final inserted = await supabase
        .from('verification_payments')
        .insert({
          'user_id': user.id,
          'verification_request_id': widget.verificationRequestId,
          'role_type': widget.roleType,
          'amount': 499.0,
          'currency': 'INR',
          'payment_gateway': 'razorpay',
          'payment_status': 'pending',
        })
        .select('id')
        .single();

    _paymentRowId = inserted['id'] as String;
  }

  Future<void> _updatePayment({
    required String status,
    String? paymentId,
    String? orderId,
  }) async {
    try {
      if (_paymentRowId == null) return;

      final supabase = Supabase.instance.client;
      await supabase.from('verification_payments').update({
        'payment_status': status,
        'payment_gateway_payment_id': paymentId,
        'payment_gateway_order_id': orderId,
        if (status == 'success') 'paid_at': DateTime.now().toIso8601String(),
      }).eq('id', _paymentRowId!);
    } catch (_) {
      // Best-effort update; UI can proceed.
    }
  }

  Future<void> _startPayment() async {
    final keyId = EnvConfig.razorpayKeyId;
    if (keyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing RAZORPAY_KEY_ID in .env.local'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isCreatingPayment = true);

    try {
      await _createPaymentRowIfNeeded();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
      setState(() => _isCreatingPayment = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isCreatingPayment = false);

    // NOTE: This is a dev stub. Proper flow should create an Order via Edge Function.
    final options = {
      'key': keyId,
      'amount': 49900, // ₹499 in paise
      'currency': 'INR',
      'name': 'Transfort',
      'description': 'Verification Fee',
      'notes': {
        'role_type': widget.roleType,
        'verification_request_id': widget.verificationRequestId,
        'payment_row_id': _paymentRowId,
      },
    };

    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
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
                      'Pay to Verify',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'One-time verification fee to unlock contact features.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    GlassmorphicButton(
                      variant: GlassmorphicButtonVariant.primary,
                      onPressed: _isCreatingPayment ? null : _startPayment,
                      child: _isCreatingPayment
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Pay ₹499'),
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
