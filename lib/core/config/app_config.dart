class AppConfig {
  static const String appName = 'Transfort';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Transport Open Market';

  static const int otpLength = 6;
  static const int otpExpirySeconds = 300;
  static const int otpResendSeconds = 60;

  static const int loadExpiryDays = 90;
  static const int maxFileUploadSizeMB = 5;
  static const int chatMessageMaxLength = 1000;
  static const int paginationLimit = 20;

  static const String defaultCountryCode = '+91';

  static const int nativeAdFrequency = 6;
  static const int maxAdsPerSession = 20;
}
