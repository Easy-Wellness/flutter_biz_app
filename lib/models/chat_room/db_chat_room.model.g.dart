// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_chat_room.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbChatRoom _$DbChatRoomFromJson(Map json) {
  return DbChatRoom(
    placeId: json['place_id'] as String,
    placeName: json['place_name'] as String,
    customerId: json['customer_id'] as String,
    customerName: json['customer_name'] as String,
    lastMessage: json['last_message'] as String,
    createdAt: DbChatRoom._fromJsonTimestamp(json['created_at'] as Timestamp),
    lastMessageAt:
        DbChatRoom._fromJsonTimestamp(json['last_message_at'] as Timestamp),
  );
}

Map<String, dynamic> _$DbChatRoomToJson(DbChatRoom instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'place_name': instance.placeName,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'last_message': instance.lastMessage,
      'created_at': DbChatRoom._toJsonTimestamp(instance.createdAt),
      'last_message_at': DbChatRoom._toJsonTimestamp(instance.lastMessageAt),
    };
