import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/appointment/db_appointment.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/screens/chat_room_list/chat_screen.dart';
import 'package:easy_wellness_biz_app/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appt_list_view.dart';

class EventCalendarScreen extends StatefulWidget {
  static const String routeName = '/event_calendar';

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  Stream<QuerySnapshot<DbAppointment>>? upcomingStream;
  Stream<QuerySnapshot<DbAppointment>>? pastStream;
  Stream<QuerySnapshot<DbAppointment>>? canceledStream;

  @override
  void initState() {
    final apptsRef = FirebaseFirestore.instance
        .collectionGroup('appointments')
        .where('place_id',
            isEqualTo:
                Provider.of<BusinessPlaceIdNotifier>(context, listen: false)
                    .businessPlaceId!)
        .withConverter<DbAppointment>(
          fromFirestore: (snapshot, _) =>
              DbAppointment.fromJson(snapshot.data()!),
          toFirestore: (appt, _) => appt.toJson(),
        );
    upcomingStream = apptsRef
        .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
        .where('effective_at',
            isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('effective_at')
        .snapshots();
    pastStream = apptsRef
        .where('status', isEqualTo: describeEnum(ApptStatus.confirmed))
        .where('effective_at',
            isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('effective_at', descending: true)
        .snapshots();
    canceledStream = apptsRef
        .where('status', isEqualTo: describeEnum(ApptStatus.canceled))
        .orderBy('effective_at', descending: true)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            unselectedLabelColor: Theme.of(context).hintColor,
            labelColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Column(
                children: [
                  Icon(Icons.upcoming_outlined),
                  Tab(text: 'Upcoming'),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.history_outlined),
                  Tab(text: 'Past'),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.event_busy_outlined),
                  Tab(text: 'Canceled'),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(children: [
          AppointmentListTabView(
            queryStream: upcomingStream!,
            secondaryBtnBuilder: (_, idx) => OutlinedButton(
              child: const Text('Cancel'),
              onPressed: () {},
            ),
          ),
          AppointmentListTabView(queryStream: pastStream!),
          AppointmentListTabView(queryStream: canceledStream!),
        ]),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}

class AppointmentListTabView extends StatelessWidget {
  const AppointmentListTabView({
    Key? key,
    required this.queryStream,
    this.secondaryBtnBuilder,
  }) : super(key: key);

  final Stream<QuerySnapshot<DbAppointment>> queryStream;
  final OutlinedButton Function(BuildContext, int)? secondaryBtnBuilder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot<DbAppointment>>(
        stream: queryStream,
        builder: (_, snapshot) {
          if (snapshot.hasError) return const Text('Something went wrong');

          if (snapshot.connectionState == ConnectionState.waiting)
            return const CircularProgressIndicator.adaptive();

          final apptList = snapshot.data?.docs ?? [];
          if (apptList.isEmpty) return Text('No appointments found.');
          return ApptListView(
            apptList: apptList,
            primaryBtnBuilder: (_, index) => ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
              onPressed: () async {
                final appt = apptList[index].data();
                final snapshot = await FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .where('place_id', isEqualTo: appt.placeId)
                    .where('customer_id', isEqualTo: appt.accountId)
                    .get();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatRoomId:
                          snapshot.docs.isNotEmpty ? snapshot.docs[0].id : null,
                      placeId: appt.placeId,
                      placeName: appt.placeName,
                      customerId: appt.accountId,
                      customerName: appt.userProfile.fullname,
                    ),
                  ),
                );
              },
            ),
            secondaryBtnBuilder: secondaryBtnBuilder,
          );
        },
      ),
    );
  }
}
