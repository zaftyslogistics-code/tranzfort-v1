import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/image/image_compressor.dart';
import '../models/verification_request_model.dart';

class SupabaseVerificationDataSource {
  final SupabaseClient _supabase;

  SupabaseVerificationDataSource(this._supabase);

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
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw ServerException(
          'User session not found. Please log in to submit verification.');
    }

    try {
      Logger.info('🪪 SUPABASE: Creating verification request');

      final inserted = await _supabase
          .from('verification_requests')
          .insert({
            'user_id': user.id,
            'role_type': roleType,
            'document_type': documentType,
            'document_number': documentNumber,
            'company_name': companyName,
            'vehicle_number': vehicleNumber,
            'status': 'pending',
          })
          .select('*')
          .single();

      final request = VerificationRequestModel.fromJson(inserted);

      final frontPath =
          '${user.id}/$roleType/${request.id}/front_${front.name}';
      final backPath = '${user.id}/$roleType/${request.id}/back_${back.name}';

      // Compress images
      final File frontFile = File(front.path);
      final File backFile = File(back.path);

      final File? compressedFront =
          await ImageCompressor.compressImage(frontFile);
      final File? compressedBack =
          await ImageCompressor.compressImage(backFile);

      // Use compressed file if available, otherwise fallback to original
      final frontBytes = compressedFront != null
          ? await compressedFront.readAsBytes()
          : await front.readAsBytes();

      final backBytes = compressedBack != null
          ? await compressedBack.readAsBytes()
          : await back.readAsBytes();

      await _upload(frontPath, Uint8List.fromList(frontBytes),
          contentType: front.mimeType);
      await _upload(backPath, Uint8List.fromList(backBytes),
          contentType: back.mimeType);

      final updated = await _supabase
          .from('verification_requests')
          .update({
            'document_front_url': frontPath,
            'document_back_url': backPath,
          })
          .eq('id', request.id)
          .select('*')
          .single();

      Logger.info('✅ SUPABASE: Verification request submitted: ${request.id}');
      return VerificationRequestModel.fromJson(updated);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> _upload(
    String path,
    Uint8List bytes, {
    String? contentType,
  }) async {
    await _supabase.storage.from(_bucketId).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );
  }

  Future<List<VerificationRequestModel>>
      getPendingVerificationRequests() async {
    try {
      final response = await _supabase
          .from('verification_requests')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => VerificationRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<VerificationRequestModel> updateVerificationStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (rejectionReason != null) {
        updates['rejection_reason'] = rejectionReason;
      }

      final response = await _supabase
          .from('verification_requests')
          .update(updates)
          .eq('id', requestId)
          .select('*')
          .single();

      return VerificationRequestModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
