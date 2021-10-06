import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'db_text_message.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class DbTextMessage {
  DbTextMessage({
    required this.authorId,
    required this.roomId,
    required this.text,
    required this.createdAt,
  });

  @JsonKey(name: 'author_id')
  final String authorId;

  @JsonKey(name: 'room_id')
  final String roomId;

  final String text;

  @JsonKey(
    name: 'created_at',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp createdAt;

  factory DbTextMessage.fromJson(Map<String, dynamic> json) =>
      _$DbTextMessageFromJson(json);

  Map<String, dynamic> toJson() => _$DbTextMessageToJson(this);

  static Timestamp _fromJsonTimestamp(Timestamp ts) => ts;
  static Timestamp _toJsonTimestamp(Timestamp ts) => ts;
}
