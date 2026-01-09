import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  const FilterButton({super.key});

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  final List<String> categories = [
    'Electrical',
    'Mechanical',
    'Construction',
    'Plumbing',
    'Carpentry',
  ];

  final Map<String, List<String>> governorateDistricts = {
    "Sana'a": ["Bani al-Harith", "Al-Sabeen", "Ma'ain"],
    'Aden': ["Crater", "Al-Mualla", "Sheikh Othman"],
    'Taiz': ["Al-Qahirah", "Sabir Al- الموادم", "Mudhaffar"],
  };

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(const Color(0xFFFFC72C)),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) return Colors.white;
          return Colors.black;
        }),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        elevation: MaterialStateProperty.all(0),
      ),
      onPressed: () => _openFilterDialog(context),
      child: const Icon(Icons.filter_list),
    );
  }

  void _openFilterDialog(BuildContext context) {
    String? selectedCategory;
    String? selectedGovernorate;
    String? selectedDistrict;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(
          builder: (context, setState) {
            final districts = selectedGovernorate != null
                ? governorateDistricts[selectedGovernorate] ?? []
                : <String>[];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Tools',
                    style: const TextStyle(
                      color: Color(0xFFFFC72C),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tool Category
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    hint: const Text(
                      'Tool Category',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v),
                  ),
                  const SizedBox(height: 12),

                  // Governorate
                  DropdownButtonFormField<String>(
                    value: selectedGovernorate,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    hint: const Text(
                      'Governorate',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: governorateDistricts.keys
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      selectedGovernorate = v;
                      selectedDistrict = null;
                    }),
                  ),
                  const SizedBox(height: 12),

                  // District (disabled until governorate selected)
                  DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    hint: Text(
                      selectedGovernorate == null
                          ? 'Select Governorate first'
                          : 'District',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    items: districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: selectedGovernorate == null
                        ? null
                        : (v) => setState(() => selectedDistrict = v),
                    disabledHint: const Text(
                      'Select Governorate first',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),

                  const SizedBox(height: 16),
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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        onPressed: () {
                          // For now, just close the dialog — UI mock only
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
}
