import 'package:flutter/material.dart';

class CounterField extends StatefulWidget {
  CounterField({
    Key? key,
    required this.value,
    required this.label,
    required this.onClicked,
  }) : super(key: key);

  final int value;
  final Function(int) onClicked;
  final String label;

  @override
  _CounterFieldState createState() => _CounterFieldState();
}

class _CounterFieldState extends State<CounterField> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  void _increment() {
    setState(() {
      value++;
    });
    widget.onClicked.call(value);
  }

  void _decrement() {
    if (value > 1) {
      setState(() {
        value--;
      });
      widget.onClicked.call(value);
    } else {
      final snackBar = SnackBar(content: Text('Cannot be smaller than 1'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: Text(widget.label),
        ),
        ElevatedButton(
          onPressed: _decrement,
          child: Icon(Icons.remove),
        ),
        Container(padding: EdgeInsets.all(16), child: Text(value.toString())),
        ElevatedButton(
          onPressed: _increment,
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}
