import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants.dart';
import '/UI/Auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    fetchProfileData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("token: $token");

    // if (token == null) {
    //   _showLoginDialog();
    //   return;
    // }

    final response = await http.get(
      Uri.parse(ApiRoutes.getProfile),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        studentData = data['student'];
        isLoading = false;
        _controller.forward(); // Start animation once data is loaded
      });
    } else {
      // _showLoginDialog();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      floatingActionButton: SizedBox(
        height: 30.sp,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          icon:  Icon(Icons.logout, color: Colors.white,size: 15.sp,),
          label:  Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 12.sp),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear(); // Clear the stored token
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
      body: isLoading
          ? _buildShimmerLoading()
          : SingleChildScrollView(
        padding:  EdgeInsets.all(0.sp),
        child: AnimatedOpacity(
          opacity: isLoading ? 0 : 1,
          duration: const Duration(seconds: 1),
          child: Column(
            children: [
              Card(
                elevation: 5,
                child: Container(
                  height: MediaQuery.of(context).size.width*0.35,
                  padding:  EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
                  decoration:  BoxDecoration(
                    color: AppColors.secondary,
                    // gradient: LinearGradient(
                    //   colors: [AppColors.secondary, AppColors.secondary],
                    // ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    // border: Border.all(
                    //   color: Colors.redAccent, // Change this to your desired border color
                    //   width: 1,           // Border width
                    // ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      SizedBox(
                        height: 90.sp,
                        width: 90.sp,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            studentData!['photo'] ?? '', // Use an empty string if the photo is null
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              // This widget will be displayed if the image fails to load
                              return Container(
                                height: 100.sp,
                                width: 100.sp,
                                color: Colors.white,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    AppAssets.cjmlogo,  // Assuming AppAssets.logo is a string path to an asset
                                    fit: BoxFit.cover,  // Ensures the logo fills the avatar space
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ),
                       SizedBox(width: 16.sp),
                      // User Info
                      Expanded(

                        child: Container(
                          height: 90.sp,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                 SizedBox(height: 10.sp),

                                Text(
                                  studentData!['student_name']?? '',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                 SizedBox(height: 5.sp),
                                Text(
                                  studentData!['email']??'',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                 SizedBox(height: 5.sp),
                                Text(
                                  studentData!['contact_no'] ?? 'N/A'.toString(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                 SizedBox(height: 8.sp),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              SizedBox(height: 8.sp),
              _buildAnimatedSection('Personal Information', [
                buildProfileRow('Name', studentData!['student_name']??''),
                buildProfileRow('Date of Birth', studentData!['dob']??''),
                buildProfileRow(
                  'Gender',
                  studentData!['gender'] == '1' ? 'Male' : 'Female',
                ),
                buildProfileRow('Nationality', studentData!['nationality']?? ''),
                buildProfileRow('Blood Group', studentData!['blood_group']??''),
              ]),
              SizedBox(height: 8.sp),
              _buildAnimatedSection('Academic Information', [
                buildProfileRow('Class', studentData!['class_name']??''),
                buildProfileRow('Section', studentData!['section']?? ''),
                buildProfileRow('Roll Number', studentData!['roll_no']??''),
                buildProfileRow(
                  'Registration Number',
                  studentData!['registration_no']??'',
                ),
                buildProfileRow('Admission Number', studentData!['adm_no']??''),
              ]),
               SizedBox(height: 8.sp),
              _buildAnimatedSection('Contact Information', [
                buildProfileRow('Contact Person', studentData!['contact_person']??''),
                buildProfileRow('Contact Number', studentData!['contact_no']??''),
                buildProfileRow('Email', studentData!['email']??''),
                buildProfileRow('Address', studentData!['address']??''),
              ]),
              const SizedBox(height: 50),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildAnimatedSection(String title, List<Widget> rows) {
    return Padding(
      padding:  EdgeInsets.all(5.sp),
      child: AnimatedContainer(
        duration: const Duration(seconds: 10 ),
        curve: Curves.easeInOut,
        padding:  EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:  TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.textwhite),
            ),
             SizedBox(height: 8.sp),
            Column(children: rows),
          ],
        ),
      ),
    );
  }

  Widget buildProfileRow(String label, String value) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 6.sp),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align the row to start
          children: [
            Text(
              "$label :",
              style:  TextStyle(fontWeight: FontWeight.w800, color: AppColors.textwhite,fontSize: 12.sp),
            ),
             SizedBox(width: 8.sp),  // Add some space between label and value
            Expanded(
              child: Text(
                value.isNotEmpty ? value : 'N/A',
                overflow: TextOverflow.visible,
                style:  TextStyle(color: AppColors.textwhite,fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Center(
      child: CupertinoActivityIndicator(radius: 20),
    );
  }
}

