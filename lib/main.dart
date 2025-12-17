import 'package:flutter/material.dart';
import 'package:adati_mobile_app/pages/home_page.dart';
import 'package:adati_mobile_app/pages/user_getaway.dart'; 
import 'package:adati_mobile_app/services/auth_service.dart';

void main() async {
  // 1. تأمين تهيئة إضافات فلاتر
  WidgetsFlutterBinding.ensureInitialized();

  // 2. جلب التوكن مع التعامل مع القيمة إذا كانت Null
  String? token = await AuthService.getToken();
  
  // 3. تحويل النتيجة لمتغير bool واضح وصريح
  bool hasToken = token != null && token.isNotEmpty;

  runApp(MyApp(isLoggedIn: hasToken));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  // تأكد أن isLoggedIn مطلوبة وغير قابلة لتكون Null
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFBC02D);
    const Color secondaryColor = Colors.black;
    const Color tertiaryColor = Color(0xFFFFFFFF);

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
      // استخدام القيمة المحسوبة مسبقاً
      home: isLoggedIn ? const HomePage() : const UserGatewayPage(),
    );
  }
}