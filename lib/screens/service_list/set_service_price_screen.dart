import 'package:easy_wellness_biz_app/models/nearby_service/db_nearby_service.model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetServicePriceScreen extends StatefulWidget {
  const SetServicePriceScreen({
    Key? key,
    required this.initialPrice,
  }) : super(key: key);

  final PriceTag initialPrice;

  @override
  State<SetServicePriceScreen> createState() => _SetServicePriceScreenState();
}

class _SetServicePriceScreenState extends State<SetServicePriceScreen> {
  PriceTag currentPrice = PriceTag(type: PriceType.free);
  bool priceCheckboxWithValueChecked = false;
  _PriceCheckboxWithValueState? priceCheckboxRef;

  void register(_PriceCheckboxWithValueState ref) => priceCheckboxRef = ref;

  @override
  void initState() {
    currentPrice = widget.initialPrice;
    switch (currentPrice.type) {
      case PriceType.fixed:
      case PriceType.startingAt:
      case PriceType.hourly:
        priceCheckboxWithValueChecked = true;
        break;
      default:
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Set price'),
          actions: [
            TextButton.icon(
              onPressed: () {
                if (priceCheckboxWithValueChecked) if (!priceCheckboxRef!
                    .isValid()) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Cannot save this price'),
                      content:
                          const Text('The price you entered is not valid.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        )
                      ],
                    ),
                  );
                  return;
                } else
                  priceCheckboxRef!.save();
                Navigator.pop(context, currentPrice);
              },
              style: TextButton.styleFrom(primary: Colors.black87),
              icon: Text('Save'),
              label: Icon(Icons.check),
            ),
          ],
        ),
        body: Column(
          children: [
            PriceCheckboxWithValue(
              key: ValueKey('Fixed'),
              titleText: 'Fixed price',
              isChecked: currentPrice.type == PriceType.fixed,
              initialValue: widget.initialPrice.value,
              register: register,
              onChecked: () => setState(() {
                priceCheckboxWithValueChecked = true;
                currentPrice = PriceTag(type: PriceType.fixed);
              }),
              onSaved: (value) =>
                  currentPrice = PriceTag(type: PriceType.fixed, value: value),
            ),
            PriceCheckboxWithValue(
              key: ValueKey('From'),
              titleText: 'Starting at',
              isChecked: currentPrice.type == PriceType.startingAt,
              initialValue: widget.initialPrice.value,
              register: register,
              onChecked: () => setState(() {
                priceCheckboxWithValueChecked = true;
                currentPrice = PriceTag(type: PriceType.startingAt);
              }),
              onSaved: (value) => currentPrice =
                  PriceTag(type: PriceType.startingAt, value: value),
            ),
            PriceCheckboxWithValue(
              key: ValueKey('Hourly'),
              titleText: 'Hourly',
              isChecked: currentPrice.type == PriceType.hourly,
              initialValue: widget.initialPrice.value,
              register: register,
              onChecked: () => setState(() {
                priceCheckboxWithValueChecked = true;
                currentPrice = PriceTag(type: PriceType.hourly);
              }),
              onSaved: (value) =>
                  currentPrice = PriceTag(type: PriceType.hourly, value: value),
            ),
            CheckboxListTile(
              key: ValueKey('Free'),
              title: const Text('Free'),
              value: currentPrice.type == PriceType.free,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) => setState(() {
                priceCheckboxWithValueChecked = false;
                currentPrice = PriceTag(type: PriceType.free);
              }),
            ),
            CheckboxListTile(
              key: ValueKey('Varies'),
              title: const Text('Price varies'),
              value: currentPrice.type == PriceType.varies,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) => setState(() {
                priceCheckboxWithValueChecked = false;
                currentPrice = PriceTag(type: PriceType.varies);
              }),
            ),
            CheckboxListTile(
              key: ValueKey('Contact us'),
              title: const Text('Customers call or chat with you to find out'),
              value: currentPrice.type == PriceType.contactUs,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) => setState(() {
                priceCheckboxWithValueChecked = false;
                currentPrice = PriceTag(type: PriceType.contactUs);
              }),
            ),
            CheckboxListTile(
              key: ValueKey('Not set'),
              title: const Text('Price not set'),
              value: currentPrice.type == PriceType.notSet,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) => setState(() {
                priceCheckboxWithValueChecked = false;
                currentPrice = PriceTag(type: PriceType.notSet);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceCheckboxWithValue extends StatefulWidget {
  const PriceCheckboxWithValue({
    Key? key,
    required this.isChecked,
    required this.titleText,
    this.initialValue,
    required this.register,
    required this.onChecked,
    required this.onSaved,
  }) : super(key: key);

  final bool isChecked;
  final String titleText;
  final int? initialValue;
  final void Function(_PriceCheckboxWithValueState) register;
  final void Function() onChecked;
  final void Function(int priceValue) onSaved;

  @override
  _PriceCheckboxWithValueState createState() => _PriceCheckboxWithValueState();
}

class _PriceCheckboxWithValueState extends State<PriceCheckboxWithValue> {
  final priceInpController = TextEditingController();
  int? priceValue;

  @override
  void initState() {
    if (widget.isChecked) widget.register(this);
    priceValue = widget.initialValue;
    priceInpController.text = "${priceValue ?? ''}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            title: Text(widget.titleText),
            value: widget.isChecked,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (_) {
              widget.onChecked();
              widget.register(this);
            },
          ),
        ),
        if (widget.isChecked)
          SizedBox(
            width: 72,
            child: TextField(
              controller: priceInpController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
              onChanged: (priceText) => setState(() =>
                  priceValue = priceText != '' ? int.parse(priceText) : 0),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Text("\$"),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: '0.00',
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  bool isValid() => (priceValue != null && priceValue! > 0);

  void save() => widget.onSaved(priceValue!);

  @override
  void dispose() {
    priceInpController.dispose();
    super.dispose();
  }
}
