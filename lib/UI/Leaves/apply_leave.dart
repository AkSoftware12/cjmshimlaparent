import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class ApplyLeaves extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<ApplyLeaves> {
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController reasonController = TextEditingController();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Restrict to current date or later
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }




  Future<void> applyLeave() async {
    setState(() {
      isLoading = true;  // Show loader
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    print(fromDate);

    final response = await http.post(
      Uri.parse(ApiRoutes.applyleave),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'selected_date': DateFormat('dd-MMM-yyyy').format(fromDate!),
        'reason': reasonController.text,
      }),
    );

    setState(() {
      isLoading = false; // Hide loader after response
    });

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      showLeaveSuccessDialog(context);
    } else {
      print("Leave application failed: ${response.body}");
      // Optionally show error dialog/snackbar here
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Leave"),
      //   backgroundColor: Colors.green,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(8.sp),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.sp),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary, // Shadow color
                        blurRadius: 10, // Softness of the shadow
                        spreadRadius: 2, // How much the shadow spreads
                        offset: Offset(0, 0), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        SizedBox(height: 30.sp),
                        _buildDatePickerField("Tap to select the From Date",
                            fromDate, true, context),
                        SizedBox(height: 20.sp),
                        TextField(
                          controller: reasonController,
                          maxLines: 6,
                          maxLength: 200,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Reason (Max 100 words)",
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                        ),
                        SizedBox(height: 30.sp),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          onPressed: isLoading ? null : applyLeave,
                          child: isLoading
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text('Submit',style:
                              TextStyle(color: Colors.white, fontSize: 16.sp),),
                        ),

                        // ElevatedButton(
                        //   onPressed: () {
                        //     applyLeave();
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: AppColors.secondary,
                        //     padding: EdgeInsets.symmetric(
                        //         horizontal: 50, vertical: 15),
                        //   ),
                        //   child: Text(
                        //     "Submit",
                        //     style:
                        //         TextStyle(color: Colors.white, fontSize: 16.sp),
                        //   ),
                        // ),
                        SizedBox(height: 10.sp),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildDatePickerField(String hintText, DateTime? selectedDate,
      bool isFromDate, BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context, isFromDate),
      borderRadius: BorderRadius.circular(10), // Smooth touch effect
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.sp),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary, // Shadow color
              blurRadius: 0, // Softness of the shadow
              spreadRadius: 2, // How much the shadow spreads
              offset: Offset(0, 0), // Changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate == null
                    ? hintText
                    : "${selectedDate.toLocal()}".split(' ')[0],
                style: TextStyle(
                  color: selectedDate == null ? Colors.grey[600] : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.calendar_today, color: AppColors.secondary, size: 20),
              // Modern icon color
            ],
          ),
        ),
      ),
    );
  }

  void showLeaveSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(
                  "Leave Applied Successfully!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Your leave request has been submitted.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    reasonController.clear();
                    setState(() {
                      fromDate = null;
                    });


                    Navigator.of(context).pop();
                  },
                  child: Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
