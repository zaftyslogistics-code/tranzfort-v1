import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/loads/presentation/screens/supplier_dashboard_screen.dart';
import '../../features/loads/presentation/screens/trucker_feed_screen.dart';

class FeedTabScreen extends ConsumerWidget {
  const FeedTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    final isSupplier = user?.isSupplierEnabled ?? false;

    return isSupplier ? const SupplierDashboardScreen() : const TruckerFeedScreen();
  }
}
