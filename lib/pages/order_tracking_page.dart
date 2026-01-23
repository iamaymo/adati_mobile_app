import 'dart:convert';

import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderTrackingPage extends StatefulWidget {
  final dynamic order;
  final bool isOwner;

  const OrderTrackingPage({
    super.key,
    required this.order,
    required this.isOwner,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Color primaryColor = const Color(0xFFFFC72C);
  late dynamic currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  // دالة لتحديث الحالة في السيرفر (تحتاج ربطها بـ API الخاص بك)
  // داخل order_tracking_page.dart
  Future<void> _updateStatus(
    String newStatus,
    Map<String, dynamic> extraData,
  ) async {
    final String orderId = currentOrder['Order_ID'].toString();
    final String url = 'http://10.0.2.2:8000/api/orders/$orderId/';

    // دمج الحالة مع الحقول الإضافية (مثل is_handed_to_delivery: true)
    Map<String, dynamic> body = {'Order_Status': newStatus, ...extraData};

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
        setState(() {
          currentOrder['Order_Status'] = newStatus;
          extraData.forEach((key, value) => currentOrder[key] = value);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("تم تحديث الحالة بنجاح!")));
      }
    } catch (e) {
      print("Update failed: $e");
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Not Started';
    try {
      DateTime dt = DateTime.parse(dateTimeStr);
      return DateFormat('MMM d, hh:mm a').format(dt);
    } catch (e) {
      return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isOwner ? 'Manage Rental' : 'Track My Rental',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildProgressCard(),
              const SizedBox(height: 16),
              _buildFinancialCard(),
              const SizedBox(height: 24),
              // الزر الديناميكي حسب الحالة
              _buildBottomActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: currentOrder['tool_image'] != null
                    ? Image.network(
                        currentOrder['tool_image'],
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 65,
                        height: 65,
                        color: Colors.grey[200],
                        child: const Icon(Icons.build),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentOrder['tool_name'] ?? 'Tool Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Customer: ${currentOrder['customer_name'] ?? 'User'}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(
            'Start Date',
            formatDateTime(currentOrder['Start_Date']),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Expected Return',
            formatDateTime(currentOrder['Due_Date']),
          ),
          const SizedBox(height: 10),
          _buildOrderNumberRow(currentOrder['Order_ID'].toString()),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    List<Map<String, dynamic>> steps = [
      {
        "title": "Request Accepted",
        "val":
            currentOrder['Order_Status'] != 'Pending' &&
            currentOrder['Order_Status'] != 'Rejected' &&
            currentOrder['Order_Status'] != 'Cancelled',
      },
      {
        "title": "Handed to Delivery",
        "val": currentOrder['is_handed_to_delivery'] ?? false,
      },
      {
        "title": "Received by Customer",
        "val": currentOrder['is_received_by_customer'] ?? false,
      },
      {
        "title": "Return Requested",
        "val": currentOrder['is_return_requested'] ?? false,
      },
      {
        "title": "Return in Transit",
        "val": currentOrder['is_return_handed_to_delivery'] ?? false,
      },
      {"title": "Finished", "val": currentOrder['Order_Status'] == 'Completed'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: steps
            .map(
              (step) => Row(
                children: [
                  Checkbox(
                    value: step['val'],
                    onChanged: null, // تعطيل الضغط اليدوي
                    shape: const CircleBorder(),
                    activeColor: primaryColor,

                    fillColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (step['val'] == true) {
                        return primaryColor; // اللون الأصفر (0xFFFFC72C) عند التفعيل
                      }
                      // اللون عند عدم التفعيل: برتقالي خفيف أو شفاف بدل الرمادي
                      return const Color.fromARGB(28, 158, 158, 158);
                    }),
                  ),
                  Text(
                    step['title'],
                    style: TextStyle(
                      color: step['val'] ? Colors.black : Colors.grey,
                      fontWeight: step['val']
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomActionButton() {
    String status = currentOrder['Order_Status'];

    if (widget.isOwner) {
      // أزرار سياف (المالك)
      if (status == 'Accepted') {
        return _actionBtn(
          "Handed to Delivery",
          () => _updateStatus('On_The_Way', {'is_handed_to_delivery': true}),
        );
      }
      if (status == 'Returning') {
        return _actionBtn(
          "Confirm Receipt of The Tool and Complete",
          () => _updateStatus('Completed', {}),
        );
      }
    } else {
      // أزرار أيمن (المستأجر)
      if (status == 'Pending') {
        return _actionBtn(
          "Cancel Order",
          () => _updateStatus('Cancelled', {}),
          color: Colors.red,
        );
      }
      if (status == 'On_The_Way') {
        return _actionBtn(
          "Confirmation of Receipt of The Tool",
          () => _updateStatus('Ongoing', {'is_received_by_customer': true}),
        );
      }
      if (status == 'Ongoing') {
        return _actionBtn(
          "Request to Return The Tool",
          () => _updateStatus('Returning', {'is_return_requested': true}),
        );
      }
      if (status == 'Returning' &&
          (currentOrder['is_return_handed_to_delivery'] == false)) {
        return _actionBtn(
          "Handed to Delivery (Back to Owner)",
          () => _updateStatus('Returning', {
            'is_return_handed_to_delivery': true,
          }),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _actionBtn(
    String title,
    VoidCallback onPress, {
    Color color = Colors.black,
  }) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: _buildInfoRow(
              "Total Paid by Customer",
              "${currentOrder['Total_Price']} YR",
              isBold: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildInfoRow(
              "Your Net Profit",
              "${currentOrder['Owner_Amount']} YR",
              isBold: true,
              textColor: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 15 : 14,
            color: textColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderNumberRow(String id) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Order ID",
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        Row(
          children: [
            Text(
              "#$id",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(text: id)),
              child: const Icon(Icons.copy, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
