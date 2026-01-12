import 'package:adati_mobile_app/pages/home_page.dart';
import 'package:adati_mobile_app/pages/idcard_image_picker.dart';
import 'package:adati_mobile_app/pages/login_page.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
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

  // New: Yemen cities and selected city
  final List<String> _yemenCities = [
    "Sana'a",
    "Aden",
    "Taiz",
    "Al Hudaydah",
    "Ibb",
    "Dhamar",
    "Al Mukalla",
    "Marib",
    "Amran",
    "Hajjah",
    "Saada",
    "Al Mahwit",
    "Raymah",
    "Shabwah",
    "Abyan",
    "Lahij",
    "Socotra",
    "Al Bayda",
    "Al Dhale'",
    "Al Mahrah",
  ];
  String? _selectedCity;

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

  // Replace previous registerUser() with this multipart version that accepts imagePath
  Future<void> registerUser(String imagePath) async {
    final url = Uri.parse('$baseUrl/register/');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add text fields (field names should match backend expected names)
      request.fields['User_Name'] =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
      request.fields['User_Email'] = _emailController.text.trim();
      request.fields['Phone_Number'] = _phoneNumberController.text.trim();
      request.fields['User_Address'] = _cityController.text
          .trim(); // المدينة فقط
      request.fields['Street'] = _districtController.text.trim();
      request.fields['password'] = _passwordController.text;

      // Attach image file
      request.files.add(
        await http.MultipartFile.fromPath('ID_Card_Image', imagePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 1. اطبع الرد كاملاً في الـ Terminal عندك
        print("FULL SERVER RESPONSE: ${response.body}");

        try {
          final Map<String, dynamic> responseData = json.decode(response.body);

          // 2. تأكد من اسم مفتاح التوكن (قد يكون 'access' أو 'token' أو 'token_key')
          String? token = responseData['access'] ?? responseData['token'];

          if (token != null) {
            await AuthService.saveToken(token);
            print("TOKEN SAVED!");
          } else {
            print(
              "WARNING: No token found in response keys: ${responseData.keys}",
            );
          }
        } catch (e) {
          print("JSON PARSE ERROR: $e");
        }

        // 3. الانتقال للهوم (وضعته خارج الـ try للتأكد من حدوثه حتى لو فشل حفظ التوكن)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        // Show server response (may contain validation errors)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${response.body}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection Error: Cannot reach the server at $baseUrl. $e',
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
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return "First name is required";
                              // Allow Arabic and Latin letters, spaces, hyphen/apostrophe; min 2 chars
                              if (!RegExp(
                                r"^[\u0600-\u06FFa-zA-Z\s'\-]{2,}$",
                              ).hasMatch(v)) {
                                return "Enter a valid first name (letters only)";
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
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return "Last name is required";
                              if (!RegExp(
                                r"^[\u0600-\u06FFa-zA-Z\s'\-]{2,}$",
                              ).hasMatch(v)) {
                                return "Enter a valid last name (letters only)";
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
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return "Email is required";
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(v))
                          return "Enter a valid email address";
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
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return "Phone number is required";
                              }
                              // 1) Check length first
                              if (v.length != 9) {
                                return "Phone must be exactly 9 digits";
                              }
                              // 2) Check first digit
                              if (!v.startsWith('7')) {
                                return "Phone must start with 7";
                              }
                              // 3) Check second digit allowed set
                              final second = v[1];
                              if (!'7310'.contains(second)) {
                                return "Second digit must be one of: 7, 3, 1, or 0";
                              }
                              // Optional: ensure all characters are digits
                              if (!RegExp(r'^\d{9}$').hasMatch(v)) {
                                return "Phone must contain only digits";
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
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromARGB(255, 230, 229, 229),
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCity,
                                isExpanded: true,
                                dropdownColor: Colors.grey[100],
                                decoration: const InputDecoration(
                                  hintText: "City",
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: _yemenCities
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCity = val;
                                    _cityController.text = val ?? '';
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return "City is required";
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextField(
                            label: "Street",
                            controller: _districtController, // 👈 ربط
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Street is required";
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
                onPressed: () async {
                  // Validate form first
                  if (_formKey.currentState?.validate() ?? false) {
                    // Navigate to IdcardImagePicker and wait for returned image path (front image)
                    final dynamic result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IdcardImagePicker(),
                      ),
                    );

                    if (result != null &&
                        result is Map &&
                        result['front'] != null) {
                      // 3. استدعاء دالة التسجيل مع مسار الصورة
                      await registerUser(result['front']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select ID image')),
                      );
                    }
                  }
                },
                label: "Next",
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
