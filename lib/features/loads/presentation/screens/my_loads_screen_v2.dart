import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../../../../shared/widgets/flat_card.dart';

/// My Loads Screen v0.02 (Supplier)
/// Shows supplier's posted loads with tabs
/// - Tab 1: All Loads
/// - Tab 2: Super Truckers (loads promoted to verified truckers)
class MyLoadsScreenV2 extends ConsumerStatefulWidget {
  const MyLoadsScreenV2({super.key});

  @override
  ConsumerState<MyLoadsScreenV2> createState() => _MyLoadsScreenV2State();
}

class _MyLoadsScreenV2State extends ConsumerState<MyLoadsScreenV2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Loads'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'All Loads'),
                Tab(text: 'Super Truckers'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Loads Tab
                _AllLoadsTab(isDark: isDark),
                
                // Super Truckers Tab
                _SuperTruckersTab(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to post load
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Post Load'),
      ),
    );
  }
}

class _AllLoadsTab extends StatelessWidget {
  final bool isDark;

  const _AllLoadsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final loads = List.generate(
      5,
      (index) => {
        'id': 'load_$index',
        'fromCity': 'Mumbai',
        'toCity': 'Delhi',
        'materialType': 'Steel',
        'truckType': '32 Ft Trailer',
        'weight': '20 tons',
        'date': 'Today',
        'status': index == 0 ? 'active' : 'pending',
        'offersCount': index * 3,
      },
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loads.length,
      itemBuilder: (context, index) {
        final load = loads[index];
        return _LoadCard(
          load: load,
          isDark: isDark,
          onTap: () {
            // TODO: Navigate to load detail
          },
        );
      },
    );
  }
}

class _SuperTruckersTab extends StatelessWidget {
  final bool isDark;

  const _SuperTruckersTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Mock data - loads promoted to Super Truckers
    final superTruckerLoads = List.generate(
      2,
      (index) => {
        'id': 'super_load_$index',
        'fromCity': 'Mumbai',
        'toCity': 'Delhi',
        'materialType': 'Steel',
        'truckType': '32 Ft Trailer',
        'weight': '20 tons',
        'date': 'Today',
        'status': 'pending_approval',
        'requestedAt': '2 hours ago',
      },
    );

    if (superTruckerLoads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Super Trucker requests yet',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Request a Super Trucker for your loads',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Request Super Trucker',
              icon: Icons.star,
              onPressed: () {
                _showSuperTruckerRequest(context);
              },
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            border: Border.all(color: AppColors.info),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Super Truckers are verified truckers with proven track records',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Request button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SecondaryButton(
            text: 'Request for Another Load',
            icon: Icons.add,
            onPressed: () {
              _showSuperTruckerRequest(context);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Super Trucker loads list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: superTruckerLoads.length,
            itemBuilder: (context, index) {
              final load = superTruckerLoads[index];
              return _SuperTruckerLoadCard(
                load: load,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSuperTruckerRequest(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SuperTruckerRequestBottomSheet(),
    );
  }
}

class _LoadCard extends StatelessWidget {
  final Map<String, dynamic> load;
  final bool isDark;
  final VoidCallback onTap;

  const _LoadCard({
    required this.load,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: load['status'] == 'active' ? AppColors.success : AppColors.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  load['status'] == 'active' ? 'ACTIVE' : 'PENDING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (load['offersCount'] > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${load['offersCount']} offers',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${load['fromCity']} → ${load['toCity']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${load['materialType']} • ${load['truckType']} • ${load['weight']}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posted ${load['date']}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuperTruckerLoadCard extends StatelessWidget {
  final Map<String, dynamic> load;
  final bool isDark;

  const _SuperTruckerLoadCard({
    required this.load,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SUPER TRUCKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pending Approval',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${load['fromCity']} → ${load['toCity']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${load['materialType']} • ${load['truckType']} • ${load['weight']}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Requested ${load['requestedAt']}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Super Trucker Request Bottom Sheet
class SuperTruckerRequestBottomSheet extends StatefulWidget {
  const SuperTruckerRequestBottomSheet({super.key});

  @override
  State<SuperTruckerRequestBottomSheet> createState() => _SuperTruckerRequestBottomSheetState();
}

class _SuperTruckerRequestBottomSheetState extends State<SuperTruckerRequestBottomSheet> {
  int _selectedOption = 0; // 0 = existing load, 1 = new load
  String? _selectedLoadId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Request Super Trucker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get verified truckers for your load',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Option 1: Select existing load
              FlatCard(
                onTap: () => setState(() => _selectedOption = 0),
                borderColor: _selectedOption == 0 ? AppColors.primary : null,
                child: Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: _selectedOption,
                      onChanged: (value) => setState(() => _selectedOption = value!),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Existing Load',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose from your posted loads',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Create new load
              FlatCard(
                onTap: () => setState(() => _selectedOption = 1),
                borderColor: _selectedOption == 1 ? AppColors.primary : null,
                child: Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: _selectedOption,
                      onChanged: (value) => setState(() => _selectedOption = value!),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Load',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Post a new load for Super Truckers',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  // TODO: Handle submission
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Super Trucker request submitted'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
