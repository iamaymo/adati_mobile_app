import 'package:flutter/material.dart';

class Tool {
  final String id;
  final String name;
  final String priceLabel; // e.g. "YER 2500"
  final String? imageUrl;
  bool rented;

  Tool({
    required this.id,
    required this.name,
    required this.priceLabel,
    this.imageUrl,
    this.rented = false,
  });
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyToolsPage(),
  ));
}

class MyToolsPage extends StatefulWidget {
  const MyToolsPage({Key? key}) : super(key: key);

  @override
  State<MyToolsPage> createState() => _MyToolsPageState();
}

class _MyToolsPageState extends State<MyToolsPage> {
  final List<Tool> _tools = [
    Tool(id: '1', name: 'Drill', priceLabel: 'YER 2500', rented: true),
    Tool(id: '2', name: 'Saw', priceLabel: 'YER 2500', rented: false),
    Tool(id: '3', name: 'Stairs', priceLabel: 'YER 1500', rented: false),
    Tool(id: '4', name: 'Lawn Mower', priceLabel: 'YER 3000', rented: true),
    Tool(id: '5', name: 'Tools bag', priceLabel: 'YER 2000', rented: true),
  ];

  void _showOptionsSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Tool'),
                onTap: () {
                  Navigator.of(context).pop();
                  _onEdit(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Tool',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onEdit(int index) {
    final tool = _tools[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit "${tool.name}" (not implemented)')),
    );
  }

  void _confirmDelete(int index) async {
    final tool = _tools[index];
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Tool'),
            content: Text('Are you sure you want to delete "${tool.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      setState(() {
        _tools.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${tool.name}"')),
      );
    }
  }

  Widget _buildStatusBadge(bool rented) {
    final color = rented ? Colors.red.shade600 : Colors.green.shade700;
    final text = rented ? 'Rented' : 'Available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildToolCard(int index) {
    final tool = _tools[index];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Image / placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: Colors.white,
              child: tool.imageUrl != null
                  ? Image.network(tool.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.build, size: 36, color: Colors.grey))
                  : const Icon(Icons.build, size: 36, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Name, price and badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  tool.priceLabel,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge and menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(tool.rented),
              const SizedBox(height: 6),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                onPressed: () => _showOptionsSheet(context, index),
                tooltip: 'More',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 4),
                      const Text('My Tools', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _tools.isEmpty
                    ? const Center(child: Text('No tools found', style: TextStyle(fontSize: 16)))
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: _tools.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildToolCard(i),
                      ),
              ),
            ],
          ),
        ),
      ),
      // Floating action can be added later for adding tools
    );
  }
}