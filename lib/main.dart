import 'package:flutter/material.dart';
import 'package:adati_mobile_app/pages/home_page.dart';
import 'package:adati_mobile_app/pages/user_getaway.dart'; 
import 'package:adati_mobile_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? token = await AuthService.getToken();
  
  bool hasToken = token != null && token.isNotEmpty;

  runApp(MyApp(isLoggedIn: hasToken));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFBC02D);
    const Color secondaryColor = Colors.black;
    const Color tertiaryColor = Colors.white;

    return MaterialApp(
      title: 'Adati App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: isLoggedIn ? const HomePage() : const UserGatewayPage(),
    );
  }
}