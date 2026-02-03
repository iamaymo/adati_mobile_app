import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/components/my_textfield.dart';
import 'package:adati_mobile_app/components/my_button.dart';
import 'package:adati_mobile_app/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();

  String? _selectedCity;
  File? _imageFile;
  String? _networkImageUrl; // للصورة القادمة من السيرفر
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> yemenCities = [
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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- جلب بيانات المستخدم من السيرفر ---
  Future<void> _fetchUserData() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/me/'), // تأكد من الرابط
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data['User_Name'] ?? '';
          _emailController.text = data['User_Email'] ?? '';
          _phoneController.text = data['Phone_Number'] ?? '';
          _streetController.text = data['Street'] ?? '';
          _selectedCity = yemenCities.contains(data['User_Address'])
              ? data['User_Address']
              : null;
          _networkImageUrl = data['Profile_Image'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- نافذة خيارات الصورة ---
  void _showImagePickerOptions() {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Take a Photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white,),
              title: const Text('Choose from Gallery',style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageFile != null || _networkImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                    _networkImageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // --- حفظ البيانات (MultipartRequest) ---
  // --- حفظ البيانات (MultipartRequest) ---
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final token = await AuthService.getToken();
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://10.0.2.2:8000/api/me/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['User_Name'] = _nameController.text;
      request.fields['User_Email'] = _emailController.text;
      request.fields['Phone_Number'] = _phoneController.text;
      request.fields['User_Address'] = _selectedCity ?? '';
      request.fields['Street'] = _streetController.text;

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Profile_Image', _imageFile!.path),
        );
      }

      // إرسال الطلب واستلام الاستجابة كاملة
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // نجاح التعديل
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        // فشل التعديل بسبب بيانات موجودة مسبقاً
        final errorData = jsonDecode(response.body);
        String errorMessage = "Update failed. Please try again.";

        if (errorData.containsKey('Phone_Number')) {
          errorMessage = "This phone number is already registered!";
        } else if (errorData.containsKey('User_Email')) {
          errorMessage = "This email address is already in use!";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red, // لون أحمر للتنبيه بالخطأ
          ),
        );
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please check your connection."),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // --- الصورة الشخصية مع القلم ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_networkImageUrl != null
                                  ? NetworkImage(
                                      _networkImageUrl!.startsWith('http')
                                          ? _networkImageUrl!.replaceAll(
                                              '127.0.0.1',
                                              '10.0.2.2',
                                            ) // لو الرابط كامل نعدل الايبي فقط
                                          : 'http://10.0.2.2:8000$_networkImageUrl', // لو الرابط ناقص (مسار فقط) نضيف السيرفر يدوياً
                                    )
                                  : null)
                              as ImageProvider?,
                    child: (_imageFile == null && _networkImageUrl == null)
                        ? Icon(Icons.person, size: 70, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBC02D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            MyTextField(label: "Full Name", controller: _nameController),
            const SizedBox(height: 20),
            MyTextField(label: "Email Address", controller: _emailController),
            const SizedBox(height: 20),
            MyTextField(label: "Phone Number", controller: _phoneController),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: InputDecoration(
                labelText: "City",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              items: yemenCities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
            const SizedBox(height: 20),
            MyTextField(label: "Street", controller: _streetController),
            const SizedBox(height: 40),
            _isSaving
                ? const CircularProgressIndicator()
                : MyButton(onPressed: _saveProfile, label: "Save Changes"),
          ],
        ),
      ),
    );
  }
}
