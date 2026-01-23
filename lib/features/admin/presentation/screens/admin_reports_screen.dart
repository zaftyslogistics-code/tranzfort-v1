import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/admin_reports_provider.dart';
import '../../data/models/user_report_model.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminReportsProvider.notifier).fetchReports());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Reports & Moderation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(adminReportsProvider.notifier).fetchReports(
                      status: state.currentFilter == 'all'
                          ? null
                          : state.currentFilter,
                    ),
          ),
        ],
      ),
      body: Container(
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
        child: Column(
          children: [
            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: state.currentFilter == 'all',
                    onSelected: () => ref
                        .read(adminReportsProvider.notifier)
                        .fetchReports(status: 'all'),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterChip(
                    label: 'Pending',
                    isSelected: state.currentFilter == 'pending',
                    onSelected: () => ref
                        .read(adminReportsProvider.notifier)
                        .fetchReports(status: 'pending'),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterChip(
                    label: 'Investigating',
                    isSelected: state.currentFilter == 'investigating',
                    onSelected: () => ref
                        .read(adminReportsProvider.notifier)
                        .fetchReports(status: 'investigating'),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterChip(
                    label: 'Resolved',
                    isSelected: state.currentFilter == 'resolved',
                    onSelected: () => ref
                        .read(adminReportsProvider.notifier)
                        .fetchReports(status: 'resolved'),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterChip(
                    label: 'Dismissed',
                    isSelected: state.currentFilter == 'dismissed',
                    onSelected: () => ref
                        .read(adminReportsProvider.notifier)
                        .fetchReports(status: 'dismissed'),
                  ),
                ],
              ),
            ),

            // Reports List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Text(
                            'Error: ${state.error}',
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        )
                      : state.reports.isEmpty
                          ? const Center(
                              child: Text(
                                'No reports found',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppDimensions.md),
                              itemCount: state.reports.length,
                              itemBuilder: (context, index) {
                                return _ReportCard(
                                    report: state.reports[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppColors.glassSurfaceStrong,
      selectedColor: AppColors.primary.withValues(alpha: 0.25),
      checkmarkColor: AppColors.textPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final UserReportModel report;

  const _ReportCard({required this.report});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'investigating':
        return AppColors.info;
      case 'resolved':
        return AppColors.success;
      case 'dismissed':
        return AppColors.textSecondary;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(report.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getStatusColor(report.status)),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(report.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  timeago.format(report.createdAt),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Reason: ${report.reason}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Type: ${report.reportedEntityType} (ID: ${report.reportedEntityId.substring(0, 8)}...)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            if (report.description != null) ...[
              const Text('Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  )),
              Text(report.description!,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: AppDimensions.md),
            ],

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (report.status == 'pending')
                  TextButton.icon(
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Investigate'),
                    onPressed: () =>
                        _updateStatus(context, ref, 'investigating'),
                  ),
                if (report.status != 'resolved' &&
                    report.status != 'dismissed') ...[
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.success),
                    label: const Text('Resolve',
                        style: TextStyle(color: AppColors.success)),
                    onPressed: () => _updateStatus(context, ref, 'resolved'),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.close,
                        size: 16, color: AppColors.textSecondary),
                    label: const Text('Dismiss',
                        style: TextStyle(color: AppColors.textSecondary)),
                    onPressed: () => _updateStatus(context, ref, 'dismissed'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, String newStatus) async {
    final adminNotesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as ${newStatus.toUpperCase()}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add admin notes (optional):'),
            const SizedBox(height: 8),
            TextField(
              controller: adminNotesController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(adminReportsProvider.notifier).updateReportStatus(
            report.id,
            newStatus,
            adminNotes: adminNotesController.text.isNotEmpty
                ? adminNotesController.text
                : null,
          );
    }
  }
}
