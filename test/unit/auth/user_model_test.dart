import 'package:flutter_test/flutter_test.dart';
import 'package:transfort_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final testJson = {
      'id': 'test-user-id',
      'mobile_number': '9876543210',
      'country_code': '+91',
      'name': 'Test User',
      'is_supplier_enabled': true,
      'is_trucker_enabled': false,
      'supplier_verification_status': 'verified',
      'trucker_verification_status': 'unverified',
      'created_at': '2026-01-18T10:00:00.000Z',
      'updated_at': '2026-01-18T10:00:00.000Z',
      'last_login_at': '2026-01-18T10:00:00.000Z',
    };

    test('fromJson creates UserModel from JSON', () {
      final userModel = UserModel.fromJson(testJson);

      expect(userModel.id, 'test-user-id');
      expect(userModel.mobileNumber, '9876543210');
      expect(userModel.countryCode, '+91');
      expect(userModel.name, 'Test User');
      expect(userModel.isSupplierEnabled, true);
      expect(userModel.isTruckerEnabled, false);
      expect(userModel.supplierVerificationStatus, 'verified');
      expect(userModel.truckerVerificationStatus, 'unverified');
    });

    test('toJson converts UserModel to JSON', () {
      final userModel = UserModel(
        id: 'test-user-id',
        mobileNumber: '9876543210',
        countryCode: '+91',
        name: 'Test User',
        isSupplierEnabled: true,
        isTruckerEnabled: false,
        supplierVerificationStatus: 'verified',
        truckerVerificationStatus: 'unverified',
        createdAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        lastLoginAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      final json = userModel.toJson();

      expect(json['id'], 'test-user-id');
      expect(json['mobile_number'], '9876543210');
      expect(json['country_code'], '+91');
      expect(json['name'], 'Test User');
      expect(json['is_supplier_enabled'], true);
      expect(json['is_trucker_enabled'], false);
    });

    test('UserModel properties are accessible', () {
      final userModel = UserModel(
        id: 'test-user-id',
        mobileNumber: '9876543210',
        countryCode: '+91',
        name: 'Test User',
        isSupplierEnabled: true,
        isTruckerEnabled: false,
        supplierVerificationStatus: 'verified',
        truckerVerificationStatus: 'unverified',
        createdAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        lastLoginAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      expect(userModel.id, 'test-user-id');
      expect(userModel.mobileNumber, '9876543210');
      expect(userModel.isSupplierEnabled, true);
      expect(userModel.isTruckerEnabled, false);
      expect(userModel.supplierVerificationStatus, 'verified');
      expect(userModel.truckerVerificationStatus, 'unverified');
    });

    test('handles null optional fields', () {
      final jsonWithNulls = {
        'id': 'test-user-id',
        'mobile_number': '9876543210',
        'country_code': '+91',
        'name': null,
        'is_supplier_enabled': false,
        'is_trucker_enabled': false,
        'supplier_verification_status': 'unverified',
        'trucker_verification_status': 'unverified',
        'created_at': '2026-01-18T10:00:00.000Z',
        'updated_at': '2026-01-18T10:00:00.000Z',
        'last_login_at': '2026-01-18T10:00:00.000Z',
      };

      final userModel = UserModel.fromJson(jsonWithNulls);

      expect(userModel.name, null);
      expect(userModel.isSupplierEnabled, false);
      expect(userModel.isTruckerEnabled, false);
    });
  });
}
