import 'package:flutter/material.dart';

class SupportHelpPage extends StatelessWidget {
  SupportHelpPage({super.key});

  // لون الهوية البصرية
  Color themeYellow = Color(0xFFFBC02D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Support & Help',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- قسم الترحيب ---
            Center(
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 80, color: themeYellow),
                  SizedBox(height: 16),
                  Text(
                    "How can we help you?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Our team is here to support you 24/7",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- خيارات التواصل السريع ---
            const Text(
              "Contact Us Directly",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildContactCard(
                  icon: Icons.chat_bubble_outline,
                  label: "Live Chat",
                  color: Colors.blue,
                  onTap: () {
                    // فتح الشات المباشر
                  },
                ),
                const SizedBox(width: 12),
                _buildContactCard(
                  icon: Icons.email_outlined,
                  label: "Email",
                  color: Colors.redAccent,
                  onTap: () {
                    // فتح تطبيق الإيميل
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- قسم الأسئلة الشائعة FAQ ---
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFAQTile(
              "How to rent a tool?",
              "Browse the available tools, choose the one you need, and send a request to the owner. Once accepted, you can coordinate the pickup.",
            ),
            _buildFAQTile(
              "What happens if a tool is damaged?",
              "Please refer to our Terms & Policies. Generally, the renter is responsible for the repair costs as assessed by the owner.",
            ),
            _buildFAQTile(
              "How can I pay for the rental?",
              "Currently, we support cash on delivery and in-app wallet payments in some regions.",
            ),
            _buildFAQTile(
              "How do I cancel my request?",
              "Go to 'My Orders', select the request, and click 'Cancel'. Please note that cancellation fees might apply if done late.",
            ),

            const SizedBox(height: 40),

            // --- زر تقديم بلاغ رسمي ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.orange,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Found a problem?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Report it to our technical team",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.push إلى صفحة ReportProblemPage التي أنشأناها سابقاً
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeYellow,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Report",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ويدجت بطاقة التواصل
  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت السؤال والجواب (Accordion)
  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconColor: themeYellow,
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
