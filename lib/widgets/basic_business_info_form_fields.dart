import 'package:easy_wellness_biz_app/formatters/phone_input_formatter.dart';
import 'package:easy_wellness_biz_app/utils/form_validation_manager.dart';
import 'package:flutter/material.dart';

import 'clearable_text_form_field.dart';
import 'pick_location_screen.dart';

final _emailRegex = RegExp(
  r'''^(([^<>()\[\]\\.,;:\s-@#$!%^&*+=_/`?{}|'"]+(\.[^<>()\[\]\\.,;:\s-@_!#$%^&*()=+/`?{}|'"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$''',
  caseSensitive: false,
);

class BasicBusinessInfoFormFields extends StatefulWidget {
  BasicBusinessInfoFormFields({
    Key? key,
    required this.formValidationManager,
    this.spacing = 16,
    this.border = const OutlineInputBorder(),

    // Initial values
    this.initialName,
    this.initialBusinessLocation,
    this.initialPhoneNumber,
    this.initialEmail,
    this.initialWebsite,

    // onSaved() methods
    required this.onNameSaved,
    required this.onBusinessLocationSaved,
    required this.onPhoneNumbSaved,
    required this.onEmailSaved,
    required this.onWebsiteSaved,
  }) : super(key: key);

  final FormValidationManager formValidationManager;
  final double spacing;
  final InputBorder border;

  final String? initialName;
  final GeoLocation? initialBusinessLocation;
  final String? initialPhoneNumber;
  final String? initialEmail;
  final String? initialWebsite;

  final void Function(String?) onNameSaved;
  final void Function(GeoLocation?) onBusinessLocationSaved;
  final void Function(String?) onPhoneNumbSaved;
  final void Function(String?) onEmailSaved;
  final void Function(String?) onWebsiteSaved;

  @override
  _BasicBusinessInfoFormFieldsState createState() =>
      _BasicBusinessInfoFormFieldsState();
}

class _BasicBusinessInfoFormFieldsState
    extends State<BasicBusinessInfoFormFields> {
  GeoLocation? businessLocation;
  double? spacing;

  @override
  void initState() {
    super.initState();
    businessLocation = widget.initialBusinessLocation;
    spacing = widget.spacing;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...[
          ClearableTextFormField(
            initialValue: widget.initialName,
            validator:
                widget.formValidationManager.wrapValidator('name', (value) {
              if (value == null || value.trim().isEmpty)
                return 'Name is required';
              if (value.trim().length < 4 || value.trim().length > 64)
                return 'Name must contain between 4 and 64 characters';
            }),
            onSaved: widget.onNameSaved,
            focusNode:
                widget.formValidationManager.getFocusNodeForField('name'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: widget.border,
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
                setState(() => businessLocation = location as GeoLocation);
            },
            child: AbsorbPointer(
              child: TextFormField(
                validator: (_) {
                  if (businessLocation == null) return 'Address is required';
                },
                onSaved: (_) =>
                    widget.onBusinessLocationSaved(businessLocation),
                keyboardType: TextInputType.streetAddress,
                readOnly: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  floatingLabelBehavior: (businessLocation != null)
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
            initialValue: widget.initialPhoneNumber,
            validator: widget.formValidationManager.wrapValidator('phoneNumb',
                (value) {
              if (value == null || value.isEmpty)
                return 'Phone number is required';
              if (value.length != 18) return 'Phone number is not valid';
            }),
            onSaved: widget.onPhoneNumbSaved,
            focusNode:
                widget.formValidationManager.getFocusNodeForField('phoneNumb'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.number,
            inputFormatters: [PhoneInputFormatter()],
            decoration: InputDecoration(
              border: widget.border,
              labelText: 'Business phone',
              helperText: '',
            ),
          ),
          ClearableTextFormField(
            initialValue: widget.initialEmail,
            validator:
                widget.formValidationManager.wrapValidator('email', (value) {
              if (value == null || value.trim().isEmpty)
                return 'Email is required';
              if (value.trim().length < 5 || value.trim().length > 50)
                return 'Email must contain between 5 and 50 characters';
              if (!_emailRegex.hasMatch(value)) return 'Email is not valid';
            }),
            onSaved: widget.onEmailSaved,
            focusNode:
                widget.formValidationManager.getFocusNodeForField('email'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: widget.border,
              labelText: 'Business email',
              helperText: '',
            ),
          ),
          ClearableTextFormField(
            initialValue: widget.initialWebsite,
            keyboardType: TextInputType.url,
            onSaved: widget.onWebsiteSaved,
            decoration: InputDecoration(
              border: widget.border,
              labelText: 'Website (optional)',
            ),
          ),
        ].expand((widget) => [widget, SizedBox(height: spacing!)])
      ],
    );
  }
}
