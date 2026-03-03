import 'dart:convert';
import 'package:adati_mobile_app/pages/report_problem_page.dart';
import 'package:adati_mobile_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderTrackingPage extends StatefulWidget {
  final dynamic order;
  final bool isOwner;

  const OrderTrackingPage({
    super.key,
    required this.order,
    required this.isOwner,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  double _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isToolStatusChecked = false;
  void _showRatingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isOwner ? "Rate the Customer" : "Rate the Tool",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: primaryColor,
                      size: 40,
                    ),
                    onPressed: () =>
                        setModalState(() => _selectedRating = index + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your experience here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _actionBtn("Submit Review", () async {
                await _submitReview();
                Navigator.pop(context);
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating star")),
      );
      return;
    }

    final String url = 'http://10.0.2.2:8000/api/reviews/';

    try {
      final String? token = await AuthService.getToken();
      Map<String, dynamic> body = {
        "Review_Value": _selectedRating,
        "Review_Text": _reviewController.text,
        "Review_Type": widget.isOwner ? "U" : "T",
        "Order_ID": currentOrder['Order_ID'],
      };
      if (widget.isOwner) {
        body["Target_User"] = currentOrder['User_ID'];
      } else {
        body["Target_Tool"] = currentOrder['Tool_ID'];
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thank you! Review submitted successfully"),
          ),
        );
        await _fetchOrderDetails();
        setState(() {
          _selectedRating = 0;
          _reviewController.clear();
        });
      } else {
        print("Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit review. Try again.")),
        );
      }
    } catch (e) {
      print("Submit Review failed: $e");
    }
  }

  final Color primaryColor = const Color(0xFFFFC72C);
  late dynamic currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  Future<void> _updateStatus(
    String newStatus,
    Map<String, dynamic> extraData,
  ) async {
    final String orderId = currentOrder['Order_ID'].toString();
    final String url = 'http://10.0.2.2:8000/api/orders/$orderId/';
    Map<String, dynamic> body = {'Order_Status': newStatus, ...extraData};

    try {
      final String? token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          currentOrder['Order_Status'] = newStatus;
          extraData.forEach((key, value) => currentOrder[key] = value);
        });
      }
    } catch (e) {
      print("Update failed: $e");
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Not Started';
    try {
      DateTime dt = DateTime.parse(dateTimeStr);
      return DateFormat('MMM d, hh:mm a').format(dt);
    } catch (e) {
      return 'Pending';
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final String orderId = currentOrder['Order_ID'].toString();
    final String url = 'http://10.0.2.2:8000/api/orders/$orderId/';

    try {
      final String? token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          currentOrder = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Refresh failed: $e");
    }
  }

  Widget _buildInsuranceStatusCard() {
    bool isRefunded =
        currentOrder['insurance_details'] != null &&
        currentOrder['insurance_details']['status'] == 'refunded';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRefunded ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRefunded ? Colors.green.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isRefunded ? Icons.check_circle_outline : Icons.security_outlined,
            color: isRefunded ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRefunded ? "Insurance Refunded" : "Insurance Deposit Held",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isRefunded
                        ? Colors.green.shade800
                        : Colors.blue.shade800,
                  ),
                ),
                Text(
                  isRefunded
                      ? "The deposit has been returned to the customer's wallet."
                      : "The system is holding the deposit until the tool is returned.",
                  style: TextStyle(
                    fontSize: 12,
                    color: isRefunded
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isOwner ? 'Manage Rental' : 'Track My Rental',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildInsuranceStatusCard(),
                const SizedBox(height: 16),
                _buildProgressCard(),
                const SizedBox(height: 16),
                _buildFinancialCard(),
                const SizedBox(height: 24),
                _buildBottomActionButton(),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportProblemPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                        bottom: 4,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.report_problem_outlined,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Report a Problem",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    double toolRealValue =
        double.tryParse(currentOrder['real_value']?.toString() ?? '0') ?? 0;
    double insuranceAmount = 0;
    if (currentOrder['insurance_details'] != null) {
      insuranceAmount =
          double.tryParse(
            currentOrder['insurance_details']['amount']?.toString() ?? '0',
          ) ??
          0;
    } else {
      insuranceAmount = toolRealValue * 0.25;
    }
    String insurancePercentage = toolRealValue > 0
        ? "${((insuranceAmount / toolRealValue) * 100).toStringAsFixed(0)}%"
        : "25%";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: currentOrder['tool_image'] != null
                    ? Image.network(
                        currentOrder['tool_image'],
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 65,
                        height: 65,
                        color: Colors.grey[200],
                        child: const Icon(Icons.build),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentOrder['tool_name'] ?? 'Tool Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Customer: ${currentOrder['customer_name'] ?? 'User'}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(
            'Start Date',
            formatDateTime(currentOrder['Start_Date']),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Expected Return',
            formatDateTime(currentOrder['Due_Date']),
          ),
          const SizedBox(height: 10),
          _buildOrderNumberRow(currentOrder['Order_ID'].toString()),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(thickness: 0.5),
          ),
          _buildInfoRow(
            "Total Tool Value",
            "${toolRealValue.toStringAsFixed(0)} YER",
          ),
          const SizedBox(height: 10),
          _buildInfoRow("Security Deposit Rate", insurancePercentage),
          const SizedBox(height: 10),
          _buildInfoRow(
            "Held Insurance Deposit",
            "${insuranceAmount.toStringAsFixed(0)} YER",
            textColor: Colors.blue.shade500,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    List<Map<String, dynamic>> steps = [
      {
        "title": "Request Accepted",
        "val":
            currentOrder['Order_Status'] != 'Pending' &&
            currentOrder['Order_Status'] != 'Rejected' &&
            currentOrder['Order_Status'] != 'Cancelled',
      },
      {
        "title": "Handed to Delivery",
        "val": currentOrder['is_handed_to_delivery'] ?? false,
      },
      {
        "title": "Received by Customer",
        "val": currentOrder['is_received_by_customer'] ?? false,
      },
      {
        "title": "Ready for Pickup",
        "val": currentOrder['is_return_requested'] ?? false,
      },
      {
        "title": "Handed to Delivery (Back)",
        "val": currentOrder['is_return_handed_to_delivery'] ?? false,
      },
      {"title": "Finished", "val": currentOrder['Order_Status'] == 'Completed'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: steps
            .map(
              (step) => Row(
                children: [
                  Checkbox(
                    value: step['val'],
                    onChanged: null,
                    shape: const CircleBorder(),
                    activeColor: primaryColor,

                    fillColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (step['val'] == true) {
                        return primaryColor;
                      }
                      return const Color.fromARGB(28, 158, 158, 158);
                    }),
                  ),
                  Text(
                    step['title'],
                    style: TextStyle(
                      color: step['val'] ? Colors.black : Colors.grey,
                      fontWeight: step['val']
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBottomActionButton() {
    String status = currentOrder['Order_Status'];

    if (status == 'Completed') {
      bool hasRatedTool = currentOrder['has_rated_tool'] ?? false;
      bool hasRatedCustomer = currentOrder['has_rated_customer'] ?? false;

      if (widget.isOwner) {
        if (hasRatedCustomer) return const SizedBox.shrink();

        return _actionBtn("Rate Customer ⭐", () => _showRatingSheet());
      } else {
        if (hasRatedTool) return const SizedBox.shrink();

        return _actionBtn("Rate Tool ⭐", () => _showRatingSheet());
      }
    }

    if (widget.isOwner) {
      if (status == 'Accepted') {
        return _actionBtn(
          "Handed to Delivery",
          () => _updateStatus('On_The_Way', {'is_handed_to_delivery': true}),
        );
      }
      if (status == 'Returning') {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade900,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Please inspect the tool's condition carefully before finishing the order.",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              value: _isToolStatusChecked,
              onChanged: (val) => setState(() => _isToolStatusChecked = val!),
              title: const Text(
                "I have confirmed that the tool is in good condition",
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 10),
            _actionBtn(
              "Finish Order",
              _isToolStatusChecked
                  ? () => _updateStatus('Completed', {})
                  : () {}, 
              color: _isToolStatusChecked ? Colors.black : Colors.grey,
            ),
          ],
        );
      }
    } else {
      if (status == 'Pending') {
        return _actionBtn(
          "Cancel Order",
          () => _updateStatus('Cancelled', {}),
          color: Colors.red,
        );
      }
      if (status == 'On_The_Way') {
        return _actionBtn(
          "Confirm Tool Receipt",
          () => _updateStatus('Ongoing', {'is_received_by_customer': true}),
        );
      }
      if (status == 'Ongoing') {
        return _actionBtn(
          "Ready for Pickup",
          () => _updateStatus('Returning', {'is_return_requested': true}),
        );
      }
      if (status == 'Returning' &&
          (currentOrder['is_return_handed_to_delivery'] == false)) {
        return _actionBtn(
          "Handed to Delivery (Back)",
          () => _updateStatus('Returning', {
            'is_return_handed_to_delivery': true,
          }),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _actionBtn(
    String title,
    VoidCallback onPress, {
    Color color = Colors.black,
  }) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: _buildInfoRow(
              "Total Paid by Customer",
              "${currentOrder['Total_Price']} YR",
              isBold: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildInfoRow(
              "Your Net Profit",
              "${currentOrder['Owner_Amount']} YR",
              isBold: true,
              textColor: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 15 : 14,
            color: textColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderNumberRow(String id) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Order ID",
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        Row(
          children: [
            Text(
              "#$id",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(text: id)),
              child: const Icon(Icons.copy, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
