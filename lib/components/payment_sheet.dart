import 'package:flutter/material.dart';

Future<void> showPaymentMethodSheet(
  BuildContext context, {
  required double amount,
  required VoidCallback onPaid,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      int selected = 0;
      final wallets = [
        {'name': 'One Cash Wallet', 'balance': 'YER 2500', 'asset': 'images/one_cash.png'},
        {'name': 'Jaib Wallet', 'balance': 'YER 1500', 'asset': 'images/jaib.png'},
      ];

      return StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header
                Row(
                  children: [
                    const Icon(Icons.payment, color: Color(0xFFFFC72C)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Choose Payment Method',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('EXISTING WALLETS',
                      style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 12),
                // wallets (with images) — removed "add new payment method"
                for (var i = 0; i < wallets.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => selected = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected == i ? const Color(0xFFFFC72C) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: selected == i ? Border.all(color: const Color(0xFFFFC72C)) : Border.all(color: Colors.white),
                        boxShadow: selected == i
                            ? [BoxShadow(color: Colors.yellow.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))]
                            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Image.asset(wallets[i]['asset']!, height: 30, width: 30, fit: BoxFit.contain),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallets[i]['name']!,
                                  style: TextStyle(
                                    color: selected == i ? Colors.black : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  wallets[i]['balance']!,
                                  style: TextStyle(
                                    color: selected == i ? Colors.black87 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            selected == i ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: selected == i ? Colors.black : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // pay button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onPaid();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC72C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Pay from balance • YER ${amount.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      });
    },
  );
}
