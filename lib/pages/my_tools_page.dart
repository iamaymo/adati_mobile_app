import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';

// ✅ استخدام نفس الـ Model الموجود في مشروعك لضمان التوافق
import '../components/product_dialog.dart';

class MyToolsPage extends StatefulWidget {
  const MyToolsPage({Key? key}) : super(key: key);

  @override
  State<MyToolsPage> createState() => _MyToolsPageState();
}

class _MyToolsPageState extends State<MyToolsPage> {
  bool _isLoading = true;
  List<dynamic> _tools = [];

  @override
  void initState() {
    super.initState();
    _fetchMyTools();
  }

  // ✅ جلب الأدوات الخاصة بي من السيرفر
  Future<void> _fetchMyTools() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8000/api/my-tools/',
        ), // تأكد من المسار في Django
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _tools = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching my tools: $e");
      setState(() => _isLoading = false);
    }
  }

  // ✅ حذف أداة من السيرفر
  Future<void> _deleteTool(int toolId) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.delete(
        Uri.parse(
          'http://10.0.2.2:8000/api/tools/$toolId/delete/',
        ), // تأكد من مطابقة المسار في urls.py بـ Django
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        // تحديث الواجهة بحذف العنصر من القائمة المحلية فوراً
        setState(() {
          _tools.removeWhere((t) => t['Tool_ID'] == toolId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tool deleted successfully"),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        debugPrint("Failed to delete: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error deleting tool: $e");
    }
  }

  void _showOptionsSheet(BuildContext context, Map<String, dynamic> item) {
    // تحديد هل الأداة متاحة حالياً أم لا
    bool isCurrentlyAvailable = item['Tool_Status'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text(
                    'Edit Tool',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // كود التعديل
                  },
                ),
                // الزر الذكي المحدث
                ListTile(
                  leading: Icon(
                    isCurrentlyAvailable
                        ? Icons.block
                        : Icons.check_circle_outline,
                    color: isCurrentlyAvailable ? Colors.orange : Colors.green,
                  ),
                  title: Text(
                    isCurrentlyAvailable
                        ? 'Make Tool Unavailable'
                        : 'Make it Available',
                    style: TextStyle(
                      color: isCurrentlyAvailable
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // نرسل الـ ID والحالة الحالية
                    _toggleToolAvailability(
                      item['Tool_ID'],
                      isCurrentlyAvailable,
                    );
                  },
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Tool',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> item) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor:
                Colors.grey[900], // جعل خلفية التنبيه داكنة لتناسب التصميم
            title: const Text(
              'Delete Tool',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to permanently delete "${item['Tool_Name']}"?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      _deleteTool(item['Tool_ID']);
    }
  }

  Future<void> _toggleToolAvailability(int toolId, bool currentStatus) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/api/tools/$toolId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'Tool_Status': !currentStatus}), // تحويلها لـ False
      );

      if (response.statusCode == 200) {
        // تحديث القائمة محلياً لرؤية التغيير فوراً
        _fetchMyTools();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentStatus
                  ? "Tool is now available"
                  : "Tool is now unavailable",
            ),
            backgroundColor: !currentStatus ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating tool status: $e");
    }
  }

  Widget _buildStatusBadge(bool isRented) {
    final color = isRented ? Colors.red.shade600 : Colors.green.shade700;
    final text = isRented ? 'Unavailable' : 'Available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildToolCard(Map<String, dynamic> item) {
    // 1. معالجة السعر ليظهر كـ رقم صحيح
    double priceDouble = double.tryParse(item['Tool_Price'].toString()) ?? 0.0;
    String cleanPrice = priceDouble
        .round()
        .toString(); // استخدم round() بدلاً من toInt()

    // 2. معالجة الصورة
    String imageUrl = item['Tool_Picture'] != null
        ? (item['Tool_Picture'].startsWith('http')
              ? item['Tool_Picture']
              : 'http://10.0.2.2:8000${item['Tool_Picture']}')
        : '';

    // 3. تحديد الحالة (المنطق الجديد)
    // في Django: Tool_Status = True تعني متوفر، و False تعني مؤجر
    // لذا نرسل "true" لـ _buildStatusBadge إذا كانت القيمة False
    bool isRented = item['Tool_Status'] == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.build),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['Tool_Name'] ?? 'No Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "YER $cleanPrice / Day",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // عرض الـ Badge بناءً على الحالة
              _buildStatusBadge(isRented),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsSheet(context, item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Tools',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tools.isEmpty
          ? const Center(child: Text('You haven\'t added any tools yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _tools.length,
              itemBuilder: (context, index) => _buildToolCard(_tools[index]),
            ),
    );
  }
}

extension on double {
  toInt() {}
}
