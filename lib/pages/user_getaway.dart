import 'package:adati_mobile_app/components/my_button.dart';
import 'package:adati_mobile_app/pages/legal_and_policies.dart';
import 'package:adati_mobile_app/pages/login_page.dart';
import 'package:adati_mobile_app/pages/register_page.dart';
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
                height: MediaQuery.of(context).size.height * 0.345,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.48,
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
                    SizedBox(height: 10),
                    MyButton(
                      label: "Login",
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),

                    SizedBox(height: 20),
                    MyButton(
                      label: "Register",
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      textColor: Theme.of(context).colorScheme.secondary,
                      borderColor: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LegalPoliciesPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Continue as Guest",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
