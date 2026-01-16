import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Note: Ensure your local path for MyButton is correct
import 'package:adati_mobile_app/components/my_button.dart';

class IdcardImagePicker extends StatefulWidget {
  const IdcardImagePicker({super.key});

  @override
  State<IdcardImagePicker> createState() => _IdcardImagePickerState();
}

class _IdcardImagePickerState extends State<IdcardImagePicker> {
  final ImagePicker _picker = ImagePicker();
  String? _frontImagePath;
  String? _backImagePath;

  // Check if front side is uploaded (was requiring both sides)
  bool get _isFormValid => _frontImagePath != null;

  Future<void> _pickImage(ImageSource source, String target) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          if (target == 'front') {
            _frontImagePath = pickedFile.path;
          } else {
            _backImagePath = pickedFile.path;
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showPickOptions(String target) {
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
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Choose from Gallery',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.gallery, target);
                              },
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
                                _pickImage(ImageSource.camera, target);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ID Card Image',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSectionTitle("ID Card From The Front"),
                      const SizedBox(height: 8),
                      _frontImagePath == null
                          ? _buildAddControls('front')
                          : _buildImagePreview(_frontImagePath!, 'front'),
                      const SizedBox(height: 24),
                      _buildSectionTitle("ID Card From The Back"),
                      const SizedBox(height: 8),
                      _backImagePath == null
                          ? _buildAddControls('back')
                          : _buildImagePreview(_backImagePath!, 'back'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // REGISTER BUTTON SECTION
              SizedBox(
                width: double.infinity,
                height: 50,
                child: MyButton(
                  onPressed: _isFormValid
                      ? () {
                          // نغلق الصفحة ونعيد مسارات الصور لصفحة الـ Register
                          Navigator.pop(context, {
                            'front': _frontImagePath,
                            'back': _backImagePath,
                          });
                        }
                      : null, // الزر يكون معطل حتى يختار الصورة
                  label: 'Continue', // غيرنا النص ليكون أنسب للمرحلة التالية
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildAddControls(String target) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showPickOptions(target),
          child: DashedRoundedContainer(
            width: double.infinity,
            height: 80,
            borderRadius: 12,
            dashColor: const Color(0xFFFBC02D),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFFFBC02D),
                    size: 30,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Select ID Photo',
                    style: TextStyle(
                      color: Color(0xFFFBC02D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildImagePreview(String path, String target) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
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
                color: Colors.grey[50],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (target == 'front') {
                      _frontImagePath = null;
                    } else {
                      _backImagePath = null;
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Container(
            height: 45, // يمكنك التحكم في الطول
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: const Color(0xFFFBC02D), // اللون الأصفر
                strokeWidth: 2,
                borderRadius: 12,
              ),
              child: TextButton(
                onPressed: () => _showPickOptions(target),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      color: Color(0xFFFBC02D), // النص باللون الأصفر أيضاً
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedRoundedContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final Color dashColor;
  final double strokeWidth;

  const DashedRoundedContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius = 12,
    this.dashColor = Colors.black,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        borderRadius: borderRadius,
        color: dashColor,
        strokeWidth: strokeWidth,
      ),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color color;
  final double strokeWidth;

  _DashedBorderPainter({
    this.borderRadius = 12,
    this.color = Colors.black,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          next.clamp(0.0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = next + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
