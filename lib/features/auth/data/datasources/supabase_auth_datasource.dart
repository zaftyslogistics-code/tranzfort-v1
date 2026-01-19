import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_model.dart';
import '../models/user_model.dart';
import '../../../../core/utils/logger.dart';

import '../datasources/mock_auth_datasource.dart';

class SupabaseAuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> sendOtp(String mobileNumber, String countryCode) async {
    try {
      final phone = '$countryCode$mobileNumber';
      Logger.info('Sending OTP to: $phone');

      await supabaseClient.auth.signInWithOtp(
        phone: phone,
      );

      Logger.info('OTP sent successfully');
    } catch (e) {
      Logger.error('Failed to send OTP', error: e);
      rethrow;
    }
  }

  @override
  Future<UserModel> verifyOtp(String mobileNumber, String otp) async {
    // Extract country code from stored session or default to +91
    const countryCode = '+91';
    try {
      final phone = '$countryCode$mobileNumber';
      Logger.info('Verifying OTP for: $phone');

      final response = await supabaseClient.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user == null) {
        throw Exception('OTP verification failed - no user returned');
      }

      Logger.info('OTP verified successfully, user ID: ${response.user!.id}');

      // Fetch user profile
      UserModel? userProfile = await _getUserProfile(response.user!.id);
      
      // If profile not found immediately, retry a few times to allow DB trigger to complete
      int retries = 3;
      while (userProfile == null && retries > 0) {
        Logger.info('User profile not found, retrying... ($retries retries left)');
        await Future.delayed(const Duration(milliseconds: 500));
        userProfile = await _getUserProfile(response.user!.id);
        retries--;
      }

      if (userProfile == null) {
        throw Exception('User profile could not be found. Please contact support.');
      }

      return userProfile;
    } catch (e) {
      Logger.error('Failed to verify OTP', error: e);
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        Logger.info('No active session');
        return null;
      }

      final userId = session.user.id;
      Logger.info('Fetching current user profile: $userId');

      final userProfile = await _getUserProfile(userId);
      return userProfile;
    } catch (e) {
      Logger.error('Failed to get current user', error: e);
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      Logger.info('Updating profile for user: $userId');

      final updateData = <String, dynamic>{
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient
          .from('users')
          .update(updateData)
          .eq('id', userId);

      Logger.info('Profile updated successfully');

      // Fetch and return updated profile
      final updatedProfile = await _getUserProfile(userId);
      if (updatedProfile == null) {
        throw Exception('Failed to fetch updated profile');
      }
      return updatedProfile;
    } catch (e) {
      Logger.error('Failed to update profile', error: e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      Logger.info('Signing out user');
      await supabaseClient.auth.signOut();
      Logger.info('User signed out successfully');
    } catch (e) {
      Logger.error('Failed to sign out', error: e);
      rethrow;
    }
  }

  @override
  Future<AdminModel?> getAdminProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('admin_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return AdminModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to fetch admin profile', error: e);
      return null;
    }
  }
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to fetch user profile', error: e);
      return null;
    }
  }
}
