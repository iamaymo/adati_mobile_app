import 'dart:convert';
import 'dart:math';

import 'package:adati_mobile_app/components/product_dialog.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class RentalSummaryPage extends StatelessWidget {
  final double amount;
  final String walletName;
  final String phoneNumber;
  final List<Product> tools;

  const RentalSummaryPage({
    Key? key,
    required this.amount,
    required this.walletName,
    required this.phoneNumber,
    required this.tools,
  }) : super(key: key);

  static const Color _primary = Color(0xFFFFC72C);
  Future<void> _submitOrder(BuildContext context) async {
    final String? token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The session has ended, please log in again."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String transactionRef = (Random().nextInt(9000) + 1000).toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool allSuccess = true;

    for (var product in tools) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/orders/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'Tool_ID': product.id,
            'Total_Price': product.price,
            'Wallet_Name': walletName,
            'Wallet_Phone_Number': phoneNumber,
            'Transaction_Ref': transactionRef,
          }),
        );

        if (response.statusCode != 201) {
          allSuccess = false;
          debugPrint("Django Error: ${response.body}");
          break;
        }
      } catch (e) {
        allSuccess = false;
        debugPrint("Connection Error: $e");
        break;
      }
    }

    if (Navigator.canPop(context)) Navigator.pop(context);

    if (allSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("order submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while processing the request."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalRentalFee = amount;
    double insuranceAmount =
        tools.fold(0.0, (sum, p) => sum + p.realValue) * 0.25;
    double grandTotal = totalRentalFee + insuranceAmount;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Rental Summary"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...tools.map((product) => _buildToolCard(product)).toList(),
                    const SizedBox(height: 10),
                    _buildInfoCard("Insurance Details", [
                      _buildRow(
                        "Total Tools Value",
                        "YER ${tools.fold(0.0, (sum, p) => sum + p.realValue).toStringAsFixed(0)}",
                      ),
                      _buildRow("Insurance Rate", "25%"),
                      _buildRow(
                        "Insurance Amount",
                        "YER ${(tools.fold(0.0, (sum, p) => sum + p.realValue) * 0.25).toStringAsFixed(0)}",
                        isBold: true,
                      ),
                    ]),
                    _buildInsuranceNote(),
                    _buildInfoCard("Payment Details", [
                      _buildRow("Wallet", walletName),
                      _buildRow("Wallet Phone Number", phoneNumber),
                      _buildRow("Rental Duration", "1 Day"),
                      const Divider(height: 20),

                      _buildRow(
                        "Rental Amount",
                        "YER ${totalRentalFee.toStringAsFixed(0)}",
                      ),
                      _buildRow(
                        "Security Deposit",
                        "YER ${insuranceAmount.toStringAsFixed(0)}",
                      ),

                      const Divider(
                        thickness: 1,
                        height: 25,
                      ),

                      _buildRow(
                        "Total to Pay Now",
                        "YER ${grandTotal.toStringAsFixed(0)}",
                        isBold: true,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: _buildRow(
                          "Returned to you later",
                          "YER ${insuranceAmount.toStringAsFixed(0)}",
                          isBold: true,
                        ),
                      ),
                    ]),

                    _buildPolicyWarning(),

                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _submitOrder(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.black,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Rental Confirmation',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(Product p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: p.images.isNotEmpty
                ? Image.network(
                    p.images[0],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "YER ${p.price} / Day",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: const Text(
        'Late return policy: Extra charges apply. Please return tools on time.',
        style: TextStyle(color: Colors.red, fontSize: 15),
      ),
    );
  }

  Widget _buildInsuranceNote() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.amber.shade800, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The insurance deposit will be fully refunded to your account once the tools are returned in good condition and on time.',
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
