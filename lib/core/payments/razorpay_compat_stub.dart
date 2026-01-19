class Razorpay {
  static const String EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const String EVENT_PAYMENT_ERROR = 'payment.error';
  static const String EVENT_EXTERNAL_WALLET = 'payment.external_wallet';

  void on(String event, Function handler) {}

  void open(Map<String, dynamic> options) {
    throw UnsupportedError('Razorpay is not supported on this platform');
  }

  void clear() {}
}

class PaymentSuccessResponse {
  final String? paymentId;
  final String? orderId;

  PaymentSuccessResponse({this.paymentId, this.orderId});
}

class PaymentFailureResponse {
  final String? message;

  PaymentFailureResponse({this.message});
}

class ExternalWalletResponse {
  final String? walletName;

  ExternalWalletResponse({this.walletName});
}
