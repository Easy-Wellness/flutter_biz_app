import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SchedulingPolicyFormFields extends StatefulWidget {
  const SchedulingPolicyFormFields({
    Key? key,
    required this.formValidationManager,
    this.spacing = 32,
    this.border = const OutlineInputBorder(),
    this.initialMinuteIncrements,
    this.initialMinLeadHours,
    this.initialMaxLeadDays,
    required this.onMinuteIncrementsSaved,
    required this.onMinLeadHoursSaved,
    required this.onMaxLeadDaysSaved,
  }) : super(key: key);

  final FormValidationManager formValidationManager;
  final double spacing;
  final InputBorder border;

  final int? initialMinuteIncrements;
  final int? initialMinLeadHours;
  final int? initialMaxLeadDays;

  final void Function(int?) onMinuteIncrementsSaved;
  final void Function(int?) onMinLeadHoursSaved;
  final void Function(int?) onMaxLeadDaysSaved;

  @override
  State<SchedulingPolicyFormFields> createState() =>
      _SchedulingPolicyFormFieldsState();
}

class _SchedulingPolicyFormFieldsState
    extends State<SchedulingPolicyFormFields> {
  final minLeadController = TextEditingController();
  final maxLeadController = TextEditingController();

  @override
  void initState() {
    minLeadController.text = widget.initialMinLeadHours?.toString() ?? '';
    maxLeadController.text = widget.initialMaxLeadDays?.toString() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormField<int>(
          initialValue: widget.initialMinuteIncrements,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onSaved: widget.onMinuteIncrementsSaved,
          // field's value is always in the unit of minutes
          builder: (field) {
            final duration = Duration(minutes: field.value!);
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
                  use24hFormat: true,
                  initialTimeInSecs: duration.inSeconds,
                  onTimeChanged: (seconds) => field.didChange(seconds ~/ 60),
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    border: widget.border,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    label: const Text('Time increments'),
                    hintText: infoText,
                    hintStyle: const TextStyle(color: Color(0xdd000000)),
                    helperText:
                        'Bookings will show up in increments of $infoText.',
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: widget.spacing),
        FormField<int>(
          initialValue: widget.initialMinLeadHours,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.formValidationManager.wrapValidator('minLeadTime',
              (value) {
            if (value == null)
              return '''Minimum lead time is required.
                          ''';
            if (value == 0)
              return '''Time is not valid.
                          ''';
          }),
          onSaved: widget.onMinLeadHoursSaved,
          // field's value is always in the unit of hours
          builder: (field) => TextField(
            controller: minLeadController,
            onChanged: (numbText) {
              if (numbText.isEmpty) return field.didChange(null);
              field.didChange(int.parse(numbText));
            },
            focusNode: widget.formValidationManager
                .getFocusNodeForField('minLeadTime'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              border: widget.border,
              label: const Text('Minimum lead time'),
              suffix: Text('hour(s)'),
              errorText: field.errorText,
              helperText:
                  'Customers must book, reschedule, or cancel appointments more than ${field.value} hour(s) in advance.',
              helperMaxLines: 2,
            ),
          ),
        ),
        SizedBox(height: widget.spacing),
        FormField<int>(
          initialValue: widget.initialMaxLeadDays,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.formValidationManager.wrapValidator('maxLeadTime',
              (value) {
            if (value == null) return 'Maximum lead time is required.';
            if (value == 0) return 'Time is not valid.';
          }),
          onSaved: widget.onMaxLeadDaysSaved,
          // field's value is always in the unit of hours
          builder: (field) => TextField(
            controller: maxLeadController,
            onChanged: (numbText) {
              if (numbText.isEmpty) return field.didChange(null);
              field.didChange(int.parse(numbText));
            },
            focusNode: widget.formValidationManager
                .getFocusNodeForField('maxLeadTime'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              border: widget.border,
              label: const Text('Maximum lead time'),
              suffix: Text('day(s)'),
              errorText: field.errorText,
              helperText:
                  'Customers will not be able to book over ${field.value} day(s) in advance.',
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    minLeadController.dispose();
    maxLeadController.dispose();
    super.dispose();
  }
}
