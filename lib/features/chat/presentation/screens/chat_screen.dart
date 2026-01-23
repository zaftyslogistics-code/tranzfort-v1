import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../deals/presentation/providers/deals_provider.dart';
import '../../../fleet/presentation/providers/fleet_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref
            .read(chatNotifierProvider.notifier)
            .markAsRead(widget.chatId, user.id);
      }
      ref.read(chatNotifierProvider.notifier).selectChat(widget.chatId);
      Future.microtask(_loadDealForChat);
    });
  }

  Future<void> _loadDealForChat() async {
    final chat = ref.read(chatNotifierProvider).selectedChat;
    if (chat == null) return;

    await ref.read(dealsNotifierProvider.notifier).fetchDeal(
          loadId: chat.loadId,
          supplierId: chat.supplierId,
          truckerId: chat.truckerId,
        );
  }

  Future<void> _showSendTruckCardSheet() async {
    final chat = ref.read(chatNotifierProvider).selectedChat;
    if (chat == null) return;

    await ref.read(fleetNotifierProvider.notifier).fetchTrucks();
    final trucks = ref.read(fleetNotifierProvider).trucks;

    if (!mounted) return;

    if (trucks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trucks found. Add a truck in Fleet.')),
      );
      return;
    }

    String? selectedTruckId;

    final saved = await showModalBottomSheet<bool>(
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
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    AppDimensions.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Send Truck Card',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  DropdownButtonFormField<String>(
                    value: selectedTruckId,
                    decoration: const InputDecoration(
                      labelText: 'Select Truck',
                    ),
                    items: trucks
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text('${t.truckNumber} • ${t.truckType}'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (val) => setModalState(() => selectedTruckId = val),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  ElevatedButton(
                    onPressed: selectedTruckId == null
                        ? null
                        : () async {
                            await ref.read(dealsNotifierProvider.notifier).ensureDeal(
                                  loadId: chat.loadId,
                                  supplierId: chat.supplierId,
                                  truckerId: chat.truckerId,
                                  truckId: selectedTruckId,
                                );

                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    child: const Text('Send'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (saved == true) {
      await _loadDealForChat();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Truck card sent')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await ref
        .read(chatNotifierProvider.notifier)
        .sendMessage(widget.chatId, user.id, text);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final chatState = ref.watch(chatNotifierProvider);
    final selectedChat = chatState.selectedChat;
    final dealsState = ref.watch(dealsNotifierProvider);
    ref.watch(fleetNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
          Column(
            children: [
              if (selectedChat != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    AppDimensions.md,
                    AppDimensions.md,
                    AppDimensions.sm,
                  ),
                  child: GlassmorphicCard(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            'Load #${selectedChat.loadId.substring(0, 6)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (selectedChat.unreadCount > 0)
                          Text(
                            '${selectedChat.unreadCount} unread',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (selectedChat != null && dealsState.deal?.truckId != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    0,
                    AppDimensions.md,
                    AppDimensions.sm,
                  ),
                  child: GlassmorphicCard(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: Supabase.instance.client
                          .from('trucks')
                          .select('truck_number, truck_type, capacity')
                          .eq('id', dealsState.deal!.truckId!)
                          .single(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 22,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (snapshot.hasError || snapshot.data == null) {
                          return Text(
                            'Truck card unavailable',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          );
                        }

                        final row = snapshot.data!;
                        return Row(
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${row['truck_number']} • ${row['truck_type']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Capacity: ${row['capacity']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              if (selectedChat != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    0,
                    AppDimensions.md,
                    AppDimensions.sm,
                  ),
                  child: GlassmorphicCard(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: Text(
                                'RC Sharing',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  dealsState.isLoading ? null : _loadDealForChat,
                              icon: const Icon(Icons.refresh, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        if (dealsState.error != null)
                          Text(
                            dealsState.error!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.danger),
                          )
                        else if (dealsState.deal == null)
                          Text(
                            'No deal created yet. Accept an offer to start RC workflow.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          )
                        else ...[
                          Text(
                            'Status: ${dealsState.deal!.rcShareStatus}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Builder(
                            builder: (context) {
                              final deal = dealsState.deal!;
                              final isSupplier = user?.id == deal.supplierId;
                              final isTrucker = user?.id == deal.truckerId;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (isTrucker)
                                    OutlinedButton.icon(
                                      onPressed: dealsState.isLoading ||
                                              dealsState.deal == null
                                          ? null
                                          : _showSendTruckCardSheet,
                                      icon: const Icon(Icons.badge_outlined),
                                      label: Text(
                                        dealsState.deal!.truckId == null
                                            ? 'Send Truck Card'
                                            : 'Change Truck Card',
                                      ),
                                    ),
                                  if (isSupplier)
                                    OutlinedButton.icon(
                                      onPressed: dealsState.isLoading ||
                                              deal.rcShareStatus == 'approved' ||
                                              deal.rcShareStatus == 'requested'
                                          ? null
                                          : () async {
                                              await ref
                                                  .read(dealsNotifierProvider
                                                      .notifier)
                                                  .requestRc();
                                            },
                                      icon: const Icon(Icons.lock_open_outlined),
                                      label: const Text('Request RC'),
                                    ),
                                  if (isTrucker)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: dealsState.isLoading ||
                                                    deal.rcShareStatus !=
                                                        'requested'
                                                ? null
                                                : () async {
                                                    await ref
                                                        .read(
                                                            dealsNotifierProvider
                                                                .notifier)
                                                        .approveRc();
                                                  },
                                            icon: const Icon(Icons.check),
                                            label: const Text('Approve'),
                                          ),
                                        ),
                                        const SizedBox(width: AppDimensions.sm),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: dealsState.isLoading ||
                                                    (deal.rcShareStatus !=
                                                            'approved' &&
                                                        deal.rcShareStatus !=
                                                            'requested')
                                                ? null
                                                : () async {
                                                    await ref
                                                        .read(
                                                            dealsNotifierProvider
                                                                .notifier)
                                                        .revokeRc();
                                                  },
                                            icon: const Icon(Icons.undo),
                                            label: const Text('Revoke'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (isSupplier)
                                    ElevatedButton.icon(
                                      onPressed: dealsState.isLoading ||
                                              deal.rcShareStatus != 'approved'
                                          ? null
                                          : () async {
                                              await ref
                                                  .read(dealsNotifierProvider
                                                      .notifier)
                                                  .loadSignedRcUrl();

                                              final url = ref
                                                  .read(dealsNotifierProvider)
                                                  .signedRcUrl;
                                              if (!context.mounted || url == null) {
                                                return;
                                              }

                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title:
                                                      const Text('RC Document'),
                                                  content: SizedBox(
                                                    width: 320,
                                                    height: 360,
                                                    child: Image.network(
                                                      url,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Center(
                                                            child: Text(
                                                                'Failed to load RC')); 
                                                      },
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context),
                                                      child: const Text('Close'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      icon: const Icon(Icons.picture_as_pdf),
                                      label: const Text('View RC (Signed URL)'),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = user?.id == message.senderId;
                        return MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text(
                      'Failed to load messages',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              MessageInput(
                controller: _messageController,
                onSend: _sendMessage,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
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
