import 'dart:convert';

import 'package:adati_mobile_app/components/product_dialog.dart';
import 'package:adati_mobile_app/pages/rental_summary_page.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<void> showPaymentMethodSheet(
  BuildContext context, {
  required double amount,
  required List<dynamic> selectedTools,
  required VoidCallback onPaid,
}) {
  int step = 1;
  int selectedWallet = 0;
  bool isFetchingPhone = true;
  String? errorMessage; // لظهور رسائل الخطأ للمستخدم
  String userPhone = "Loading...";
  bool isEditingPhone = false; // هل المستخدم حالياً في وضع تعديل الرقم يدوياً؟

  final phoneController = TextEditingController();
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final wallets = [
    {'name': 'One Cash Wallet', 'asset': 'images/one_cash.png'},
    {'name': 'Jaib Wallet', 'asset': 'images/jaib.png'},
  ];
  bool isYemeniPhoneValid(String phone) {
    final regex = RegExp(r'^7[0137][0-9]{7}$');
    return regex.hasMatch(phone);
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> fetchUserPhone() async {
            if (!isFetchingPhone) return; // لضمان عدم التكرار
            final token = await AuthService.getToken();
            try {
              final response = await http.get(
                Uri.parse('http://10.0.2.2:8000/api/me/'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
              if (response.statusCode == 200) {
                final data = json.decode(utf8.decode(response.bodyBytes));
                setState(() {
                  userPhone = data['Phone_Number'] ?? "Not Set";
                  phoneController.text = userPhone;
                  isFetchingPhone = false;
                });
              }
            } catch (e) {
              setState(() => isFetchingPhone = false);
            }
          }

          if (isFetchingPhone) fetchUserPhone();

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
                        step == 1
                            ? Icons.payment
                            : (step == 2
                                  ? Icons.phone_android
                                  : Icons.lock_outline),
                        color: const Color(0xFFFFC72C),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step == 1
                              ? 'Choose Wallet'
                              : (step == 2 ? 'Phone Number' : 'Verification'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedWallet == i
                                ? const Color(0xFFFFC72C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                wallets[i]['asset']!,
                                height: 35,
                                width: 35,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  wallets[i]['name']!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                selectedWallet == i
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: selectedWallet == i
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],

                  // STEP 2: PHONE NUMBER
                  if (step == 2) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isEditingPhone
                            ? "Enter phone number for this payment:"
                            : "Payment via registered number:",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 15),
                    isEditingPhone
                        ? TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "777 777 777",
                              hintStyle: const TextStyle(color: Colors.white24),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFFFC72C),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFC72C).withOpacity(0.2),
                              ),
                            ),
                            child: isFetchingPhone
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFFC72C),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        phoneController.text.isEmpty
                                            ? userPhone
                                            : phoneController.text,
                                        style: const TextStyle(
                                          color: Color(0xFFFFC72C),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "Using this number for this transaction only",
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                    const SizedBox(height: 10),

                    // زر التبديل بين العرض والتعديل
                    if (!isEditingPhone)
                      TextButton(
                        onPressed: () => setState(() => isEditingPhone = true),
                        child: const Text(
                          "Change phone number",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],

                  // STEP 3: OTP
                  if (step == 3) ...[
                    Text(
                      "Code Sent to ${phoneController.text}",
                      style: const TextStyle(color: Colors.white70),
                    ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLength: 1,
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5)
                                FocusScope.of(context).nextFocus();
                              if (value.isEmpty && index > 0)
                                FocusScope.of(context).previousFocus();
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white24,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFFFC72C),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    // ملاحظة: تم حذف رابط "Change phone number" من هنا
                  ],

                  const SizedBox(height: 20),

                  // Action Button
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isFetchingPhone
                          ? null
                          : () {
                              setState(() {
                                if (step == 1)
                                  step = 2;
                                else if (step == 2)
                                  step = 3;
                                else if (step == 3) {
                                  // منطق التحقق والذهاب لصفحة الملخص
                                  String enteredOtp = otpControllers
                                      .map((e) => e.text)
                                      .join();
                                  if (enteredOtp == "000000") {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RentalSummaryPage(
                                          amount: amount,
                                          walletName:
                                              wallets[selectedWallet]['name']!,
                                          phoneNumber: phoneController.text,
                                          tools: List<Product>.from(
                                            selectedTools,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    errorMessage = "Invalid OTP. Use 000000";
                                  }
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC72C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        step == 3 ? "Verify" : "Next",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
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
