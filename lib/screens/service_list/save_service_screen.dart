import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_wellness_biz_app/constants/misc.dart';
import 'package:easy_wellness_biz_app/models/nearby_service/db_nearby_service.model.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/screens/service_list/set_service_price_screen.dart';
import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_time_picker.dart';
import 'package:easy_wellness_biz_app/widgets/clearable_text_form_field.dart';
import 'package:easy_wellness_biz_app/widgets/scheduling_policy_form_fields.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

class SaveServiceScreen extends StatefulWidget {
  static const String routeName = '/save_service';

  const SaveServiceScreen({
    Key? key,
    this.serviceId,
    this.initialData,
  }) : super(key: key);

  final String? serviceId;
  final DbNearbyService? initialData;

  @override
  State<SaveServiceScreen> createState() => _SaveServiceScreenState();
}

class _SaveServiceScreenState extends State<SaveServiceScreen> {
  final formKey = GlobalKey<FormState>();
  Future<DocumentSnapshot<DbPlace>>? placeSnapshot;

  @override
  void initState() {
    placeSnapshot = FirebaseFirestore.instance
        .collection('places')
        .doc(Provider.of<BusinessPlaceIdNotifier>(context, listen: false)
            .businessPlaceId)
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Save service'),
        ),
        body: Form(
          key: formKey,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<DocumentSnapshot<DbPlace>>(
                  future: placeSnapshot!,
                  builder: (_, snapshot) {
                    if (snapshot.hasError)
                      return const Center(
                          child: Text('Something went wrong 😞'));
                    if (!snapshot.hasData)
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                    return ServiceFormFields(
                      formKey: formKey,
                      placeId: snapshot.data!.id,
                      placeData: snapshot.data!.data()!,
                      serviceId: widget.serviceId,
                      initialData: widget.initialData,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceFormFields extends StatefulWidget {
  const ServiceFormFields({
    Key? key,
    required this.formKey,
    required this.placeId,
    required this.placeData,
    this.serviceId,
    this.initialData,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final String placeId;
  final DbPlace placeData;
  final String? serviceId;
  final DbNearbyService? initialData;

  @override
  State<ServiceFormFields> createState() => _ServiceFormFieldsState();
}

class _ServiceFormFieldsState extends State<ServiceFormFields> {
  final formValidationManager = FormValidationManager();

  String serviceName = '';
  String specialty = '';
  int duration = 0;
  PriceTag priceTag = PriceTag(type: PriceType.free);
  int minuteIncrements = 0;
  int minLeadHours = 0;
  int maxLeadDays = 0;
  String description = '';

  @override
  Widget build(BuildContext context) {
    final formKey = widget.formKey;
    final placeId = widget.placeId;
    final placeData = widget.placeData;
    final serviceId = widget.serviceId;
    final initialData = widget.initialData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[
          ClearableTextFormField(
            initialValue: initialData?.serviceName,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator:
                formValidationManager.wrapValidator('serviceName', (value) {
              if (value == null || value.trim().isEmpty)
                return 'Service name is required';
              if (value.trim().length < 4 || value.trim().length > 37)
                return 'Service name must contain between 4 and 37 characters';
            }),
            focusNode:
                formValidationManager.getFocusNodeForField('serviceName'),
            onSaved: (value) => serviceName = value!.trim(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text('Service name'),
              helperText: '',
            ),
          ),
          DropdownSearch<String>(
            label: 'Specialty',
            mode: Mode.MENU,
            showClearButton: true,
            showSelectedItems: true,
            items: specialties,
            itemAsString: (value) => value!.titleCase,
            scrollbarProps: ScrollbarProps(interactive: true),
            selectedItem: initialData?.specialty,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                value == null ? 'Please select a specialty' : null,
            onSaved: (value) => specialty = value!,
            dropdownSearchDecoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
              border: OutlineInputBorder(),
              helperText: '',
            ),
            popupItemBuilder: (_, value, isSelected) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: SizedBox(
                    height: 32,
                    width: 32,
                    child: SvgPicture.asset(
                      'assets/icons/specialty_${value.snakeCase}_icon.svg',
                    ),
                  ),
                  title: Text(
                    value.titleCase,
                    style: isSelected
                        ? TextStyle(
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                ),
              );
            },
          ),
          FormField<int>(
            initialValue: initialData?.duration,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value == 0) return 'Duration is required';
            },
            onSaved: (minutes) => duration = minutes!,
            // field's value is always in the unit of minutes
            builder: (field) {
              final duration = Duration(minutes: field.value ?? 0);
              final hours = duration.inHours;
              final hoursText = hours >= 1 ? '$hours hour(s) ' : '';
              final minutes = duration.inMinutes.remainder(60);
              final minutesText = minutes == 0 ? '' : '$minutes minutes';
              final infoText = hoursText + minutesText;
              return MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  showCustomTimePicker(
                    context: context,
                    minuteInterval: 15,
                    use24hFormat: true,
                    initialTimeInSecs: duration.inSeconds,
                    onTimeChanged: (seconds) => field.didChange(seconds ~/ 60),
                  );
                },
                child: AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: const Text('Duration'),
                      hintText: infoText,
                      hintStyle: const TextStyle(color: Color(0xdd000000)),
                      suffixIcon: Icon(Icons.watch_later_outlined),
                      errorText: field.errorText,
                      helperText:
                          'The maximum duration for this service is ${infoText == '' ? '_ ' : infoText}.',
                    ),
                  ),
                ),
              );
            },
          ),
          FormField<PriceTag>(
            initialValue:
                initialData?.priceTag ?? PriceTag(type: PriceType.free),
            onSaved: (value) => priceTag = value!,
            builder: (field) {
              String valueText = '';
              String typeText = describeEnum(field.value!.type).titleCase;
              switch (field.value!.type) {
                case PriceType.fixed:
                case PriceType.startingAt:
                case PriceType.hourly:
                  valueText = '\$${field.value!.value}';
                  typeText = ' ($typeText)';
                  break;
                default:
              }
              return MaterialButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final PriceTag? priceTag = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SetServicePriceScreen(initialPrice: field.value!),
                    ),
                  );
                  if (priceTag != null) field.didChange(priceTag);
                },
                child: AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: const Text('Price'),
                      hintText: valueText + typeText,
                      hintStyle: const TextStyle(color: Color(0xdd000000)),
                      suffixIcon: Icon(Icons.payments_outlined),
                      errorText: field.errorText,
                      helperText: '',
                    ),
                  ),
                ),
              );
            },
          ),
          SchedulingPolicyFormFields(
            formValidationManager: formValidationManager,
            initialMinuteIncrements:
                initialData?.minuteIncrements ?? placeData.minuteIncrements,
            initialMinLeadHours:
                initialData?.minLeadHours ?? placeData.minLeadHours,
            initialMaxLeadDays:
                initialData?.maxLeadDays ?? placeData.maxLeadDays,
            onMinuteIncrementsSaved: (minutes) => minuteIncrements = minutes!,
            onMinLeadHoursSaved: (hours) => minLeadHours = hours!,
            onMaxLeadDaysSaved: (days) => maxLeadDays = days!,
          ),
          TextFormField(
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            initialValue: initialData?.description,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator:
                formValidationManager.wrapValidator('description', (value) {
              if (value == null || value.trim().isEmpty)
                return 'Description is required';
            }),
            focusNode:
                formValidationManager.getFocusNodeForField('description'),
            onSaved: (value) => description = value!.trim(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Service description',
              alignLabelWithHint: true,
              helperText: '',
            ),
            minLines: 3,
            maxLines: null,
            maxLength: 600,
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final serviceToSave = DbNearbyService(
                    rating: initialData?.rating ?? 0,
                    ratingsTotal: initialData?.ratingsTotal ?? 0,
                    specialty: specialty,
                    serviceName: serviceName,
                    priceTag: priceTag,
                    placeName: placeData.name,
                    placeId: placeId,
                    address: placeData.address,
                    description: description,
                    duration: duration,
                    geoPosition: placeData.geoPosition,
                    minuteIncrements: minuteIncrements,
                    minLeadHours: minLeadHours,
                    maxLeadDays: maxLeadDays,
                  );
                  final servicesRef = FirebaseFirestore.instance
                      .collection('places')
                      .doc(placeId)
                      .collection('services')
                      .withConverter<DbNearbyService>(
                        fromFirestore: (snapshot, _) =>
                            DbNearbyService.fromJson(snapshot.data()!),
                        toFirestore: (service, _) => service.toJson(),
                      );
                  (serviceId != null)
                      ? await servicesRef
                          .doc(serviceId)
                          .set(serviceToSave, SetOptions(merge: true))
                      : await servicesRef.add(serviceToSave);
                  Navigator.pop(context);
                  showCustomSnackBar(context, 'Service is saved successfully');
                } else
                  formValidationManager.erroredFields.first.focusNode
                      .requestFocus();
              },
              child: const Text('Save'),
            ),
          )
        ].expand((widget) => [widget, const SizedBox(height: 24)])
      ],
    );
  }
}
