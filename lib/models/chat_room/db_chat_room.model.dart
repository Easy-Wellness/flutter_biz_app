import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_chat_room.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbChatRoom {
  DbChatRoom({
    required this.placeId,
    required this.placeName,
    required this.customerId,
    required this.customerName,
    required this.lastMessage,
    required this.createdAt,
    required this.lastMessageAt,
  });

  @JsonKey(name: 'place_id')
  final String placeId;

  @JsonKey(name: 'place_name')
  final String placeName;

  @JsonKey(name: 'customer_id')
  final String customerId;

  @JsonKey(name: 'customer_name')
  final String customerName;

  @JsonKey(name: 'last_message')
  final String lastMessage;

  @JsonKey(
    name: 'created_at',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp createdAt;

  @JsonKey(
    name: 'last_message_at',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp lastMessageAt;

  factory DbChatRoom.fromJson(Map<String, dynamic> json) =>
      _$DbChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$DbChatRoomToJson(this);

  static Timestamp _fromJsonTimestamp(Timestamp ts) => ts;
  static Timestamp _toJsonTimestamp(Timestamp ts) => ts;
}
