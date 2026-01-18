class VerificationPaymentModel {
  final String id;
  final String userId;
  final String? verificationRequestId;
  final String roleType;
  final double amount;
  final String currency;
  final String paymentGateway;
  final String? paymentGatewayOrderId;
  final String? paymentGatewayPaymentId;
  final String paymentStatus;
  final String? paymentMethod;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VerificationPaymentModel({
    required this.id,
    required this.userId,
    this.verificationRequestId,
    required this.roleType,
    required this.amount,
    required this.currency,
    required this.paymentGateway,
    this.paymentGatewayOrderId,
    this.paymentGatewayPaymentId,
    required this.paymentStatus,
    this.paymentMethod,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationPaymentModel.fromJson(Map<String, dynamic> json) {
    return VerificationPaymentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      verificationRequestId: json['verification_request_id'] as String?,
      roleType: json['role_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: (json['currency'] as String?) ?? 'INR',
      paymentGateway: (json['payment_gateway'] as String?) ?? 'razorpay',
      paymentGatewayOrderId: json['payment_gateway_order_id'] as String?,
      paymentGatewayPaymentId: json['payment_gateway_payment_id'] as String?,
      paymentStatus: (json['payment_status'] as String?) ?? 'pending',
      paymentMethod: json['payment_method'] as String?,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'verification_request_id': verificationRequestId,
      'role_type': roleType,
      'amount': amount,
      'currency': currency,
      'payment_gateway': paymentGateway,
      'payment_gateway_order_id': paymentGatewayOrderId,
      'payment_gateway_payment_id': paymentGatewayPaymentId,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
