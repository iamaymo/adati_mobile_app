import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';

// تعريف الـ Extension بشكل صحيح خارج الكلاس
extension PriceFormatter on double {
  String toPriceString() => this.toStringAsFixed(0);
}

class RequestDetailsPage extends StatelessWidget {
  final dynamic order;
  const RequestDetailsPage({super.key, required this.order});

  Future<void> _updateOrderStatus(
    BuildContext context,
    String newStatus,
  ) async {
    final String orderId = order['Order_ID'].toString();
    final String url = 'http://10.0.2.2:8000/api/orders/$orderId/';

    Map<String, dynamic> body = {'Order_Status': newStatus};

    if (newStatus == "Accepted") {
      DateTime now = DateTime.now();
      DateTime dueDate = now.add(const Duration(days: 1));
      body['Start_Date'] = now.toIso8601String();
      body['Due_Date'] = dueDate.toIso8601String();
    }

    try {
      final String? token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (context.mounted) Navigator.pop(context, true);
      } else {
        debugPrint("Update Failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double total =
        double.tryParse(order['Total_Price']?.toString() ?? '0') ?? 0;
    double ownerAmount =
        double.tryParse(order['Owner_Amount']?.toString() ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("تفاصيل الطلب"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الأداة
            if (order['tool_image'] != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  image: DecorationImage(
                    image: NetworkImage(order['tool_image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            _buildSectionTitle("بيانات الأداة"),
            _buildInfoRow("اسم الأداة", order['tool_name']),
            _buildInfoRow("المبلغ المدفوع", "YER ${total.toPriceString()}"),

            const Divider(height: 40),

            _buildSectionTitle("بيانات العميل"),
            _buildInfoRow("الاسم", order['customer_name']),
            _buildInfoRow("المحفظة", order['Wallet_Name']),
            _buildInfoRow("رقم الهاتف", order['Wallet_Phone_Number']),
            _buildAddressRow(
              "العنوان",
              "${order['customer_address'] ?? ''}, ${order['customer_street'] ?? ''}",
            ),

            const SizedBox(height: 30),

            // بطاقة الأرباح
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    "أرباحك من هذا الطلب",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "YER ${ownerAmount.toPriceString()}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(context, "Accepted"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("قبول الطلب"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateOrderStatus(context, "Rejected"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("رفض"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value ?? "غير متوفر",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              (value.trim() == "," || value.isEmpty) ? "غير متوفر" : value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
