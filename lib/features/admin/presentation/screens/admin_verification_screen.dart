import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../verification/data/models/verification_request_model.dart';
import '../providers/admin_verification_provider.dart';

class AdminVerificationScreen extends ConsumerStatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  ConsumerState<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState
    extends ConsumerState<AdminVerificationScreen> {
  String _roleFilter = 'all';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(adminVerificationNotifierProvider.notifier)
        .fetchPendingRequests());
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialStart = _dateRange?.start ?? now.subtract(const Duration(days: 7));
    final initialEnd = _dateRange?.end ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (!mounted) return;
    setState(() => _dateRange = picked);
  }

  List<VerificationRequestModel> _applyFilters(
    List<VerificationRequestModel> requests,
  ) {
    Iterable<VerificationRequestModel> filtered = requests;

    if (_roleFilter != 'all') {
      filtered = filtered.where((r) => r.roleType == _roleFilter);
    }

    final range = _dateRange;
    if (range != null) {
      filtered = filtered.where((r) {
        final created = r.createdAt;
        return !created.isBefore(range.start) && !created.isAfter(range.end);
      });
    }

    return filtered.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminVerificationNotifierProvider);
    final filtered = _applyFilters(state.pendingRequests);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verifications'),
        actions: [
          IconButton(
            tooltip: 'Filter by date range',
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range),
          ),
          if (_dateRange != null)
            IconButton(
              tooltip: 'Clear date filter',
              onPressed: () => setState(() => _dateRange = null),
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _roleFilter,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'supplier', child: Text('Supplier')),
                      DropdownMenuItem(value: 'trucker', child: Text('Trucker')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _roleFilter = value);
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.filter_alt),
                    label: Text(
                      _dateRange == null
                          ? 'Any date'
                          : '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading && state.pendingRequests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Text('No pending verification requests'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final request = filtered[index];
                          return _VerificationRequestCard(request: request);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _VerificationRequestCard extends ConsumerWidget {
  final VerificationRequestModel request;

  const _VerificationRequestCard({required this.request});

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
                Text(
                  'Role: ${request.roleType.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Date: ${request.createdAt.toLocal().toString().split('.')[0]}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const Divider(),
            Text('Document: ${request.documentType}'),
            if (request.documentNumber != null)
              Text('Doc Number: ${request.documentNumber}'),
            if (request.companyName != null)
              Text('Company: ${request.companyName}'),
            if (request.vehicleNumber != null)
              Text('Vehicle: ${request.vehicleNumber}'),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                _DocumentPreview(
                  label: 'Front',
                  path: request.documentFrontUrl,
                ),
                const SizedBox(width: AppDimensions.md),
                _DocumentPreview(
                  label: 'Back',
                  path: request.documentBackUrl,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showNeedsMoreInfoDialog(context, ref),
                  child: const Text('Needs info'),
                ),
                TextButton(
                  onPressed: () => _showRejectDialog(context, ref),
                  child:
                      const Text('Reject', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: AppDimensions.md),
                ElevatedButton(
                  onPressed: () => _approveRequest(context, ref),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNeedsMoreInfoDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Needs More Info'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Note to user',
            hintText: 'e.g. Please upload a clearer photo of the document',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final note = controller.text.trim();
              if (note.isEmpty) return;

              Navigator.pop(context);
              final success = await ref
                  .read(adminVerificationNotifierProvider.notifier)
                  .updateStatus(request.id, 'needs_more_info', reason: note);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(success ? 'Marked as needs more info' : 'Action Failed'),
                  backgroundColor: success ? Colors.blueGrey : Colors.red,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _approveRequest(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(adminVerificationNotifierProvider.notifier)
        .updateStatus(request.id, 'approved');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Request Approved' : 'Action Failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'e.g. Documents are blurry',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) return;

              Navigator.pop(context);
              final success = await ref
                  .read(adminVerificationNotifierProvider.notifier)
                  .updateStatus(request.id, 'rejected', reason: reason);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(success ? 'Request Rejected' : 'Action Failed'),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  final String label;
  final String? path;

  const _DocumentPreview({required this.label, this.path});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        _SignedImagePreview(path: path),
      ],
    );
  }
}

class _SignedImagePreview extends StatefulWidget {
  final String? path;

  const _SignedImagePreview({this.path});

  @override
  State<_SignedImagePreview> createState() => _SignedImagePreviewState();
}

class _SignedImagePreviewState extends State<_SignedImagePreview> {
  String? _url;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _SignedImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _url = null;
      _load();
    }
  }

  Future<void> _load() async {
    final path = widget.path;
    if (path == null || path.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final signedUrl = await Supabase.instance.client.storage
          .from('verification-documents')
          .createSignedUrl(path, 60 * 10);

      if (!mounted) return;
      setState(() => _url = signedUrl);
    } catch (_) {
      // Keep fallback UI
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _url == null
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.black,
                    insetPadding: const EdgeInsets.all(AppDimensions.md),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 5,
                            child: Image.network(
                              _url!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : (_url == null
                ? const Center(child: Icon(Icons.broken_image))
                : ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                    child: Image.network(
                      _url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image));
                      },
                    ),
                  )),
      ),
    );
  }
}
