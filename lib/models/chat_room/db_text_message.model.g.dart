// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_text_message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbTextMessage _$DbTextMessageFromJson(Map json) {
  return DbTextMessage(
    authorId: json['author_id'] as String,
    roomId: json['room_id'] as String,
    text: json['text'] as String,
    createdAt:
        DbTextMessage._fromJsonTimestamp(json['created_at'] as Timestamp),
  );
}

Map<String, dynamic> _$DbTextMessageToJson(DbTextMessage instance) =>
    <String, dynamic>{
      'author_id': instance.authorId,
      'room_id': instance.roomId,
      'text': instance.text,
      'created_at': DbTextMessage._toJsonTimestamp(instance.createdAt),
    };
