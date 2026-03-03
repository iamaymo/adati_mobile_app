import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String label;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool? enabled;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Function(String)? onChanged;

  const MyTextField({
    super.key,
    required this.label,
    this.validator,
    this.controller,
    this.enabled,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant MyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller?.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
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
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          controller: _controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          obscureText: widget.obscureText,
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
  final bool obscureText;

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
  TextEditingController? _controller;
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant MyTextFieldWS oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller?.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
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
          controller: _controller,
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
