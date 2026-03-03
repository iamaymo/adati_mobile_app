import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  final Function(String? category, String? city) onApply;

  const FilterButton({super.key, required this.onApply});

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  final List<String> categories = [
    'All',
    'Electrical',
    'Mechanical',
    'Construction',
    'Plumbing',
    'Carpentry',
    'Gardening',
  ];

  final List<String> yemenCities = [
    'All',
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

  String? selectedCategory;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC72C),
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
        minimumSize: const Size(54, 54),
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

                  _buildDropdown(
                    hint: 'Tool Category',
                    value: selectedCategory,
                    items: categories,
                    onChanged: (v) =>
                        setDialogState(() => selectedCategory = v),
                  ),
                  const SizedBox(height: 12),
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
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC72C),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          widget.onApply(selectedCategory, selectedCity);
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
