import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../providers/loads_provider.dart';
import '../widgets/empty_loads_state.dart';

class LoadDetailTruckerScreen extends ConsumerStatefulWidget {
  final String loadId;

  const LoadDetailTruckerScreen({
    super.key,
    required this.loadId,
  });

  @override
  ConsumerState<LoadDetailTruckerScreen> createState() =>
      _LoadDetailTruckerScreenState();
}

class _LoadDetailTruckerScreenState
    extends ConsumerState<LoadDetailTruckerScreen> {
  bool _viewCountUpdated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchLoad();
    });
  }

  Future<void> _fetchLoad() async {
    await ref.read(loadsNotifierProvider.notifier).fetchLoadById(widget.loadId);

    if (!_viewCountUpdated && mounted) {
      final load = ref.read(loadsNotifierProvider).selectedLoad;
      if (load != null) {
        _viewCountUpdated = true;
        await ref
            .read(loadsNotifierProvider.notifier)
            .updateLoad(load.id, {'viewCount': load.viewCount + 1});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadsState = ref.watch(loadsNotifierProvider);
    final load = loadsState.selectedLoad;

    if (loadsState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (load == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Load Details')),
        body: const EmptyLoadsState(message: 'Load not found'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Load Details')),
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
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradientText(
                      'Load Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _DetailSection(
                      title: 'Route',
                      children: [
                        _DetailRow(label: 'From', value: load.fromLocationDisplay),
                        _DetailRow(label: 'To', value: load.toLocationDisplay),
                      ],
                    ),
                    _DetailSection(
                      title: 'Load',
                      children: [
                        _DetailRow(label: 'Material', value: load.loadType),
                        _DetailRow(label: 'Truck', value: load.truckTypeRequired),
                        if (load.weight != null)
                          _DetailRow(
                            label: 'Weight',
                            value: '${load.weight!.toStringAsFixed(1)} tons',
                          ),
                      ],
                    ),
                    _DetailSection(
                      title: 'Pricing',
                      children: [
                        _DetailRow(
                          label: 'Price',
                          value: load.price != null
                              ? Formatters.formatCurrency(load.price!)
                              : 'Negotiable',
                        ),
                        if (load.paymentTerms != null &&
                            load.paymentTerms!.isNotEmpty)
                          _DetailRow(
                            label: 'Payment Terms',
                            value: load.paymentTerms!,
                          ),
                      ],
                    ),
                    _DetailSection(
                      title: 'Schedule',
                      children: [
                        _DetailRow(
                          label: 'Loading Date',
                          value: load.loadingDate != null
                              ? Formatters.formatDate(load.loadingDate!)
                              : 'Not specified',
                        ),
                        _DetailRow(
                          label: 'Expires',
                          value: Formatters.formatDate(load.expiresAt),
                        ),
                      ],
                    ),
                    if (load.notes != null && load.notes!.isNotEmpty)
                      _DetailSection(
                        title: 'Notes',
                        children: [
                          Text(
                            load.notes!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppDimensions.xl),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/chats'),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat with Supplier'),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Call feature coming soon')),
                        );
                      },
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Call Supplier'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppDimensions.sm),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
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
