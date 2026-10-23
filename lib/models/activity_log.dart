class ActivityLog {
  final int id;
  final String? actorId;
  final String actorNameSnapshot;
  final String action;
  final String entityType;
  final String? entityId;
  final String? description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const ActivityLog({
    required this.id,
    this.actorId,
    required this.actorNameSnapshot,
    required this.action,
    required this.entityType,
    this.entityId,
    this.description,
    required this.metadata,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int,
      actorId: json['actor_id'] as String?,
      actorNameSnapshot: json['actor_name_snapshot'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String?,
      description: json['description'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor_id': actorId,
      'actor_name_snapshot': actorNameSnapshot,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
