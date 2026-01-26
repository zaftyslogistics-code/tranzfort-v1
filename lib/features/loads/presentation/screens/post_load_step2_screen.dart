import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/load.dart';
import '../providers/loads_provider.dart';
import '../widgets/load_form_field.dart';

class PostLoadStep2Screen extends ConsumerStatefulWidget {
  final Map<String, dynamic> loadData;
  final Load? existingLoad;
  final String onSuccessRoute;
  final bool showBottomNavigation;
  final bool forceSuperLoad;

  const PostLoadStep2Screen({
    super.key,
    required this.loadData,
    this.existingLoad,
    this.onSuccessRoute = '/supplier-dashboard',
    this.showBottomNavigation = true,
    this.forceSuperLoad = false,
  });

  @override
  ConsumerState<PostLoadStep2Screen> createState() =>
      _PostLoadStep2ScreenState();
}

class _PostLoadStep2ScreenState extends ConsumerState<PostLoadStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _loadingDate;
  bool _allowCall = true;
  bool _allowChat = true;
  bool get _isEdit => widget.existingLoad != null;

  @override
  void initState() {
    super.initState();
    final load = widget.existingLoad;
    if (load != null) {
      _priceController.text = load.price?.toStringAsFixed(0) ?? '';
      _paymentTermsController.text = load.paymentTerms ?? '';
      _notesController.text = load.notes ?? '';
      _loadingDate = load.loadingDate;
      _allowCall = load.contactPreferencesCall;
      _allowChat = load.contactPreferencesChat;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _paymentTermsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickLoadingDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );

    if (selected != null) {
      setState(() => _loadingDate = selected);
    }
  }

  Future<void> _submitLoad() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final payload = {
      ...widget.loadData,
      'supplierId': user.id,
      if (widget.forceSuperLoad) 'isSuperLoad': true,
      if (widget.forceSuperLoad) 'postedByAdminId': user.id,
      'price': double.tryParse(_priceController.text),
      'paymentTerms': _paymentTermsController.text.isEmpty
          ? null
          : _paymentTermsController.text,
      'loadingDate': _loadingDate?.toIso8601String(),
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
      'contactPreferencesCall': _allowCall,
      'contactPreferencesChat': _allowChat,
    };

    final loadsNotifier = ref.read(loadsNotifierProvider.notifier);

    bool success;
    String? auditEntityId;

    if (widget.forceSuperLoad) {
      if (_isEdit) {
        final updated = await loadsNotifier.updateLoadReturningLoad(
          widget.existingLoad!.id,
          payload,
        );
        success = updated != null;
        auditEntityId = updated?.id;
        if (success) {
          await _logSuperLoadAudit(
            action: 'super_load_updated',
            entityId: auditEntityId!,
          );
        }
      } else {
        final created = await loadsNotifier.createLoadReturningLoad(payload);
        success = created != null;
        auditEntityId = created?.id;
        if (success) {
          await _logSuperLoadAudit(
            action: 'super_load_created',
            entityId: auditEntityId!,
          );
        }
      }
    } else {
      success = _isEdit
          ? await loadsNotifier.updateLoad(widget.existingLoad!.id, payload)
          : await loadsNotifier.createLoad(payload);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Load updated successfully'
              : 'Load posted successfully'),
        ),
      );
      context.go(widget.onSuccessRoute);
    } else if (mounted) {
      final error = ref.read(loadsNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to post load')),
      );
    }
  }

  Future<void> _logSuperLoadAudit({
    required String action,
    required String entityId,
  }) async {
    try {
      final adminId = ref.read(authNotifierProvider).user?.id;
      if (adminId == null) return;

      await Supabase.instance.client.from('audit_logs').insert({
        'admin_id': adminId,
        'action': action,
        'entity_type': 'load',
        'entity_id': entityId,
      });
    } catch (_) {
      // Best-effort only.
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadsState = ref.watch(loadsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Load - Step 2'),
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
          const Positioned(
            top: -140,
            right: -120,
            child: _GlowOrb(
              size: 280,
              color: AppColors.cyanGlowStrong,
            ),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(
              size: 320,
              color: AppColors.primary,
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.lg),
                children: [
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GradientText(
                          _isEdit ? 'Edit Load - Step 2' : 'Post Load - Step 2',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        Text(
                          'Pricing & Preferences',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        LoadFormField(
                          label: 'Price (₹)',
                          controller: _priceController,
                          hint: 'Optional',
                          keyboardType: TextInputType.number,
                          validator: Validators.validatePrice,
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        LoadFormField(
                          label: 'Payment Terms',
                          controller: _paymentTermsController,
                          hint: 'Advance / To Pay / Negotiable',
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        LoadFormField(
                          label: 'Loading Date',
                          controller: TextEditingController(
                            text: _loadingDate == null
                                ? ''
                                : '${_loadingDate!.day}/${_loadingDate!.month}/${_loadingDate!.year}',
                          ),
                          readOnly: true,
                          onTap: _pickLoadingDate,
                          hint: 'Select date',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        LoadFormField(
                          label: 'Notes',
                          controller: _notesController,
                          hint: 'Any special instructions (optional)',
                          maxLines: 4,
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        Text(
                          'Contact Preferences',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        SwitchListTile(
                          value: _allowCall,
                          onChanged: (value) =>
                              setState(() => _allowCall = value),
                          title: const Text('Allow Calls'),
                        ),
                        SwitchListTile(
                          value: _allowChat,
                          onChanged: (value) =>
                              setState(() => _allowChat = value),
                          title: const Text('Allow Chat'),
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        ElevatedButton(
                          onPressed: loadsState.isLoading ? null : _submitLoad,
                          child: loadsState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isEdit ? 'Update Load' : 'Post Load'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          widget.showBottomNavigation ? const AppBottomNavigation() : null,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withAlpha((0.35 * 255).round()),
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}
