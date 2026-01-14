import 'package:adati_mobile_app/components/my_textfield.dart';
import 'package:adati_mobile_app/pages/password_changed_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/my_button.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_passController.text != _confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }
    // print(
    //   "Sending to server - Email: ${widget.email}, Pass: ${_passController.text}",
    // );
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'password': _passController.text,
        }),
      );
      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Password updated successfully!"),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PasswordChangedPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server error. Please try again later."),
          ),
        );
      }
    } catch (e) {
      print("Connection Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create New Password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Enter your new secure password below."),
            const SizedBox(height: 40),
            MyTextFieldWS(label: "New Password", controller: _passController),
            const SizedBox(height: 20),
            MyTextFieldWS(
              label: "Confirm Password",
              controller: _confirmController,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : MyButton(onPressed: _updatePassword, label: "Reset Password"),
          ],
        ),
      ),
    );
  }
}
