/// MaterialTypeSelector Widget
/// 
/// Searchable dropdown for selecting material types.
/// Shows recently used materials at top, then common materials.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/material_types.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class MaterialTypeSelector extends StatefulWidget {
  final String? selectedMaterialId;
  final String? customMaterialName;
  final ValueChanged<String> onMaterialSelected;
  final ValueChanged<String>? onCustomMaterialEntered;
  final String? errorText;

  const MaterialTypeSelector({
    super.key,
    this.selectedMaterialId,
    this.customMaterialName,
    required this.onMaterialSelected,
    this.onCustomMaterialEntered,
    this.errorText,
  });

  @override
  State<MaterialTypeSelector> createState() => _MaterialTypeSelectorState();
}

class _MaterialTypeSelectorState extends State<MaterialTypeSelector> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<String> _recentMaterials = [];

  @override
  void initState() {
    super.initState();
    _loadRecentMaterials();
    if (widget.customMaterialName != null) {
      _customController.text = widget.customMaterialName!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(kRecentMaterialsKey) ?? [];
    setState(() {
      _recentMaterials = recent;
    });
  }

  Future<void> _addToRecentMaterials(String materialId) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = List<String>.from(_recentMaterials);
    
    // Remove if already exists
    recent.remove(materialId);
    // Add to front
    recent.insert(0, materialId);
    // Limit size
    if (recent.length > kMaxRecentMaterials) {
      recent.removeLast();
    }
    
    await prefs.setStringList(kRecentMaterialsKey, recent);
    setState(() {
      _recentMaterials = recent;
    });
  }

  MaterialTypeData? get _selectedMaterial {
    if (widget.selectedMaterialId == null) return null;
    return getMaterialTypeById(widget.selectedMaterialId!);
  }

  bool get _isOtherSelected => widget.selectedMaterialId == 'other';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main selector button
        GestureDetector(
          onTap: () => _showMaterialSheet(context),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              border: Border.all(
                color: widget.errorText != null
                    ? AppColors.error
                    : AppColors.borderLight.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                if (_selectedMaterial != null) ...[
                  Text(
                    _selectedMaterial!.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isOtherSelected && widget.customMaterialName != null
                          ? widget.customMaterialName!
                          : _selectedMaterial!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select material type',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Error text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.paddingXSmall,
              left: AppDimensions.paddingSmall,
            ),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),

        // Custom input (visible when "Other" is selected)
        if (_isOtherSelected) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          TextField(
            controller: _customController,
            decoration: InputDecoration(
              hintText: 'Enter material name',
              prefixIcon: const Icon(Icons.edit_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
            ),
            onChanged: (value) {
              widget.onCustomMaterialEntered?.call(value);
            },
          ),
        ],
      ],
    );
  }

  void _showMaterialSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MaterialSelectionSheet(
        selectedMaterialId: widget.selectedMaterialId,
        recentMaterials: _recentMaterials,
        onSelect: (materialId) {
          _addToRecentMaterials(materialId);
          widget.onMaterialSelected(materialId);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Bottom sheet for material selection
class _MaterialSelectionSheet extends StatefulWidget {
  final String? selectedMaterialId;
  final List<String> recentMaterials;
  final ValueChanged<String> onSelect;

  const _MaterialSelectionSheet({
    this.selectedMaterialId,
    required this.recentMaterials,
    required this.onSelect,
  });

  @override
  State<_MaterialSelectionSheet> createState() => _MaterialSelectionSheetState();
}

class _MaterialSelectionSheetState extends State<_MaterialSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MaterialTypeData> get _filteredMaterials {
    return searchMaterialTypes(_searchQuery);
  }

  List<MaterialTypeData> get _recentMaterialsList {
    return widget.recentMaterials
        .map((id) => getMaterialTypeById(id))
        .whereType<MaterialTypeData>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with search
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Material',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search materials...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Material list
          Expanded(
            child: ListView(
              children: [
                // Recent materials section
                if (_recentMaterialsList.isNotEmpty && _searchQuery.isEmpty) ...[
                  _buildSectionHeader('Recently Used'),
                  ..._recentMaterialsList.map((material) => _buildMaterialTile(material)),
                  const Divider(),
                ],

                // All materials section
                _buildSectionHeader(_searchQuery.isEmpty ? 'All Materials' : 'Search Results'),
                ..._filteredMaterials.map((material) => _buildMaterialTile(material)),

                // Bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingSmall,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMaterialTile(MaterialTypeData material) {
    final isSelected = widget.selectedMaterialId == material.id;

    return ListTile(
      leading: Text(
        material.icon,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        material.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () => widget.onSelect(material.id),
    );
  }
}
