import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // استيراد المكتبة

class AddToolImage extends StatefulWidget {
  const AddToolImage({super.key});

  @override
  State<AddToolImage> createState() => _AddToolImageState();
}

class _AddToolImageState extends State<AddToolImage> {
  final ImagePicker _picker = ImagePicker();

  // دالة اختيار الصورة
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // لتقليل حجم الصورة قبل الرفع
      );

      if (pickedFile != null) {
        // العودة للصفحة السابقة وإرسال مسار الصورة
        Navigator.pop(context, pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Tool Image',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر المعرض
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: DashedRoundedContainer(
                          width: double.infinity,
                          height: 120,
                          borderRadius: 12,
                          dashColor: const Color(0xFFFBC02D),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFFFBC02D),
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Go To Your Photos',
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
                      const SizedBox(height: 20),
                      // زر الكاميرا
                      SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFBC02D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Use Camera',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كود الـ DashedRoundedContainer يبقى كما هو عندك...

/// Simple widget that draws a dashed rounded rectangle around its child.
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

    // draw dashed path
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
