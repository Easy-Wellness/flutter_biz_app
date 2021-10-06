import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/chat_room/db_chat_room.model.dart';
import 'package:easy_wellness_biz_app/models/chat_room/db_text_message.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    this.chatRoomId,
    required this.placeId,
    required this.placeName,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  final String? chatRoomId;
  final String placeId;
  final String placeName;
  final String customerId;
  final String customerName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUser = types.User(id: FirebaseAuth.instance.currentUser!.uid);
  final chatRoomListRef = FirebaseFirestore.instance
      .collection('chat_rooms')
      .withConverter<DbChatRoom>(
        fromFirestore: (snapshot, _) => DbChatRoom.fromJson(snapshot.data()!),
        toFirestore: (room, _) => room.toJson(),
      );
  String? chatRoomId;
  Stream<QuerySnapshot<DbTextMessage>>? messageListStream;

  @override
  void initState() {
    chatRoomId = widget.chatRoomId;
    if (chatRoomId != null)
      messageListStream = chatRoomListRef
          .doc(chatRoomId)
          .collection('messages')
          .withConverter<DbTextMessage>(
            fromFirestore: (snapshot, _) =>
                DbTextMessage.fromJson(snapshot.data()!),
            toFirestore: (mess, _) => mess.toJson(),
          )
          .orderBy('created_at', descending: true)
          .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.customerName}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: StreamBuilder<QuerySnapshot<DbTextMessage>>(
              stream: messageListStream,
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Text('Something went wrong');
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const CircularProgressIndicator.adaptive();

                final messageList = snapshot.data?.docs ?? [];
                return Chat(
                  messages: messageList.map((dbMess) {
                    final messData = dbMess.data();

                    /// Messages are already grouped by date. The date divider
                    /// will appear on every new day (midnight) or if there are
                    /// more than 15 minutes difference between 2 messages
                    /// (taken from Facebook Messenger).
                    return types.TextMessage(
                      text: messData.text,
                      author: types.User(id: messData.authorId),
                      id: dbMess.id,
                      status: types.Status.delivered,
                      createdAt: messData.createdAt.millisecondsSinceEpoch,
                    );
                  }).toList(),
                  onSendPressed: (message) async {
                    if (chatRoomId == null) {
                      final roomRef = await chatRoomListRef.add(DbChatRoom(
                        placeId: widget.placeId,
                        placeName: widget.placeName,
                        customerId: widget.customerId,
                        customerName: widget.customerName,
                        lastMessage: message.text,
                        createdAt: Timestamp.now(),
                        lastMessageAt: Timestamp.now(),
                      ));
                      final messageListRef = roomRef
                          .collection('messages')
                          .withConverter<DbTextMessage>(
                            fromFirestore: (snapshot, _) =>
                                DbTextMessage.fromJson(snapshot.data()!),
                            toFirestore: (mess, _) => mess.toJson(),
                          );
                      messageListRef.add(DbTextMessage(
                        authorId: currentUser.id,
                        text: message.text,
                        roomId: roomRef.id,
                        createdAt: Timestamp.now(),
                      ));
                      return setState(() {
                        chatRoomId = roomRef.id;
                        messageListStream = messageListRef
                            .orderBy('created_at', descending: true)
                            .snapshots();
                      });
                    }
                    final roomRef = chatRoomListRef.doc(chatRoomId!);
                    roomRef.update({
                      'last_message': message.text,
                      'last_message_at': Timestamp.now(),
                    });
                    roomRef
                        .collection('messages')
                        .withConverter<DbTextMessage>(
                          fromFirestore: (snapshot, _) =>
                              DbTextMessage.fromJson(snapshot.data()!),
                          toFirestore: (mess, _) => mess.toJson(),
                        )
                        .add(DbTextMessage(
                          authorId: currentUser.id,
                          text: message.text,
                          roomId: chatRoomId!,
                          createdAt: Timestamp.now(),
                        ));
                  },
                  user: currentUser,
                  theme: const DefaultChatTheme(
                    inputTextDecoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                      hintText: 'Tap here to chat...',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    inputTextCursorColor: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
