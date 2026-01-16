import 'package:adati_mobile_app/pages/user_getaway.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 3;
  static const Color yellow = Color(0xFFFBC02D);
  static const Color darkGray = Color(0xFF6B6B6B);

  void logout() async {
    await AuthService.removeToken(); // حذف التوكن
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserGatewayPage()),
        (route) => false, // يحذف كل الصفحات السابقة من الذاكرة
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // قسم الصورة الشخصية مع تأثير الوهج (من Setting1 و Setting2)
              // Center(
              //   child: Column(
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(6),
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           boxShadow: [
              //             BoxShadow(
              //               color: yellow.withOpacity(0.4),
              //               blurRadius: 30,
              //               spreadRadius: 2,
              //             )
              //           ],
              //         ),
              //         child: const CircleAvatar(
              //           radius: 50,
              //           backgroundColor: Colors.white,
              //           child: CircleAvatar(
              //             radius: 46,
              //             backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(height: 15),
              //       const Text(
              //         'Sayaf Al-Ameri',
              //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              //       ),
              //       Text(
              //         'Active since - June 2025',
              //         style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              //       ),
              //     ],
              //   ),
              // ),

              // const SizedBox(height: 30),

              // // قسم المعلومات الشخصية (بأسلوب البطاقات التفاعلية من Setting2)
              // const Text(
              //   'Personal Information',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGray),
              // ),
              // const SizedBox(height: 12),
              // _InfoTile(
              //   icon: Icons.email_outlined,
              //   label: 'Email',
              //   value: 'aymanqadasi89@gmail.com',
              //   onEdit: () {},
              // ),
              // _InfoTile(
              //   icon: Icons.phone_android,
              //   label: 'Phone',
              //   value: '+967 770-000-777',
              //   onEdit: () {},
              // ),
              // _InfoTile(
              //   icon: Icons.location_on_outlined,
              //   label: 'Location',
              //   value: 'Yemen, Sana\'a',
              //   onEdit: () {},
              // ),

              // const SizedBox(height: 25),

              // // قسم الإحصائيات (بألوان DarkGray لتباين احترافي)
              // const Text(
              //   'Activity Overview',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGray),
              // ),
              // const SizedBox(height: 12),
              // Row(
              //   children: [
              //     Expanded(child: _StatBox(title: 'Posts', value: '20', color: yellow)),
              //     const SizedBox(width: 12),
              //     Expanded(child: _StatBox(title: 'Stars', value: '55', color: darkGray)),
              //   ],
              // ),

              // const SizedBox(height: 25),

              // زر الإعدادات والمزيد
              Text(
                'System',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 12),
              _ActionMenu(
                icon: Icons.settings_suggest_outlined,
                title: 'General Settings',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _ActionMenu(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              const SizedBox(height: 10),

              _ActionMenu(
                icon: Icons.logout,
                title: 'Log out',
                onTap: logout,
                color: Colors.red,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ويدجت عرض المعلومات الشخصية (دمج التصميمين)
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFBC02D), size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ويدجت الإحصائيات (StatCard المطور)
class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ويدجت القوائم التفاعلية
class _ActionMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _ActionMenu({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = const Color(0xFFFBC02D),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
