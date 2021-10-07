import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/appointment/db_appointment.model.dart';
import 'package:easy_wellness_biz_app/widgets/weekly_schedule_settings/seconds_to_friendly_time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApptListView extends StatelessWidget {
  const ApptListView({
    Key? key,
    required this.apptList,
    required this.primaryBtnBuilder,
    this.secondaryBtnBuilder,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<DbAppointment>> apptList;
  final Widget Function(BuildContext, QueryDocumentSnapshot<DbAppointment>)
      primaryBtnBuilder;
  final OutlinedButton Function(
      BuildContext, QueryDocumentSnapshot<DbAppointment>)? secondaryBtnBuilder;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: apptList.length,
        itemBuilder: (ctx, idx) {
          final apptData = apptList[idx].data();
          final visitReasonIsEmpty = (apptData.visitReason == null ||
              apptData.visitReason!.trim().isEmpty);
          final profile = apptData.userProfile;
          final effectiveAt = apptData.effectiveAt.toDate();
          final month = DateFormat.yMMMMd().format(effectiveAt).substring(0, 3);
          final dayOfWeek =
              DateFormat.yMMMMEEEEd().format(effectiveAt).substring(0, 3);
          final timeInSecs = (effectiveAt.millisecondsSinceEpoch -
                  DateUtils.dateOnly(effectiveAt).millisecondsSinceEpoch) ~/
              1000;
          final friendlyDayTimeBuilder = StringBuffer();
          friendlyDayTimeBuilder.writeAll([
            dayOfWeek,
            secondsToFriendlyTime(timeInSecs),
          ], ' ');
          return Card(
            key: ValueKey(apptList[idx].id),
            elevation: 2,
            shape: ContinuousRectangleBorder(
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            '${effectiveAt.day}',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(month,
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...[
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.subtitle2,
                                  children: [
                                    WidgetSpan(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Icon(
                                            Icons.home_repair_service_outlined),
                                      ),
                                    ),
                                    TextSpan(text: apptData.serviceName),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyText2,
                                  children: [
                                    WidgetSpan(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Icon(Icons.schedule),
                                      ),
                                    ),
                                    TextSpan(
                                        text:
                                            friendlyDayTimeBuilder.toString()),
                                  ],
                                ),
                              ),
                            ].expand((widget) =>
                                [widget, const SizedBox(height: 8)]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Text(
                    'Customer info',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.person_outlined),
                          ),
                        ),
                        TextSpan(
                            text: '${profile.fullname} (${profile.gender})'),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.contact_phone_outlined),
                          ),
                        ),
                        TextSpan(text: profile.phoneNumber),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.dialpad_outlined),
                          ),
                        ),
                        TextSpan(
                          text:
                              '${DateTime.now().year - profile.birthDate.toDate().year} years old',
                        ),
                      ],
                    ),
                  ),
                  if (!visitReasonIsEmpty) const Divider(thickness: 1),
                  if (!visitReasonIsEmpty)
                    Center(
                      child: OutlinedButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Reason'),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            scrollable: true,
                            content: Text(apptData.visitReason!),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('I have done reading ✓'),
                              )
                            ],
                          ),
                        ),
                        child: Text('View reason for visit'),
                      ),
                    ),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      if (secondaryBtnBuilder != null)
                        secondaryBtnBuilder!(context, apptList[idx]),
                      const SizedBox(width: 8),
                      primaryBtnBuilder(context, apptList[idx]),
                      const SizedBox(width: 8),
                    ],
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
      ),
    );
  }
}
