import '../models/admin_model.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signUpWithEmailPassword(String email, String password);

  Future<UserModel> signInWithEmailPassword(String email, String password);

  Future<UserModel?> getCurrentUser();

  Future<void> signOut();

  Future<UserModel> updateProfile(String userId, Map<String, dynamic> updates);

  Future<AdminModel?> getAdminProfile(String userId);
}
