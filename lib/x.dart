import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class EditToolPost extends StatefulWidget {
  final Map<String, dynamic> toolData;

  const EditToolPost({super.key, required this.toolData});

  @override
  State<EditToolPost> createState() => _EditToolPostState();
}

class _EditToolPostState extends State<EditToolPost> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  static const int _maxImages = 3;
  // هذه القائمة ستحتوي على مسارات الصور (سواء روابط من السيرفر أو ملفات جديدة)
  List<dynamic> _selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // تنظيف السعر من .0
    String rawPrice = widget.toolData['Tool_Price']?.toString() ?? "0";
    if (rawPrice.contains('.')) rawPrice = rawPrice.split('.')[0];

    _nameController = TextEditingController(text: widget.toolData['Tool_Name']);
    _priceController = TextEditingController(text: rawPrice);
    _descriptionController = TextEditingController(
      text: widget.toolData['Tool_Description'],
    );

    // جلب الصور الثلاث من السيرفر ووضعها في القائمة
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

  Future<void> _pickImage() async {
    if (_selectedImages.length >= _maxImages) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Tool',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Tool Name *'),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Example: Electric Drill'),
            ),
            const SizedBox(height: 20),
            _buildLabel('Rental Price (Per Day) *'),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Example: 3000'),
            ),
            const SizedBox(height: 20),
            _buildLabel('Tool Description *'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration('Write about tool condition...'),
            ),
            const SizedBox(height: 25),

            // قسم الصور بنفس تصميم صفحة الإضافة
            _buildLabel('Tool Images (Max 3)'),
            const Text(
              "The first image is the main display photo.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                onPressed: _isFormValid
                    ? () {
                        /* سنضيف كود التحديث هنا */
                      }
                    : null,
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
      onTap: _pickImage,
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
