import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_card.dart';

/// Admin Support Inbox Screen v0.02
/// Shows all support tickets with tabs and filters
/// - Tabs: All / General / Super Loads / Super Truckers
/// - Ticket list with status badges
/// - Flat design
class AdminSupportInboxScreen extends ConsumerStatefulWidget {
  const AdminSupportInboxScreen({super.key});

  @override
  ConsumerState<AdminSupportInboxScreen> createState() => _AdminSupportInboxScreenState();
}

class _AdminSupportInboxScreenState extends ConsumerState<AdminSupportInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all'; // all, open, in_progress, resolved

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Support Inbox'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Status')),
              const PopupMenuItem(value: 'open', child: Text('Open')),
              const PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
              const PopupMenuItem(value: 'resolved', child: Text('Resolved')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Open', count: 12, isDark: isDark),
                _StatItem(label: 'In Progress', count: 5, isDark: isDark),
                _StatItem(label: 'Resolved', count: 48, isDark: isDark),
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
              isScrollable: true,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'General'),
                Tab(text: 'Super Loads'),
                Tab(text: 'Super Truckers'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TicketList(ticketType: 'all', statusFilter: _selectedStatus, isDark: isDark),
                _TicketList(ticketType: 'general_support', statusFilter: _selectedStatus, isDark: isDark),
                _TicketList(ticketType: 'super_load_request', statusFilter: _selectedStatus, isDark: isDark),
                _TicketList(ticketType: 'super_trucker_request', statusFilter: _selectedStatus, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _TicketList extends StatelessWidget {
  final String ticketType;
  final String statusFilter;
  final bool isDark;

  const _TicketList({
    required this.ticketType,
    required this.statusFilter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Mock tickets
    final tickets = _getMockTickets(ticketType, statusFilter);

    if (tickets.isEmpty) {
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
              'No tickets found',
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
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _TicketCard(
          ticket: ticket,
          isDark: isDark,
          onTap: () {
            context.push('/admin/support/ticket/${ticket['id']}');
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMockTickets(String type, String status) {
    final allTickets = [
      {
        'id': 'ticket_1',
        'type': 'super_load_request',
        'subject': 'Super Loads Access Request',
        'userName': 'Rajesh Kumar',
        'userPhone': '+91 98765 43210',
        'status': 'open',
        'createdAt': '2 hours ago',
        'unreadCount': 2,
      },
      {
        'id': 'ticket_2',
        'type': 'super_trucker_request',
        'subject': 'Super Trucker Request for Load #123',
        'userName': 'ABC Transport Ltd',
        'userPhone': '+91 98765 43211',
        'status': 'in_progress',
        'createdAt': '5 hours ago',
        'unreadCount': 0,
      },
      {
        'id': 'ticket_3',
        'type': 'general_support',
        'subject': 'Unable to post load',
        'userName': 'Suresh Sharma',
        'userPhone': '+91 98765 43212',
        'status': 'open',
        'createdAt': '1 day ago',
        'unreadCount': 1,
      },
    ];

    return allTickets.where((ticket) {
      final typeMatch = type == 'all' || ticket['type'] == type;
      final statusMatch = status == 'all' || ticket['status'] == status;
      return typeMatch && statusMatch;
    }).toList();
  }
}

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final bool isDark;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket['status'] as String);
    final typeLabel = _getTypeLabel(ticket['type'] as String);

    return FlatCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (ticket['status'] as String).toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  typeLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (ticket['unreadCount'] > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket['unreadCount'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket['subject'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                ticket['userName'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                ticket['userPhone'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket['createdAt'] as String,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.info;
      case 'resolved':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'super_load_request':
        return 'SUPER LOADS';
      case 'super_trucker_request':
        return 'SUPER TRUCKER';
      case 'general_support':
        return 'GENERAL';
      default:
        return 'OTHER';
    }
  }
}
