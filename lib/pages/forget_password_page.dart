import 'package:adati_mobile_app/components/back_button.dart';
import 'package:adati_mobile_app/components/h1_text.dart';
import 'package:adati_mobile_app/components/my_button.dart';
import 'package:adati_mobile_app/components/my_textfield.dart';
import 'package:adati_mobile_app/pages/login_page.dart';
import 'package:adati_mobile_app/pages/verification_page.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final pattern = r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 100, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyBackButton(),
              SizedBox(height: 30),
              H1Text(data: "Forgot Password?"),
              SizedBox(height: 20),
              Text(
                "Don't worry! It occurs. Please enter the email address linked with your account.",
                style: TextStyle(color: Colors.grey[800], fontSize: 16),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: MyTextField(
                  label: "Enter your email",
                  validator: _emailValidator,
                  controller: _emailController,
                ),
              ),

              SizedBox(height: 25),
              MyButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VerificationPage(email: _emailController.text),
                      ),
                    );
                  }
                },
                label: "Send Code",
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Remember Password? ",
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      minimumSize: WidgetStateProperty.all(Size(0, 0)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue[900],
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
