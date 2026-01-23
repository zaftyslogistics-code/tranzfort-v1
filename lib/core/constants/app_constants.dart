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
    'negotiation',
    'booked',
    'completed',
    'expired',
  ];

  static const List<String> chatStatuses = [
    'active',
    'locked',
  ];

  static const List<String> offerStatuses = [
    'proposed',
    'countered',
    'rejected',
    'accepted',
    'expired',
  ];

  static const List<String> rcShareStatuses = [
    'not_requested',
    'requested',
    'approved',
    'revoked',
  ];

  static const List<String> paymentStatuses = [
    'pending',
    'success',
    'failed',
    'refunded',
  ];
}
