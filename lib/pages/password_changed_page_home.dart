import 'package:adati_mobile_app/components/h1_text.dart';
import 'package:flutter/material.dart';
import '/components/my_button.dart';

class PasswordChangedPageHome extends StatefulWidget {
  const PasswordChangedPageHome({super.key});

  @override
  State<PasswordChangedPageHome> createState() => _PasswordChangedPageHomeState();
}

class _PasswordChangedPageHomeState extends State<PasswordChangedPageHome> {
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
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  label: "Back to Home",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
