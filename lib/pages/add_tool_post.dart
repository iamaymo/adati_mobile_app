import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // نحتاجه لمنع إدخال الحروف في السعر
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/pages/add_tool_image.dart';
import 'package:adati_mobile_app/services/auth_service.dart';

class AddToolPost extends StatefulWidget {
  const AddToolPost({super.key});

  @override
  State<AddToolPost> createState() => _AddToolPostState();
}

class _AddToolPostState extends State<AddToolPost> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedImagePath;
  bool _isLoading = false;

  // دالة للتحقق هل الحقول ممتلئة أم لا
  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> uploadTool() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('http://10.0.2.2:8000/api/tools/');
      var request = http.MultipartRequest('POST', uri);
      String? token = await AuthService.getToken();
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['Tool_Name'] = _nameController.text;
      request.fields['Tool_Description'] = _descriptionController.text;
      request.fields['Tool_Price'] = _priceController.text;
      request.fields['Tool_Status'] = 'True';

      if (_selectedImagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Tool_Picture',
            _selectedImagePath!,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tool added successfully!")),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: ${response.body}")));
      }
    } catch (e) {
      print("Exception: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Add Tool Details',
          style: TextStyle(color: Colors.black,),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Tool Name *'),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (value) => setState(() {}), // لتحديث حالة الزر
                    decoration: _inputDecoration('Example: Electric Drill'),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Rental Price (Numbers Only) *'),
                  TextFormField(
                    controller: _priceController,
                    onChanged: (value) => setState(() {}), // لتحديث حالة الزر
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ], // يمنع الحروف تماماً
                    decoration: _inputDecoration('Example: 3000'),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Tool Description *'),
                  TextFormField(
                    controller: _descriptionController,
                    onChanged: (value) => setState(() {}), // لتحديث حالة الزر
                    maxLines: 4,
                    decoration: _inputDecoration(
                      'Write about tool condition...',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // زر إضافة الصورة - يتم تفعيله فقط عند ملئ الحقول
                  _buildAddImageButton(),

                  if (_selectedImagePath != null) ...[
                    const SizedBox(height: 20),
                    _buildImagePreview(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: uploadTool,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAddImageButton() {
    bool enabled = _isFormValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!enabled)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Please fill all fields to enable image upload",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enabled
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddToolImage(),
                      ),
                    );
                    if (result != null) {
                      setState(() => _selectedImagePath = result as String);
                    }
                  }
                : null, // تعطيل الزر برمجياً
            icon: const Icon(Icons.image, color: Colors.white),
            label: const Text(
              'Add Tool Image',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? const Color(0xFFFBC02D) : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selected Image Preview:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImagePath = null),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cancel, color: Colors.red, size: 30),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
