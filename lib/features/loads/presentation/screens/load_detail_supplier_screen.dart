import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../providers/loads_provider.dart';
import '../widgets/empty_loads_state.dart';
import '../../../offers/presentation/providers/offers_provider.dart';
import '../../../deals/presentation/providers/deals_provider.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/load.dart';

class LoadDetailSupplierScreen extends ConsumerStatefulWidget {
  final String loadId;

  const LoadDetailSupplierScreen({
    super.key,
    required this.loadId,
  });

  @override
  ConsumerState<LoadDetailSupplierScreen> createState() =>
      _LoadDetailSupplierScreenState();
}

class _LoadDetailSupplierScreenState
    extends ConsumerState<LoadDetailSupplierScreen> {
  (String, Color) _statusMeta(Load load) {
    if (load.isExpired) return ('Expired', AppColors.danger);

    switch (load.status) {
      case 'negotiation':
        return ('Negotiation', Colors.orange);
      case 'booked':
        return ('Booked', Colors.blue);
      case 'completed':
        return ('Completed', AppColors.success);
      case 'active':
        return ('Active', AppColors.primary);
      default:
        return (load.status, AppColors.textSecondary);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(loadsNotifierProvider.notifier).fetchLoadById(widget.loadId);
      ref
          .read(offersNotifierProvider.notifier)
          .fetchOffersForLoad(widget.loadId);
    });
  }

  Future<void> _refreshOffers() async {
    final load = ref.read(loadsNotifierProvider).selectedLoad;
    if (load == null) return;
    await ref.read(offersNotifierProvider.notifier).fetchOffersForLoad(load.id);
  }

  Future<void> _counterOffer(String offerId) async {
    final priceController = TextEditingController();
    final messageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Counter Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Counter price (optional)',
              ),
            ),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Counter'),
          ),
        ],
      ),
    );

    final rawPrice = priceController.text.trim();
    final rawMessage = messageController.text.trim();
    priceController.dispose();
    messageController.dispose();

    if (confirmed != true) return;

    final updates = <String, dynamic>{
      'status': 'countered',
    };

    if (rawPrice.isNotEmpty) {
      final price = double.tryParse(rawPrice.replaceAll(',', ''));
      if (price == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid price')),
        );
        return;
      }
      updates['price'] = price;
    }

    if (rawMessage.isNotEmpty) {
      updates['message'] = rawMessage;
    }

    final updated = await ref
        .read(offersNotifierProvider.notifier)
        .updateOffer(offerId: offerId, updates: updates);

    if (!mounted) return;
    if (updated == null) {
      final err = ref.read(offersNotifierProvider).error ?? 'Action failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Counter offer sent')),
    );
  }

  Future<void> _rejectOffer(String offerId) async {
    final updated = await ref
        .read(offersNotifierProvider.notifier)
        .updateOffer(offerId: offerId, updates: {'status': 'rejected'});

    if (!mounted) return;
    if (updated == null) {
      final err = ref.read(offersNotifierProvider).error ?? 'Action failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer rejected')),
    );
  }

  Future<void> _acceptOffer(String offerId) async {
    final offerUpdated = await ref
        .read(offersNotifierProvider.notifier)
        .updateOffer(offerId: offerId, updates: {'status': 'accepted'});

    if (!mounted) return;
    if (offerUpdated == null) {
      final err = ref.read(offersNotifierProvider).error ?? 'Action failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    final loadUpdated = await ref
        .read(loadsNotifierProvider.notifier)
        .updateLoad(widget.loadId, {'status': 'booked'});

    if (!mounted) return;
    if (!loadUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer accepted but load update failed')),
      );
      return;
    }

    await ref.read(dealsNotifierProvider.notifier).ensureDeal(
          loadId: widget.loadId,
          supplierId: offerUpdated.supplierId,
          truckerId: offerUpdated.truckerId,
          offerId: offerUpdated.id,
          truckId: offerUpdated.truckId,
        );

    if (EnvConfig.enableAnalytics) {
      await AnalyticsService().trackBusinessEvent(
        'offer_accepted',
        properties: {
          'load_id': widget.loadId,
          'offer_id': offerUpdated.id,
        },
      );
    }

    // Best-effort notification to trucker.
    try {
      await Supabase.instance.client.rpc(
        'notify_offer_accepted',
        params: {
          'p_offer_id': offerUpdated.id,
        },
      );
    } catch (_) {
      // Notification failures should not block main flow.
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer accepted. Load booked.')),
    );
  }

  Future<void> _deleteLoad() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Load'),
        content: const Text('Are you sure you want to delete this load?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(loadsNotifierProvider.notifier)
          .deleteLoad(widget.loadId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Load deleted')),
        );
        context.pop();
      }
    }
  }

  Future<void> _markCompleted() async {
    final success = await ref
        .read(loadsNotifierProvider.notifier)
        .updateLoad(widget.loadId, {'status': 'completed'});

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load marked as completed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadsState = ref.watch(loadsNotifierProvider);
    final load = loadsState.selectedLoad;
    final offersState = ref.watch(offersNotifierProvider);

    if (loadsState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (load == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Load Details')),
        body: const EmptyLoadsState(
          message: 'Load not found',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteLoad,
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
                    Row(
                      children: [
                        Expanded(
                          child: GradientText(
                            'Load Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final meta = _statusMeta(load);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: AppDimensions.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: meta.$2.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
                                border: Border.all(
                                  color: meta.$2.withAlpha((0.4 * 255).round()),
                                ),
                              ),
                              child: Text(
                                meta.$1,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: meta.$2,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (load.status == 'negotiation') ...[
                      const SizedBox(height: AppDimensions.sm),
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Text(
                          'Negotiation in progress. You may receive new offers or counters.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                    if (load.status == 'booked') ...[
                      const SizedBox(height: AppDimensions.sm),
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Text(
                          'This load is booked. You should not accept additional offers.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.lg),
                    _DetailSection(
                      title: 'Route',
                      children: [
                        _DetailRow(
                            label: 'From', value: load.fromLocationDisplay),
                        _DetailRow(label: 'To', value: load.toLocationDisplay),
                      ],
                    ),
                    _DetailSection(
                      title: 'Load',
                      children: [
                        _DetailRow(label: 'Material', value: load.loadType),
                        _DetailRow(
                            label: 'Truck', value: load.truckTypeRequired),
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
                    _DetailSection(
                      title: 'Contacts',
                      children: [
                        _DetailRow(
                          label: 'Allow Calls',
                          value: load.contactPreferencesCall ? 'Yes' : 'No',
                        ),
                        _DetailRow(
                          label: 'Allow Chat',
                          value: load.contactPreferencesChat ? 'Yes' : 'No',
                        ),
                      ],
                    ),
                    _DetailSection(
                      title: 'Stats',
                      children: [
                        _DetailRow(
                            label: 'Views', value: load.viewCount.toString()),
                        _DetailRow(
                          label: 'Status',
                          value: load.isExpired ? 'Expired' : load.status,
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
                    _DetailSection(
                      title: 'Offers',
                      children: [
                        if (offersState.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (offersState.error != null)
                          Text(
                            'Error: ${offersState.error}',
                            style: const TextStyle(color: AppColors.danger),
                          )
                        else if (offersState.offers.isEmpty)
                          Text(
                            'No offers yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          )
                        else
                          ...offersState.offers.map(
                            (offer) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppDimensions.md),
                                child: GlassmorphicCard(
                                  padding:
                                      const EdgeInsets.all(AppDimensions.md),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Trucker: ${offer.truckerId}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                      Text(
                                        'Status: ${offer.status}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                      if (offer.price != null)
                                        Text(
                                          'Price: ${Formatters.formatCurrency(offer.price!)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      if (offer.message != null &&
                                          offer.message!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: AppDimensions.xs),
                                          child: Text(
                                            offer.message!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: AppColors
                                                        .textSecondary),
                                          ),
                                        ),
                                      const SizedBox(height: AppDimensions.sm),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: offer.status ==
                                                          'accepted' ||
                                                      load.status == 'booked'
                                                  ? null
                                                  : () =>
                                                      _counterOffer(offer.id),
                                              child: const Text('Counter'),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppDimensions.sm),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: offer.status ==
                                                          'accepted' ||
                                                      offer.status == 'rejected'
                                                  ? null
                                                  : () =>
                                                      _rejectOffer(offer.id),
                                              child: const Text('Reject'),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppDimensions.sm),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: offer.status ==
                                                          'accepted' ||
                                                      load.status == 'booked'
                                                  ? null
                                                  : () =>
                                                      _acceptOffer(offer.id),
                                              child: const Text('Accept'),
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
                        const SizedBox(height: AppDimensions.sm),
                        OutlinedButton.icon(
                          onPressed: _refreshOffers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Offers'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    ElevatedButton.icon(
                      onPressed: () => context.push(
                        '/post-load-step1',
                        extra: load,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Load'),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    OutlinedButton.icon(
                      onPressed: _markCompleted,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as Completed'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
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
