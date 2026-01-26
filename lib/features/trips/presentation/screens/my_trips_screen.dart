/// My Trips Screen (MVP 2.0)
/// 
/// Shows trucker's trips organized by status:
/// - ONGOING: Loads the trucker has contacted/expressed interest in
/// - COMPLETED: Past trips
/// - CALLS: Recent call history

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/my_trips_provider.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ONGOING'),
            Tab(text: 'COMPLETED'),
            Tab(text: 'CALLS'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.secondaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _OngoingTripsTab(),
            _CompletedTripsTab(),
            _CallHistoryTab(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}

class _OngoingTripsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(ongoingTripsProvider);

    return tripsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyStatePresets.error(
        message: error.toString(),
        onRetry: () => ref.refresh(ongoingTripsProvider),
      ),
      data: (trips) {
        if (trips.isEmpty) {
          return EmptyStatePresets.noTrips(
            onFindLoads: () => context.go('/trucker-feed'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _TripCard(
              trip: trip,
              onTap: () => context.push('/load-detail-trucker', extra: trip.loadId),
            );
          },
        );
      },
    );
  }
}

class _CompletedTripsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(completedTripsProvider);

    return tripsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyStatePresets.error(
        message: error.toString(),
        onRetry: () => ref.refresh(completedTripsProvider),
      ),
      data: (trips) {
        if (trips.isEmpty) {
          return const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'No completed trips',
            subtitle: 'Your completed trips will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _TripCard(
              trip: trip,
              onTap: () => context.push('/load-detail-trucker', extra: trip.loadId),
              showRateButton: !trip.hasRated,
            );
          },
        );
      },
    );
  }
}

class _CallHistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsAsync = ref.watch(callHistoryProvider);

    return callsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyStatePresets.error(
        message: error.toString(),
        onRetry: () => ref.refresh(callHistoryProvider),
      ),
      data: (calls) {
        if (calls.isEmpty) {
          return EmptyStatePresets.noCallHistory(
            onFindLoads: () => context.go('/trucker-feed'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return _CallCard(call: call);
          },
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripData trip;
  final VoidCallback onTap;
  final bool showRateButton;

  const _TripCard({
    required this.trip,
    required this.onTap,
    this.showRateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.fromCity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildStatusBadge(trip.status),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.toCity,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingSmall),

                // Details row
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trip.material,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.scale,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.weight.toStringAsFixed(0)}T',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Supplier name
                const SizedBox(height: AppDimensions.paddingSmall),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trip.supplierName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(trip.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Rate button
                if (showRateButton) ...[
                  const SizedBox(height: AppDimensions.paddingSmall),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Open rating dialog
                      },
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text('Rate this supplier'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'contacted':
        color = AppColors.info;
        label = 'Contacted';
        break;
      case 'negotiating':
        color = AppColors.warning;
        label = 'Negotiating';
        break;
      case 'booked':
        color = AppColors.success;
        label = 'Booked';
        break;
      case 'completed':
        color = AppColors.textSecondary;
        label = 'Completed';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _CallCard extends StatelessWidget {
  final CallData call;

  const _CallCard({required this.call});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: GlassmorphicCard(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  call.supplierName.isNotEmpty
                      ? call.supplierName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.supplierName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${call.fromCity} → ${call.toCity}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCallTime(call.callTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating if available
              if (call.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        call.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCallTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
