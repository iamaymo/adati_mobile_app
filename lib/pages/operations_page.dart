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
  // دالة جلب الطلبات من السيرفر
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
        onRefresh: () async => setState(() {}), // سحب الشاشة لتحديث البيانات
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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return _buildOrderCard(order);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
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
        title: Text(
          order['tool_name'] ?? 'Unknown Tool',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          // الحالات التي تفتح صفحة التتبع
          List<String> trackingStatuses = [
            'Accepted',
            'On_The_Way',
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

          // الانتقال وانتظار النتيجة (Result)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );

          // إذا كانت النتيجة true، نقوم بتحديث القائمة الرئيسية
          if (result == true) {
            setState(() {}); 
          }
        },
      ),
    );
  }

  // دالة لتحديد لون الحالة
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