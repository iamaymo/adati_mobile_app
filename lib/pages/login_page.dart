import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// الاستيرادات الخاصة بك
import 'package:adati_mobile_app/pages/forget_password_page.dart';
import '/components/my_button.dart';
import '/components/back_button.dart';
import '/components/h1_text.dart';
import '/components/my_textfield.dart';
import '/pages/register_page.dart';
import '/pages/home_page.dart'; // 👈 استيراد الصفحة الرئيسية
import 'package:adati_mobile_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 1. تعريف المتحكمات لاستخراج النصوص
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // دالة تسجيل الدخول
  Future<void> loginUser() async {
    // التحقق من صحة المدخلات محلياً أولاً
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // عنوان الـ API (تأكد من استخدام IP جهازك إذا كنت تجرب على جوال حقيقي)
    const String url = 'http://10.0.2.2:8000/api/token/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'User_Email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // نجاح تسجيل الدخول
        final data = jsonDecode(response.body);

        // حالياً سنطبع التوكن فقط (سنقوم بحفظه لاحقاً في SharedPreferences)
        print("Access Token: ${data['access']}");
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // حفظ التوكن الحقيقي القادم من السيرفر
          await AuthService.saveToken(data['access']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Successful!'),
              backgroundColor: Colors.green,
            ),
          );

          // الانتقال للصفحة الرئيسية
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        print("Error Body: ${response.body}");
        // فشل تسجيل الدخول (بيانات خاطئة)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // خطأ في الاتصال بالخادم
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Server error: $e')));
      }
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final pattern = r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$';
    if (!RegExp(pattern).hasMatch(value.trim()))
      return 'Please enter a valid email';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Please enter your password';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyBackButton(),
              const SizedBox(height: 30),
              const H1Text(data: "Welcome Back !"),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyTextField(
                      controller: _emailController, // 👈 ربط المتحكم
                      label: "Enter your email",
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 15),
                    MyTextFieldWS(
                      controller: _passwordController, // 👈 ربط المتحكم
                      label: "Enter your password",
                      validator: _passwordValidator,
                      obscureText: true, // تأكد من وجود خاصية إخفاء الباسورد
                    ),
                  ],
                ),
              ),
              // ... (زر Forget Password كما هو في كودك)
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
                    "Forget Password?",
                    style: TextStyle(
                      color: Colors.blue[900],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MyButton(
                onPressed: loginUser, // 👈 استدعاء الدالة هنا
                label: "Login",
              ),
              const SizedBox(height: 30),
              // ... (رابط Register Now كما هو في كودك)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Register Now",
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
