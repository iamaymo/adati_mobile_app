import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';

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
    double toolValue =
        double.tryParse(order['real_value']?.toString() ?? '0') ?? 0;
    if (toolValue == 0 && order['insurance_details'] != null) {
      toolValue =
          double.tryParse(
            order['insurance_details']['amount']?.toString() ?? '0',
          ) ??
          0;
    }
    double insuranceAmount = toolValue * 0.25;
    print("Order Data from Database: ${jsonEncode(order)}");
    double total =
        double.tryParse(order['Total_Price']?.toString() ?? '0') ?? 0;
    double ownerAmount =
        double.tryParse(order['Owner_Amount']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Request Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tool Image
            if (order['tool_image'] != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(order['tool_image']),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            // Tool Information Section
            _buildSectionHeader("Tool Information"),
            _buildInfoBox([
              _buildInfoRow("Tool Name", order['tool_name']),
              _buildInfoRow("Total Paid", "YER ${total.toPriceString()}"),
            ]),

            const SizedBox(height: 20),

            // Customer Information Section
            _buildSectionHeader("Customer Details"),
            _buildInfoBox([
              _buildInfoRow("Name", order['customer_name']),
              _buildRatingRow("Customer Rating", order['customer_rating']),
              _buildInfoRow("Wallet", order['Wallet_Name']),
              _buildInfoRow("Phone", order['Wallet_Phone_Number']),
              _buildAddressRow(
                "Address",
                "${order['customer_address'] ?? ''}, ${order['customer_street'] ?? ''}",
              ),
            ]),

            const SizedBox(height: 20),
            // 1. حساب مبلغ الضمان برمجياً للعرض

            // 2. إضافة العنوان (Section Header)
            _buildSectionHeader("Security & Insurance"),

            // 3. إضافة صندوق معلومات الضمان
            _buildInfoBox([
              _buildInfoRow(
                "Insurance Amount",
                "YER ${insuranceAmount.toPriceString()}",
              ),
              _buildInfoRow(
                "Status",
                "Held by System",
              ), // بما أن الطلب لسه ما انقبل، الحالة محجوزة
            ]),

            const SizedBox(height: 12),

            // 4. ملاحظة طمأنة للمؤجر (اختياري)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.gpp_good_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "This deposit is held to protect your tool against damages or late returns.",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Earnings Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Your Earnings from this request",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
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

            const SizedBox(height: 20),

            // Action Buttons
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(context, "Accepted"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC72C),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Accept Request",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateOrderStatus(context, "Rejected"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  // المربع الرمادي الشفاف الذي يجمع المعلومات
  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.06), // خلفية رمادية خفيفة جداً
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRatingRow(String label, dynamic ratingValue) {
    // تحويل القيمة إلى double سواء كانت String أو int من قاعدة البيانات
    double rating = double.tryParse(ratingValue?.toString() ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          Row(
            children: [
              // عرض النجوم
              ...List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                );
              }),
              const SizedBox(width: 5),
              Text(
                "($rating)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          Text(
            value ?? "N/A",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              (value.trim() == "," || value.isEmpty) ? "N/A" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
