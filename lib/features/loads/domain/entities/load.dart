import 'package:equatable/equatable.dart';

class Load extends Equatable {
  final String id;
  final String supplierId;
  final String fromLocation;
  final String fromCity;
  final String? fromState;
  final String toLocation;
  final String toCity;
  final String? toState;
  final String loadType;
  final String truckTypeRequired;
  final double? weight;
  final double? price;
  final String priceType;
  final String? paymentTerms;
  final DateTime? loadingDate;
  final String? notes;
  final bool contactPreferencesCall;
  final bool contactPreferencesChat;
  final String status;
  final DateTime expiresAt;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Load({
    required this.id,
    required this.supplierId,
    required this.fromLocation,
    required this.fromCity,
    this.fromState,
    required this.toLocation,
    required this.toCity,
    this.toState,
    required this.loadType,
    required this.truckTypeRequired,
    this.weight,
    this.price,
    required this.priceType,
    this.paymentTerms,
    this.loadingDate,
    this.notes,
    required this.contactPreferencesCall,
    required this.contactPreferencesChat,
    required this.status,
    required this.expiresAt,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active' && !isExpired;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get hasPrice => price != null && price! > 0;
  bool get hasWeight => weight != null && weight! > 0;
  
  String get fromLocationDisplay => fromState != null 
      ? '$fromCity, $fromState' 
      : fromCity;
  
  String get toLocationDisplay => toState != null 
      ? '$toCity, $toState' 
      : toCity;

  factory Load.fromJson(Map<String, dynamic> json) {
    return Load(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      fromLocation: json['from_location'] as String,
      fromCity: json['from_city'] as String,
      fromState: json['from_state'] as String?,
      toLocation: json['to_location'] as String,
      toCity: json['to_city'] as String,
      toState: json['to_state'] as String?,
      loadType: json['load_type'] as String,
      truckTypeRequired: json['truck_type_required'] as String,
      weight: json['weight'] as double?,
      price: json['price'] as double?,
      priceType: json['price_type'] as String,
      paymentTerms: json['payment_terms'] as String?,
      loadingDate: json['loading_date'] != null 
          ? DateTime.parse(json['loading_date'] as String) 
          : null,
      notes: json['notes'] as String?,
      contactPreferencesCall: json['contact_preferences_call'] as bool,
      contactPreferencesChat: json['contact_preferences_chat'] as bool,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      viewCount: json['view_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'from_location': fromLocation,
      'from_city': fromCity,
      'from_state': fromState,
      'to_location': toLocation,
      'to_city': toCity,
      'to_state': toState,
      'load_type': loadType,
      'truck_type_required': truckTypeRequired,
      'weight': weight,
      'price': price,
      'price_type': priceType,
      'payment_terms': paymentTerms,
      'loading_date': loadingDate?.toIso8601String(),
      'notes': notes,
      'contact_preferences_call': contactPreferencesCall,
      'contact_preferences_chat': contactPreferencesChat,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        supplierId,
        fromLocation,
        fromCity,
        fromState,
        toLocation,
        toCity,
        toState,
        loadType,
        truckTypeRequired,
        weight,
        price,
        priceType,
        paymentTerms,
        loadingDate,
        notes,
        contactPreferencesCall,
        contactPreferencesChat,
        status,
        expiresAt,
        viewCount,
        createdAt,
        updatedAt,
      ];
}
