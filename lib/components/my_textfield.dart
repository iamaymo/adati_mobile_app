import 'package:flutter/material.dart';

// ===============================================
// 1. MyTextField (الحقل العادي)
// ===============================================

class MyTextField extends StatefulWidget {
  final String label;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool? enabled;
  final TextInputType? keyboardType;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.label,
    this.validator,
    this.controller,
    this.enabled,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  // المتحكم الداخلي (يستخدم إذا لم يتم تمرير متحكم خارجي)
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  // ⭐️ مهم: تصحيح الوصول إلى المتحكم الداخلي ⭐️
  @override
  void didUpdateWidget(covariant MyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // إذا كان المتحكم القديم داخليًا، تخلص منه (نستخدم `_controller` مباشرةً)
      if (oldWidget.controller == null) {
        _controller?.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    // التخلص من المتحكم فقط إذا كان داخليًا
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

// ===============================================
// 2. MyTextFieldWS (حقل كلمة المرور مع زر الإظهار/الإخفاء)
// ===============================================

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

  // ⭐️ مهم: تصحيح الوصول إلى المتحكم الداخلي ⭐️
  @override
  void didUpdateWidget(covariant MyTextFieldWS oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // إذا كان المتحكم القديم داخليًا، تخلص منه (نستخدم `_controller` مباشرةً)
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
