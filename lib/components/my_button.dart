import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final double width;
  final double height;

  MyButton({super.key, this.width = 0.9, this.height = 0.07});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widget.width,
      height: MediaQuery.of(context).size.height * widget.height,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shadowColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: Text(
          "Login",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 25,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
