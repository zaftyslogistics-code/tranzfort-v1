import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/image/image_compressor.dart';
import '../models/truck_model.dart';
import 'fleet_datasource.dart';

class SupabaseFleetDataSource implements FleetDataSource {
  final SupabaseClient _client;

  SupabaseFleetDataSource(this._client);

  static const String _bucketId = 'fleet-documents';

  @override
  Future<List<TruckModel>> getTrucks({String? transporterId}) async {
    try {
      var query = _client.from('trucks').select();

      if (transporterId != null) {
        query = query.eq('transporter_id', transporterId);
      } else {
        // If no specific transporterId, assume current user (RLS will enforce this anyway for 'own trucks' policy)
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          query = query.eq('transporter_id', userId);
        }
      }

      final data = await query.order('created_at', ascending: false);

      return (data as List).map((json) => TruckModel.fromJson(json)).toList();
    } catch (e) {
      Logger.error('Error fetching trucks', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TruckModel> addTruck(Map<String, dynamic> truckData,
      {XFile? rcDocument, XFile? insuranceDocument}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw ServerException('User not authenticated');
    }

    try {
      // 1. Insert truck data first to get the ID
      final payload = {
        ...truckData,
        'transporter_id': user.id,
      };

      final inserted =
          await _client.from('trucks').insert(payload).select().single();

      var truck = TruckModel.fromJson(inserted);

      // 2. Upload documents if present
      String? rcUrl;
      String? insuranceUrl;

      if (rcDocument != null) {
        rcUrl = await _uploadDocument(user.id, truck.id, 'rc', rcDocument);
      }

      if (insuranceDocument != null) {
        insuranceUrl = await _uploadDocument(
            user.id, truck.id, 'insurance', insuranceDocument);
      }

      // 3. Update truck with document URLs if uploaded
      if (rcUrl != null || insuranceUrl != null) {
        final updates = <String, dynamic>{};
        if (rcUrl != null) updates['rc_document_url'] = rcUrl;
        if (insuranceUrl != null) {
          updates['insurance_document_url'] = insuranceUrl;
        }

        final updated = await _client
            .from('trucks')
            .update(updates)
            .eq('id', truck.id)
            .select()
            .single();

        truck = TruckModel.fromJson(updated);
      }

      return truck;
    } catch (e) {
      Logger.error('Error adding truck', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TruckModel> updateTruck(String id, Map<String, dynamic> updates,
      {XFile? rcDocument, XFile? insuranceDocument}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw ServerException('User not authenticated');
    }

    try {
      // 1. Upload new documents if present
      if (rcDocument != null) {
        updates['rc_document_url'] =
            await _uploadDocument(user.id, id, 'rc', rcDocument);
      }

      if (insuranceDocument != null) {
        updates['insurance_document_url'] =
            await _uploadDocument(user.id, id, 'insurance', insuranceDocument);
      }

      // 2. Update truck record
      final updated = await _client
          .from('trucks')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return TruckModel.fromJson(updated);
    } catch (e) {
      Logger.error('Error updating truck', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTruck(String id) async {
    try {
      await _client.from('trucks').delete().eq('id', id);
    } catch (e) {
      Logger.error('Error deleting truck', error: e);
      throw ServerException(e.toString());
    }
  }

  Future<String> _uploadDocument(
      String userId, String truckId, String type, XFile file) async {
    final path = '$userId/$truckId/${type}_${file.name}';

    // Compress image
    final File imageFile = File(file.path);
    final File? compressedImage =
        await ImageCompressor.compressImage(imageFile);

    final bytes = compressedImage != null
        ? await compressedImage.readAsBytes()
        : await file.readAsBytes();

    await _client.storage.from(_bucketId).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType,
            upsert: true,
          ),
        );

    // Get public URL? Or just the path?
    // Usually standard is to store the path if using signed URLs, or public URL if public bucket.
    // The schema says TEXT for url.
    // Since bucket is private, we should probably store the path and generate signed URLs on fetch,
    // OR we can rely on `storage.from().getPublicUrl()` if we switch to public (not recommended for docs).
    // For now, let's store the path. The UI will need to generate a signed URL to display it.

    return path;
  }
}
