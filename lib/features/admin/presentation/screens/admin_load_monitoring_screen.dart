import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/admin_monitoring_provider.dart';

class AdminLoadMonitoringScreen extends ConsumerStatefulWidget {
  const AdminLoadMonitoringScreen({super.key});

  @override
  ConsumerState<AdminLoadMonitoringScreen> createState() => _AdminLoadMonitoringScreenState();
}

class _AdminLoadMonitoringScreenState extends ConsumerState<AdminLoadMonitoringScreen> {
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
              : Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.secondaryBackground),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('From')),
                          DataColumn(label: Text('To')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Posted')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: state.allLoads.map((load) {
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
                ),
    );
  }

  void _confirmDelete(BuildContext context, String loadId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Load?'),
        content: const Text('This action will permanently remove the load from the marketplace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminMonitoringNotifierProvider.notifier).deleteLoad(loadId);
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
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
