/// Standardized error messages for the application
/// Provides user-friendly messages for common errors
class ErrorMessages {
  // Authentication errors
  static const String authInvalidCredentials = 'Invalid email or password. Please try again.';
  static const String authEmailAlreadyExists = 'An account with this email already exists.';
  static const String authWeakPassword = 'Password is too weak. Please use a stronger password.';
  static const String authNetworkError = 'Network error. Please check your connection and try again.';
  static const String authSessionExpired = 'Your session has expired. Please log in again.';
  static const String authUnauthorized = 'You are not authorized to perform this action.';

  // Network errors
  static const String networkTimeout = 'Request timed out. Please check your connection.';
  static const String networkNoInternet = 'No internet connection. Please check your network.';
  static const String networkServerError = 'Server error. Please try again later.';

  // Data errors
  static const String dataNotFound = 'The requested data was not found.';
  static const String dataLoadFailed = 'Failed to load data. Please try again.';
  static const String dataSaveFailed = 'Failed to save data. Please try again.';
  static const String dataDeleteFailed = 'Failed to delete. Please try again.';
  static const String dataUpdateFailed = 'Failed to update. Please try again.';

  // Validation errors
  static const String validationRequired = 'This field is required.';
  static const String validationInvalidEmail = 'Please enter a valid email address.';
  static const String validationInvalidPhone = 'Please enter a valid phone number.';
  static const String validationPasswordMismatch = 'Passwords do not match.';
  static const String validationInvalidInput = 'Invalid input. Please check and try again.';

  // File upload errors
  static const String uploadFailed = 'File upload failed. Please try again.';
  static const String uploadTooLarge = 'File is too large. Maximum size is 5MB.';
  static const String uploadInvalidFormat = 'Invalid file format. Please use a supported format.';

  // Feature-specific errors
  static const String loadPostFailed = 'Failed to post load. Please try again.';
  static const String chatSendFailed = 'Failed to send message. Please try again.';
  static const String verificationFailed = 'Verification failed. Please try again.';
  static const String truckAddFailed = 'Failed to add truck. Please try again.';
  static const String truckUpdateFailed = 'Failed to update truck. Please try again.';
  static const String truckDeleteFailed = 'Failed to delete truck. Please try again.';

  // Generic errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String unknownError = 'An unexpected error occurred. Please contact support if this persists.';

  /// Convert technical error to user-friendly message
  static String getUserFriendlyMessage(String technicalError) {
    final error = technicalError.toLowerCase();

    // Authentication errors
    if (error.contains('invalid_grant') || error.contains('invalid credentials')) {
      return authInvalidCredentials;
    }
    if (error.contains('email already exists') || error.contains('duplicate')) {
      return authEmailAlreadyExists;
    }
    if (error.contains('weak password')) {
      return authWeakPassword;
    }
    if (error.contains('session') || error.contains('expired')) {
      return authSessionExpired;
    }
    if (error.contains('unauthorized') || error.contains('permission denied')) {
      return authUnauthorized;
    }

    // Network errors
    if (error.contains('timeout')) {
      return networkTimeout;
    }
    if (error.contains('network') || error.contains('connection')) {
      return networkNoInternet;
    }
    if (error.contains('500') || error.contains('502') || error.contains('503')) {
      return networkServerError;
    }

    // Data errors
    if (error.contains('not found') || error.contains('404')) {
      return dataNotFound;
    }

    // Validation errors
    if (error.contains('violates not-null constraint') || error.contains('required')) {
      return validationRequired;
    }
    if (error.contains('invalid email')) {
      return validationInvalidEmail;
    }

    // File upload errors
    if (error.contains('file too large') || error.contains('size')) {
      return uploadTooLarge;
    }
    if (error.contains('invalid format') || error.contains('unsupported')) {
      return uploadInvalidFormat;
    }

    // Default to generic error
    return genericError;
  }

  /// Get error message with context
  static String getContextualError(String operation, String? technicalError) {
    if (technicalError == null || technicalError.isEmpty) {
      return 'Failed to $operation. Please try again.';
    }
    return getUserFriendlyMessage(technicalError);
  }
}
