import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../verification/data/models/verification_request_model.dart';

class AdminVerificationDashboard extends ConsumerStatefulWidget {
  const AdminVerificationDashboard({super.key});

  @override
  ConsumerState<AdminVerificationDashboard> createState() => _AdminVerificationDashboardState();
}

class _AdminVerificationDashboardState extends ConsumerState<AdminVerificationDashboard> {
  bool _isLoading = true;
  List<VerificationRequestModel> _pendingRequests = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('verification_requests')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: true);

      final requests = (response as List)
          .map((json) => VerificationRequestModel.fromJson(json))
          .toList();

      if (mounted) {
        setState(() {
          _pendingRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Failed to fetch verification requests', error: e);
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String requestId, String status, {String? reason}) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final supabase = Supabase.instance.client;
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        'reviewed_at': DateTime.now().toIso8601String(),
      };
      
      if (reason != null) {
        updates['rejection_reason'] = reason;
      }

      await supabase
          .from('verification_requests')
          .update(updates)
          .eq('id', requestId);

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Request $status'),
          backgroundColor: status == 'approved' ? AppColors.success : AppColors.danger,
        ),
      );

      _fetchRequests(); // Refresh list
    } catch (e) {
      Logger.error('Failed to update request status', error: e);

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showRejectionDialog(String requestId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassSurfaceStrong,
        title: const Text('Reject Request', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(requestId, 'rejected', reason: reasonController.text);
            },
            child: const Text('Reject', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: Stack(
        children: [
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text('Error: $_error', style: const TextStyle(color: AppColors.danger)))
          else if (_pendingRequests.isEmpty)
            const Center(
              child: Text(
                'No pending requests',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.lg),
              itemCount: _pendingRequests.length,
              itemBuilder: (context, index) {
                final request = _pendingRequests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.md),
                  child: GlassmorphicCard(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GradientText(
                              request.roleType.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(request.createdAt),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'User ID: ${request.userId}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Doc: ${request.documentType} ${request.documentNumber ?? ""}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        if (request.companyName != null)
                          Text('Company: ${request.companyName}', style: const TextStyle(color: Colors.white)),
                        if (request.vehicleNumber != null)
                          Text('Vehicle: ${request.vehicleNumber}', style: const TextStyle(color: Colors.white)),
                        
                        const SizedBox(height: AppDimensions.md),
                        Row(
                          children: [
                            if (request.documentFrontUrl != null)
                              Expanded(child: _buildDocLink('Front', request.documentFrontUrl!)),
                            if (request.documentBackUrl != null)
                              Expanded(child: _buildDocLink('Back', request.documentBackUrl!)),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(request.id, 'approved'),
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.md),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showRejectionDialog(request.id),
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDocLink(String label, String url) {
    // In a real app, this would open the image. For now, it's just a text placeholder or we could make it a button.
    // Since we stored the PATH, we need to generate a signed URL or public URL.
    // For simplicity in this admin dashboard, we'll assume we can't easily show it without more logic,
    // so we'll just show the label. Ideally, we'd use Supabase storage.from().getSignedUrl().
    return TextButton.icon(
      onPressed: () {
        // TODO: Implement image viewer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image viewing not implemented in this version')),
        );
      },
      icon: const Icon(Icons.image, size: 16),
      label: Text(label),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute}';
  }
}
