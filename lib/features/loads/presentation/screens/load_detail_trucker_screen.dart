import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/price_display.dart';
import '../../../../shared/widgets/supplier_mini_card.dart';
import '../../../../shared/widgets/load_status_badge.dart';
import '../../../profile/presentation/providers/supplier_profile_provider.dart';
import '../providers/loads_provider.dart';
import '../widgets/empty_loads_state.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/share_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../fleet/presentation/providers/fleet_provider.dart';
import '../../../offers/presentation/providers/offers_provider.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/load.dart';

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
  bool _isBookmarked = false;

  Future<void> _openChatForLoad() async {
    final user = ref.read(authNotifierProvider).user;
    final load = ref.read(loadsNotifierProvider).selectedLoad;

    if (user == null || load == null) return;

    final chatId =
        await ref.read(chatNotifierProvider.notifier).getOrCreateChatId(
              loadId: load.id,
              supplierId: load.supplierId,
              truckerId: user.id,
            );

    if (!mounted) return;

    if (chatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open chat')),
      );
      return;
    }

    context.push('/chat', extra: chatId);
  }

  Future<void> _showMakeOfferSheet() async {
    final user = ref.read(authNotifierProvider).user;
    final load = ref.read(loadsNotifierProvider).selectedLoad;
    if (user == null || load == null) return;

    final fleetState = ref.read(fleetNotifierProvider);
    final trucks = fleetState.trucks;

    final priceController = TextEditingController();
    final messageController = TextEditingController();
    String? selectedTruckId;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.glassSurfaceStrong,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.lg,
                right: AppDimensions.lg,
                top: AppDimensions.lg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppDimensions.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Make Offer',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  TextField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price (optional)',
                      hintText: 'Enter your offer amount',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Message (optional)',
                      hintText: 'Add any notes for the supplier',
                    ),
                  ),
                  if (trucks.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.sm),
                    DropdownButtonFormField<String>(
                      value: selectedTruckId,
                      decoration: const InputDecoration(
                        labelText: 'Select Truck (optional)',
                      ),
                      items: trucks
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text('${t.truckNumber} • ${t.truckType}'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (val) =>
                          setModalState(() => selectedTruckId = val),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.lg),
                  Consumer(
                    builder: (context, ref, _) {
                      final offersState = ref.watch(offersNotifierProvider);
                      return ElevatedButton(
                        onPressed: offersState.isLoading
                            ? null
                            : () async {
                                final rawPrice = priceController.text.trim();
                                final price = rawPrice.isEmpty
                                    ? null
                                    : double.tryParse(
                                        rawPrice.replaceAll(',', ''),
                                      );

                                if (rawPrice.isNotEmpty && price == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid price')),
                                  );
                                  return;
                                }

                                final offer = await ref
                                    .read(offersNotifierProvider.notifier)
                                    .createOffer(
                                      loadId: load.id,
                                      supplierId: load.supplierId,
                                      truckerId: user.id,
                                      truckId: selectedTruckId,
                                      price: price,
                                      message:
                                          messageController.text.trim().isEmpty
                                              ? null
                                              : messageController.text.trim(),
                                    );

                                if (offer == null) {
                                  if (!context.mounted) return;
                                  final err =
                                      ref.read(offersNotifierProvider).error ??
                                          'Failed to create offer';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(err)),
                                  );
                                  return;
                                }

                                if (EnvConfig.enableAnalytics) {
                                  await AnalyticsService().trackBusinessEvent(
                                    'offer_created',
                                    properties: {
                                      'load_id': load.id,
                                    },
                                  );
                                }

                                if (!context.mounted) return;
                                Navigator.pop(context, true);
                              },
                        child: offersState.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Submit Offer'),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    priceController.dispose();
    messageController.dispose();

    if (!mounted) return;
    if (result == true) {
      final latestLoad = ref.read(loadsNotifierProvider).selectedLoad;
      if (latestLoad != null && latestLoad.status == 'active') {
        await ref
            .read(loadsNotifierProvider.notifier)
            .updateLoad(latestLoad.id, {'status': 'negotiation'});
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer submitted')),
      );
    }
  }

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
    final user = ref.watch(authNotifierProvider).user;
    final canContact = user?.isTruckerVerified ?? false;
    final canOffer = canContact &&
        load != null &&
        !load.isExpired &&
        load.status != 'booked' &&
        load.status != 'completed';

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

    final supplierAsync = ref.watch(supplierProfileProvider(load.supplierId));

    final priceData = PriceData(
      priceType: PriceType.fromString(load.priceType),
      ratePerTon: load.ratePerTon,
      fixedPrice: load.price,
      weightTons: load.weight,
      advanceRequired: load.advanceRequired,
      advancePercent: load.advancePercent,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Details'),
        actions: [
          BookmarkButton(
            isBookmarked: _isBookmarked,
            onToggle: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked ? 'Load bookmarked' : 'Bookmark removed',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          ShareButton(
            loadId: load.id,
            fromCity: load.fromCity,
            toCity: load.toCity,
            truckType: load.truckTypeRequired,
          ),
          const SizedBox(width: 8),
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
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (load.isSuperLoad) ...[
                                  const _SuperLoadBadge(),
                                  const SizedBox(width: AppDimensions.xs),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.sm,
                                    vertical: AppDimensions.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: meta.$2
                                        .withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusSm),
                                    border: Border.all(
                                      color: meta.$2
                                          .withAlpha((0.4 * 255).round()),
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
                                ),
                              ],
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
                          'Negotiation in progress. Prices and terms may be changing.',
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
                          'This load is already booked. New offers are disabled.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.lg),
                    supplierAsync.when(
                      data: (supplier) {
                        return SupplierCard(
                          supplierId: supplier.id,
                          supplierName: supplier.name,
                          fullName: supplier.fullName,
                          location: supplier.location,
                          phoneNumber: supplier.phone,
                          rating: supplier.rating,
                          ratingCount: supplier.ratingCount,
                          isVerified: supplier.isVerified,
                          onTap: () => context.push(
                            '/supplier-profile/${supplier.id}',
                          ),
                          onChatTap: canContact ? _openChatForLoad : null,
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
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
                        PriceDisplayDetailed(priceData: priceData),
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
                    OutlinedButton.icon(
                      onPressed: canOffer ? _showMakeOfferSheet : null,
                      icon: const Icon(Icons.local_offer_outlined),
                      label: Text(
                        load.status == 'booked'
                            ? 'Offers Closed'
                            : 'Make Offer',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    ElevatedButton.icon(
                      onPressed: canContact ? _openChatForLoad : null,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat with Supplier'),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    OutlinedButton.icon(
                      onPressed: canContact
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Call feature coming soon'),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Call Supplier'),
                    ),
                    if (!canContact) ...[
                      const SizedBox(height: AppDimensions.md),
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Verification required',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text(
                              'Get verified to unlock chat and call features.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            ElevatedButton(
                              onPressed: () => context.push('/verification'),
                              child: const Text('Get Verified'),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SuperLoadBadge extends StatelessWidget {
  const _SuperLoadBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xxs,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD54F),
            Color(0xFFFFA000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: const Color(0xFFFFD54F),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FFD54F),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'SUPER LOAD',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
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
