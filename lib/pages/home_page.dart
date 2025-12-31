import 'package:adati_mobile_app/components/product_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/pages/add_tool_post.dart';
import 'package:adati_mobile_app/pages/login_page.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
// import 'package:adati_mobile_app/pages/product_dialog.dart'; // 👈 تأكد من المسار
import '../components/my_textfield.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Product {
  final int id;
  final String title;
  final String price;
  final String image;
  final String owner;
  final String description; // 👈 مضاف

  _Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.owner,
    required this.description, // 👈 مضاف
  });

  factory _Product.fromJson(Map<String, dynamic> json) {
    return _Product(
      id: json['Tool_ID'],
      title: json['Tool_Name'],
      price: double.parse(json['Tool_Price'].toString()).toInt().toString(),
      image: json['Tool_Picture'].startsWith('http')
          ? json['Tool_Picture']
          : 'http://10.0.2.2:8000${json['Tool_Picture']}',
      owner: json['owner_name'] ?? "Unknown",
      description:
          json['Tool_Description'] ?? "لا يوجد وصف لهذه الأداة حالياً.",
    );
  }
}

class _HomePageState extends State<HomePage> {
  int bottomNavIndex = 0;
  String userName = "User";
  bool isLoading = true;
  List<_Product> products = [];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchUserData();
    await fetchTools();
  }

  Future<void> fetchUserData() async {
    final token = await AuthService.getToken();
    if (token == null) {
      _handleLogout();
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() => userName = data['User_Name'] ?? "User");
      }
    } catch (e) {
      print("User Fetch Error: $e");
    }
  }

  Future<void> fetchTools() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/tools/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted)
          setState(() {
            products = data.map((item) => _Product.fromJson(item)).toList();
            isLoading = false;
          });
      }
    } catch (e) {
      setState(() => isLoading = false);
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
    final hour = DateTime.now().hour; // جلب الساعة الحالية (0-23)

    if (hour >= 5 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening!';
    } else {
      return 'Good Night!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: bottomNavIndex == 1 ? const CartPage() : _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddToolPost()),
          );
          fetchTools();
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
        onRefresh: loadInitialData, // 👈 هذه الدالة ستُنفذ عند السحب لأسفل
        color: Theme.of(context).colorScheme.primary, // لون المؤشر
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(
                // 💡 ملاحظة: الـ GridView يجب أن يكون دائماً قابل للسحب (physics) ليتمكن الـ RefreshIndicator من العمل
                child: products.isEmpty
                    ? ListView(
                        // نستخدم ListView هنا لكي يعمل السحب حتى لو كانت القائمة فارغة
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text("No tools added yet. Pull to refresh."),
                          ),
                        ],
                      )
                    : GridView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(), // 👈 ضروري جداً لعمل السحب
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemBuilder: (context, index) =>
                            _buildProductCard(products[index]),
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
        // 🔥 تحويل البيانات للـ Dialog
        showProductDialog(
          context,
          Product(
            title: product.title,
            price: "YER ${product.price}",
            image: product.image,
            description: product.description,
          ),
        );
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
                  product.image,
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(child: MyTextField(label: 'Search tools...')),
        const SizedBox(width: 12),
        Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.search, color: Colors.white),
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
      onTap: () => setState(() => bottomNavIndex = idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
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
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
