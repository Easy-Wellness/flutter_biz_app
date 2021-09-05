import 'package:flutter/material.dart';

class FormValidationManager {
  final _fieldValidationStates = Map<String, FormFieldValidationState>();

  void _ensureExists(String key) {
    _fieldValidationStates[key] ??= FormFieldValidationState(key: key);
  }

  List<FormFieldValidationState> get erroredFields =>
      _fieldValidationStates.entries
          .where((s) => s.value.hasError)
          .map((s) => s.value)
          .toList();

  FocusNode getFocusNodeForField(key) {
    _ensureExists(key);
    return _fieldValidationStates[key]!.focusNode;
  }

  FormFieldValidator<T> wrapValidator<T>(
      String key, FormFieldValidator<T> validator) {
    _ensureExists(key);

    return (input) {
      final inputErrMsg = validator(input);
      _fieldValidationStates[key]!.hasError =
          (inputErrMsg?.isNotEmpty ?? false);
      return inputErrMsg;
    };
  }

  void dispose() {
    _fieldValidationStates.entries.forEach((s) {
      s.value.focusNode.dispose();
    });
  }
}

class FormFieldValidationState {
  final String key;

  bool hasError;
  FocusNode focusNode;

  FormFieldValidationState({required this.key})
      : hasError = false,
        focusNode = FocusNode();
}
