import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/components/my_textfield.dart';
import 'package:adati_mobile_app/components/my_button.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:adati_mobile_app/pages/forget_password_page.dart';
import 'package:adati_mobile_app/pages/password_changed_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    // 1. التحقق من تطابق كلمتي السر الجديدتين
    if (_newPassController.text != _confirmPassController.text) {
      _showSnackBar("New passwords do not match!", Colors.red);
      return;
    }

    // 2. التحقق من ملء الحقول
    if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/change-password/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'old_password': _oldPassController.text,
          'new_password': _newPassController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PasswordChangedPage(),
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(
          errorData['error'] ?? "Failed to update password",
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar("Connection error. Please check your server.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update your account password to stay secure.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // حقل الباسورد القديم
            MyTextFieldWS(
              label: "Current Password",
              controller: _oldPassController,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // حقل الباسورد الجديد
            MyTextFieldWS(
              label: "New Password",
              controller: _newPassController,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // تأكيد الباسورد الجديد
            MyTextFieldWS(
              label: "Confirm New Password",
              controller: _confirmPassController,
              obscureText: true,
            ),

            // رابط نسيت كلمة السر أسفل اليمين
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgetPasswordPage(),
                    ),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.blue[900],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFBC02D)),
                  )
                : MyButton(
                    onPressed: _updatePassword,
                    label: "Update Password",
                  ),
          ],
        ),
      ),
    );
  }
}
