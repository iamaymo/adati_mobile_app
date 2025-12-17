import 'package:adati_mobile_app/pages/home_page.dart';
import 'package:adati_mobile_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import '/components/my_button.dart';
import '/components/back_button.dart';
import '/components/h1_text.dart';
import '/components/my_textfield.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ⭐️ تحديد العنوان في مكان واضح ⭐️
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // 1. تعريف المتحكمات
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _countryCodeController = TextEditingController(
    text: '+967',
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    // 1. تجميع البيانات
    final userName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    final userAddress =
        '${_cityController.text.trim()}, ${_districtController.text.trim()}';

    // 2. تجميع البيانات كـ JSON
    final Map<String, dynamic> requestBody = {
      // يجب أن تكون أسماء الحقول مطابقة لـ Serializer في Django
      "User_Name": userName,
      "User_Email": _emailController.text.trim(),
      "Phone_Number": _phoneNumberController.text.trim(),
      "User_Address": userAddress,
      "password": _passwordController.text, // غالباً ما يتوقع Django 'password'
    };

    final url = Uri.parse('$baseUrl/register/');

    try {
      // 3. إرسال طلب POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // 4. معالجة الرد من الخادم
      if (response.statusCode == 201) {
        // التسجيل ناجح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // ⭐️⭐️ التعديل الحاسم: الانتقال إلى صفحة HomePage ⭐️⭐️
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ), // ⬅️ تم التغيير هنا
        );
      } else if (response.statusCode == 400) {
        // خطأ في البيانات المدخلة
        String errorMessage = "Registration failed: ";
        try {
          final errorData = jsonDecode(response.body);

          if (errorData is Map) {
            errorData.forEach((key, value) {
              errorMessage +=
                  "$key: ${value.toString().replaceAll('[', '').replaceAll(']', '')}; ";
            });
          } else {
            errorMessage = "Registration failed. Raw error: ${response.body}";
          }
        } catch (e) {
          errorMessage =
              "Registration failed. Server sent an unreadable error. Status: 400";
        }
        print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 8),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // خطأ خادم آخر (مثل 500)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server Error: ${response.statusCode}. Please try again later.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // خطأ في الاتصال بالشبكة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection Error: Cannot reach the server at $baseUrl. Ensure Django is running.',
          ),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
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
              MyBackButton(),
              const SizedBox(height: 30),
              const H1Text(data: "Create Account"),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Row 1: First Name & Last Name (مربوطة بالمتحكمات)
                    Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: _firstNameController, // 👈 ربط
                            label: "First Name",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "First name is required";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextField(
                            label: "Last Name",
                            controller: _lastNameController, // 👈 ربط
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Last name is required";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Row 2: Email (مربوطة بالمتحكم)
                    MyTextField(
                      label: "Email",
                      controller: _emailController, // 👈 ربط
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Row 3: Phone Number
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: MyTextField(
                            label: "Key",
                            controller: _countryCodeController,
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextField(
                            label: "Phone Number",
                            controller: _phoneNumberController, // 👈 ربط
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Phone number is required";
                              }
                              if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                                return "Phone number must be 9 digits";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Row 4: City & District
                    Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            label: "City",
                            controller: _cityController, // 👈 ربط
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "City is required";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextField(
                            label: "District",
                            controller: _districtController, // 👈 ربط
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "District is required";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Row 5: Password
                    // نفترض أن MyTextFieldWS هو حقل إدخال كلمة المرور الخاص بك
                    MyTextFieldWS(
                      label: "Password",
                      controller: _passwordController, // 👈 ربط
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              MyButton(
                onPressed: () {
                  // التحقق من المدخلات قبل الإرسال
                  if (_formKey.currentState?.validate() ?? false) {
                    registerUser();
                  }
                },
                label: "Register",
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      minimumSize: MaterialStateProperty.all(Size(0, 0)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      "Login Now",
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
