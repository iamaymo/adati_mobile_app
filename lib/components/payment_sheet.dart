import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showPaymentMethodSheet(
  BuildContext context, {
  required double amount,
  required VoidCallback onPaid,
}) {
  int step = 1; 
  int selectedWallet = 0;
  String? errorMessage; // لظهور رسائل الخطأ للمستخدم
  
  final phoneController = TextEditingController();
  List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());

  final wallets = [
    {'name': 'One Cash Wallet', 'asset': 'images/one_cash.png'},
    {'name': 'Jaib Wallet', 'asset': 'images/jaib.png'},
  ];

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                  // Header
                  Row(
                    children: [
                      Icon(
                        step == 1 ? Icons.payment : (step == 2 ? Icons.phone_android : Icons.lock_outline), 
                        color: const Color(0xFFFFC72C)
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step == 1 ? 'Choose Wallet' : (step == 2 ? 'Phone Number' : 'Verification'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),

                  // Display Error Message if exists
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // STEP 1: SELECT WALLET
                  if (step == 1) ...[
                    for (var i = 0; i < wallets.length; i++)
                      GestureDetector(
                        onTap: () => setState(() {
                          selectedWallet = i;
                          errorMessage = null;
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedWallet == i ? const Color(0xFFFFC72C) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.asset(wallets[i]['asset']!, height: 35, width: 35, fit: BoxFit.contain),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  wallets[i]['name']!,
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(
                                selectedWallet == i ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: selectedWallet == i ? Colors.black : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],

                  // STEP 2: PHONE NUMBER
                  if (step == 2) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Enter your 9-digit phone number", style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() => errorMessage = null),
                      decoration: InputDecoration(
                        counterText: "", // Hidden for cleaner look
                        prefixIcon: const Icon(Icons.phone, color: Color(0xFFFFC72C)),
                        hintText: "7xxxxxxxx",
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFC72C)), borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],

                  // STEP 3: OTP
                  if (step == 3) ...[
                    Text("Sent to ${phoneController.text}", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          child: TextField(
                            controller: otpControllers[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            maxLength: 1,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) {
                              setState(() => errorMessage = null);
                              if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
                              if (value.isEmpty && index > 0) FocusScope.of(context).previousFocus();
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFC72C)), borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setState(() {
                        step = 2;
                        errorMessage = null;
                      }),
                      child: const Text("Change phone number", style: TextStyle(color: Color(0xFFFFC72C))),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (step == 1) {
                            step = 2;
                          } else if (step == 2) {
                            if (phoneController.text.length == 9) {
                              step = 3;
                              errorMessage = null;
                            } else {
                              errorMessage = "Phone number must be 9 digits";
                            }
                          } else if (step == 3) {
                            String enteredOtp = otpControllers.map((e) => e.text).join();
                            if (enteredOtp == "000000") {
                              Navigator.of(context).pop(); 
                              onPaid(); 
                            } else {
                              errorMessage = "Invalid code. Please use 000000";
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC72C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        step == 3 ? 'Confirm & Pay' : 'Next',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}