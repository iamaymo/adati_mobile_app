// ignore_for_file: deprecated_member_use

import 'package:adati_mobile_app/components/my_button.dart';
import 'package:flutter/material.dart';

class UserGatewayPage extends StatefulWidget {
  const UserGatewayPage({super.key});

  @override
  State<UserGatewayPage> createState() => _UserGatewayPageState();
}

class _UserGatewayPageState extends State<UserGatewayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/login_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      width: MediaQuery.of(context).size.width * 0.4,
                      "images/adati_logo_txt.png",
                    ),
                    MyButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
