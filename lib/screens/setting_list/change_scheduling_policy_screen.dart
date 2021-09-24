import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final minLeadController = TextEditingController();
  final maxLeadController = TextEditingController();
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
        minLeadController.text = place.minLeadHours.toString();
        maxLeadController.text = place.maxLeadDays.toString();
        return Form(
          key: formKey,
          child: Scrollbar(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    FormField<int>(
                      initialValue: place.minuteIncrements!,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (minutes) => minuteIncrements = minutes!,
                      // field's value is always in the unit of minutes
                      builder: (field) {
                        final duration = Duration(minutes: field.value!);
                        final hours = duration.inHours;
                        final hoursText = hours >= 1 ? '$hours hour(s) ' : '';
                        final minutes = duration.inMinutes.remainder(60);
                        final minutesText =
                            minutes == 0 ? '' : '$minutes minutes';
                        final infoText = hoursText + minutesText;
                        return MaterialButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            showCustomTimePicker(
                              context: context,
                              use24hFormat: true,
                              initialTimeInSecs: duration.inSeconds,
                              onTimeChanged: (seconds) =>
                                  field.didChange(seconds ~/ 60),
                            );
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                label: const Text('Time increments'),
                                hintText: infoText,
                                hintStyle:
                                    const TextStyle(color: Color(0xdd000000)),
                                helperText:
                                    'Bookings will show up in increments of $infoText.',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    FormField<int>(
                      initialValue: place.minLeadHours!,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: formValidationManager
                          .wrapValidator('minLeadTime', (value) {
                        if (value == null)
                          return '''Minimum lead time is required.
                          ''';
                        if (value == 0)
                          return '''Time is not valid.
                          ''';
                      }),
                      onSaved: (hours) => minLeadHours = hours!,
                      // field's value is always in the unit of hours
                      builder: (field) => TextField(
                        controller: minLeadController,
                        onChanged: (numbText) {
                          if (numbText.isEmpty) return field.didChange(null);
                          field.didChange(int.parse(numbText));
                        },
                        focusNode: formValidationManager
                            .getFocusNodeForField('minLeadTime'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text('Minimum lead time'),
                          suffix: Text('hour(s)'),
                          errorText: field.errorText,
                          helperText:
                              'Customers must book, reschedule, or cancel appointments more than ${field.value} hour(s) in advance.',
                          helperMaxLines: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FormField<int>(
                      initialValue: place.maxLeadDays,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: formValidationManager
                          .wrapValidator('maxLeadTime', (value) {
                        if (value == null)
                          return 'Maximum lead time is required.';
                        if (value == 0) return 'Time is not valid.';
                      }),
                      onSaved: (days) => maxLeadDays = days!,
                      // field's value is always in the unit of hours
                      builder: (field) => TextField(
                        controller: maxLeadController,
                        onChanged: (numbText) {
                          if (numbText.isEmpty) return field.didChange(null);
                          field.didChange(int.parse(numbText));
                        },
                        focusNode: formValidationManager
                            .getFocusNodeForField('maxLeadTime'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text('Maximum lead time'),
                          suffix: Text('day(s)'),
                          errorText: field.errorText,
                          helperText:
                              'Customers will not be able to book over ${field.value} day(s) in advance.',
                        ),
                      ),
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

  @override
  void dispose() {
    minLeadController.dispose();
    maxLeadController.dispose();
    super.dispose();
  }
}
