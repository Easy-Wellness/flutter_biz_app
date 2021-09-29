import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:easy_wellness_biz_app/widgets/scheduling_policy_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChangeSchedulingPolicyScreen extends StatelessWidget {
  const ChangeSchedulingPolicyScreen({Key? key}) : super(key: key);

  static const String routeName = '/change_scheduling_policy';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scheduling policy'),
        ),
        body: Consumer<BusinessPlaceIdNotifier>(
          builder: (_, notifier, child) =>
              Body(placeId: notifier.businessPlaceId!),
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key, required this.placeId}) : super(key: key);

  final String placeId;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final formKey = GlobalKey<FormState>();
  final formValidationManager = FormValidationManager();
  Future<DocumentSnapshot<DbPlace>>? docSnapshot;

  int minuteIncrements = 0;
  int minLeadHours = 0;
  int maxLeadDays = 0;

  @override
  void initState() {
    docSnapshot = FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .get();
    super.initState();
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
        final placeId = snapshot.data!.id;
        final place = snapshot.data!.data()!;
        return Form(
          key: formKey,
          child: Scrollbar(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SchedulingPolicyFormFields(
                      formValidationManager: formValidationManager,
                      initialMinuteIncrements: place.minuteIncrements,
                      initialMinLeadHours: place.minLeadHours,
                      initialMaxLeadDays: place.maxLeadDays,
                      onMinuteIncrementsSaved: (minutes) =>
                          minuteIncrements = minutes!,
                      onMinLeadHoursSaved: (hours) => minLeadHours = hours!,
                      onMaxLeadDaysSaved: (days) => maxLeadDays = days!,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            await FirebaseFirestore.instance
                                .collection('places')
                                .doc(placeId)
                                .update({
                              'minute_increments': minuteIncrements,
                              'min_lead_hours': minLeadHours,
                              'max_lead_days': maxLeadDays,
                            });
                            Navigator.pop(context);
                            showCustomSnackBar(context,
                                'Scheduling policy is updated successfully.');
                          } else
                            formValidationManager.erroredFields.first.focusNode
                                .requestFocus();
                        },
                        child: Text('Save'),
                      ),
                    )
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
