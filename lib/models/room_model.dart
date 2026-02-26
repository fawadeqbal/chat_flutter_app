import 'user_model.dart';
import 'message_model.dart';

class RoomModel {
  final String id;
  final String type; // PRIVATE, GROUP
  final List<RoomMember> members;
  final MessageModel? lastMessage;
  final int unreadCount;
  final String? pinnedMessageId;
  final MessageModel? pinnedMessage;

  bool get isGroup => type == 'GROUP';

  RoomModel({
    required this.id,
    required this.type,
    required this.members,
    this.lastMessage,
    this.unreadCount = 0,
    this.pinnedMessageId,
    this.pinnedMessage,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? (json['isGroup'] == true ? 'GROUP' : 'PRIVATE'),
      members: json['members'] != null
          ? (json['members'] as List).map((m) => RoomMember.fromJson(m)).toList()
          : [],
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : (json['messages'] != null && (json['messages'] as List).isNotEmpty)
              ? MessageModel.fromJson(json['messages'][0])
              : null,
      unreadCount: json['unreadCount'] ?? 0,
      pinnedMessageId: json['pinnedMessageId']?.toString(),
      pinnedMessage: json['pinnedMessage'] != null
          ? MessageModel.fromJson(json['pinnedMessage'])
          : null,
    );
  }

  RoomModel copyWith({
    String? type,
    List<RoomMember>? members,
    MessageModel? lastMessage,
    int? unreadCount,
    String? pinnedMessageId,
    MessageModel? pinnedMessage,
  }) {
    return RoomModel(
      id: id,
      type: type ?? this.type,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      pinnedMessageId: pinnedMessageId ?? this.pinnedMessageId,
      pinnedMessage: pinnedMessage ?? this.pinnedMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'members': members.map((m) => m.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'pinnedMessageId': pinnedMessageId,
      'pinnedMessage': pinnedMessage?.toJson(),
    };
  }
}

class RoomMember {
  final String userId;
  final UserModel user;

  RoomMember({required this.userId, required this.user});

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      userId: json['userId']?.toString() ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'user': user.toJson(),
    };
  }
}
