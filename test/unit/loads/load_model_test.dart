import 'package:flutter_test/flutter_test.dart';
import 'package:transfort_app/features/loads/data/models/load_model.dart';

void main() {
  group('LoadModel', () {
    final testJson = {
      'id': 'load-123',
      'supplier_id': 'user-456',
      'from_location': 'Mumbai, Maharashtra',
      'from_city': 'Mumbai',
      'from_state': 'Maharashtra',
      'to_location': 'Delhi, Delhi',
      'to_city': 'Delhi',
      'to_state': 'Delhi',
      'load_type': 'Electronics',
      'truck_type_required': 'Container 20ft',
      'weight': 15.5,
      'price': 50000.0,
      'price_type': 'Fixed',
      'payment_terms': 'Advance 50%',
      'loading_date': '2026-01-25T00:00:00.000Z',
      'notes': 'Handle with care',
      'contact_preferences_call': true,
      'contact_preferences_chat': true,
      'status': 'active',
      'expires_at': '2026-04-25T10:00:00.000Z',
      'view_count': 10,
      'created_at': '2026-01-18T10:00:00.000Z',
      'updated_at': '2026-01-18T10:00:00.000Z',
    };

    test('fromJson creates LoadModel from JSON', () {
      final loadModel = LoadModel.fromJson(testJson);

      expect(loadModel.id, 'load-123');
      expect(loadModel.supplierId, 'user-456');
      expect(loadModel.fromCity, 'Mumbai');
      expect(loadModel.toCity, 'Delhi');
      expect(loadModel.loadType, 'Electronics');
      expect(loadModel.truckTypeRequired, 'Container 20ft');
      expect(loadModel.weight, 15.5);
      expect(loadModel.price, 50000.0);
      expect(loadModel.status, 'active');
      expect(loadModel.viewCount, 10);
    });

    test('toJson converts LoadModel to JSON', () {
      final loadModel = LoadModel(
        id: 'load-123',
        supplierId: 'user-456',
        fromLocation: 'Mumbai, Maharashtra',
        fromCity: 'Mumbai',
        fromState: 'Maharashtra',
        toLocation: 'Delhi, Delhi',
        toCity: 'Delhi',
        toState: 'Delhi',
        loadType: 'Electronics',
        truckTypeRequired: 'Container 20ft',
        weight: 15.5,
        price: 50000.0,
        priceType: 'Fixed',
        paymentTerms: 'Advance 50%',
        loadingDate: DateTime.parse('2026-01-25'),
        notes: 'Handle with care',
        contactPreferencesCall: true,
        contactPreferencesChat: true,
        status: 'active',
        expiresAt: DateTime.parse('2026-04-25T10:00:00.000Z'),
        viewCount: 10,
        createdAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      final json = loadModel.toJson();

      expect(json['id'], 'load-123');
      expect(json['from_city'], 'Mumbai');
      expect(json['to_city'], 'Delhi');
      expect(json['load_type'], 'Electronics');
      expect(json['truck_type_required'], 'Container 20ft');
      expect(json['weight'], 15.5);
      expect(json['price'], 50000.0);
    });

    test('LoadModel properties are accessible', () {
      final loadModel = LoadModel(
        id: 'load-123',
        supplierId: 'user-456',
        fromLocation: 'Mumbai, Maharashtra',
        fromCity: 'Mumbai',
        fromState: 'Maharashtra',
        toLocation: 'Delhi, Delhi',
        toCity: 'Delhi',
        toState: 'Delhi',
        loadType: 'Electronics',
        truckTypeRequired: 'Container 20ft',
        weight: 15.5,
        price: 50000.0,
        priceType: 'Fixed',
        paymentTerms: 'Advance 50%',
        loadingDate: DateTime.parse('2026-01-25'),
        notes: 'Handle with care',
        contactPreferencesCall: true,
        contactPreferencesChat: true,
        status: 'active',
        expiresAt: DateTime.parse('2026-04-25T10:00:00.000Z'),
        viewCount: 10,
        createdAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-18T10:00:00.000Z'),
      );

      expect(loadModel.id, 'load-123');
      expect(loadModel.fromCity, 'Mumbai');
      expect(loadModel.toCity, 'Delhi');
      expect(loadModel.status, 'active');
      expect(loadModel.viewCount, 10);
    });

    test('handles null optional fields', () {
      final jsonWithNulls = {
        'id': 'load-123',
        'supplier_id': 'user-456',
        'from_location': 'Mumbai, Maharashtra',
        'from_city': 'Mumbai',
        'from_state': null,
        'to_location': 'Delhi, Delhi',
        'to_city': 'Delhi',
        'to_state': null,
        'load_type': 'Electronics',
        'truck_type_required': 'Container 20ft',
        'weight': null,
        'price': null,
        'price_type': 'Fixed',
        'payment_terms': null,
        'loading_date': null,
        'notes': null,
        'contact_preferences_call': true,
        'contact_preferences_chat': true,
        'status': 'active',
        'expires_at': '2026-04-25T10:00:00.000Z',
        'view_count': 0,
        'created_at': '2026-01-18T10:00:00.000Z',
        'updated_at': '2026-01-18T10:00:00.000Z',
      };

      final loadModel = LoadModel.fromJson(jsonWithNulls);

      expect(loadModel.weight, null);
      expect(loadModel.price, null);
      expect(loadModel.notes, null);
    });
  });
}
