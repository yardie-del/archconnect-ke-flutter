/// Ported from the Kotlin `NotificationType` enum.
enum NotificationType {
  escrowFunded,
  escrowReleased,
  milestoneDelivered,
  milestoneReleased,
  bidAccepted,
  newBid,
  newMessage,
  siteVisit,
  siteVisitBooked,
  siteVisitConfirmed,
  disputeUpdate,
  subscriptionExpiry,
  subscriptionRenewal,
  reviewReceived,
  referralReward,
  boraqsVerification,
  systemAlert,
}

/// Ported from the Kotlin `AppNotificationEntity`.
class AppNotification {
  AppNotification({
    String? id,
    required this.type,
    required this.title,
    required this.message,
    this.projectId,
    this.isRead = false,
    DateTime? timestamp,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? projectId;
  final bool isRead;
  final DateTime timestamp;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      projectId: projectId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
    );
  }
}