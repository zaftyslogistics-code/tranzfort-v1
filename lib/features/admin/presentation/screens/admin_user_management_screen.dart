import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/data/models/user_model.dart';
import '../providers/admin_users_provider.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminUsersNotifierProvider.notifier).fetchUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            onPressed: state.isLoading
                ? null
                : () => ref.read(adminUsersNotifierProvider.notifier).fetchUsers(
                      query: _searchController.text,
                    ),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search (mobile/name)',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                ref.read(adminUsersNotifierProvider.notifier).fetchUsers(query: value);
              },
            ),
            const SizedBox(height: AppDimensions.md),
            if (state.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.danger),
                ),
                child: Text(
                  state.error!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.danger),
                ),
              ),
            const SizedBox(height: AppDimensions.md),
            Expanded(
              child: state.isLoading && state.users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.users.isEmpty
                      ? const Center(child: Text('No users found'))
                      : _buildResponsiveUserList(context, state.users),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveUserList(BuildContext context, List<UserModel> users) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    if (isMobile) {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(context, user);
        },
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppColors.secondaryBackground),
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Mobile')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Supplier')),
              DataColumn(label: Text('Trucker')),
              DataColumn(label: Text('Supplier KYC')),
              DataColumn(label: Text('Trucker KYC')),
            ],
            rows: users.map((u) => _buildDataRow(context, u)).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
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
                  'ID: ${user.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${user.countryCode}${user.mobileNumber}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text('Name: ${user.name ?? '-'}'),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Supplier', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: user.isSupplierEnabled,
                        onChanged: (val) => _updateUser(user.id, {'is_supplier_enabled': val}),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trucker', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: user.isTruckerEnabled,
                        onChanged: (val) => _updateUser(user.id, {'is_trucker_enabled': val}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Supplier KYC', style: TextStyle(fontWeight: FontWeight.w500)),
                      _StatusDropdown(
                        value: user.supplierVerificationStatus,
                        onChanged: (val) => _updateUser(user.id, {'supplier_verification_status': val}),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trucker KYC', style: TextStyle(fontWeight: FontWeight.w500)),
                      _StatusDropdown(
                        value: user.truckerVerificationStatus,
                        onChanged: (val) => _updateUser(user.id, {'trucker_verification_status': val}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, UserModel user) {
    return DataRow(
      cells: [
        DataCell(Text(user.id.substring(0, 8))),
        DataCell(Text('${user.countryCode}${user.mobileNumber}')),
        DataCell(Text(user.name ?? '-')),
        DataCell(
          Switch(
            value: user.isSupplierEnabled,
            onChanged: (val) => _updateUser(user.id, {'is_supplier_enabled': val}),
          ),
        ),
        DataCell(
          Switch(
            value: user.isTruckerEnabled,
            onChanged: (val) => _updateUser(user.id, {'is_trucker_enabled': val}),
          ),
        ),
        DataCell(_StatusDropdown(
          value: user.supplierVerificationStatus,
          onChanged: (val) => _updateUser(user.id, {'supplier_verification_status': val}),
        )),
        DataCell(_StatusDropdown(
          value: user.truckerVerificationStatus,
          onChanged: (val) => _updateUser(user.id, {'trucker_verification_status': val}),
        )),
      ],
    );
  }

  Future<void> _updateUser(String userId, Map<String, dynamic> updates) async {
    final success = await ref.read(adminUsersNotifierProvider.notifier).updateUser(userId, updates);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'User updated' : 'Failed to update user'),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _StatusDropdown({
    required this.value,
    required this.onChanged,
  });

  static const _values = ['unverified', 'verified', 'rejected'];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _values.contains(value) ? value : 'unverified',
      items: _values
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              ))
          .toList(growable: false),
      onChanged: (val) {
        if (val == null) return;
        onChanged(val);
      },
    );
  }
}
