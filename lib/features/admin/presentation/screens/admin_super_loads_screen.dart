import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/admin/admin_app_bar.dart';
import '../../../loads/domain/entities/load.dart';
import '../providers/admin_super_loads_provider.dart';

class AdminSuperLoadsScreen extends ConsumerStatefulWidget {
  const AdminSuperLoadsScreen({super.key});

  @override
  ConsumerState<AdminSuperLoadsScreen> createState() =>
      _AdminSuperLoadsScreenState();
}

class _AdminSuperLoadsScreenState extends ConsumerState<AdminSuperLoadsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminSuperLoadsNotifierProvider.notifier).fetchSuperLoads();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, String loadId) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Delete Super Load?'),
        content: const Text(
            'This action will permanently remove the Super Load from the marketplace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(adminSuperLoadsNotifierProvider.notifier)
        .deleteSuperLoad(loadId);

    if (!context.mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Deleted' : 'Delete failed'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _cloneAndRepost(BuildContext context, Load load) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref
        .read(adminSuperLoadsNotifierProvider.notifier)
        .cloneAndRepost(load);

    if (!context.mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Cloned & reposted' : 'Clone failed'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(authNotifierProvider).admin;
    if (admin == null || !admin.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Super Loads')),
        body: const Center(
          child: Text('Access denied. Super admin only.'),
        ),
      );
    }

    final state = ref.watch(adminSuperLoadsNotifierProvider);

    return Scaffold(
      appBar: AdminAppBarWithBreadcrumbs(
        title: 'Super Loads',
        breadcrumbs: const [
          BreadcrumbItem(label: 'Dashboard'),
          BreadcrumbItem(label: 'Super Loads'),
        ],
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(adminSuperLoadsNotifierProvider.notifier)
                .fetchSuperLoads(query: _searchController.text),
            color: AppColors.textPrimary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/super-loads/create-step1'),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.secondaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'From/To/Truck/Material',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => ref
                        .read(adminSuperLoadsNotifierProvider.notifier)
                        .fetchSuperLoads(query: _searchController.text),
                  ),
                ),
                onSubmitted: (v) => ref
                    .read(adminSuperLoadsNotifierProvider.notifier)
                    .fetchSuperLoads(query: v),
              ),
            ),
            Expanded(
              child: state.isLoading && state.superLoads.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(child: Text('Error: ${state.error}'))
                      : state.superLoads.isEmpty
                          ? const Center(child: Text('No Super Loads found'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.all(AppDimensions.md),
                              itemCount: state.superLoads.length,
                              itemBuilder: (context, index) {
                                final load = state.superLoads[index];

                                return Card(
                                  color: AppColors.glassSurfaceStrong,
                                  margin: const EdgeInsets.only(
                                      bottom: AppDimensions.md),
                                  child: ListTile(
                                    title: Text(
                                      '${load.fromCity} → ${load.toCity}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${load.truckTypeRequired} • ${load.loadType}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        switch (value) {
                                          case 'edit':
                                            context.push(
                                              '/admin/super-loads/edit-step1',
                                              extra: load,
                                            );
                                            break;
                                          case 'clone':
                                            await _cloneAndRepost(context, load);
                                            break;
                                          case 'delete':
                                            await _confirmDelete(context, load.id);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'clone',
                                          child: Text('Clone & repost'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
