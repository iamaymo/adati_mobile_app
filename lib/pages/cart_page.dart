import 'dart:convert';

import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/cart.dart';
import '../components/product_dialog.dart';
import '../components/payment_sheet.dart';
import '../components/my_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<void> _processCheckout(List<Product> items) async {
    final String? token = await AuthService.getToken();
    final String url = 'http://10.0.2.2:8000/api/orders/';

    int successCount = 0;

    for (var product in items) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'Tool_ID': product.id}),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          successCount++;
        }
      } catch (e) {
        debugPrint("Error renting tool ${product.title}: $e");
      }
    }

    if (successCount > 0) {
      Cart.instance.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully rented $successCount tools!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ValueListenableBuilder<List<Product>>(
          valueListenable: Cart.instance.items,
          builder: (context, items, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cart',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => Cart.instance.clear()),
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Expanded(child: Center(child: Text('Cart is empty'))),
                if (items.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final p = items[idx];
                        final imageUrl = (p.images.isNotEmpty
                            ? p.images[0]
                            : '');
                        return GestureDetector(
                          onTap: () {
                            showProductDialog(context, p, null);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        height: 56,
                                        width: 56,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 30,
                                                ),
                                      )
                                    : const SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${p.price}, per Day",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Cart.instance.removeAt(idx),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'YER ${Cart.instance.totalPrice().toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: MyButton(
                      width: 0.9,
                      height: 0.06,
                      label: 'Rent Now',
                      onPressed: items.isEmpty
                          ? null
                          : () {
                              showPaymentMethodSheet(
                                context,
                                amount: Cart.instance.totalPrice(),
                                selectedTools: items,
                                onPaid: () async {
                                  await _processCheckout(items);
                                },
                              );
                            },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
