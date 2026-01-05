import 'package:adati_mobile_app/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'my_tools.dart';
import 'rented_tools.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String email = "Loading...";
  String phone = "Not set";
  String address = "Not set";
  bool isLoading = true;

  static const Color _bgYellow = Color(0xFFFBC02D);

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/me/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          userName = data['User_Name'] ?? "No Name";
          email = data['User_Email'] ?? "No Email";
          phone = data['Phone_Number'] ?? "No Phone";
          address = data['User_Address'] ?? "No Address";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: _bgYellow))
            : RefreshIndicator(
                onRefresh: fetchUserData,
                color: _bgYellow,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 15),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings_outlined, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Avatar Section
                      Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _bgYellow.withOpacity(0.45),
                                  blurRadius: 24,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundImage: AssetImage(
                                  'images/avatar.png',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Stats Section
                      Row(
                        children: [
                          // زر Posts
                          _StatBox(
                            title: 'Posts',
                            value: '20',
                            color: Colors.grey.shade800,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyToolsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 15),
                          // زر Stars (تم ربطه الآن بصفحة RentedToolsPage)
                          _StatBox(
                            title: 'Stars',
                            value: '55',
                            color: _bgYellow,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RentedToolsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _ProfileInfoTile(
                        icon: Icons.email_outlined,
                        title: email,
                      ),
                      const SizedBox(height: 12),
                      _ProfileInfoTile(icon: Icons.phone_android, title: phone),
                      const SizedBox(height: 12),
                      _ProfileInfoTile(
                        icon: Icons.location_on_outlined,
                        title: address,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// المكون الفرعي StatBox
class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatBox({
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// مكون عرض المعلومات الشخصية
class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const _ProfileInfoTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBC02D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBC02D).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFBC02D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
