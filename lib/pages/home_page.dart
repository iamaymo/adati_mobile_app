import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/prodct.dart';
import '../components/my_textfield.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Product {
  final String title;
  final String price;
  final String image;
  bool isFavorite;
  _Product({
    required this.title,
    required this.price,
    required this.image,
    this.isFavorite = false,
  });
}

class _HomePageState extends State<HomePage> {
  int bottomNavIndex = 0;
  String selectedCategory = 'All';

  // المتغير الذي سيخزن الاسم القادم من قاعدة البيانات
  String userName = "User";
  bool isLoading = true;

  final categories = ['All', 'Hand', 'Power', 'Garden', 'Ele'];
  final products = List.generate(
    6,
    (i) => _Product(
      title: [
        'Cordless Drill',
        'Hammer',
        'Circular Saw',
        'Wrench Set',
        'Sander',
        'Pliers',
      ][i % 6],
      price: [
        '\$79.99',
        '\$12.50',
        '\$129.00',
        '\$34.75',
        '\$49.00',
        '\$15.00',
      ][i % 6],
      image: 'images/adati_logo.png',
    ),
  );

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // دالة جلب الاسم من Django API المعدلة
  Future<void> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // تأكد أنك في صفحة تسجيل الدخول حفظت التوكن باسم 'access_token'
      final token = prefs.getString('access_token');

      print("DEBUG: Fetching data with Token: $token");

      if (token == null) {
        print("DEBUG: No token found in SharedPreferences");
        setState(() => isLoading = false);
        return;
      }

      // تم تعديل الرابط ليتوافق مع ملف urls.py (path('me/', ...))
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // تأكد من وجود مسافة بعد Bearer
        },
      );

      print("DEBUG: Response Status: ${response.statusCode}");
      print("DEBUG: Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // 'User_Name' هو الحقل المعرف في UserSerializer
          userName = data['User_Name'] ?? "أيمن";
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        print("DEBUG: Unauthorized - Token might be expired or invalid");
        setState(() => isLoading = false);
      } else {
        print("DEBUG: Server Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("DEBUG: Connection Exception: $e");
      setState(() => isLoading = false);
    }
  }

  void toggleFavorite(int idx) {
    setState(() => products[idx].isFavorite = !products[idx].isFavorite);
  }

  void changeBottomNav(int idx) => setState(() => bottomNavIndex = idx);
  void changeCategory(String c) => setState(() => selectedCategory = c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // use tertiary (white) from theme instead of hardcoded white
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: bottomNavIndex == 1 ? const CartPage() : _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        // use secondary (black) from theme
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return Center(
        // use primary (yellow) from theme
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildCategories(),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemBuilder: (context, index) =>
                    _buildProductCard(products[index], index),
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
              'Hi $userName!', // سيعرض "أيمن" هنا بعد نجاح الطلب
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Text(
              'Good Morning!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('images/adati_logo.png'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(child: MyTextField(label: 'Search')),
        const SizedBox(width: 12),
        Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(14), // more rounded
          ),
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 52, // increased height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () => changeCategory(cat),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(14), // more rounded
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // slightly larger text
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(_Product product, int index) {
    return GestureDetector(
      onTap: () => showProductDialog(
        context,
        Product(
          title: product.title,
          price: product.price,
          image: product.image,
          description: 'High quality ${product.title}.',
          rating: 4.5,
          reviews: 12,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Center(
                child: Image.asset(
                  product.image,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tool name: bigger and bold
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // increased size
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Price: semibold and slightly smaller than title
                  Text(
                    product.price,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600, // semi-bold
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
      onTap: () => changeBottomNav(idx),
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
