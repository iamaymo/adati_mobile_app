import 'dart:convert';
import 'package:adati_mobile_app/pages/order_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'request_details_page.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  Future<List<dynamic>> _getReceivedOrders() async {
    final String? token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/orders/?role=incoming'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load received orders");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Incoming Requests',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<dynamic>>(
          future: _getReceivedOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC72C)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No rental requests yet"));
            }

            // --- منطق الفرز هنا ---
            final allOrders = snapshot.data!;
            final activeOrders = allOrders
                .where((o) => o['Order_Status'] != 'Completed')
                .toList();
            final completedOrders = allOrders
                .where((o) => o['Order_Status'] == 'Completed')
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // أولاً: الطلبات النشطة
                ...activeOrders.map((order) => _buildOrderCard(order)).toList(),

                // ثانياً: الفاصل (يظهر فقط إذا كان هناك طلبات مكتملة)
                if (completedOrders.isNotEmpty) ...[
                  _buildSectionDivider("Completed"),
                  const SizedBox(height: 12),
                ],

                // ثالثاً: الطلبات المكتملة
                ...completedOrders
                    .map((order) => _buildOrderCard(order))
                    .toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ويدجت الفاصل مع النص في المنتصف
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
    bool isCompleted = order['Order_Status'] == 'Completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCompleted ? 0.5 : 2, // تقليل الظل للطلبات المنتهية
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        // جعل الطلبات المكتملة باهتة قليلاً للتمييز
        contentPadding: const EdgeInsets.all(12),
        leading: Opacity(
          opacity: isCompleted ? 0.6 : 1.0,
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
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("From: ${order['customer_name']}"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order['Order_Status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                order['Order_Status'],
                style: TextStyle(
                  color: _getStatusColor(order['Order_Status']),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          List<String> trackingStatuses = [
            'Accepted',
            'On The Way',
            'Ongoing',
            'Returning',
            'Completed',
          ];

          Widget targetPage;
          if (trackingStatuses.contains(order['Order_Status'])) {
            targetPage = OrderTrackingPage(order: order, isOwner: true);
          } else {
            targetPage = RequestDetailsPage(order: order);
          }

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
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
