class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? relatedEntityId;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? json['_id']).toString(),
      type: json['type'] ?? "SYSTEM",
      title: json['title'] ?? "",
      body: json['body'] ?? "",
      relatedEntityId: json['related_entity_id'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
