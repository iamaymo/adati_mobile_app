import 'package:adati_mobile_app/components/product_dialog.dart';
import 'package:adati_mobile_app/pages/incoming_requests.dart';
import 'package:adati_mobile_app/pages/order_tracking_page.dart';
import 'package:adati_mobile_app/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/pages/add_tool_post.dart';
import 'package:adati_mobile_app/pages/login_page.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
import '../components/my_textfield.dart';
import '../components/filter_button.dart';
import 'cart_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart'; // 👈 استيراد صفحة البروفايل الجديدة

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Product {
  final int id;
  final String title;
  final String price;
  final List<String> images;
  final int ownerId;
  final String owner;
  final String description;
  final double realValue;
  // أضف هذه الحقول الجديدة
  final String category;
  final String city;

  _Product({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
    required this.ownerId,
    required this.owner,
    required this.description,
    required this.realValue,
    required this.category, // أضف هنا
    required this.city, // أضف هنا
  });

  factory _Product.fromJson(Map<String, dynamic> json) {
    final String city;
    // 1. معالجة السعر
    String formattedPrice = "0";
    if (json['Tool_Price'] != null) {
      double? priceDouble = double.tryParse(json['Tool_Price'].toString());
      formattedPrice = priceDouble?.round().toString() ?? "0";
    }

    // 2. جلب الصور من حقل all_pictures القادم من السيرفر
    List<String> collectedImages = [];

    if (json['all_pictures'] != null && json['all_pictures'] is List) {
      // نأخذ القائمة الجاهزة من السيرفر مباشرة
      collectedImages = List<String>.from(
        json['all_pictures'].map((url) => url.toString()),
      );
    } else {
      // حل احتياطي في حال فشل all_pictures
      if (json['Tool_Picture'] != null) {
        collectedImages.add(json['Tool_Picture']);
      }
    }

    // 3. طباعة للتأكد (اختياري)
    print(
      "المنتج: ${json['Tool_Name']} - الصور النهائية: ${collectedImages.length}",
    );

    double rv = double.tryParse(json['real_value']?.toString() ?? '0.0') ?? 0.0;
    return _Product(
      id: json['Tool_ID'] ?? 0,
      title: json['Tool_Name'] ?? "No Name",
      price: formattedPrice,
      images: collectedImages,
      ownerId: json['User_ID'] ?? 0,
      owner: json['owner_name'] ?? "Unknown",
      description: json['Tool_Description'] ?? "",
      realValue:
          double.tryParse(json['real_value']?.toString() ?? '0.0') ?? 0.0,
      // تأكد أن هذه المفاتيح تطابق ما يرسله السيرفر (Django)
      category: json['Tool_Category'] ?? "Uncategorized",
      city: json['owner_city'] ?? "Unknown",
    );
  }
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  void _searchTools(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final titleLower = product.title.toLowerCase();
        final searchLower = query.toLowerCase();
        return titleLower.contains(searchLower);
      }).toList();
    });
  }

  void _checkAccess(VoidCallback onAuthorized) {
    if (currentUserId == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black, // خلفية سوداء
          title: Text(
            "Access Denied",
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
          content: Text(
            "You need to log in to access this feature.",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary, // زر أساسي
              ),
              child: const Text(
                "Login or Register",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    } else {
      onAuthorized();
    }
  }

  int bottomNavIndex = 0;
  String userName = "User";
  bool isLoading = true;
  List<_Product> products = [];
  List<_Product> filteredProducts = [];
  void _filterTools(String? selectedCategory, String? selectedCity) {
    setState(() {
      filteredProducts = products.where((tool) {
        // فلترة الفئة: إذا كانت 'All' أو null نمرر الكل، وإلا نقارن
        bool matchesCat =
            (selectedCategory == null || selectedCategory == 'All')
            ? true
            : tool.category == selectedCategory;

        // فلترة المدينة: نفس المنطق
        bool matchesCity = (selectedCity == null || selectedCity == 'All')
            ? true
            : tool.city == selectedCity;

        return matchesCat && matchesCity;
      }).toList();
    });
  }

  void _applyLocalFilter(String? category, String? city) {
    setState(() {
      filteredProducts = products.where((product) {
        // إذا اختار 'All' أو لم يختار شيئاً، اعتبر الشرط محققاً (true)
        final bool matchesCategory = (category == null || category == 'All')
            ? true
            : product.category == category;

        final bool matchesCity = (city == null || city == 'All')
            ? true
            : product.city == city;

        return matchesCategory && matchesCity;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchUserData();
    await fetchTools();
  }

  int? currentUserId;

  Future<void> fetchUserData() async {
    final token = await AuthService.getToken();
    if (token == null) {
      setState(() {
        userName = "Guest";
        currentUserId = null; // لا يوجد ID للمستخدم الزائر
        isLoading = false;
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['User_Name'] ?? "User";
          currentUserId = data['User_ID'] ?? 0; // جلب الـ ID الخاص بك
        });
      }
    } catch (e) {
      print("User Fetch Error: $e");
    }
  }

  List _tools = [];

  Future<void> _getTools({String? category, String? city}) async {
    setState(() => isLoading = true);

    final token = await AuthService.getToken();
    // بناء الرابط مع إضافة Query Parameters للفلترة
    var uri = Uri.parse('http://10.0.2.2:8000/api/tools/').replace(
      queryParameters: {
        if (category != null) 'category': category,
        if (city != null) 'city': city,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _tools = json.decode(response.body);
        isLoading = false;
      });
    }
  }

  Future<void> fetchTools({String? category, String? city}) async {
    setState(() => isLoading = true); // تفعيل مؤشر التحميل

    final token = await AuthService.getToken();

    // بناء الرابط مع بارامترات الفلترة
    final Map<String, String> queryParameters = {};
    if (category != null && category != 'All')
      queryParameters['category'] = category;
    if (city != null) queryParameters['city'] = city;

    final uri = Uri.http('10.0.2.2:8000', '/api/tools/', queryParameters);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // فك التشفير ودعم العربية
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            products = data.map((item) => _Product.fromJson(item)).toList();
            filteredProducts = products; // في البداية نعرض كل شيء
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching tools: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleLogout() async {
    await AuthService.removeToken();
    if (mounted)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning!';
    if (hour >= 12 && hour < 17) return 'Good Afternoon!';
    if (hour >= 17 && hour < 21) return 'Good Evening!';
    return 'Good Night!';
  }

  // دالة اختيار الصفحة بناءً على الـ Index
  Widget _getSelectedPage() {
    switch (bottomNavIndex) {
      case 0:
        return _buildMainContent();
      case 1:
        return const CartPage();
      case 2:
        return const FavoritePage();
      case 3:
        return const ProfilePage(); // 👈 تم ربط صفحة البروفايل هنا
      default:
        return _buildMainContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: _getSelectedPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _checkAccess(() async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddToolPost()),
            );
            fetchTools();
          });
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMainContent() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadInitialData,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 12),
              Expanded(
                child: products.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text("No tools added yet. Pull to refresh."),
                          ),
                        ],
                      )
                    : GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemBuilder: (context, index) =>
                            _buildProductCard(filteredProducts[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(_Product product) {
    return GestureDetector(
      onTap: () {
        _checkAccess(() {
          showProductDialog(
            context,
            Product(
              ownerId: product.ownerId,
              id: product.id,
              title: product.title,
              price: product.price,
              realValue: product.realValue,
              images: product.images,
              description: product.description,
            ),
            currentUserId,
          );
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first : '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "YER ${product.price}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Owner: ${product.owner}",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi $userName!',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              _getGreeting(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        Row(
          children: [
            IconButton(
              onPressed: () {
                _checkAccess(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OperationsPage(),
                    ),
                  );
                });
              },
              icon: Icon(Icons.notifications_active, size: 28),
            ),
            IconButton(
              onPressed: () {
                _checkAccess(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                });
              },
              icon: const Icon(Icons.settings_outlined, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
            label: 'Search tools...',
            controller: _searchController, // مرر المتحكم هنا
            onChanged: (value) =>
                _searchTools(value), // استدعاء دالة البحث عند كل حرف
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 55,
          width: 55,
          child: Center(
            child: FilterButton(
              onApply: (category, city) {
                _applyLocalFilter(category, city);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', bottomNavIndex == 0, 0),
            _buildNavItem(Icons.shopping_cart, 'Cart', bottomNavIndex == 1, 1),
            const SizedBox(width: 48),
            _buildNavItem(Icons.favorite, 'Favorite', bottomNavIndex == 2, 2),
            _buildNavItem(Icons.person, 'Profile', bottomNavIndex == 3, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, int idx) {
    return GestureDetector(
      onTap: () => {
        if (idx == 0)
          {setState(() => bottomNavIndex = idx)}
        else
          {
            _checkAccess(() {
              setState(() => bottomNavIndex = idx);
            }),
          },
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 25,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
