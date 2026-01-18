class AppConstants {
  static const String termsUrl = 'https://transfort.app/terms';
  static const String privacyUrl = 'https://transfort.app/privacy';
  static const String supportEmail = 'support@transfort.app';

  static const List<String> verificationStatuses = [
    'unverified',
    'pending',
    'verified',
    'rejected',
  ];

  static const List<String> loadStatuses = [
    'active',
    'expired',
    'closed',
  ];

  static const List<String> chatStatuses = [
    'active',
    'locked',
  ];

  static const List<String> paymentStatuses = [
    'pending',
    'success',
    'failed',
    'refunded',
  ];
}
