import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class EditToolPost extends StatefulWidget {
  final Map<String, dynamic> toolData; // استقبال بيانات الأداة الحالية

  const EditToolPost({super.key, required this.toolData});

  @override
  State<EditToolPost> createState() => _EditToolPostState();
}

class _EditToolPostState extends State<EditToolPost> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Navigator.of(ctx).pop(),
          child: Container(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.28, // رفعناه قليلاً ليناسب المحتوى
                minChildSize: 0.2,
                maxChildSize: 0.6,
                builder: (context, scrollController) {
                  final bottomInset = MediaQuery.of(context).viewPadding.bottom;
                  return Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20), // زوايا أكثر نعومة
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 12,
                          left: 12,
                          right: 12,
                          bottom: bottomInset + 16,
                        ),
                        child: ListView(
                          controller: scrollController,
                          shrinkWrap: true,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Take a Photo',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickFromCamera();
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Choose from Gallery',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickFromGallery();
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  static const int _maxImages = 3;
  List<dynamic> _selectedImages =
      []; // قد تحتوي على String (مسارات قديمة) أو File (صور جديدة)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // تنظيف السعر
    String rawPrice = widget.toolData['Tool_Price']?.toString() ?? "0";
    if (rawPrice.contains('.')) {
      rawPrice = rawPrice.split('.')[0];
    }

    // تعبئة البيانات
    _nameController = TextEditingController(text: widget.toolData['Tool_Name']);
    _priceController = TextEditingController(text: rawPrice);
    _descriptionController = TextEditingController(
      text: widget.toolData['Tool_Description'],
    );

    // ✅ السطر الناقص الذي سيقوم بعرض الصور فوراً
    _loadExistingImages();
  }

  void _loadExistingImages() {
    final data = widget.toolData;
    if (data['Tool_Picture'] != null) _selectedImages.add(data['Tool_Picture']);
    if (data['Tool_Picture2'] != null)
      _selectedImages.add(data['Tool_Picture2']);
    if (data['Tool_Picture3'] != null)
      _selectedImages.add(data['Tool_Picture3']);
  }

  Future<void> _pickFromGallery() async {
    if (_selectedImages.length >= _maxImages) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickFromCamera() async {
    if (_selectedImages.length >= _maxImages) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> updateTool() async {
    setState(() => _isLoading = true);
    try {
      // 1. تحديد الرابط الخاص بالأداة المحددة للتعديل
      final toolId = widget.toolData['Tool_ID'];
      final uri = Uri.parse('http://10.0.2.2:8000/api/tools/$toolId/');

      // 2. استخدام PATCH بدلاً من PUT لتحديث الحقول المرسلة فقط
      var request = http.MultipartRequest('PATCH', uri);
      String? token = await AuthService.getToken();
      request.headers['Authorization'] = 'Bearer $token';

      // 3. إضافة البيانات النصية
      request.fields['Tool_Name'] = _nameController.text;
      request.fields['Tool_Description'] = _descriptionController.text;
      request.fields['Tool_Price'] = _priceController.text;

      // 4. التعامل مع الصور (نمر على القائمة ونضيف فقط الملفات الجديدة)
      // ملاحظة: السيرفر يحتاج مسميات محددة Tool_Picture, Tool_Picture2, Tool_Picture3
      for (int i = 0; i < _selectedImages.length; i++) {
        String fieldName = (i == 0) ? 'Tool_Picture' : 'Tool_Picture${i + 1}';

        if (_selectedImages[i] is File) {
          // إذا كان ملفاً جديداً، نقوم برفعه
          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
              (_selectedImages[i] as File).path,
            ),
          );
        } else {
          // إذا كان نصاً (URL)، يعني أن الصورة لم تتغير، لا نرسل شيئاً لهذا الحقل
          // السيرفر سيعتبره حقلاً لم يتغير ويحتفظ بالقديم بفضل الـ PATCH
        }
      }

      // 5. إرسال الطلب
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tool updated successfully!")),
        );
        Navigator.pop(
          context,
          true,
        ); // نرجع true لنخبر الصفحة السابقة بضرورة التحديث
      } else {
        if (!mounted) return;
        print("Error body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Exception during update: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Edit Tool Details',
          style: TextStyle(color: Colors.black),
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
                    onChanged: (value) => setState(() {}),
                    decoration: _inputDecoration('Example: Electric Drill'),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Rental Price (Per Day) *'),
                  TextFormField(
                    controller: _priceController,
                    onChanged: (value) => setState(() {}),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration('Example: 3000'),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Tool Description *'),
                  TextFormField(
                    controller: _descriptionController,
                    onChanged: (value) => setState(() {}),
                    maxLines: 4,
                    decoration: _inputDecoration(
                      'Write about tool condition...',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // زر الحفظ (نفس شكل زر المشاركة)
                  _buildLabel('Tool Images (Max 3)'),
                  const Text(
                    "The first image is the main display photo.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _selectedImages.length < _maxImages
                        ? _selectedImages.length + 1
                        : _maxImages,
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length &&
                          _selectedImages.length < _maxImages) {
                        return _buildAddImageButton();
                      }
                      return _buildImagePreview(index);
                    },
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid ? updateTool : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBC02D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey),
            SizedBox(height: 4),
            Text("Add", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    final image = _selectedImages[index];
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image is File
                ? Image.file(
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.network(
                    image.startsWith('http')
                        ? image
                        : 'http://10.0.2.2:8000$image',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImages.removeAt(index)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel, color: Colors.red, size: 20),
            ),
          ),
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
