import 'package:adati_mobile_app/components/product_dialog.dart';
import 'package:flutter/material.dart';
import '../components/cart.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Rental Summary"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...tools.map((product) => _buildToolCard(product)).toList(),

                    const SizedBox(height: 10),

                    // تفاصيل الدفع والمحفظة
                    _buildInfoCard("Payment Details", [
                      _buildRow("Wallet", walletName),
                      _buildRow("Wallet Phone Number", phoneNumber),
                      _buildRow("Rental Duration", "1 Day"),
                    ]),

                    // تفاصيل السعر
                    _buildInfoCard("Price Breakdown", [
                      _buildRow(
                        "Total Amount",
                        "YER ${amount.toStringAsFixed(0)}",
                        isBold: true,
                      ),
                    ]),

                    // تحذير السياسة
                    _buildPolicyWarning(),
                  ],
                ),
              ),
            ),

            // Proceed to payment button
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
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
                    'Proceed to Payment',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // الدوال المساعدة تم نقلها لداخل الكلاس ليتم التعرف عليها
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
}
