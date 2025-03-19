import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../PaymentGateway/PayButton/pay_button.dart';
import '../../constants.dart';
import '../Auth/login_screen.dart';

class FeesDemoScreen extends StatefulWidget {
  const FeesDemoScreen({super.key});

  @override
  State<FeesDemoScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesDemoScreen> {
  bool isLoading = false;
  List fees = [];
  Map<String, dynamic>? studentData;
  Set<int> selectedFees = {}; // Track selected fee IDs
  double totalAmount = 0.0;
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  @override
  void initState() {
    super.initState();
    fetchFeesData();
  }

  Future<void> fetchFeesData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getFees),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fees = data['fees'];
        fetchStudentData();
        isLoading = false;
      });
    } else {
      _showLoginDialog();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showLoginDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Please log in again to continue.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleSelection(int id, double amount) {
    setState(() {
      if (selectedFees.contains(id)) {
        selectedFees.remove(id);
        totalAmount -= amount;
      } else {
        selectedFees.add(id);
        totalAmount += amount;
      }
    });
  }
  Future<void> fetchStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getProfile),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        studentData = data['student'];
        isLoading = false;
        print(studentData);

      });
    } else {
      _showLoginDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: isLoading
          ? WhiteCircularProgressWidget()
          : fees.isEmpty
          ? Center(child: DataNotFoundWidget(title: 'Fees Not Available.'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: fees.length,
              itemBuilder: (context, index) {
                return PaymentCard(
                  amount: fees[index]['to_pay_amount'].toString(),
                  status: fees[index]['pay_status'],
                  dueDate: fees[index]['due_date'].toString(),
                  payDate: fees[index]['pay_date'].toString(),
                  id: fees[index]['id'],
                  isSelected: selectedFees.contains(fees[index]['id']),
                  onSelect: (bool selected) {
                    _toggleSelection(
                        fees[index]['id'],
                        double.parse(fees[index]['to_pay_amount'].toString()));
                  }, month: months[index],
                );
              },
            ),
          ),
          if (selectedFees.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CommonNdpsButton(buttonText: "Pay Now",
                  status: 'Active', amount: totalAmount.toString(),
                  custFirstName:  studentData?['student_name'],
                  custLastName: 'N/A',
                  mobile: studentData!['contact_no'].toString(), email: studentData!['email'].toString(),
                  address: studentData!['address'].toString(),
                ),
              ),
            ),
            // SizedBox(
            //   width: double.infinity,
            //   child: Padding(
            //     padding: EdgeInsets.all(16),
            //     child: ElevatedButton(
            //       onPressed: () {
            //         print("Processing payment for ₹$totalAmount");
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.blue,
            //         padding: EdgeInsets.symmetric(vertical: 12),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //       ),
            //       child: Text(
            //         "Pay ₹$totalAmount",
            //         style: GoogleFonts.montserrat(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
        ],
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final String amount;
  final String status;
  final String dueDate;
  final String payDate;
  final String month;
  final int id;
  final bool isSelected;
  final ValueChanged<bool> onSelect;

  PaymentCard({
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.payDate,
    required this.id,
    required this.isSelected,
    required this.onSelect, required this.month,
  });




  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(5),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              height: 50.sp,
              width: 50.sp,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${month.substring(0, 3).toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.w700,fontSize: 13.sp), // Optional styling
                    ),

                    Text(status.toLowerCase() == 'paid' ? 'Paid' :'Due',
                      style: GoogleFonts.montserrat(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        color: status.toLowerCase() == 'paid' ? Colors.green : Colors.red,
                      ),
                    ),

                  ],
                ),
              ),
            )
          ],
        ),

        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "₹$amount",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          status.toLowerCase() == 'paid'
              ? (payDate.length >= 10 ? payDate.substring(0, 10) : payDate)
              : '$dueDate',
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: status.toLowerCase() == 'paid' ? Colors.green : Colors.red,
          ),
        ),

        trailing: status.toLowerCase() == 'paid' ? Checkbox(
          onChanged: (bool? value) {
            if (value != null) {
            }
          },
          value: true,
          activeColor: Colors.green,
        ) : Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            if (value != null) {
              onSelect(value);
            }
          },
        ),


      ),
    );
  }
}
