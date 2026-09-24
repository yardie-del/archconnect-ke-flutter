import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_notification.dart';
import '../widgets/wallet_helpers.dart';

(Color, IconData) _iconFor(NotificationType type) {
  switch (type) {
    case NotificationType.escrowFunded:
    case NotificationType.escrowReleased:
    case NotificationType.milestoneReleased:
      return (mpesaGreen, Icons.account_balance_wallet);
    case NotificationType.milestoneDelivered:
    case NotificationType.bidAccepted:
      return (kenyaGreenPrimary, Icons.check_circle);
    case NotificationType.siteVisit:
    case NotificationType.siteVisitBooked:
    case NotificationType.siteVisitConfirmed:
      return (safariGold, Icons.location_on);
    case NotificationType.disputeUpdate:
      return (kenyaRed, Icons.gavel);
    case NotificationType.newMessage:
      return (const Color(0xFF0284C7), Icons.chat);
    case NotificationType.newBid:
      return (const Color(0xFF0284C7), Icons.attach_money);
    case NotificationType.subscriptionExpiry:
    case NotificationType.subscriptionRenewal:
      return (const Color(0xFF9333EA), Icons.autorenew);
    case NotificationType.reviewReceived:
      return (safariGold, Icons.star);
    case NotificationType.referralReward:
      return (mpesaGreen, Icons.card_giftcard);
    case NotificationType.boraqsVerification:
      return (kenyaGreenPrimary, Icons.verified);
    case NotificationType.systemAlert:
      return (slateDark, Icons.notifications);
  }
}

/// Dart port of the Kotlin `NotificationsScreen`. Tapping a notification
/// marks it read and, if it references a project, calls [onNavigateToProject].
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.notifications,
    this.onNavigateToProject,
    this.onNotificationsChanged,
  });

  final List<AppNotification> notifications;
  final ValueChanged<String>? onNavigateToProject;
  final ValueChanged<List<AppNotification>>? onNotificationsChanged;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _items = widget.notifications;

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: kenyaRed, borderRadius: BorderRadius.circular(10)),
                child: Text('$_unreadCount New',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(fontSize: 12, color: kenyaGreenPrimary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _items.isEmpty ? _buildEmptyState() : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: slateMuted),
            const SizedBox(height: 12),
            const Text('No notifications yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: slateDark)),
            const SizedBox(height: 4),
            const Text(
              'Updates on escrow releases, milestones, and project messages will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: slateMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _NotificationCard(
        notification: _items[i],
        onTap: () => _handleTap(_items[i]),
      ),
    );
  }

  void _handleTap(AppNotification n) {
    setState(() {
      _items = _items.map((x) => x.id == n.id ? x.copyWith(isRead: true) : x).toList();
    });
    widget.onNotificationsChanged?.call(_items);
    if (n.projectId != null) widget.onNavigateToProject?.call(n.projectId!);
  }

  void _markAllRead() {
    setState(() {
      _items = _items.map((x) => x.copyWith(isRead: true)).toList();
    });
    widget.onNotificationsChanged?.call(_items);
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _iconFor(notification.type);
    final formattedTime = DateFormat('MMM d, h:mm a').format(notification.timestamp);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : kenyaGreenPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notification.isRead ? cardBorder : kenyaGreenPrimary.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 13,
                            color: slateDark,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: kenyaGreenPrimary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(notification.message, style: const TextStyle(fontSize: 12, color: slateMedium, height: 1.15)),
                  const SizedBox(height: 6),
                  Text(formattedTime, style: const TextStyle(fontSize: 10, color: slateMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}