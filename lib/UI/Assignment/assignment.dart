import 'package:cjmshimlaparent/HexColorCode/HexColor.dart';
import 'package:cjmshimlaparent/UI/Assignment/upload_assignments.dart';
import 'package:cjmshimlaparent/UI/Assignment/view_assignments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../constants.dart';
import 'package:html/parser.dart' as html_parser;
import '../Auth/login_screen.dart';
import 'assignment_detalis.dart';

class AssignmentListScreen extends StatefulWidget {
  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  bool isLoading = false;
  List assignments = []; // Declare a list to hold API data

  @override
  void initState() {
    super.initState();
    DateTime.now().subtract(const Duration(days: 30));
    fetchAssignmentsData();
  }

  Future<void> fetchAssignmentsData() async {
    setState(() {
      isLoading = true; // Show progress bar
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getAssignments),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        assignments = jsonResponse['data']; // Update state with fetched data
        isLoading = false; // Stop progress bar
      });
    } else {
      _showLoginDialog();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _refresh() {
    setState(() {
      fetchAssignmentsData();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
          iconTheme: IconThemeData(color: AppColors.textwhite),
          backgroundColor: AppColors.secondary,
          title: Text(
            'Home Work',
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
              color: AppColors.textwhite,
            ),
          )),
      body: isLoading
          ? WhiteCircularProgressWidget()
          : assignments.isEmpty
              ? Center(
                  child: DataNotFoundWidget(
                  title: 'Assignments  Not Available.',
                ))
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    String description = html_parser
                            .parse(assignment['description'] ?? 'N/A')
                            .body
                            ?.text ??
                        '';
                    // String startDate = DateFormat('dd-MM-yyyy')
                    //     .format(DateTime.parse(assignment['start_date'] ?? ''));
                    // String endDate = DateFormat('dd-MM-yyyy')
                    //     .format(DateTime.parse(assignment['due_date'] ?? ''));

                    return Stack(
                      children: [
                        Card(
                          elevation: 6,
                          color: Colors.blueGrey,
                          // Light background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// **Title & Index**
                                Row(
                                  children: [
                                    Container(
                                      height: 35.sp,
                                      width: 35.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15.sp),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            assignment['title'].toString().toUpperCase()??'??',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '${description ?? 'N/A'}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // if(assignment['attach']==)
                                    // _buildButton(
                                    //   text: 'View',
                                    //   color: AppColors.secondary,
                                    //   onTap: () async {
                                    //     // final Uri pdfUri = Uri.parse(assignment['attach'].toString());
                                    //     FileOpener.openFile(
                                    //         assignment['attach'].toString());
                                    //   },
                                    // ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),

                        Card(
                          margin: EdgeInsets.symmetric(vertical: 3.sp,horizontal: 8.sp),
                          elevation: 6,
                          color: Colors.white,
                          // Light background
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.sp),
                          ),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  AssignmentDetalis(title: '${assignment['title'].toString()}', descripation: '${assignment['description'].toString()}',)),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(10.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// **Title & Index**
                                  Row(
                                    children: [
                                      Container(
                                        height: 35.sp,
                                        width: 35.sp,
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.sp),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              assignment['title']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              description,
                                              // maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if(assignment['attach']=='null' && assignment['attach']=='')
                                      _buildButton(
                                        text: 'View',
                                        color: AppColors.secondary,
                                        onTap: () async {
                                          // final Uri pdfUri = Uri.parse(assignment['attach'].toString());
                                          FileOpener.openFile(
                                              assignment['attach'].toString());
                                        },
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  /// **Reusable Widget for Date**
  Widget _buildDateInfo(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          date,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// **Reusable Button Widget**
  Widget _buildButton(
      {required String text,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: MediaQuery.of(context).size.width*0.85,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
        child: Center(
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// **Status Box**
  Widget _buildStatusBox(String status) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: status == 'submitted' ? Colors.green : Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          status.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
