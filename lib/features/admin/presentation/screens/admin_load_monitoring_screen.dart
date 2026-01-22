import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/admin_monitoring_provider.dart';

class AdminLoadMonitoringScreen extends ConsumerStatefulWidget {
  const AdminLoadMonitoringScreen({super.key});

  @override
  ConsumerState<AdminLoadMonitoringScreen> createState() =>
      _AdminLoadMonitoringScreenState();
}

class _AdminLoadMonitoringScreenState
    extends ConsumerState<AdminLoadMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(adminMonitoringNotifierProvider.notifier).fetchAllLoads());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMonitoringNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Monitoring'),
      ),
      body: state.isLoading && state.allLoads.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.allLoads.isEmpty
              ? const Center(child: Text('No loads found'))
              : _buildResponsiveLoadList(context, state.allLoads),
    );
  }

  Widget _buildResponsiveLoadList(BuildContext context, List<dynamic> loads) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.md),
        itemCount: loads.length,
        itemBuilder: (context, index) {
          final load = loads[index];
          return _buildLoadCard(context, load);
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor:
                  MaterialStateProperty.all(AppColors.secondaryBackground),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('From')),
                DataColumn(label: Text('To')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Posted')),
                DataColumn(label: Text('Actions')),
              ],
              rows: loads.map((load) {
                return DataRow(cells: [
                  DataCell(Text(load.id.substring(0, 8))),
                  DataCell(Text(load.fromCity)),
                  DataCell(Text(load.toCity)),
                  DataCell(Text(load.loadType)),
                  DataCell(_StatusBadge(status: load.status)),
                  DataCell(Text(Formatters.formatDate(load.createdAt))),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, load.id),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLoadCard(BuildContext context, dynamic load) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      color: AppColors.glassSurfaceStrong,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${load.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _StatusBadge(status: load.status),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text('Route: ${load.fromCity} → ${load.toCity}'),
            Text('Type: ${load.loadType}'),
            Text('Posted: ${Formatters.formatDate(load.createdAt)}'),
            const SizedBox(height: AppDimensions.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, load.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String loadId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Load?'),
        content: const Text(
            'This action will permanently remove the load from the marketplace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(adminMonitoringNotifierProvider.notifier)
                  .deleteLoad(loadId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'expired':
        color = Colors.orange;
        break;
      case 'deleted':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
