import 'package:adati_mobile_app/components/my_button.dart';
import 'package:flutter/material.dart';

class LegalPoliciesPage extends StatefulWidget {
  const LegalPoliciesPage({super.key});

  @override
  State<LegalPoliciesPage> createState() => _LegalPoliciesPageState();
}

class _LegalPoliciesPageState extends State<LegalPoliciesPage> {
  bool _isAccepted = false;

  // توحيد الهوية البصرية بناءً على مشروع Adati
  final Color themeYellow = const Color(0xFFFBC02D);
  final Color textColor = const Color(0xFF1A1A1A);
  final Color subTextColor = const Color(0xFF666666);
  final Color linkColor = const Color(0xFF2E5AAC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Legal & Policies',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: RawScrollbar(
        thumbColor: themeYellow.withOpacity(0.8),
        radius: const Radius.circular(20),
        thickness: 6,
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- قسم الترحيب ---
              Text(
                'Welcome to Adati 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Professional Tool Sharing Platform',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: linkColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'By joining our community, you agree to our terms of service designed to ensure a safe and fair experience for everyone.',
                style: TextStyle(
                  fontSize: 15,
                  color: subTextColor,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1, color: Color(0xFFEEEEEE)),

              // --- بنود السياسة الاحترافية لمشروع أداتي ---
              _buildSectionTitle(
                '1. Payments & Security Deposit',
                Icons.payments_outlined,
              ),
              _buildBulletPoint(
                'All payments are processed securely online. A security deposit (insurance) is required and will be held by Adati until the tool is safely returned.',
              ),
              _buildBulletPoint(
                'Adati charges a service commission on each rental. If a request is cancelled before owner approval, the full amount and commission will be refunded.',
              ),

              _buildSectionTitle(
                '2. Cancellation Policy',
                Icons.event_busy_outlined,
              ),
              _buildBulletPoint(
                'Once the tool owner approves your rental request, the transaction is final and cancellation is not permitted.',
              ),

              _buildSectionTitle(
                '3. Late Returns & Damages',
                Icons.report_problem_outlined,
              ),
              _buildBulletPoint(
                'The renter must return the tool on time. In case of delay or damage, the owner can file a report, and costs will be deducted from the security deposit.',
              ),

              _buildSectionTitle(
                '4. Identity Verification',
                Icons.verified_user_outlined,
              ),
              _buildBulletPoint(
                'To ensure safety, all users must provide valid ID verification. Providing false information or bypassing the app payment system will lead to a permanent ban.',
              ),

              _buildSectionTitle(
                '5. Adati as a Mediator',
                Icons.gavel_outlined,
              ),
              _buildBulletPoint(
                'Adati acts as a mediator (judge) in disputes. While we strive for fairness, the platform is not legally liable for tool malfunctions or physical accidents during use.',
              ),

              _buildSectionTitle(
                '6. Renter Responsibility',
                Icons.handyman_outlined,
              ),
              _buildBulletPoint(
                'The renter is responsible for inspecting the tool upon handover. Using the tool for any illegal purposes is strictly prohibited.',
              ),

              const SizedBox(height: 32),

              // --- منطقة الموافقة (Checkbox) ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeYellow.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeYellow.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAccepted,
                      activeColor: themeYellow,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        "I Have Read And Agree To The Terms",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- زر القبول والمتابعة ---
              MyButton(
                onPressed: _isAccepted
                    ? () => Navigator.of(context).pop(true)
                    : null,
                label: "Accept & Continue",
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت عنوان القسم مع أيقونة
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: themeYellow),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت نقطة الشرح
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: themeYellow),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: subTextColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
