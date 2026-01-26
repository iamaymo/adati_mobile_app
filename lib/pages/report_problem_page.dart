import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adati_mobile_app/services/auth_service.dart';

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  String? selectedProblemType;

  bool isFaqExpanded = true;
  bool isFormExpanded = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  // أنواع المشاكل المتوقعة في التطبيق
  final List<String> problemCategories = [
    'Technical Problem',
    'Fraud or Scam',
    'User Behavior',
    'Tool Damage/Issues',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBC02D),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            // الهيدر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [BackButton(onPressed: () => Navigator.pop(context))],
              ),
            ),

            const Text(
              "Report a Problem",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "We are here to help you",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProblemTypeDropdown(),

                      const SizedBox(height: 30),

                      // إذا كانت مشكلة تقنية، نظهر نصيحة سريعة أولاً (FAQ)
                      if (selectedProblemType == 'Technical Problem')
                        _buildQuickHintCard(
                          "App not working correctly?",
                          "Try clearing the app cache or updating to the latest version. If the problem persists, please fill out the form below.",
                        ),

                      // إذا تم اختيار أي نوع مشكلة، يظهر نموذج المراسلة
                      if (selectedProblemType != null)
                        _buildFormSection(
                          title: "Report Details",
                          subtitle:
                              "Provide more details so we can assist you better",
                          isExpanded: isFormExpanded,
                          onToggle: () =>
                              setState(() => isFormExpanded = !isFormExpanded),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // اختيار نوع المشكلة
  Widget _buildProblemTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F4F8), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: DropdownButtonFormField<String>(
          value: selectedProblemType,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            hintText: "What's the issue?",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
          icon: const Icon(
            Icons.report_problem_outlined,
            color: Color(0xFFFBC02D),
            size: 25,
          ),
          items: problemCategories.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF34495E),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedProblemType = val),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: const Color(0xFFFBC02D),
                size: 30,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFBC02D),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "Your Contact Email",
            emailController,
            Icons.email_outlined,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            "Your Phone Number",
            phoneController,
            Icons.phone_android_outlined,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            "Problem Description",
            detailsController,
            Icons.edit_note_outlined,
            maxLines: 5,
            maxLength: 500,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBC02D),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Submit Report",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF34495E),
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 22),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            hintText: "Type here...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFFBC02D)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHintCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFBC02D).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFFBC02D)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF856404),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF856404),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    // 1. التحقق من الحقول
    if (emailController.text.isEmpty ||
        detailsController.text.isEmpty ||
        selectedProblemType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(
      () => isFormExpanded = false,
    ); // إغلاق النموذج أثناء التحميل (اختياري)

    try {
      final String? token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/reports/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'Problem_Type': selectedProblemType,
          'Contact_Email': emailController.text,
          'Contact_Phone': phoneController.text,
          'Description': detailsController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // إفراغ الحقول والعودة للخلف بعد ثانية
        emailController.clear();
        phoneController.clear();
        detailsController.clear();
        Future.delayed(
          const Duration(seconds: 2),
          () => Navigator.pop(context),
        );
      } else {
        throw Exception("Failed to submit report");
      }
    } catch (e) {}
  }
}
