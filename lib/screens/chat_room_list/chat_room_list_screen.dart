import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/chat_room/db_chat_room.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class ChatRoomListScreen extends StatefulWidget {
  const ChatRoomListScreen({Key? key}) : super(key: key);

  static const String routeName = '/chat_room_list';

  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  Stream<QuerySnapshot<DbChatRoom>>? queryStream;

  @override
  void initState() {
    queryStream = FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('place_id',
            isEqualTo:
                Provider.of<BusinessPlaceIdNotifier>(context, listen: false)
                    .businessPlaceId!)
        .orderBy('last_message_at', descending: true)
        .withConverter<DbChatRoom>(
          fromFirestore: (snapshot, _) => DbChatRoom.fromJson(snapshot.data()!),
          toFirestore: (room, _) => room.toJson(),
        )
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats with customers'),
      ),
      body: SafeArea(
        child: Center(
          child: StreamBuilder<QuerySnapshot<DbChatRoom>>(
            stream: queryStream,
            builder: (_, snapshot) {
              if (snapshot.hasError) return const Text('Something went wrong');

              if (snapshot.connectionState == ConnectionState.waiting)
                return const CircularProgressIndicator.adaptive();

              final chatRoomList = snapshot.data?.docs ?? [];
              if (chatRoomList.isEmpty) return Text('No chat rooms found.');

              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: chatRoomList.length,
                itemBuilder: (_, index) {
                  final roomId = chatRoomList[index].id;
                  final roomData = chatRoomList[index].data();
                  return ListTile(
                    key: ValueKey(roomId),
                    leading: Icon(Icons.question_answer_outlined),
                    title: Text(
                      roomData.customerName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      roomData.lastMessage,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    trailing:
                        Text(_formatTimestamp(roomData.lastMessageAt.toDate())),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatRoomId: roomId,
                          placeId: roomData.placeId,
                          placeName: roomData.placeName,
                          customerId: roomData.customerId,
                          customerName: roomData.customerName,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 8),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

/// Show Absolute or Relative Timestamps.
String _formatTimestamp(DateTime ts) {
  final duration = DateTime.now().difference(ts).abs();
  final dayOfWeek = DateFormat.yMMMMEEEEd().format(ts).substring(0, 3);
  final month = DateFormat.yMMMMd().format(ts).substring(0, 3);
  final nDays = duration.inDays;
  final nHours = duration.inHours;
  final nMinutes = duration.inMinutes;
  final nSeconds = duration.inSeconds;
  if (nHours < 24) {
    if (nSeconds <= 60) return 'now';
    if (nMinutes < 60) return '$nMinutes minutes';
    return '$nHours hour${nHours > 1 ? 's' : ''}';
  }
  if (nDays < 7) return dayOfWeek;
  if (ts.year == DateTime.now().year) return '$month ${ts.day}';
  return '$month ${ts.day}, ${ts.year.toString().substring(2)}';
}
