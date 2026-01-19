import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_verification_datasource.dart';
import '../../data/repositories/verification_repository_impl.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../domain/usecases/get_pending_verification_requests.dart';
import '../../domain/usecases/update_verification_status.dart';
import '../../domain/usecases/create_verification_request.dart';

final verificationDataSourceProvider = Provider<SupabaseVerificationDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseVerificationDataSource(supabase);
});

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final ds = ref.watch(verificationDataSourceProvider);
  return VerificationRepositoryImpl(ds);
});

final createVerificationRequestUseCaseProvider = Provider((ref) {
  final repo = ref.watch(verificationRepositoryProvider);
  return CreateVerificationRequest(repo);
});

final getPendingVerificationRequestsUseCaseProvider = Provider((ref) {
  final repo = ref.watch(verificationRepositoryProvider);
  return GetPendingVerificationRequests(repo);
});

final updateVerificationStatusUseCaseProvider = Provider((ref) {
  final repo = ref.watch(verificationRepositoryProvider);
  return UpdateVerificationStatus(repo);
});
