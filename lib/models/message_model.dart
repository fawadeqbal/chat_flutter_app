enum MessageStatus { SENT, DELIVERED, SEEN }

class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String type; // TEXT, IMAGE, FILE
  final List<dynamic>? attachments;
  final DateTime createdAt;
  final MessageStatus status;
  final DateTime? deliveredAt;
  final DateTime? seenAt;
  final List<ReactionModel> reactions;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    this.type = 'TEXT',
    this.attachments,
    required this.createdAt,
    this.status = MessageStatus.SENT,
    this.deliveredAt,
    this.seenAt,
    this.reactions = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      content: json['content'],
      type: json['type'] ?? 'TEXT',
      attachments: json['attachments'],
      createdAt: DateTime.parse(json['createdAt']),
      status: _parseStatus(json['status']),
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      seenAt: json['seenAt'] != null ? DateTime.parse(json['seenAt']) : null,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List).map((r) => ReactionModel.fromJson(r)).toList()
          : [],
    );
  }

  static MessageStatus _parseStatus(String? status) {
    switch (status) {
      case 'DELIVERED':
        return MessageStatus.DELIVERED;
      case 'SEEN':
        return MessageStatus.SEEN;
      default:
        return MessageStatus.SENT;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'seenAt': seenAt?.toIso8601String(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
    };
  }

  MessageModel copyWith({
    MessageStatus? status,
    DateTime? deliveredAt,
    DateTime? seenAt,
    List<ReactionModel>? reactions,
  }) {
    return MessageModel(
      id: id,
      roomId: roomId,
      senderId: senderId,
      content: content,
      type: type,
      attachments: attachments,
      createdAt: createdAt,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      seenAt: seenAt ?? this.seenAt,
      reactions: reactions ?? this.reactions,
    );
  }
}

class ReactionModel {
  final String id;
  final String userId;
  final String emoji;
  final String? username;

  ReactionModel({
    required this.id,
    required this.userId,
    required this.emoji,
    this.username,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      username: json['user']?['username']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'emoji': emoji,
      'user': username != null ? {'username': username} : null,
    };
  }
}
