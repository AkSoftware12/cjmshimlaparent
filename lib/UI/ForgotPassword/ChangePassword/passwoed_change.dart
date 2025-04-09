import 'dart:convert';

import 'package:cjmshimlaparent/UI/Auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../strings.dart';
import '/UI/bottom_navigation.dart';
import '/constants.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';

class PasswordChangePage extends StatefulWidget {

  const PasswordChangePage({
    super.key,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<PasswordChangePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio(); // Initialize Dio
  bool _isLoading = false;
  List<dynamic> studentList = []; // ✅ Dropdown ke liye data list
  bool _isPasswordVisible = false;
  bool _isPasswordVisible2 = false;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Radio Button List Data
  String? selectedOption;

  @override
  void initState() {
    super.initState();
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Old Password'),
                ),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'New Password'),
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                // Handle password change logic
                String oldPassword = oldPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (newPassword == confirmPassword) {
                  // Proceed with password change
                  try {
                    // Disable the button and show loading indicator
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return Center(child: CircularProgressIndicator());
                    //   },
                    // );

                    Uri uri = Uri.https(
                      'testapi.cjmshimla.in',
                      '/api/change-password',
                      {
                        'password': newPassword
                      }, // Pass new password as a query parameter
                    );

                    final response = await http.get(
                      uri,
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                        // Include token if needed
                      },
                    );

                    // Navigator.of(context).pop(); // Close the loading dialog

                    if (response.statusCode == 200) {
                      // Password changed successfully
                      print("Password changed successfully");
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomNavBarScreen(
                            initialIndex: 0,
                          ),
                        ),
                      );

                      // Close the change password dialog
                    } else {
                      // Handle API error (e.g., wrong old password or server error)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Failed to change password: ${response.body}")),
                      );
                    }
                  } catch (e) {
                    // Handle exception
                    Navigator.of(context).pop(); // Close the loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                } else {
                  // Show error if passwords don't match
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("New passwords do not match")),
                  );
                }
              },
              child: Text("Change"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.pass=='1234') {
    //   _showChangePasswordDialog(context);
    //
    // }
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.sp),
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.sp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 110.sp,
                            width: 150.sp,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10.sp)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 90.sp,
                                  width: 90.sp,
                                  child: Image.asset(
                                    AppAssets.changePawword,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.sp),
                          Text(
                            'Please change your Password'.toUpperCase(),
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.sp),
                      // Email Input
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: TextFormField(
                          controller: newPasswordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(CupertinoIcons.lock_fill),
                            hintText: AppStrings.newPassword,
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye_solid,
                                size: MediaQuery.of(context).size.height * 0.03,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.passwordRequired;
                            } else if (value.length < 6) {
                              return "Password must be at least 6 characters long";
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: 15.sp),
                      // Password Input
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !_isPasswordVisible2,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(CupertinoIcons.lock_fill),
                            hintText: AppStrings.confirmPassword,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible2
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye_solid,
                                size: MediaQuery.of(context).size.height * 0.03,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible2 = !_isPasswordVisible2;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.passwordRequired;
                            } else if (value.length < 6) {
                              return "Password must be at least 6 characters long";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20.sp),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('tokenForgot');
                              // Handle password change logic
                              String oldPassword = oldPasswordController.text;
                              String newPassword = newPasswordController.text;
                              String confirmPassword =
                                  confirmPasswordController.text;

                              if (newPassword == confirmPassword) {
                                // Proceed with password change
                                try {
                                  // Disable the button and show loading indicator
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (BuildContext context) {
                                  //     return Center(child: CircularProgressIndicator());
                                  //   },
                                  // );

                                  Uri uri = Uri.https(
                                    'testapi.cjmshimla.in',
                                    '/api/change-password',
                                    {
                                      'password': newPassword
                                    }, // Pass new password as a query parameter
                                  );

                                  final response = await http.get(
                                    uri,
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $token',
                                      // Include token if needed
                                    },
                                  );

                                  // Navigator.of(context).pop(); // Close the loading dialog

                                  if (response.statusCode == 200) {
                                    // Password changed successfully

                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.clear();
                                    print("Password changed successfully");
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LoginPage(
                                        ),
                                      ),
                                    );

                                    // Close the change password dialog
                                  } else {
                                    // Handle API error (e.g., wrong old password or server error)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Failed to change password: ${response.body}")),
                                    );
                                  }
                                } catch (e) {
                                  // Handle exception
                                  Navigator.of(context)
                                      .pop(); // Close the loading dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              } else {
                                // Show error if passwords don't match
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("New passwords do not match")),
                                );
                              }
                            },
                            child: Text(
                              AppStrings.changePassword.toUpperCase(),
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  color: AppColors.textwhite),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(
                            'Provider by AVI-SUN',
                            style: GoogleFonts.montserrat(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),

      // Center(
      //   child: SingleChildScrollView(
      //     child: Center(
      //       child: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(10.sp)
      //           ),
      //           child: Column(
      //             children: <Widget>[
      //               Card(
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(8.0),
      //                   child: Text('Please change your Password ',style: TextStyle(
      //                     fontSize: 20.sp
      //                   ),),
      //                 ),),
      //               SizedBox(height: 50.sp,),
      //               TextFormField(
      //                 controller: _passwordController,
      //                 obscureText: !_isPasswordVisible,
      //                 decoration: InputDecoration(
      //                   prefixIcon: const Icon(CupertinoIcons.lock_shield_fill),
      //                   hintText: AppStrings.password,
      //                   suffixIcon: IconButton(
      //                     icon: Icon(
      //                       _isPasswordVisible
      //                           ? CupertinoIcons.eye_slash_fill
      //                           : CupertinoIcons.eye_solid,
      //                     ),
      //                     onPressed: () {
      //                       setState(() {
      //                         _isPasswordVisible = !_isPasswordVisible;
      //                       });
      //                     },
      //                   ),
      //                   border: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(8),
      //                   ),
      //                 ),
      //                 validator: (value) {
      //                   if (value == null || value.isEmpty) {
      //                     return AppStrings.passwordRequired;
      //                   }
      //                   return null;
      //                 },
      //               ),
      //
      //
      //               Card(
      //                 elevation: 5,
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(8.0),
      //                   child: TextField(
      //                     controller: oldPasswordController,
      //                     obscureText: true,
      //                     decoration: InputDecoration(labelText: 'Old Password'),
      //                   ),
      //                 ),
      //               ),
      //               Card(
      //                 elevation: 5,
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(8.0),
      //                   child: TextField(
      //                     controller: newPasswordController,
      //                     obscureText: true,
      //                     decoration: InputDecoration(labelText: 'New Password'),
      //                   ),
      //                 ),
      //               ),
      //               Card(
      //                 elevation: 5,
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(8.0),
      //                   child: TextField(
      //                     controller: confirmPasswordController,
      //                     obscureText: true,
      //                     decoration: InputDecoration(labelText: 'Confirm Password'),
      //                   ),
      //                 ),
      //               ),
      //
      //               SizedBox(height: 50.sp,),
      //
      //
      //               Card(
      //                 color: Colors.blue,
      //                 elevation: 5,
      //                 child: TextButton(
      //                   onPressed: () async {
      //                     final prefs = await SharedPreferences.getInstance();
      //                     final token = prefs.getString('token');
      //                     // Handle password change logic
      //                     String oldPassword = oldPasswordController.text;
      //                     String newPassword = newPasswordController.text;
      //                     String confirmPassword = confirmPasswordController.text;
      //
      //                     if (newPassword == confirmPassword) {
      //                       // Proceed with password change
      //                       try {
      //                         // Disable the button and show loading indicator
      //                         // showDialog(
      //                         //   context: context,
      //                         //   builder: (BuildContext context) {
      //                         //     return Center(child: CircularProgressIndicator());
      //                         //   },
      //                         // );
      //
      //                         Uri uri = Uri.https(
      //                           'testapi.cjmshimla.in',
      //                           '/api/change-password',
      //                           {'password': newPassword}, // Pass new password as a query parameter
      //                         );
      //
      //                         final response = await http.get(
      //                           uri,
      //                           headers: {
      //                             'Content-Type': 'application/json',
      //                             'Authorization': 'Bearer $token', // Include token if needed
      //                           },
      //                         );
      //
      //                         // Navigator.of(context).pop(); // Close the loading dialog
      //
      //                         if (response.statusCode == 200) {
      //                           // Password changed successfully
      //                           print("Password changed successfully");
      //                           Navigator.pushReplacement(
      //                             context,
      //                             MaterialPageRoute(
      //                               builder: (context) => BottomNavBarScreen(initialIndex: 0,),
      //                             ),
      //                           );
      //
      //                           // Close the change password dialog
      //                         } else {
      //                           // Handle API error (e.g., wrong old password or server error)
      //                           ScaffoldMessenger.of(context).showSnackBar(
      //                             SnackBar(content: Text("Failed to change password: ${response.body}")),
      //                           );
      //                         }
      //                       } catch (e) {
      //                         // Handle exception
      //                         Navigator.of(context).pop(); // Close the loading dialog
      //                         ScaffoldMessenger.of(context).showSnackBar(
      //                           SnackBar(content: Text("Error: $e")),
      //                         );
      //                       }
      //                     } else {
      //                       // Show error if passwords don't match
      //                       ScaffoldMessenger.of(context).showSnackBar(
      //                         SnackBar(content: Text("New passwords do not match")),
      //                       );
      //                     }
      //                   },
      //                   child: Text("Change Password ",style: TextStyle(
      //                     fontSize: 15.sp,
      //                     color: Colors.white
      //                   ),),
      //                 ),
      //               )
      //
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
