import 'package:adati_mobile_app/components/h1_text.dart';
import 'package:flutter/material.dart';
import '/components/my_button.dart';

class PasswordChangedPage extends StatefulWidget {
  const PasswordChangedPage({super.key});

  @override
  State<PasswordChangedPage> createState() => _PasswordChangedPageState();
}

class _PasswordChangedPageState extends State<PasswordChangedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset( 
                "images/check.png",
                height: MediaQuery.of(context).size.height * 0.18,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              H1Text(data: "Password Changed!"),
              const SizedBox(height: 8),
              Text(
                "Your password has been changed\nsuccessfully.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: MyButton(
                  onPressed: () {
                    // navigate back to login or pop
                    Navigator.of(context).pop();
                  },
                  label: "Back to Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
