import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Data export service for GDPR compliance
/// Allows users to download all their data
class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Export all user data to JSON
  Future<File> exportUserDataToJson() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Logger.info('📦 Starting data export for user $userId');

      // Fetch all user data
      final userData = await _fetchAllUserData(userId);

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(userData);

      // Save to file
      final file = await _saveToFile(jsonString, 'user_data.json');

      Logger.info('✅ Data export completed: ${file.path}');
      return file;
    } catch (e) {
      Logger.error('Failed to export user data', error: e);
      rethrow;
    }
  }

  /// Export user data to CSV
  Future<File> exportUserDataToCsv() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Logger.info('📦 Starting CSV export for user $userId');

      final userData = await _fetchAllUserData(userId);
      final csvString = _convertToCSV(userData);

      final file = await _saveToFile(csvString, 'user_data.csv');

      Logger.info('✅ CSV export completed: ${file.path}');
      return file;
    } catch (e) {
      Logger.error('Failed to export CSV', error: e);
      rethrow;
    }
  }

  /// Fetch all user data from database
  Future<Map<String, dynamic>> _fetchAllUserData(String userId) async {
    final data = <String, dynamic>{};

    try {
      // User profile
      final profile =
          await _client.from('users').select().eq('id', userId).single();
      data['profile'] = profile;

      // User loads
      final loads =
          await _client.from('loads').select().eq('supplier_id', userId);
      data['loads'] = loads;

      // User trucks
      final trucks =
          await _client.from('trucks').select().eq('transporter_id', userId);
      data['trucks'] = trucks;

      // User chats
      final chats = await _client
          .from('chats')
          .select()
          .or('supplier_id.eq.$userId,trucker_id.eq.$userId');
      data['chats'] = chats;

      // User ratings
      final ratings = await _client
          .from('ratings')
          .select()
          .or('rater_id.eq.$userId,rated_user_id.eq.$userId');
      data['ratings'] = ratings;

      // User notifications
      final notifications =
          await _client.from('notifications').select().eq('user_id', userId);
      data['notifications'] = notifications;

      // Verification requests
      final verifications = await _client
          .from('verification_requests')
          .select()
          .eq('user_id', userId);
      data['verifications'] = verifications;

      // Export metadata
      data['export_metadata'] = {
        'exported_at': DateTime.now().toIso8601String(),
        'user_id': userId,
        'version': '1.0.0',
      };

      return data;
    } catch (e) {
      Logger.error('Failed to fetch user data', error: e);
      rethrow;
    }
  }

  /// Save data to file
  Future<File> _saveToFile(String content, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      return file;
    } catch (e) {
      Logger.error('Failed to save file', error: e);
      rethrow;
    }
  }

  /// Convert data to CSV format
  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // Add header
    buffer.writeln('Category,Field,Value');

    // Convert each section to CSV rows
    data.forEach((category, value) {
      if (value is Map) {
        value.forEach((field, fieldValue) {
          buffer.writeln(
              '$category,$field,"${_escapeCSV(fieldValue.toString())}"');
        });
      } else if (value is List) {
        buffer.writeln('$category,count,${value.length}');
        for (int i = 0; i < value.length; i++) {
          if (value[i] is Map) {
            (value[i] as Map).forEach((field, fieldValue) {
              buffer.writeln(
                  '$category[$i],$field,"${_escapeCSV(fieldValue.toString())}"');
            });
          }
        }
      } else {
        buffer.writeln('$category,value,"${_escapeCSV(value.toString())}"');
      }
    });

    return buffer.toString();
  }

  /// Escape CSV special characters
  String _escapeCSV(String value) {
    return value.replaceAll('"', '""');
  }

  /// Get export file size estimate
  Future<int> getExportSizeEstimate() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return 0;

      final userData = await _fetchAllUserData(userId);
      final jsonString = jsonEncode(userData);
      return jsonString.length;
    } catch (e) {
      return 0;
    }
  }
}
