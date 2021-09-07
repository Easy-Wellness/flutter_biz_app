import 'package:flutter/services.dart';

final _vnShortPhoneNumbRegex = RegExp(r'(\d{2})(\d{3})(\d{2})(\d{2})');
final _vnLongPhoneNumbRegex = RegExp(r'(\d{1})(\d{2})(\d{3})(\d{2})(\d{2})');

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;
    if (newText.length == 9 &&
        newText[0] != '0' &&
        newText.length > oldText.length) {
      return TextEditingValue(
        selection: TextSelection.collapsed(offset: 18),
        text: newText.replaceAllMapped(_vnShortPhoneNumbRegex,
            (Match m) => '(+84) ${m[1]} ${m[2]} ${m[3]} ${m[4]}'),
      );
    }
    if (newText.length == 10 && newText.length > oldText.length) {
      return newValue.copyWith(
        selection: TextSelection.collapsed(offset: 18),
        text: newText.replaceAllMapped(_vnLongPhoneNumbRegex,
            (Match m) => '(+84) ${m[2]} ${m[3]} ${m[4]} ${m[5]}'),
      );
    }
    return newValue;
  }
}
