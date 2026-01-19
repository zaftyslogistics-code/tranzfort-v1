import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/admin_config_provider.dart';

class AdminConfigScreen extends ConsumerStatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  ConsumerState<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends ConsumerState<AdminConfigScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminConfigNotifierProvider.notifier).fetchConfig());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminConfigNotifierProvider);
    final config = state.config;
    final notifier = ref.read(adminConfigNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.error != null) ...[
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
              const SizedBox(height: AppDimensions.lg),
            ],
            _ConfigSection(
              title: 'Monetization & Ads',
              children: [
                SwitchListTile(
                  title: const Text('Enable AdMob Ads'),
                  subtitle: const Text('Global toggle for all banner and native ads'),
                  value: config.enableAds,
                  onChanged: notifier.updateEnableAds,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            _ConfigSection(
              title: 'Verification Fees (INR)',
              children: [
                _ConfigInput(
                  label: 'Trucker Verification Fee',
                  value: config.verificationFeeTrucker.toString(),
                  onChanged: (val) => notifier.updateVerificationFeeTrucker(int.tryParse(val) ?? 0),
                ),
                const SizedBox(height: AppDimensions.md),
                _ConfigInput(
                  label: 'Supplier Verification Fee',
                  value: config.verificationFeeSupplier.toString(),
                  onChanged: (val) => notifier.updateVerificationFeeSupplier(int.tryParse(val) ?? 0),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            _ConfigSection(
              title: 'Marketplace Rules',
              children: [
                _ConfigInput(
                  label: 'Load Expiry (Days)',
                  value: config.loadExpiryDays.toString(),
                  onChanged: (val) => notifier.updateLoadExpiryDays(int.tryParse(val) ?? 0),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton(
              onPressed: state.isSaving
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await notifier.saveConfig();
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Configuration saved successfully'
                              : 'Failed to save configuration'),
                          backgroundColor: ok ? AppColors.success : AppColors.danger,
                        ),
                      );
                    },
              child: state.isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ConfigSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: AppDimensions.md),
        Card(
          color: AppColors.glassSurfaceStrong,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _ConfigInput extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _ConfigInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onSubmitted: onChanged,
    );
  }
}
