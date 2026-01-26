import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_card.dart';

/// Trucker Results Screen v0.02
/// Shows loads matching search criteria
/// - Expandable filter header
/// - Tab bar: All Loads / Super Loads
/// - Flat load cards
/// - Infinite scroll pagination
class TruckerResultsScreen extends ConsumerStatefulWidget {
  final String? fromLocation;
  final String? toLocation;

  const TruckerResultsScreen({
    super.key,
    this.fromLocation,
    this.toLocation,
  });

  @override
  ConsumerState<TruckerResultsScreen> createState() => _TruckerResultsScreenState();
}

class _TruckerResultsScreenState extends ConsumerState<TruckerResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFilterExpanded = false;

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
      body: SafeArea(
        child: Column(
          children: [
            // Header with route info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.fromLocation ?? "Any"} → ${widget.toLocation ?? "Any"}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              '24 loads found',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFilterExpanded ? Icons.expand_less : Icons.tune,
                        ),
                        onPressed: () {
                          setState(() => _isFilterExpanded = !_isFilterExpanded);
                        },
                      ),
                    ],
                  ),

                  // Expandable Filters
                  if (_isFilterExpanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // TODO: Add filter chips (Truck Type, Material Type, Weight, Price Range)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChip(label: 'Truck Type', isDark: isDark),
                              _FilterChip(label: 'Material', isDark: isDark),
                              _FilterChip(label: 'Weight', isDark: isDark),
                              _FilterChip(label: 'Price', isDark: isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

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
                  Tab(text: 'Super Loads'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All Loads Tab
                  _LoadsList(isDark: isDark, isSuperLoads: false),
                  
                  // Super Loads Tab
                  _LoadsList(isDark: isDark, isSuperLoads: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadsList extends StatelessWidget {
  final bool isDark;
  final bool isSuperLoads;

  const _LoadsList({
    required this.isDark,
    required this.isSuperLoads,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data
    final loads = List.generate(
      10,
      (index) => {
        'fromCity': 'Mumbai',
        'toCity': 'Delhi',
        'materialType': 'Steel',
        'truckType': '32 Ft Trailer',
        'price': '₹45,000',
        'weight': '20 tons',
        'date': 'Today',
        'supplierName': 'ABC Transport',
        'isVerified': true,
        'isSuperLoad': isSuperLoads,
      },
    );

    if (loads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isSuperLoads ? 'No Super Loads available' : 'No loads found',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loads.length,
      itemBuilder: (context, index) {
        final load = loads[index];
        return LoadCard(
          fromCity: load['fromCity'] as String,
          toCity: load['toCity'] as String,
          materialType: load['materialType'] as String,
          truckType: load['truckType'] as String,
          price: load['price'] as String,
          weight: load['weight'] as String,
          date: load['date'] as String,
          supplierName: load['supplierName'] as String,
          isVerified: load['isVerified'] as bool,
          isSuperLoad: load['isSuperLoad'] as bool,
          onTap: () {
            // TODO: Navigate to load detail
          },
          onBookmark: () {
            // TODO: Toggle bookmark
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Open filter dialog
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
