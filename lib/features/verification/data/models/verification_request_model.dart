class VerificationRequestModel {
  final String id;
  final String userId;
  final String roleType;
  final String documentType;
  final String? documentNumber;
  final String? documentFrontUrl;
  final String? documentBackUrl;
  final String? companyName;
  final String? vehicleNumber;
  final String status;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.roleType,
    required this.documentType,
    this.documentNumber,
    this.documentFrontUrl,
    this.documentBackUrl,
    this.companyName,
    this.vehicleNumber,
    required this.status,
    this.rejectionReason,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      roleType: json['role_type'] as String,
      documentType: json['document_type'] as String,
      documentNumber: json['document_number'] as String?,
      documentFrontUrl: json['document_front_url'] as String?,
      documentBackUrl: json['document_back_url'] as String?,
      companyName: json['company_name'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      status: (json['status'] as String?) ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role_type': roleType,
      'document_type': documentType,
      'document_number': documentNumber,
      'document_front_url': documentFrontUrl,
      'document_back_url': documentBackUrl,
      'company_name': companyName,
      'vehicle_number': vehicleNumber,
      'status': status,
      'rejection_reason': rejectionReason,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
