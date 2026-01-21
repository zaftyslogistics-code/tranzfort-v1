import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/free_badge.dart';
import '../../domain/entities/truck.dart';
import '../../domain/entities/truck_specification.dart';
import '../../../../shared/widgets/simple_truck_type_selector.dart';
import '../providers/fleet_provider.dart';

class AddTruckScreen extends ConsumerStatefulWidget {
  final Truck? truck; // For editing

  const AddTruckScreen({super.key, this.truck});

  @override
  ConsumerState<AddTruckScreen> createState() => _AddTruckScreenState();
}

class _AddTruckScreenState extends ConsumerState<AddTruckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _truckNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  
  TruckSpecification? _selectedSpecification;
  String? _selectedTruckType;
  DateTime? _rcExpiryDate;
  DateTime? _insuranceExpiryDate;
  XFile? _rcDocument;
  XFile? _insuranceDocument;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.truck != null) {
      _populateFields(widget.truck!);
    }
  }

  void _populateFields(Truck truck) {
    _truckNumberController.text = truck.truckNumber;
    _capacityController.text = truck.capacity.toString();
    // TODO: Find matching specification based on truck.truckType
    // For now, we'll set a default specification
    _selectedSpecification = TruckSpecification.getSmartIndianTruckSpecifications().first;
    _rcExpiryDate = truck.rcExpiryDate;
    _insuranceExpiryDate = truck.insuranceExpiryDate;
  }

  @override
  void dispose() {
    _truckNumberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.truck != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Truck' : 'Add New Truck'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.danger),
              onPressed: _deleteTruck,
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
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              // Header Card
              GlassmorphicCard(
                backgroundColor: AppColors.glassSurfaceStrong,
                padding: const EdgeInsets.all(AppDimensions.lg),
                showGlow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GradientText(
                          isEditing ? 'Edit Truck Details' : 'Add New Truck',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        FreeBadge(text: isEditing ? 'EDIT' : 'NEW'),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      isEditing 
                        ? 'Update your truck information below'
                        : 'Fill in the details to add a new truck to your fleet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // Form Card
              GlassmorphicCard(
                backgroundColor: AppColors.glassSurfaceStrong,
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Truck Number
                      Text(
                        'Truck Number',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      TextFormField(
                        controller: _truckNumberController,
                        decoration: InputDecoration(
                          labelText: 'e.g., MH-12-AB-1234',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter truck number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.lg),

                      // Truck Specification
                      // SmartTruckSpecificationSelector(
                      //   initialSpec: _selectedSpecification,
                      //   onSpecificationSelected: (TruckSpecification spec) {
                      //     setState(() {
                      //       _selectedSpecification = spec;
                      //       // Auto-fill capacity based on specification
                      //       _capacityController.text = spec.maxCapacity.toString();
                      //     });
                      //   },
                      // ),
                      
                      // Truck Type Selection
                      SimpleTruckTypeSelector(
                        initialType: _selectedTruckType,
                        onTruckTypeSelected: (String truckType) {
                          setState(() {
                            _selectedTruckType = truckType;
                            // Auto-fill capacity based on truck type
                            if (truckType.contains('6 Tyres')) {
                              _capacityController.text = '10';
                            } else if (truckType.contains('10 Tyres')) {
                              _capacityController.text = '15';
                            } else if (truckType.contains('14 Tyres')) {
                              _capacityController.text = '20';
                            } else if (truckType.contains('8 Tyres')) {
                              _capacityController.text = '8';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.lg),

                      // Capacity (Auto-filled from specification)
                      Text(
                        'Capacity (tons)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Auto-filled from truck type',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.glassBorder),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter capacity';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.lg),

                      // Specification Summary
                      if (_selectedSpecification != null)
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.md),
                          decoration: BoxDecoration(
                            color: AppColors.truckPrimary.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(color: AppColors.truckPrimary.withAlpha((0.3 * 255).round())),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Specification:',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedSpecification!.tyreCount} Tyres • ${_selectedSpecification!.bodyType}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              Text(
                                'Capacity: ${_selectedSpecification!.capacityRange}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),

                      // Document Uploads
                      Text(
                        'Documents',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      
                      // RC Document
                      _buildDocumentUpload(
                        'RC Document',
                        _rcDocument,
                        (file) => setState(() => _rcDocument = file),
                        _rcExpiryDate,
                        (date) => setState(() => _rcExpiryDate = date),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      
                      // Insurance Document
                      _buildDocumentUpload(
                        'Insurance Document',
                        _insuranceDocument,
                        (file) => setState(() => _insuranceDocument = file),
                        _insuranceExpiryDate,
                        (date) => setState(() => _insuranceExpiryDate = date),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Submit Button
              GlassmorphicButton(
                variant: GlassmorphicButtonVariant.primary,
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(isEditing ? 'Update Truck' : 'Add Truck'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload(
    String title,
    XFile? document,
    Function(XFile) onDocumentSelected,
    DateTime? expiryDate,
    Function(DateTime) onExpiryDateSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (document != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: AppDimensions.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    'Uploaded',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          
          // Upload Button
          OutlinedButton.icon(
            onPressed: () => _pickDocument(onDocumentSelected),
            icon: const Icon(Icons.upload_file, size: 16),
            label: Text(document == null ? 'Upload Document' : 'Change Document'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: AppColors.truckPrimary),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          
          // Expiry Date
          InkWell(
            onTap: () => _selectExpiryDate(onExpiryDateSelected, expiryDate),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    expiryDate != null 
                        ? 'Expires: ${_formatDate(expiryDate)}'
                        : 'Select Expiry Date',
                    style: TextStyle(
                      color: expiryDate != null ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocument(Function(XFile) onSelected) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      onSelected(file);
    }
  }

  Future<void> _selectExpiryDate(Function(DateTime) onSelected, DateTime? currentDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      onSelected(date);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTruckType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a truck type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(fleetNotifierProvider.notifier);
      final truckData = {
        'truck_number': _truckNumberController.text,
        'truck_type': _selectedTruckType,
        'capacity': double.tryParse(_capacityController.text) ?? 0.0,
        'rc_expiry_date': _rcExpiryDate?.toIso8601String(),
        'insurance_expiry_date': _insuranceExpiryDate?.toIso8601String(),
      };

      bool success;
      if (widget.truck != null) {
        success = await notifier.updateTruck(
          widget.truck!.id,
          truckData,
          rcDocument: _rcDocument,
          insuranceDocument: _insuranceDocument,
        );
      } else {
        success = await notifier.addTruck(
          truckData,
          rcDocument: _rcDocument,
          insuranceDocument: _insuranceDocument,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.truck != null
                  ? 'Truck updated successfully'
                  : 'Truck added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else {
          final error = ref.read(fleetNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to save truck'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteTruck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassSurfaceStrong,
        title: Text(
          'Delete Truck',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${widget.truck!.truckNumber}? This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              setState(() => _isLoading = true);
              final success = await ref
                  .read(fleetNotifierProvider.notifier)
                  .deleteTruck(widget.truck!.id);
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Truck deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop(); // Close screen
                } else {
                  final error = ref.read(fleetNotifierProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Failed to delete truck'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
