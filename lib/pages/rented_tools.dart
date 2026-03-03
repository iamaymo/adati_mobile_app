import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'order_tracking_page.dart';

class RentedToolsPage extends StatefulWidget {
  const RentedToolsPage({Key? key}) : super(key: key);

  @override
  State<RentedToolsPage> createState() => _RentedToolsPageState();
}

class _RentedToolsPageState extends State<RentedToolsPage> {
  final Color primaryColor = const Color(0xFFFFC72C);

  Future<List<dynamic>> _getMyOrders() async {
    final String? token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/orders/?role=my_orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load your orders");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Rented Tools',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<dynamic>>(
          future: _getMyOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No rental history found"));
            }

            final allOrders = snapshot.data!;
            final activeOrders = allOrders
                .where(
                  (o) =>
                      o['Order_Status'] != 'Completed' &&
                      o['Order_Status'] != 'Cancelled' &&
                      o['Order_Status'] != 'Rejected',
                )
                .toList();
            final inactiveOrders = allOrders
                .where(
                  (o) =>
                      o['Order_Status'] == 'Completed' ||
                      o['Order_Status'] == 'Cancelled' ||
                      o['Order_Status'] == 'Rejected',
                )
                .toList();
            final completedOrders = allOrders
                .where((o) => o['Order_Status'] == 'Completed')
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...activeOrders.map((order) => _buildOrderCard(order)).toList(),

                if (inactiveOrders.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildSectionDivider("History"),
                  const SizedBox(height: 12),
                ],

                ...inactiveOrders
                    .map((order) => _buildOrderCard(order))
                    .toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, endIndent: 10)),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const Expanded(child: Divider(thickness: 1, indent: 10)),
      ],
    );
  }

  Widget _buildOrderCard(dynamic order) {
    String status = order['Order_Status'];

    bool isInactive =
        status == 'Completed' || status == 'Cancelled' || status == 'Rejected';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isInactive ? 0.5 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Opacity(
          opacity: isInactive ? 0.6 : 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: order['tool_image'] != null
                ? Image.network(
                    order['tool_image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.build, color: Colors.grey),
                  ),
          ),
        ),
        title: Text(
          order['tool_name'] ?? 'Unknown Tool',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isInactive ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Owner: ${order['owner_name'] ?? 'Owner'}"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: (status == 'Cancelled' || status == 'Rejected')
            ? null
            : const Icon(Icons.chevron_right),
        onTap: () async {
          if (status == 'Cancelled' || status == 'Rejected') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("This request was $status"),
                backgroundColor: Colors.black87,
                duration: const Duration(seconds: 1),
              ),
            );
            return;
          }

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderTrackingPage(order: order, isOwner: false),
            ),
          );

          if (result == true) {
            setState(() {});
          }
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
      case 'Completed':
      case 'Ongoing':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
