import 'package:flutter/material.dart';

class TermsAndPoliciesPage extends StatelessWidget {
  const TermsAndPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color themeYellow = Color(0xFFFBC02D);
    const Color textColor = Color(0xFF1A1A1A);
    const Color subTextColor = Color(0xFF666666);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Terms & Policies',
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
              const Text(
                'Welcome to Adati 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Legal Terms & Conditions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E5AAC),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'By using our platform, you agree to the following terms. We aim to build a safe and trustworthy community for tool sharing.',
                style: TextStyle(
                  fontSize: 15,
                  color: subTextColor,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              _buildSectionTitle(
                '1. Payments & Commission',
                Icons.payments_outlined,
              ),
              _buildBulletPoint(
                'Adati uses a secure online payment system. The total amount includes the rental fee, a security deposit (insurance), and a service commission.',
              ),
              _buildBulletPoint(
                'If a request is cancelled before approval, the full amount including commission will be refunded to your wallet/account.',
              ),

              _buildSectionTitle(
                '2. Cancellation & Returns',
                Icons.event_busy_outlined,
              ),
              _buildBulletPoint(
                'Once the tool owner approves the request, cancellation is not permitted.',
              ),
              _buildBulletPoint(
                'Delayed returns will result in deductions from your security deposit. The owner has the right to file a "Late Return Report" through the app.',
              ),

              _buildSectionTitle(
                '3. Security Deposit (Insurance)',
                Icons.shield_outlined,
              ),
              _buildBulletPoint(
                'The security deposit is held by Adati and is only released back to the renter after the owner confirms the safe return of the tool.',
              ),
              _buildBulletPoint(
                'In case of damages or loss, Adati will deduct the repair costs from the deposit based on the reported evidence.',
              ),

              _buildSectionTitle(
                '4. Identity Verification',
                Icons.verified_user_outlined,
              ),
              _buildBulletPoint(
                'To ensure community safety, all users must provide a valid ID and verify their phone number. Providing false information will lead to permanent account suspension.',
              ),

              _buildSectionTitle(
                '5. Adati as an Intermediary',
                Icons.gavel_outlined,
              ),
              _buildBulletPoint(
                'Adati acts as a mediator in disputes. While we strive to resolve conflicts fairly, the platform is not legally liable for any physical accidents or tool malfunctions.',
              ),
              _buildBulletPoint(
                'Users are responsible for inspecting the tool carefully at the moment of handover.',
              ),

              _buildSectionTitle('6. Prohibited Actions', Icons.block_flipped),
              _buildBulletPoint(
                'Attempting to bypass the app payment system to avoid commission is strictly prohibited and will result in a permanent ban.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFFBC02D)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFFBC02D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
