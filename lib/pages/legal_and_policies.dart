import 'package:adati_mobile_app/components/my_button.dart';
import 'package:flutter/material.dart';

class LegalPoliciesPage extends StatefulWidget {
  const LegalPoliciesPage({super.key});

  @override
  State<LegalPoliciesPage> createState() => _LegalPoliciesPageState();
}

class _LegalPoliciesPageState extends State<LegalPoliciesPage> {
  bool _isAccepted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Legal and Policies',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: RawScrollbar(
        // تم تغيير لون شريط السحب إلى الأصفر هنا
        thumbColor: Theme.of(context).colorScheme.primary,
        radius: const Radius.circular(20),
        thickness: 6,
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- قسم الترحيب ---
              const Text(
                'Welcome to our app 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We make tool sharing simple.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E5AAC),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Borrow, rent, or share tools with people around you — save money, reduce waste, and build a community based on trust and cooperation.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),
              const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 24),

              // --- قسم شروط الاستخدام ---
              const Text(
                'Terms of Use',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome to the Adati application! Before using our services, please read the following terms carefully:',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              _buildSectionTitle('1. Tool Responsibility'),
              _buildBulletPoint(
                'The renter is fully responsible for the tool during the rental period and must return it in the same condition as received.',
              ),
              _buildBulletPoint(
                'In case of damage or loss, the renter will bear the cost of repair or replacement as assessed by the owner.',
              ),

              _buildSectionTitle('2. Lawful Use'),
              _buildBulletPoint('The renter is fully responsible...'),
              _buildBulletPoint(
                'Sub-leasing or re-renting the tool to a third party is strictly prohibited without written approval from the owner.',
              ),

              _buildSectionTitle('3. Safety and Warranty'),
              _buildBulletPoint(
                'The application does not provide any direct warranty regarding the condition or suitability of the tools.',
              ),
              _buildBulletPoint(
                'The renter is responsible for inspecting and ensuring that the tool is safe and fit for use before operating it.',
              ),
              _buildBulletPoint(
                'Adati acts only as a digital intermediary between the owner and the renter and bears no responsibility for any damages, accidents, or disputes.',
              ),

              _buildSectionTitle('4. Conduct and Ratings'),
              _buildBulletPoint(
                'All users must behave respectfully and professionally.',
              ),
              _buildBulletPoint(
                'Both parties have the right to rate each other after the rental is completed.',
              ),

              _buildSectionTitle('5. Data and Privacy'),
              _buildBulletPoint(
                'Your data is used only to facilitate the service and improve user experience.',
              ),
              _buildBulletPoint(
                'Your personal information will not be shared with any third party without your consent.',
              ),

              _buildSectionTitle('6. Disclaimer of Liability'),
              _buildBulletPoint(
                'Adati shall not be held liable for any direct or indirect losses resulting from the use of the application.',
              ),
              _buildBulletPoint(
                'Users are solely responsible for verifying the identity of the other party.',
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: _isAccepted,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAccepted = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "I Have Read And Agree To The Terms",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              MyButton(
                onPressed: _isAccepted
                    ? () => Navigator.of(context)
                          .pop(true) // نرسل "true" لصفحة التسجيل
                    : null, // معطل إذا لم يؤشر على الـ Checkbox
                label: "Accept & Continue",
              ),
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFBC02D),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
