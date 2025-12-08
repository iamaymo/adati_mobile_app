import 'package:flutter/material.dart';

class H1Text extends StatelessWidget {
  final String data;
  const H1Text({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    );
  }
}
