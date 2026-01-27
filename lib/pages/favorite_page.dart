import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';

// ✅ استيراد نفس ملفات السلة
import '../components/product_dialog.dart';

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
    // ترتيب المنطق: جلب المستخدم أولاً ثم جلب المفضلات
    fetchCurrentUser().then((_) {
      fetchFavorites();
    });
  }

  // جلب المفضلات المرتبطة بالحساب من السيرفر
  Future<void> fetchFavorites() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/favorites/'),
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
      debugPrint("Error removing favorite: $e");
    }
  }

  // ✅ تحويل عنصر المفضلة إلى Product
  Product _mapFavoriteToProduct(Map<String, dynamic> item) {
    // 3. تحويل السعر
    double priceAsDouble =
        double.tryParse(item['Tool_Price'].toString()) ?? 0.0;
    double realValueAsDouble =
        double.tryParse(item['real_value'].toString()) ?? 0.0;
    // 4. استخراج ID المالك (حسب الـ Serializer الخاص بك هو User_ID داخل الأداة)
    int ownerId = item['User_ID'] ?? 0;

    return Product(
      id: item['Tool_ID'] ?? 0,
      title: item['Tool_Name'] ?? 'No Name',
      price: priceAsDouble.toInt().toString(), // سيحول 3000.0 إلى "3000"
      realValue: realValueAsDouble,
      images: [
        item['Tool_Picture'].startsWith('http')
            ? item['Tool_Picture']
            : 'http://10.0.2.2:8000${item['Tool_Picture']}',
      ], // الصور الآن ستمر بشكل صحيح للديلوق
      ownerId: ownerId,
      description: item['Tool_Description'] ?? '',
    );
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

  int? currentUserId;
  // داخل FavoritePage
  Future<void> fetchCurrentUser() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // تأكد أن الحقل في الـ API هو User_ID وليس id
          currentUserId = data['User_ID'];
        });
        debugPrint(
          "Current User ID Loaded: $currentUserId",
        ); // للتأكد في الـ Console
      }
    } catch (e) {
      debugPrint("Error fetching user ID: $e");
    }
  }

  Widget _buildFavoriteItem(Map<String, dynamic> item) {
    final p = _mapFavoriteToProduct(item);
    String imageUrl = item['Tool_Picture'].startsWith('http')
        ? item['Tool_Picture']
        : 'http://10.0.2.2:8000${item['Tool_Picture']}';

    return GestureDetector(
      onTap: () {
        if (currentUserId == null) return; // safety

        final product = _mapFavoriteToProduct(item);

        showProductDialog(context, product, currentUserId);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.fromARGB(99, 251, 193, 45),
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
                    "YER ${p.price}",
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
      ),
    );
  }
}

extension on double {
  toInt() {}
}
