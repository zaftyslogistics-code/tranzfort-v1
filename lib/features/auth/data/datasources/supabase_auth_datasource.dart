import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_model.dart';
import '../models/user_model.dart';
import '../../../../core/utils/logger.dart';

import 'auth_datasource.dart';

class SupabaseAuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSourceImpl({required this.supabaseClient});

  String _mobilePlaceholder(String userId) {
    final compact = userId.replaceAll('-', '');
    return compact.length <= 15 ? compact : compact.substring(0, 15);
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
      String email, String password) async {
    try {
      Logger.info('Signing up with email/password: $email');
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Signup failed - no user returned');
      }

      final userId = response.user!.id;

      // Fetch user profile (trigger may take a moment)
      UserModel? userProfile = await _getUserProfile(userId);
      int retries = 3;
      while (userProfile == null && retries > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        userProfile = await _getUserProfile(userId);
        retries--;
      }

      if (userProfile == null) {
        try {
          await supabaseClient.from('users').upsert(
            {
              'id': userId,
              'mobile_number':
                  response.user!.phone ?? _mobilePlaceholder(response.user!.id),
              'country_code':
                  response.user!.userMetadata?['country_code'] ?? '+91',
              'name':
                  response.user!.userMetadata?['name'] ?? response.user!.email,
              'email': response.user!.email,
              'last_login_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'id',
          );
        } catch (e) {
          Logger.error('Failed to create user profile after signup', error: e);
        }

        userProfile = await _getUserProfile(userId);
      }

      if (userProfile != null) return userProfile;

      final createdAt =
          DateTime.tryParse(response.user!.createdAt) ?? DateTime.now();
      return UserModel(
        id: userId,
        mobileNumber: SUBSTRING_PLACEHOLDER,
        countryCode: '+91',
        name: response.user!.userMetadata?['name'] ??
            response.user!.email ??
            'User',
        createdAt: createdAt,
        lastLoginAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      Logger.error('Failed to sign up with email/password', error: e);
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithEmailPassword(
      String email, String password) async {
    try {
      Logger.info('Signing in with email/password: $email');
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed - no user returned');
      }

      final userProfile = await _getUserProfile(response.user!.id);
      if (userProfile != null) return userProfile;

      // If no profile found but user is authenticated, create a basic user model
      final createdAt =
          DateTime.tryParse(response.user!.createdAt) ?? DateTime.now();
      return UserModel(
        id: response.user!.id,
        mobileNumber: SUBSTRING_PLACEHOLDER,
        countryCode: '+91',
        name: response.user!.userMetadata?['name'] ??
            response.user!.email ??
            'User',
        createdAt: createdAt,
        lastLoginAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      Logger.error('Failed to sign in with email/password', error: e);
      rethrow;
    }
  }

  static const String SUBSTRING_PLACEHOLDER = 'user';

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

      // Try to get user profile from database
      final userProfile = await _getUserProfile(userId);
      if (userProfile != null) {
        return userProfile;
      }

      // If no profile found but user is authenticated, create a basic user model
      Logger.info('No user profile found, creating basic user from session');
      final createdAt =
          DateTime.tryParse(session.user.createdAt) ?? DateTime.now();

      return UserModel(
        id: userId,
        mobileNumber: SUBSTRING_PLACEHOLDER,
        countryCode: '+91',
        name:
            session.user.userMetadata?['name'] ?? session.user.email ?? 'User',
        createdAt: createdAt,
        lastLoginAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
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
      Logger.info(
          '🔧 DATASOURCE: Updating profile for user: $userId with updates: $updates');

      // Add updated_at timestamp
      final Map<String, dynamic> updateData = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient.from('users').update(updateData).eq('id', userId);

      // Fetch updated profile; if the row doesn't exist yet, create it and retry.
      var updatedProfile = await _getUserProfile(userId);
      if (updatedProfile == null) {
        final authUser = supabaseClient.auth.currentUser;
        try {
          await supabaseClient.from('users').upsert(
            {
              'id': userId,
              'mobile_number': authUser?.phone ?? _mobilePlaceholder(userId),
              'country_code': authUser?.userMetadata?['country_code'] ?? '+91',
              'name': authUser?.userMetadata?['name'] ?? authUser?.email,
              'email': authUser?.email,
              ...updateData,
            },
            onConflict: 'id',
          );
        } catch (e) {
          Logger.error('Failed to upsert user profile during updateProfile',
              error: e);
        }

        updatedProfile = await _getUserProfile(userId);
      }

      if (updatedProfile == null) {
        throw Exception('Failed to fetch updated profile');
      }

      Logger.info('Profile updated successfully');
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
