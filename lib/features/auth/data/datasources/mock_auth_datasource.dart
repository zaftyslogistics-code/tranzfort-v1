import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/admin_model.dart';

abstract class AuthDataSource {
  Future<void> sendOtp(String mobileNumber, String countryCode);
  Future<UserModel> verifyOtp(String mobileNumber, String otp);
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> updates);
  Future<AdminModel?> getAdminProfile(String userId);
}

class MockAuthDataSource implements AuthDataSource {
  final SharedPreferences prefs;
  final Uuid uuid = const Uuid();

  MockAuthDataSource(this.prefs);

  // Clear all mock authentication data for testing
  Future<void> clearMockData() async {
    try {
      await prefs.remove('current_user_id');
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('user_')) {
          await prefs.remove(key);
        }
      }
      Logger.info('🧹 MOCK: Cleared all mock auth data');
    } catch (e) {
      Logger.error('Error clearing mock auth data', error: e);
    }
  }

  @override
  Future<void> sendOtp(String mobileNumber, String countryCode) async {
    Logger.info('📱 MOCK: Sending OTP to $countryCode$mobileNumber');
    Logger.info('🔐 MOCK: OTP Code is: 123456 (accept any 6-digit code)');
    
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserModel> verifyOtp(String mobileNumber, String otp) async {
    Logger.info('✅ MOCK: Verifying OTP $otp for $mobileNumber');
    
    if (otp.length != 6) {
      throw Exception('Invalid OTP length');
    }

    await Future.delayed(const Duration(seconds: 1));

    final existingUserJson = prefs.getString('user_$mobileNumber');
    
    if (existingUserJson != null && existingUserJson.isNotEmpty) {
      try {
        final user = UserModel.fromJson(jsonDecode(existingUserJson));
        final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
        await _saveUser(updatedUser);
        await prefs.setString('current_user_id', updatedUser.id);
        Logger.info('👤 MOCK: Existing user logged in: ${updatedUser.id}');
        return updatedUser;
      } catch (e) {
        Logger.error('Error parsing existing user', error: e);
        // Continue to create new user if parsing fails
      }
    }
    
    // Create new user
    final newUser = UserModel(
      id: uuid.v4(),
      mobileNumber: mobileNumber,
      countryCode: '+91',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _saveUser(newUser);
    await prefs.setString('current_user_id', newUser.id);
    Logger.info('🆕 MOCK: New user created: ${newUser.id}');
    return newUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userId = prefs.getString('current_user_id');
    if (userId == null || userId.isEmpty) {
      Logger.info('❌ MOCK: No current user');
      return null;
    }

    // First try to find user by mobile number (most reliable)
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('user_')) {
        final userJson = prefs.getString(key);
        if (userJson != null && userJson.isNotEmpty) {
          try {
            final user = UserModel.fromJson(jsonDecode(userJson));
            // Check both ID and mobile number for robustness
            if (user.id == userId) {
              Logger.info('👤 MOCK: Current user found by ID: ${user.id}');
              return user;
            }
          } catch (e) {
            Logger.error('Error parsing user from JSON', error: e);
            // Continue searching
          }
        }
      }
    }

    Logger.info('❌ MOCK: User not found for ID: $userId');
    return null;
  }

  @override
  Future<void> signOut() async {
    final currentUserId = await prefs.getString('current_user_id');
    if (currentUserId != null) {
      // Find and clear the user's intent selection
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('user_')) {
          final userJson = prefs.getString(key);
          if (userJson != null) {
            final userMap = jsonDecode(userJson) as Map<String, dynamic>;
            if (userMap['id'] == currentUserId) {
              // Clear intent selection but keep other user data
              userMap['isSupplierEnabled'] = false;
              userMap['isTruckerEnabled'] = false;
              await prefs.setString(key, jsonEncode(userMap));
              Logger.info('🔄 MOCK: Cleared intent selection for user $currentUserId');
              break;
            }
          }
        }
      }
    }
    
    await prefs.remove('current_user_id');
    Logger.info('👋 MOCK: User signed out');
  }

  @override
  Future<UserModel> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    Logger.info('📝 MOCK: Updating profile for $userId: $updates');
    
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('User not found');
    }

    Logger.info('📝 MOCK: Current user before update - Supplier: ${currentUser.isSupplierEnabled}, Trucker: ${currentUser.isTruckerEnabled}');

    // Create updated user with proper field mapping
    UserModel updatedUser;
    if (updates.containsKey('isSupplierEnabled')) {
      updatedUser = currentUser.copyWith(
        isSupplierEnabled: updates['isSupplierEnabled'],
        updatedAt: DateTime.now(),
      );
    } else if (updates.containsKey('isTruckerEnabled')) {
      updatedUser = currentUser.copyWith(
        isTruckerEnabled: updates['isTruckerEnabled'],
        updatedAt: DateTime.now(),
      );
    } else {
      // For other updates, use the JSON method
      final updatedUserJson = {
        ...currentUser.toJson(),
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };
      updatedUser = UserModel.fromJson(updatedUserJson);
    }

    await _saveUser(updatedUser);
    
    // Ensure current_user_id is still set
    await prefs.setString('current_user_id', updatedUser.id);
    
    Logger.info('✅ MOCK: Profile updated successfully - Supplier: ${updatedUser.isSupplierEnabled}, Trucker: ${updatedUser.isTruckerEnabled}');
    return updatedUser;
  }

  @override
  Future<AdminModel?> getAdminProfile(String userId) async {
    // Mock auth should NEVER create admin profiles for mobile users
    // Only real Supabase admin users should have admin profiles
    Logger.info('❌ MOCK: Admin profiles not available in mock auth');
    return null;
  }

  Future<void> _saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await prefs.setString('user_${user.mobileNumber}', userJson);
  }
}
