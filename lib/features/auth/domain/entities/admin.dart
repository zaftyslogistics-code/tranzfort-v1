class Admin {
  final String id;
  final String role;
  final String? fullName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.id,
    required this.role,
    this.fullName,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isVerificationOfficer => role == 'verification_officer';
  bool get isSupportAgent => role == 'support_agent';
  bool get isAnalyst => role == 'analyst';
}
