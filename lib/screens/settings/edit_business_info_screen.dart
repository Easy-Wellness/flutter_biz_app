import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/models/working_hours/working_hours.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:easy_wellness_biz_app/utils/seconds_to_friendly_time.dart';
import 'package:easy_wellness_biz_app/widgets/basic_business_info_form_fields.dart';
import 'package:easy_wellness_biz_app/widgets/pick_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

class EditBusinessInfoScreen extends StatelessWidget {
  const EditBusinessInfoScreen({Key? key}) : super(key: key);

  static const String routeName = '/edit_business_info_screen';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit business info'),
        ),
        body: Consumer<BusinessPlaceIdNotifier>(
          builder: (_, notifier, child) =>
              Body(placeId: notifier.businessPlaceId),
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key, this.placeId}) : super(key: key);

  final String? placeId;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final formKey = GlobalKey<FormState>();
  final formValidationManager = FormValidationManager();
  Future<DocumentSnapshot<DbPlace>>? docSnapshot;

  String name = '';
  GeoLocation? businessLocation;
  String phoneNumber = '';
  String email = '';
  String? website;

  @override
  void initState() {
    super.initState();
    if (widget.placeId == null) return;
    docSnapshot = FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<DbPlace>>(
      future: docSnapshot,
      builder: (_, snapshot) {
        if (snapshot.hasError)
          return Center(child: const Text('Something went wrong 😞'));
        if (!snapshot.hasData)
          return Center(child: const CircularProgressIndicator.adaptive());
        final place = snapshot.data!.data()!;
        return Form(
          key: formKey,
          child: Scrollbar(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...[
                      BasicBusinessInfoFormFields(
                        formValidationManager: formValidationManager,
                        initialName: place.name,
                        initialBusinessLocation: GeoLocation(
                          placeId: snapshot.data!.id,
                          address: place.address,
                          latitule: place.geoPosition.geopoint.latitude,
                          longitude: place.geoPosition.geopoint.longitude,
                        ),
                        initialEmail: place.email,
                        initialPhoneNumber: place.phoneNumber,
                        initialWebsite: place.website,
                        onNameSaved: (value) => name = value!.trim(),
                        onBusinessLocationSaved: (value) =>
                            businessLocation = value,
                        onPhoneNumbSaved: (value) => phoneNumber = value!,
                        onEmailSaved: (value) => email = value!,
                        onWebsiteSaved: (value) => website = value,
                      ),
                      Text('Working hours',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  for (String dayOfWeek
                                      in _workingHoursInSecs.toJson().keys)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 64,
                                            child: Text(
                                              dayOfWeek
                                                  .substring(0, 3)
                                                  .titleCase,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildTimeRangeListItems(
                                              context,
                                              (_workingHoursInSecs
                                                          .toJson()[dayOfWeek]
                                                      as List)
                                                  .map<TimeIntervalInSecs>(
                                                      (interval) =>
                                                          TimeIntervalInSecs
                                                              .fromJson(
                                                                  interval))
                                                  .toList()),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: Theme.of(context).hintColor),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              // final geo = Geoflutterfire();
                              // final GeoFirePoint point = geo.point(
                              //   latitude: businessLocation!.latitule,
                              //   longitude: businessLocation!.longitude,
                              // );
                              // final geoPos = GeoPosition(
                              //   geohash: point.data['geohash'],
                              //   geopoint: point.data['geopoint'],
                              // );
                              // final docSnapshot = await FirebaseFirestore.instance
                              //     .collection('places')
                              //     .doc(businessLocation!.placeId)
                              //     .withConverter<DbPlace>(
                              //       fromFirestore: (snapshot, _) =>
                              //           DbPlace.fromJson(snapshot.data()!),
                              //       toFirestore: (place, _) => place.toJson(),
                              //     )
                              //     .get();
                              // if (docSnapshot.exists)
                              //   return showCustomSnackBar(context,
                              //       'There is already a business place at the specified address in our system');
                              // await docSnapshot.reference.set(DbPlace(
                              //   name: name,
                              //   ownerId: FirebaseAuth.instance.currentUser!.uid,
                              //   geoPosition: geoPos,
                              //   email: email,
                              //   phoneNumber: phoneNumber,
                              //   address: businessLocation!.address,
                              //   website: website,
                              //   status: 'operational',
                              // ));
                              // Provider.of<BusinessPlaceIdNotifier>(context,
                              //         listen: false)
                              //     .businessPlaceId = businessLocation!.placeId;
                              // navigateToRootScreen(
                              //     context, RootScreen.settingsScreen);
                              // showCustomSnackBar(
                              //     context, 'Welcome to your new business place');
                            } else
                              formValidationManager
                                  .erroredFields.first.focusNode
                                  .requestFocus();
                          },
                          child: Text('Done'),
                        ),
                      )
                    ].expand((widget) => [widget, const SizedBox(height: 16)])
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildTimeRangeListItems(
    BuildContext context, List<TimeIntervalInSecs> timeIntervalsInSecs) {
  return timeIntervalsInSecs.isEmpty
      ? Text(
          'Closed',
          style: TextStyle(color: Theme.of(context).hintColor),
        )
      : Column(
          children: [
            for (var interval in timeIntervalsInSecs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    '${secondsToFriendlyTime(interval.start)} - ${secondsToFriendlyTime(interval.end)}'),
              ),
          ],
        );
}

final _workingHoursInSecs = WorkingHours.fromJson({
  'monday': [
    {'start': 28800, 'end': 61200},
    {'start': 28800, 'end': 61200},
    {'start': 28800, 'end': 61200},
    {'start': 28800, 'end': 61200},
  ],
  'tuesday': [
    {'start': 28800, 'end': 61200},
  ],
  'wednesday': [
    {'start': 28800, 'end': 61200},
  ],
  'thursday': [
    {'start': 28800, 'end': 61200},
  ],
  'friday': [
    {'start': 28800, 'end': 61200},
  ],
  'saturday': [],
  'sunday': []
});
