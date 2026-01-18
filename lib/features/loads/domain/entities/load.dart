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
