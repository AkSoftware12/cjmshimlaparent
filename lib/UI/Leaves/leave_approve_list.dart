

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarPrimari.dart';
import '../../constants.dart';


class LeaveRequest {
  String fromDate;
  String toDate;
  String status;
  String reason;
  bool isApproved;

  LeaveRequest({
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.reason,
    required this.isApproved,
  });
}

class ApproveLeaveList extends StatefulWidget {
  @override
  _LeaveScreenState createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<ApproveLeaveList> {

  List leavelist = []; // Declare a list to hold API data
  bool isLoading = true;




  @override
  void initState() {
    super.initState();
    fetchApplyLeave();
  }

  Future<void> fetchApplyLeave() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");


    final response = await http.get(
      Uri.parse(ApiRoutes.applyleave),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        leavelist = data['data'];
        isLoading = false;
        print(leavelist);
      });
    } else {
      // _showLoginDialog();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Leave"),
      //   backgroundColor: Colors.green,
      // ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 20.sp),
        child: isLoading
            ? Center(child: PrimaryCircularProgressWidget()) // Show loader while fetching
            : leavelist.isEmpty
            ? Center(child: DataNotFoundWidget( title: 'Leave not available.',)


        )
            : ListView.builder(
          itemCount: leavelist.length,
          itemBuilder: (context, index) {
            final request = leavelist[index];
            return Stack(
              children: [
                Card(
                  color: AppColors.secondary,
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.sp),
                            bottomRight: Radius.circular(10.sp),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("From: ${request['dates'][0]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("To: ${request['dates'][0]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text("Status: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    request['status'] == 0
                                        ? 'Pending'
                                        : request['status'] == 1
                                        ? 'Approved'
                                        : 'Rejected',
                                    style: TextStyle(
                                      color: request['status'] == 0
                                          ? Colors.orange
                                          : request['status'] == 1
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                  "Reason: ${request['reason'].toString()}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      bottomSheet: Container(
        width: double.infinity,
        height: 20.sp,
        color: AppColors.secondary,
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Powered By ',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'AviSun',
                  style: GoogleFonts.poppins(
                    color: Colors.orangeAccent,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),

                ),
              ],
            )),
      ),

    );
  }
}
