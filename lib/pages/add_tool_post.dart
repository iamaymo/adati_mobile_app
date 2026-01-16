import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // نحتاجه لمنع إدخال الحروف في السعر
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart'; // NEW

class AddToolPost extends StatefulWidget {
  const AddToolPost({super.key});

  @override
  State<AddToolPost> createState() => _AddToolPostState();
}

class _AddToolPostState extends State<AddToolPost> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const int _maxImages = 3; // NEW: maximum allowed images

  List<String> _selectedImages = []; // NEW: multiple image paths
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

      // --- التعديل هنا لتوزيع الصور على الثلاثة حقول ---

      if (_selectedImages.isNotEmpty) {
        // الصورة الأولى للحقل الأساسي
        request.files.add(
          await http.MultipartFile.fromPath('Tool_Picture', _selectedImages[0]),
        );

        // الصورة الثانية (إذا وجدت) للحقل الثاني
        if (_selectedImages.length > 1) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'Tool_Picture2',
              _selectedImages[1],
            ),
          );
        }

        // الصورة الثالثة (إذا وجدت) للحقل الثالث
        if (_selectedImages.length > 2) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'Tool_Picture3',
              _selectedImages[2],
            ),
          );
        }
      }
      // -----------------------------------------------

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
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Add Tool Details',
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
                    onChanged: (value) => setState(() {}), // لتحديث حالة الزر
                    decoration: _inputDecoration('Example: Electric Drill'),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Rental Price (Numbers Only) *'),
                  TextFormField(
                    controller: _priceController,
                    onChanged: (value) =>
                        setState(() {}), // لتحديث الحسبة فوراً أثناء الكتابة
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration('Example: 3000'),
                  ),

                  // الملاحظة الديناميكية
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Builder(
                      builder: (context) {
                        // جلب القيمة من المتحكم وتحويلها لرقم
                        double inputPrice =
                            double.tryParse(_priceController.text) ?? 0;
                        // حساب الخصم (10%)
                        double fee = inputPrice * 0.10;
                        // المبلغ النهائي
                        double finalAmount = inputPrice - fee;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Note: Adati takes a 10% service fee.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                            if (inputPrice > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  left: 21.0,
                                ),
                                child: Text(
                                  'If you set ${inputPrice.toStringAsFixed(0)} , you will receive ${finalAmount.toStringAsFixed(0)} YER.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(
                                      0xFF2E5AAC,
                                    ), // لون أزرق لتمييز المبلغ
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
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

                  // Selected images grid (appears between Description and Add Image button)
                  if (_selectedImages.isNotEmpty) _buildImageGrid(),
                  const SizedBox(height: 20),

                  // Full-width Add Image button only when NO images selected
                  if (_selectedImages.isEmpty) _buildAddImageButton(),

                  const SizedBox(height: 20),

                  // Upload button (moved to the end). Text changed to "Share tool".
                  if (_selectedImages.isNotEmpty)
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
                          'Share tool',
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
                ? () =>
                      _showImageSourceSheet() // NEW: open bottom sheet for picking
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

  // NEW: show modal bottom sheet styled exactly like idcard_image_picker (black draggable sheet)
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
                initialChildSize: 0.25,
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
                          top: Radius.circular(12),
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
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white54,
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

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    try {
      final images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        final remaining = _maxImages - _selectedImages.length;
        if (remaining <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You can add up to 3 images.")),
            );
          }
          return;
        }
        final toAdd = images.take(remaining).map((e) => e.path).toList();
        setState(() {
          _selectedImages.addAll(toAdd);
        });
        if (images.length > remaining && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Only $remaining image(s) were added (max $_maxImages).",
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Gallery pick error: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    try {
      if (_selectedImages.length >= _maxImages) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can add up to 3 images.")),
          );
        }
        return;
      }
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image.path);
        });
      }
    } catch (e) {
      print('Camera pick error: $e');
    }
  }

  // UPDATED: grid preview for multiple images (4 columns) with small 'X' to remove
  // and an extra small add-tile (square with plus) as the last cell
  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selected Image Preview:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              _selectedImages.length +
              (_selectedImages.length < _maxImages ? 1 : 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            // If last cell -> show add-tile
            if (index == _selectedImages.length &&
                _selectedImages.length < _maxImages) {
              return GestureDetector(
                onTap: () {
                  if (_isFormValid) _showImageSourceSheet();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      // nested smaller yellow square to make the "add" button appear smaller
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBC02D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            final path = _selectedImages[index];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(path),
                    height: 70,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedImages.removeAt(index)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
