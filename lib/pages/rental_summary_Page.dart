import 'package:flutter/material.dart';
import 'home_page.dart';

class RentalSummaryPage extends StatelessWidget {
  const RentalSummaryPage({Key? key}) : super(key: key);

  static const Color _primary = Color(0xFFFFC72C);

  @override
  Widget build(BuildContext context) {
    final maxContentWidth = 900.0;

    // sample data (UI-only)
    const toolName = 'Cordless Drill';
    const toolDesc = 'High-performance cordless drill suitable for home and professional tasks. Lightweight with long battery life.';
    const imageAsset = 'images/adati_logo.png';
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 3));
    final days = endDate.difference(startDate).inDays;
    const pricePerDay = 50.0; // currency-agnostic for UI
    const deliveryFee = 10.0;
    final totalPrice = pricePerDay * days + deliveryFee;

    Widget card(Widget child) => Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: child,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 6),
                        const Text('Rental Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tool Information Card
                          card(Row(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: Image.asset(imageAsset, fit: BoxFit.contain),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(toolName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8),
                                    Text(toolDesc, style: TextStyle(color: Colors.black87, height: 1.3)),
                                  ],
                                ),
                              ),
                            ],
                          )),

                          // Rental Duration
                          card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Rental Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(child: Text('Start: ${_formatDate(startDate)}', style: TextStyle(color: Colors.grey.shade800))),
                              Expanded(child: Text('End: ${_formatDate(endDate)}', style: TextStyle(color: Colors.grey.shade800))),
                            ]),
                            const SizedBox(height: 8),
                            Text('Total days: $days', style: TextStyle(color: Colors.grey.shade700)),
                          ])),

                          // Price Breakdown
                          card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Price Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Price per day', style: TextStyle(color: Colors.grey.shade800)),
                              Text('${_formatCurrency(pricePerDay)} x $days', style: TextStyle(color: Colors.grey.shade800)),
                            ]),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Delivery fee', style: TextStyle(color: Colors.grey.shade800)),
                              Text(_formatCurrency(deliveryFee), style: TextStyle(color: Colors.grey.shade800)),
                            ]),
                            const Divider(height: 20, thickness: 1),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              Text(_formatCurrency(totalPrice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ]),
                          ])),

                          // Late return warning
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Late return policy: Extra charges apply for late returns (e.g., 10 PLN per extra day). Please return the tool on time to avoid fees.',
                                  style: TextStyle(color: Colors.red.shade700, height: 1.3),
                                ),
                              )
                            ]),
                          ),

                          const SizedBox(height: 24),
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
                          // UI-only: normally proceed to payment flow
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Proceed to Payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _two(int v) => v.toString().padLeft(2, '0');
  String _formatCurrency(double v) => '\${v.toStringAsFixed(2)}';
}

// preview runner
void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: RentalSummaryPage()));
}
