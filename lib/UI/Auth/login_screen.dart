import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../HexColorCode/HexColor.dart';
import '../ForgotPassword/forgot_password.dart';
import '/UI/bottom_navigation.dart';
import '/constants.dart';
import '../../strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login_student.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio(); // Initialize Dio
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  List loginStudent = []; // Declare a list to hold API data


  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.post(
        ApiRoutes.login,
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data; // FIX: No need to decode

        if (jsonResponse['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('studentList', jsonEncode(jsonResponse['students']));
          setState(() {
            loginStudent = jsonResponse['students']; // Update state with fetched data
            _isLoading = false;
            prefs.setString('password', _passwordController.text);
            print('Login Student: $loginStudent');
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginStudentPage(pass: '${_passwordController.text}',),
            ),
          );


        } else {
          print('${AppStrings.loginFailedDebug}${jsonResponse['message']}');
          _showErrorDialog(jsonResponse['message']);
        }
      } else {
        print('${AppStrings.loginFailedMessage} ${response.statusCode}');
        _showErrorDialog(AppStrings.loginFailedMessage);
      }
    } on DioException catch (e) {
      String errorMessage = AppStrings.unexpectedError;
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data;
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      print('${AppStrings.generalErrorDebug}$e');
      _showErrorDialog(AppStrings.unexpectedError);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.loginFailedTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show dialog for changing password
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
              onPressed: () {
                // Handle password change logic
                String oldPassword = oldPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (newPassword == confirmPassword) {
                  // Proceed with password change
                  print("Old Password: $oldPassword");
                  print("New Password: $newPassword");
                  Navigator.of(context).pop();
                } else {
                  // Show error if passwords don't match
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("New passwords do not match")),
                  );
                }
              },
              child: Text("Change"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
               SizedBox(height: 15.sp),
              Container(
                width: MediaQuery.of(context).size.width*0.90,
                // width: 350.sp,
                padding:  EdgeInsets.all(15.sp),
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
                                borderRadius: BorderRadius.circular(10.sp)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 90.sp,
                                  width: 90.sp,
                                  child: Image.asset(
                                    AppAssets.cjmlogo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                           SizedBox(height: 5.sp),
                           Text(
                            AppStrings.studentLogin,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width*0.04,
                              // fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                       SizedBox(height: 15.sp),
                      // Email Input
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.07,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.account_circle_outlined),
                            hintText: AppStrings.email,
                            hintStyle: TextStyle(color: Colors.grey.shade500,fontSize: MediaQuery.of(context).size.width*0.035),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                          ),
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return AppStrings.invalidEmail;
                          //   }
                          //   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          //     return AppStrings.invalidEmail;
                          //   }
                          //   return null;
                          // },
                        ),
                      ),
                       SizedBox(height: 15.sp),
                      // Password Input
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.07,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(CupertinoIcons.lock_shield_fill),
                            hintText: AppStrings.password,
                            hintStyle: TextStyle(color: Colors.grey.shade500,fontSize: MediaQuery.of(context).size.width*0.035),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye_solid,size:MediaQuery.of(context).size.height*0.03,

                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.passwordRequired;
                            }
                            return null;
                          },
                        ),
                      ),
                       SizedBox(height: 10.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      ForgotPasswordPage()),);
                            },
                            child: Text(
                              "Forgot password?",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 12.sp,
                                    fontWeight: FontWeight.normal,
                                    color: HexColor('#f04949')),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CupertinoSwitch (
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },

                          ),
                           Text(AppStrings.rememberMe,style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.03,
                          ),),
                        ],
                      ),
                       SizedBox(height: 10.sp),
                      if (_isLoading) const CircularProgressIndicator() else SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding:  EdgeInsets.symmetric(vertical: 15.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                          ),
                          onPressed: () {

                            _login();
                            // var token = "123"; // Define the token
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => BottomNavBarScreen(token: token), // Pass the token directly
                            //   ),
                            // );
                          },
                          child:  Text(
                            AppStrings.login,
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: AppColors.textwhite),
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
                    padding:  EdgeInsets.only(top: 8.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text('Provider by AVI-SUN',
                            style: GoogleFonts.montserrat(
                              textStyle: Theme.of(context).textTheme.displayLarge,
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
    );
  }
}
