import 'package:adati_mobile_app/pages/edit_tool_post.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';
import '../components/product_dialog.dart';

class MyToolsPage extends StatefulWidget {
  const MyToolsPage({Key? key}) : super(key: key);

  @override
  State<MyToolsPage> createState() => _MyToolsPageState();
}

class _MyToolsPageState extends State<MyToolsPage> {
  bool _isLoading = true;
  List<dynamic> _tools = [];
  final String baseUrl = 'http://10.0.2.2:8000';
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchMyTools();
  }

  Future<void> _loadUserId() async {
    setState(() {
      // _currentUserId = ['User_ID'];
    });
  }

  String _formatImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  Product _mapToolToProduct(Map<String, dynamic> item) {
    return Product(
      id: item['Tool_ID'] ?? 0,
      title: item['Tool_Name'] ?? 'No Name',
      price: (double.tryParse(item['Tool_Price'].toString()) ?? 0.0)
          .round()
          .toString(),
      images: [_formatImageUrl(item['Tool_Picture'])],
      ownerId: item['User_ID'] ?? 0,
      description: item['Tool_Description'] ?? '',
    );
  }

  Future<void> _fetchMyTools() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/my-tools/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(
          utf8.decode(response.bodyBytes),
        );
        if (mounted) {
          setState(() {
            _tools = decodedData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTool(int toolId) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/tools/$toolId/delete/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _tools.removeWhere((t) => t['Tool_ID'] == toolId);
          });
        }
        _showSuccessSnackBar("Tool deleted successfully");
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }
  void _showSuccessSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _showOptionsSheet(BuildContext context, Map<String, dynamic> item) {

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditToolPost(toolData: item),
                      ),
                    );
                  },
                ),
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
                Colors.grey[900],
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
        Uri.parse('$baseUrl/api/tools/$toolId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'Tool_Status': !currentStatus}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            int index = _tools.indexWhere((t) => t['Tool_ID'] == toolId);
            if (index != -1) {
              _tools[index]['Tool_Status'] = !currentStatus;
            }
          });
        }
        _showSuccessSnackBar(
          !currentStatus ? "Tool is now available" : "Tool is now unavailable",
        );
      }
    } catch (e) {
      debugPrint("Toggle Error: $e");
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
    double priceDouble = double.tryParse(item['Tool_Price'].toString()) ?? 0.0;
    String cleanPrice = priceDouble
        .round()
        .toString();

    String imageUrl = item['Tool_Picture'] != null
        ? (item['Tool_Picture'].startsWith('http')
              ? item['Tool_Picture']
              : 'http://10.0.2.2:8000${item['Tool_Picture']}')
        : '';

    bool isRented = item['Tool_Status'] == false;

    return GestureDetector(
      onTap: () {
        showProductDialog(context, _mapToolToProduct(item), item['User_ID']);
      },

      child: Container(
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
                _buildStatusBadge(isRented),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptionsSheet(context, item),
                ),
              ],
            ),
          ],
        ),
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
      body: RefreshIndicator(
        color: const Color(0xFFFBC02D),
        onRefresh: () async {
          await _fetchMyTools();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tools.isEmpty
            ? const Center(child: Text('You haven\'t added any tools yet.'))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _tools.length,
                itemBuilder: (context, index) => _buildToolCard(_tools[index]),
              ),
      ),
    );
  }
}
