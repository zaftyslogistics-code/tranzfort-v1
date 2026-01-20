import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/verification_request_model.dart';

class MockVerificationDataSource {
  static const String _bucketId = 'verification-documents';

  Future<VerificationRequestModel> createVerificationRequest({
    required String roleType,
    required String documentType,
    String? documentNumber,
    String? companyName,
    String? vehicleNumber,
    required XFile front,
    required XFile back,
  }) async {
    Logger.info('📋 MOCK: Creating verification request for $roleType');
    
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate a mock verification request ID
      final requestId = 'mock_verification_${DateTime.now().millisecondsSinceEpoch}';
      
      // Mock file upload simulation
      Logger.info('📤 MOCK: Uploading front document for $roleType');
      await Future.delayed(const Duration(seconds: 1));
      
      Logger.info('📤 MOCK: Uploading back document for $roleType');
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock verification request
      final verificationRequest = VerificationRequestModel(
        id: requestId,
        userId: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        roleType: roleType,
        documentType: documentType,
        documentNumber: documentNumber ?? 'MOCK_${DateTime.now().millisecondsSinceEpoch}',
        companyName: companyName,
        vehicleNumber: vehicleNumber,
        documentFrontUrl: 'https://mock-storage.example.com/verification-documents/$requestId/front.jpg',
        documentBackUrl: 'https://mock-storage.example.com/verification-documents/$requestId/back.jpg',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      Logger.info('✅ MOCK: Verification request created successfully: $requestId');
      return verificationRequest;
      
    } catch (e) {
      Logger.error('❌ MOCK: Error creating verification request: $e');
      throw ServerException('Mock verification request failed: $e');
    }
  }

  Future<List<VerificationRequestModel>> getPendingVerificationRequests() async {
    Logger.info('📋 MOCK: Getting pending verification requests');
    
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Return empty list for mock (no pending requests)
      Logger.info('✅ MOCK: No pending verification requests found');
      return [];
      
    } catch (e) {
      Logger.error('❌ MOCK: Error getting pending verification requests: $e');
      throw ServerException('Mock get pending requests failed: $e');
    }
  }

  Future<VerificationRequestModel> updateVerificationStatus({
    required String requestId,
    required String status,
    String? adminNotes,
  }) async {
    Logger.info('📋 MOCK: Updating verification status for $requestId to $status');
    
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 1));
      
      // Create updated verification request
      final updatedRequest = VerificationRequestModel(
        id: requestId,
        userId: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        roleType: 'supplier', // Default role
        documentType: 'aadhaar', // Default document type
        documentNumber: 'MOCK_${DateTime.now().millisecondsSinceEpoch}',
        status: status,
        rejectionReason: adminNotes,
        documentFrontUrl: 'https://mock-storage.example.com/verification-documents/$requestId/front.jpg',
        documentBackUrl: 'https://mock-storage.example.com/verification-documents/$requestId/back.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      Logger.info('✅ MOCK: Verification status updated successfully: $requestId -> $status');
      return updatedRequest;
      
    } catch (e) {
      Logger.error('❌ MOCK: Error updating verification status: $e');
      throw ServerException('Mock update verification status failed: $e');
    }
  }

  Future<String> uploadDocument(XFile file, String path) async {
    Logger.info('📤 MOCK: Uploading document to path: $path');
    
    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock file URL
      final mockUrl = 'https://mock-storage.example.com/verification-documents/$path/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Logger.info('✅ MOCK: Document uploaded successfully: $mockUrl');
      return mockUrl;
      
    } catch (e) {
      Logger.error('❌ MOCK: Error uploading document: $e');
      throw ServerException('Mock document upload failed: $e');
    }
  }
}
