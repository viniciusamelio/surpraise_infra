class GetNotificationOutput {
  const GetNotificationOutput({
    required this.id,
    required this.userId,
    required this.message,
    required this.sentAt,
    required this.topic,
    required this.viewed,
  });
  final String id;
  final String userId;
  final String message;
  final DateTime sentAt;
  final String topic;
  final bool viewed;
}
