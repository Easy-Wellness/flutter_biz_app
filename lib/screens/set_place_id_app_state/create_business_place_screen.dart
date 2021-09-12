import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/constants/misc.dart';
import 'package:easy_wellness_biz_app/models/location/geo_position.model.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:easy_wellness_biz_app/utils/navigate_to_root_screen.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:easy_wellness_biz_app/widgets/basic_business_info_form_fields.dart';
import 'package:easy_wellness_biz_app/widgets/pick_location_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:provider/provider.dart';

class CreateBusinessPlaceScreen extends StatelessWidget {
  const CreateBusinessPlaceScreen({Key? key}) : super(key: key);

  static const String routeName = '/create_business_place';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add new business'),
        ),
        body: Body(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final formKey = GlobalKey<FormState>();
  final formValidationManager = FormValidationManager();

  String name = '';
  GeoLocation? businessLocation;
  String phoneNumber = '';
  String email = '';
  String? website;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
                  onNameSaved: (value) => name = value!.trim(),
                  onBusinessLocationSaved: (value) => businessLocation = value,
                  onPhoneNumbSaved: (value) => phoneNumber = value!,
                  onEmailSaved: (value) => email = value!,
                  onWebsiteSaved: (value) => website = value,
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        final geo = Geoflutterfire();
                        final GeoFirePoint point = geo.point(
                          latitude: businessLocation!.latitule,
                          longitude: businessLocation!.longitude,
                        );
                        final geoPos = GeoPosition(
                          geohash: point.data['geohash'],
                          geopoint: point.data['geopoint'],
                        );
                        final docSnapshot = await FirebaseFirestore.instance
                            .collection('places')
                            .doc(businessLocation!.placeId)
                            .withConverter<DbPlace>(
                              fromFirestore: (snapshot, _) =>
                                  DbPlace.fromJson(snapshot.data()!),
                              toFirestore: (place, _) => place.toJson(),
                            )
                            .get();
                        if (docSnapshot.exists)
                          return showCustomSnackBar(context,
                              'There is already a business place at the specified address in our system');
                        await docSnapshot.reference.set(DbPlace(
                          name: name,
                          ownerId: FirebaseAuth.instance.currentUser!.uid,
                          geoPosition: geoPos,
                          email: email,
                          phoneNumber: phoneNumber,
                          workingHours: defaultWorkingHoursInSecs,
                          address: businessLocation!.address,
                          website: website,
                          status: 'operational',
                        ));
                        Provider.of<BusinessPlaceIdNotifier>(context,
                                listen: false)
                            .businessPlaceId = businessLocation!.placeId;
                        navigateToRootScreen(
                            context, RootScreen.settingsScreen);
                        showCustomSnackBar(
                            context, 'Welcome to your new business place');
                      } else
                        formValidationManager.erroredFields.first.focusNode
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
    );
  }
}
