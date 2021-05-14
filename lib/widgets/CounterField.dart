import 'package:flutter/material.dart';

class CounterField extends StatefulWidget {
  CounterField(
      {Key key, @required this.value, @required this.label, this.onClicked})
      : super(key: key);

  final int value;
  final Function onClicked;
  final String label;

  @override
  _CounterFieldState createState() =>
      _CounterFieldState(value, onClicked, label);
}

class _CounterFieldState extends State<CounterField> {
  _CounterFieldState(this.value, this.onClicked, this.label);

  int value;
  final Function onClicked;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(0, 0, 16, 0), child: Text(label)),
        ElevatedButton(
          onPressed: () {
            if (value == 1) {
              final snackBar =
                  SnackBar(content: Text('Cant be smaller than 1'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              setState(() {
                value--;
              });
              if (onClicked != null) {
                onClicked(value);
              }
            }
          },
          child: Icon(Icons.remove),
        ),
        Container(padding: EdgeInsets.all(16), child: Text(value.toString())),
        ElevatedButton(
          onPressed: () {
            setState(() {
              value++;
            });
            if (onClicked != null) {
              onClicked(value);
            }
          },
          child: Icon(Icons.add),
        ),
        Flex(direction: Axis.horizontal)
      ],
    );
  }
}
