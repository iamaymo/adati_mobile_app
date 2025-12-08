import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String label;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  const MyTextField({
    super.key,
    required this.label,
    this.validator,
    this.controller,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  TextEditingController? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    } else {
      _internalController = widget.controller;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 230, 229, 229),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: TextFormField(
          controller: _internalController,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.label,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }
}

class MyTextFieldWS extends StatefulWidget {
  final String label;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool
  obscureText; // whether this field should start obscured (default true)

  const MyTextFieldWS({
    super.key,
    required this.label,
    this.validator,
    this.controller,
    this.obscureText = true,
  });

  @override
  State<MyTextFieldWS> createState() => _MyTextFieldWSState();
}

class _MyTextFieldWSState extends State<MyTextFieldWS> {
  TextEditingController? _internalController;
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    if (widget.controller == null) {
      _internalController = TextEditingController();
    } else {
      _internalController = widget.controller;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  void _toggleObscure() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 230, 229, 229),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: TextFormField(
          controller: _internalController,
          validator: widget.validator,
          obscureText: _obscured,
          decoration: InputDecoration(
            hintText: widget.label,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
              onPressed: _toggleObscure,
            ),
          ),
        ),
      ),
    );
  }
}
