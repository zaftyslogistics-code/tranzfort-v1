import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfort_app/core/utils/logger.dart';

/// Utility to clear mock authentication data for testing
class MockDataCleaner {
  static Future<void> clearAllMockData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear current user session
      await prefs.remove('current_user_id');
      
      // Clear all mock users
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('user_')) {
          await prefs.remove(key);
        }
      }
      
      // Clear any other mock data
      await prefs.remove('mock_admin_data');
      await prefs.remove('mock_loads');
      await prefs.remove('mock_chats');
      
      Logger.info('🧹 MOCK: All mock data cleared successfully');
    } catch (e) {
      Logger.error('Error clearing mock data', error: e);
    }
  }
}
