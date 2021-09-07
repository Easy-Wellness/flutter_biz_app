import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/formatters/phone_input_formatter.dart';
import 'package:easy_wellness_biz_app/models/location/geo_location.model.dart';
import 'package:easy_wellness_biz_app/models/location/geo_position.model.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/routes.dart';
import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:easy_wellness_biz_app/utils/navigate_to_root_screen.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:easy_wellness_biz_app/widgets/clearable_text_form_field.dart';
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
          title: Text('Business info'),
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
                ClearableTextFormField(
                  validator:
                      formValidationManager.wrapValidator('name', (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Name is required';
                    if (value.trim().length < 4 || value.trim().length > 64)
                      return 'Name must contain between 4 and 64 characters';
                  }),
                  focusNode: formValidationManager.getFocusNodeForField('name'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSaved: (value) => name = value!,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Business name',
                    helperText: '',
                  ),
                ),
                MaterialButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final location = await Navigator.pushNamed(
                        context, PickLocationScreen.routeName);
                    if (location != null && mounted)
                      setState(
                          () => businessLocation = location as GeoLocation);
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      validator: (_) {
                        if (businessLocation == null)
                          return 'Address is required';
                      },
                      keyboardType: TextInputType.streetAddress,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        floatingLabelBehavior:
                            (businessLocation?.address != null)
                                ? FloatingLabelBehavior.always
                                : null,
                        labelText: 'Business address',
                        helperText: '',
                        suffixIcon: Icon(Icons.chevron_right),
                        hintText: businessLocation?.address,
                      ),
                    ),
                  ),
                ),
                ClearableTextFormField(
                  validator:
                      formValidationManager.wrapValidator('phoneNumb', (value) {
                    if (value == null || value.isEmpty)
                      return 'Phone number is required';
                    if (value.length != 18) return 'Phone number is not valid';
                  }),
                  focusNode:
                      formValidationManager.getFocusNodeForField('phoneNumb'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSaved: (value) => phoneNumber = value!,
                  keyboardType: TextInputType.number,
                  inputFormatters: [PhoneInputFormatter()],
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Business phone',
                    helperText: '',
                  ),
                ),
                ClearableTextFormField(
                  validator:
                      formValidationManager.wrapValidator('email', (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Email is required';
                    if (value.trim().length < 5 || value.trim().length > 50)
                      return 'Email must contain between 5 and 50 characters';
                    if (!_emailRegex.hasMatch(value))
                      return 'Email is not valid';
                  }),
                  focusNode:
                      formValidationManager.getFocusNodeForField('email'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSaved: (value) => email = value!,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Business email',
                    helperText: '',
                  ),
                ),
                ClearableTextFormField(
                  keyboardType: TextInputType.url,
                  onSaved: (value) => website = value,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Website (optional)',
                  ),
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
                        final docRef = await FirebaseFirestore.instance
                            .collection('places')
                            .withConverter<DbPlace>(
                              fromFirestore: (snapshot, _) =>
                                  DbPlace.fromJson(snapshot.data()!),
                              toFirestore: (place, _) => place.toJson(),
                            )
                            .add(DbPlace(
                              name: name,
                              ownerId: FirebaseAuth.instance.currentUser!.uid,
                              geoPosition: geoPos,
                              email: email,
                              phoneNumber: phoneNumber,
                              address: businessLocation!.address,
                              website: website,
                              status: 'operational',
                            ));
                        Provider.of<BusinessPlaceIdNotifier>(context,
                                listen: false)
                            .businessPlaceId = docRef.id;
                        navigateToRootScreen(
                            context, RootScreen.settingsScreen);
                        showCustomSnackBar(context,
                            'Your new business place is successfully created');
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

final _emailRegex = RegExp(
  r'''^(([^<>()\[\]\\.,;:\s-@#$!%^&*+=_/`?{}|'"]+(\.[^<>()\[\]\\.,;:\s-@_!#$%^&*()=+/`?{}|'"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$''',
  caseSensitive: false,
);
