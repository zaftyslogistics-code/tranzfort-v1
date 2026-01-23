import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/manage_admins_provider.dart';

class ManageAdminsScreen extends ConsumerStatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  ConsumerState<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends ConsumerState<ManageAdminsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentAdminId = ref.read(authNotifierProvider).user?.id;
      if (currentAdminId != null) {
        ref
            .read(manageAdminsNotifierProvider(currentAdminId).notifier)
            .fetchAdmins();
      }
    });
  }

  void _showCreateAdminDialog() {
    final userIdController = TextEditingController();
    final fullNameController = TextEditingController();
    String selectedRole = 'verification_officer';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Create New Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID (UUID)',
                hintText: 'Enter existing user UUID',
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name (optional)',
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(
                  value: 'super_admin',
                  child: Text('Super Admin'),
                ),
                DropdownMenuItem(
                  value: 'verification_officer',
                  child: Text('Verification Officer'),
                ),
                DropdownMenuItem(
                  value: 'support_agent',
                  child: Text('Support Agent'),
                ),
                DropdownMenuItem(
                  value: 'analyst',
                  child: Text('Analyst'),
                ),
              ],
              onChanged: (value) {
                if (value != null) selectedRole = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = userIdController.text.trim();
              if (userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID is required')),
                );
                return;
              }

              final currentAdminId = ref.read(authNotifierProvider).user?.id;
              if (currentAdminId == null) return;

              final success = await ref
                  .read(manageAdminsNotifierProvider(currentAdminId).notifier)
                  .createAdmin(
                    userId: userId,
                    role: selectedRole,
                    fullName: fullNameController.text.trim().isEmpty
                        ? null
                        : fullNameController.text.trim(),
                  );

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Admin created successfully'
                          : 'Failed to create admin',
                    ),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showUpdateRoleDialog(String adminId, String currentRole) {
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Update Admin Role'),
        content: DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: const InputDecoration(labelText: 'New Role'),
          items: const [
            DropdownMenuItem(
              value: 'super_admin',
              child: Text('Super Admin'),
            ),
            DropdownMenuItem(
              value: 'verification_officer',
              child: Text('Verification Officer'),
            ),
            DropdownMenuItem(
              value: 'support_agent',
              child: Text('Support Agent'),
            ),
            DropdownMenuItem(
              value: 'analyst',
              child: Text('Analyst'),
            ),
          ],
          onChanged: (value) {
            if (value != null) selectedRole = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentAdminId = ref.read(authNotifierProvider).user?.id;
              if (currentAdminId == null) return;

              final success = await ref
                  .read(manageAdminsNotifierProvider(currentAdminId).notifier)
                  .updateAdminRole(adminId: adminId, newRole: selectedRole);

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Role updated successfully'
                          : 'Failed to update role',
                    ),
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAdmin(String adminId, String fullName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Delete Admin'),
        content:
            Text('Are you sure you want to revoke admin access for $fullName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final currentAdminId = ref.read(authNotifierProvider).user?.id;
              if (currentAdminId == null) return;

              final success = await ref
                  .read(manageAdminsNotifierProvider(currentAdminId).notifier)
                  .deleteAdmin(adminId);

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Admin deleted successfully'
                          : 'Failed to delete admin',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAdminId = ref.watch(authNotifierProvider).user?.id;
    final admin = ref.watch(authNotifierProvider).admin;

    if (currentAdminId == null || admin == null || !admin.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Admins')),
        body: const Center(
          child: Text('Access denied. Super admin only.'),
        ),
      );
    }

    final state = ref.watch(manageAdminsNotifierProvider(currentAdminId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Admins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateAdminDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.secondaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : state.admins.isEmpty
                    ? const Center(child: Text('No admins found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        itemCount: state.admins.length,
                        itemBuilder: (context, index) {
                          final adminItem = state.admins[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppDimensions.md),
                            child: GlassmorphicCard(
                              child: ListTile(
                                title: Text(
                                  adminItem.fullName ?? 'Unnamed Admin',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${adminItem.role}\nID: ${adminItem.id}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: AppColors.primary),
                                      onPressed: () => _showUpdateRoleDialog(
                                        adminItem.id,
                                        adminItem.role,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: AppColors.danger),
                                      onPressed: () => _confirmDeleteAdmin(
                                        adminItem.id,
                                        adminItem.fullName ?? 'this admin',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
