import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({Key key, @required this.text, @required this.onPressed})
      : super(key: key);

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return (ElevatedButton(
        onPressed: this.onPressed,
        child: Text(
          this.text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 1.0,
        )));
  }
}
