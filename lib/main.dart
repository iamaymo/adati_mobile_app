import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFBC02D);
    const Color secondaryColor = Colors.black;
    const Color tertiaryColor = Color(
      0xFFFFFFFF,
    ); // <-- Add your tertiary color here

    return MaterialApp(
      title: 'Focus Zone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: tertiaryColor, // <-- Add this line
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
