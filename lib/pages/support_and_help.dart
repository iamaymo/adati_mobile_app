import 'package:adati_mobile_app/pages/report_problem_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportHelpPage extends StatelessWidget {
  SupportHelpPage({super.key});

  final Color themeYellow = const Color(0xFFFBC02D);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose Support Channel",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 30),
                title: const Text("WhatsApp Support", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Immediate response for urgent issues"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _launchURL("https://wa.me/967777000000");
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.telegram, color: Colors.blue, size: 35),
                title: const Text("Telegram Support", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Chat with our community bot"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _launchURL("https://t.me/Your_Telegram_Username");
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

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
            Center(
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 80, color: themeYellow),
                  const SizedBox(height: 16),
                  const Text(
                    "How can we help you?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Our team is here to support you 24/7",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
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
                  onTap: () => _showChatOptions(context),
                ),
                const SizedBox(width: 15),
                _buildContactCard(
                  icon: Icons.email_outlined,
                  label: "Email",
                  color: Colors.redAccent,
                  onTap: () => _launchURL("mailto:support@adati.com?subject=Inquiry"),
                ),
              ],
            ),
            const SizedBox(height: 35),
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
              "How do I cancel my request?",
              "Go to 'My Orders', select the request, and click 'Cancel'.",
            ),

            const SizedBox(height: 40),
            _buildReportBanner(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        iconColor: themeYellow,
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem_outlined, color: Colors.orange, size: 35),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Found a technical issue?", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Report it to our developers", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportProblemPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeYellow,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Report", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}