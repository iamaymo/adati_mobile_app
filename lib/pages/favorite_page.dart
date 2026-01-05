import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool isLoading = true;
  List<dynamic> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  // جلب المفضلات المرتبطة بالحساب من السيرفر
  Future<void> fetchFavorites() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8000/api/favorites/',
        ), // تأكد من المسار في السيرفر
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          favoriteItems = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // حذف من المفضلة عبر السيرفر
  Future<void> removeFromFavorite(int toolId) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/favorites/toggle/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'tool_id': toolId}),
      );
      if (response.statusCode == 200) {
        fetchFavorites(); // إعادة جلب القائمة بعد الحذف
      }
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return _buildFavoriteItem(item);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "Your favorite list is empty",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> item) {
    // معالجة رابط الصورة
    String imageUrl = item['Tool_Picture'].startsWith('http')
        ? item['Tool_Picture']
        : 'http://10.0.2.2:8000${item['Tool_Picture']}';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['Tool_Name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "YER ${item['Tool_Price']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => removeFromFavorite(item['Tool_ID']),
          ),
        ],
      ),
    );
  }
}
