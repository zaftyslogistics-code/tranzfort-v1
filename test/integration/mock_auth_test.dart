import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfort_app/features/auth/data/datasources/mock_auth_datasource.dart';
import 'package:transfort_app/features/auth/data/models/user_model.dart';

void main() {
  group('Mock Auth Tests', () {
    late MockAuthDataSource mockAuth;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      mockAuth = MockAuthDataSource(prefs);
    });

    test('should update user profile correctly', () async {
      // First create a user
      final user = await mockAuth.verifyOtp('9876543210', '123456');
      
      // Verify initial state
      expect(user.isSupplierEnabled, false);
      expect(user.isTruckerEnabled, false);
      
      // Update profile to enable supplier
      final updatedUser = await mockAuth.updateProfile(
        user.id,
        {'isSupplierEnabled': true},
      );
      
      // Verify update
      expect(updatedUser.isSupplierEnabled, true);
      expect(updatedUser.isTruckerEnabled, false);
      
      // Verify getCurrentUser returns updated user
      final currentUser = await mockAuth.getCurrentUser();
      expect(currentUser?.isSupplierEnabled, true);
      expect(currentUser?.isTruckerEnabled, false);
    });

    test('should update user profile to trucker', () async {
      // First create a user
      final user = await mockAuth.verifyOtp('9876543210', '123456');
      
      // Update profile to enable trucker
      final updatedUser = await mockAuth.updateProfile(
        user.id,
        {'isTruckerEnabled': true},
      );
      
      // Verify update
      expect(updatedUser.isSupplierEnabled, false);
      expect(updatedUser.isTruckerEnabled, true);
      
      // Verify getCurrentUser returns updated user
      final currentUser = await mockAuth.getCurrentUser();
      expect(currentUser?.isSupplierEnabled, false);
      expect(currentUser?.isTruckerEnabled, true);
    });
  });
}
