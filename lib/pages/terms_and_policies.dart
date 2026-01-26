import 'package:flutter/material.dart';

class TermsAndPoliciesPage extends StatelessWidget {
  const TermsAndPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // توحيد لون الهوية البصرية للتطبيق
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
              // --- قسم الترويسة ---
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

              // --- بنود السياسة ---
              _buildSectionTitle(
                '1. Tool Responsibility',
                Icons.handyman_outlined,
              ),
              _buildBulletPoint(
                'The renter is fully responsible for the tool during the rental period and must return it in the same condition as received.',
              ),
              _buildBulletPoint(
                'In case of damage or loss, the renter will bear the cost of repair or replacement as assessed by the owner.',
              ),

              _buildSectionTitle('2. Lawful Use', Icons.gavel_outlined),
              _buildBulletPoint(
                'Tools must be used only for legal and legitimate purposes.',
              ),
              _buildBulletPoint(
                'Sub-leasing or re-renting the tool to a third party is strictly prohibited without written approval from the owner.',
              ),

              _buildSectionTitle(
                '3. Safety and Warranty',
                Icons.security_outlined,
              ),
              _buildBulletPoint(
                'The application does not provide any direct warranty regarding the condition or suitability of the tools.',
              ),
              _buildBulletPoint(
                'The renter is responsible for inspecting and ensuring the tool is safe before operation.',
              ),
              _buildBulletPoint(
                'Adati acts only as a digital intermediary and bears no responsibility for accidents or disputes.',
              ),

              _buildSectionTitle('4. Conduct and Ratings', Icons.star_outline),
              _buildBulletPoint(
                'All users must behave respectfully and professionally.',
              ),
              _buildBulletPoint(
                'Both parties have the right to rate each other after the rental is completed.',
              ),

              _buildSectionTitle(
                '5. Data and Privacy',
                Icons.privacy_tip_outlined,
              ),
              _buildBulletPoint(
                'Your data is used only to facilitate the service and improve user experience.',
              ),
              _buildBulletPoint(
                'Personal information will not be shared with third parties without your explicit consent.',
              ),

              _buildSectionTitle('6. Disclaimer', Icons.info_outline),
              _buildBulletPoint(
                'Adati shall not be held liable for any direct or indirect losses resulting from the use of the application.',
              ),
              _buildBulletPoint(
                'Users are solely responsible for verifying the identity of the other party.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت عنوان القسم مع أيقونة بسيطة
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

  // ويدجت النقطة
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
