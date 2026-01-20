import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/free_badge.dart';
import '../../domain/entities/truck.dart';
import '../providers/fleet_provider.dart';
import '../widgets/add_truck_floating_button.dart';
import '../widgets/fleet_stats_card.dart';
import '../widgets/truck_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class FleetManagementScreen extends ConsumerStatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  ConsumerState<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends ConsumerState<FleetManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(fleetNotifierProvider.notifier).fetchTrucks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fleetState = ref.watch(fleetNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const GradientText(
          'My Fleet',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.truckPrimary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.check_circle)),
            Tab(text: 'Expiring', icon: Icon(Icons.warning)),
            Tab(text: 'All', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBackground,
                    AppColors.secondaryBackground,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Content
          if (fleetState.isLoading && fleetState.trucks.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (fleetState.error != null && fleetState.trucks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${fleetState.error}',
                      style: const TextStyle(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(fleetNotifierProvider.notifier)
                          .fetchTrucks(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            TabBarView(
              controller: _tabController,
              children: [
                _buildTruckList('active', fleetState.trucks),
                _buildTruckList('expiring', fleetState.trucks),
                _buildTruckList('all', fleetState.trucks),
              ],
            ),
        ],
      ),
      floatingActionButton: const AddTruckFloatingButton(),
    );
  }

  Widget _buildTruckList(String filter, List<Truck> allTrucks) {
    List<Truck> filteredTrucks;
    switch (filter) {
      case 'active':
        filteredTrucks = allTrucks.where((t) => t.isActive).toList();
        break;
      case 'expiring':
        filteredTrucks = allTrucks
            .where(
              (t) => t.isRcExpiringSoon ||
                  t.isInsuranceExpiringSoon ||
                  t.isRcExpired ||
                  t.isInsuranceExpired,
            )
            .toList();
        break;
      default:
        filteredTrucks = allTrucks;
    }

    return Column(
      children: [
        // Fleet Stats Card
        Container(
          margin: const EdgeInsets.all(AppDimensions.lg),
          child: const FleetStatsCard(),
        ),
        
        // Truck List
        Expanded(
          child: filteredTrucks.isEmpty
              ? _buildEmptyState(filter)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                  itemCount: filteredTrucks.length,
                  itemBuilder: (context, index) {
                    final truck = filteredTrucks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.md),
                      child: TruckCard(
                        truck: truck,
                        onTap: () => _showTruckDetails(truck),
                        onEdit: () => _editTruck(truck),
                        onDelete: () => _deleteTruck(truck),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    String? subMessage;
    IconData icon;
    String? actionText;
    VoidCallback? onAction;

    switch (filter) {
      case 'active':
        message = 'No Active Trucks';
        subMessage = 'Add a truck to your fleet to get started.';
        icon = Icons.local_shipping_outlined;
        actionText = 'Add Your First Truck';
        onAction = _addTruck;
        break;
      case 'expiring':
        message = 'All Documents Valid';
        subMessage = 'Great job! None of your trucks have expiring documents.';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'No Trucks Added';
        subMessage = 'Build your fleet by adding trucks.';
        icon = Icons.add_circle_outline;
        actionText = 'Add Your First Truck';
        onAction = _addTruck;
        break;
    }

    return EmptyStateWidget(
      message: message,
      subMessage: subMessage,
      icon: icon,
      actionLabel: actionText,
      onAction: onAction,
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Trucks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.lg),
            ...['All', 'Active Only', 'Expiring Soon', 'Inactive'].map((filter) => 
              ListTile(
                title: Text(
                  filter,
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                trailing: _selectedFilter == filter.toLowerCase().replaceAll(' ', '')
                    ? const Icon(Icons.check, color: AppColors.truckPrimary)
                    : null,
                onTap: () {
                  setState(() => _selectedFilter = filter.toLowerCase().replaceAll(' ', ''));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _addTruck() {
    // Navigate to add truck screen
    context.push('/add-truck');
  }

  void _showTruckDetails(Truck truck) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: GlassmorphicCard(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      truck.truckNumber,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  FreeBadge(text: truck.isActive ? 'ACTIVE' : 'INACTIVE'),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              _buildDetailRow('Type', truck.truckType),
              _buildDetailRow('Capacity', '${truck.capacity} tons'),
              _buildDetailRow('RC Status', truck.rcExpiryDate != null 
                  ? 'Valid until ${_formatDate(truck.rcExpiryDate!)}' 
                  : 'Not uploaded'),
              _buildDetailRow('Insurance Status', truck.insuranceExpiryDate != null 
                  ? 'Valid until ${_formatDate(truck.insuranceExpiryDate!)}' 
                  : 'Not uploaded'),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GlassmorphicButton(
                      variant: GlassmorphicButtonVariant.primary,
                      onPressed: () {
                        Navigator.pop(context);
                        _editTruck(truck);
                      },
                      child: const Text('Edit Truck'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: GlassmorphicButton(
                      showGlow: false,
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTruck(truck);
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editTruck(Truck truck) {
    // Navigate to edit truck screen
    context.push('/edit-truck', extra: truck.id);
  }

  void _deleteTruck(Truck truck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassSurfaceStrong,
        title: Text(
          'Delete Truck',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete ${truck.truckNumber}? This action cannot be undone.',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(fleetNotifierProvider.notifier)
                  .deleteTruck(truck.id);
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${truck.truckNumber} deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  final error = ref.read(fleetNotifierProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Failed to delete truck'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
