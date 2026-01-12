import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  const FilterButton({super.key});

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  // قائمة الفئات
  final List<String> categories = [
    'Electrical',
    'Mechanical',
    'Construction',
    'Plumbing',
    'Carpentry',
  ];

  // قائمة المدن اليمنية كاملة
  final List<String> yemenCities = [
    "Sana'a",
    "Aden",
    "Taiz",
    "Al Hudaydah",
    "Ibb",
    "Dhamar",
    "Al Mukalla",
    "Marib",
    "Amran",
    "Hajjah",
    "Saada",
    "Al Mahwit",
    "Raymah",
    "Shabwah",
    "Abyan",
    "Lahij",
    "Socotra",
    "Al Bayda",
    "Al Dhale'",
    "Al Mahrah",
  ];

  // متغيرات لحفظ القيم المختارة (للمحافظة عليها حتى بعد إغلاق الديالوج)
  String? selectedCategory;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC72C), // اللون الأصفر
        foregroundColor: Colors.black, // لون الأيقونة
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
        minimumSize: const Size(54, 54), // لضبط الطول مع حقل البحث
      ),
      onPressed: () => _openFilterDialog(context),
      child: const Icon(Icons.filter_list, size: 28),
    );
  }

  void _openFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Tools',
                    style: TextStyle(
                      color: Color(0xFFFFC72C),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. اختيار الفئة
                  _buildDropdown(
                    hint: 'Tool Category',
                    value: selectedCategory,
                    items: categories,
                    onChanged: (v) =>
                        setDialogState(() => selectedCategory = v),
                  ),
                  const SizedBox(height: 12),

                  // 2. اختيار المدينة (City)
                  _buildDropdown(
                    hint: 'City',
                    value: selectedCity,
                    items: yemenCities,
                    onChanged: (v) => setDialogState(() => selectedCity = v),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // زر الإلغاء
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // زر التطبيق
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC72C),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // هنا تطبق الفلترة بناءً على selectedCategory و selectedCity
                          print("Category: $selectedCategory, City: $selectedCity");
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // الـ Widget الموحد للقوائم المنسدلة مع إجبار اللون الأبيض
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      dropdownColor: const Color(0xFF2A2A2A),
      iconEnabledColor: Colors.white,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      // الـ Hint باللون الأبيض الصريح
      hint: Text(
        hint,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white38,
          fontSize: 15,
        ),
      ),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFFC72C), width: 1),
        ),
      ),
    );
  }
}