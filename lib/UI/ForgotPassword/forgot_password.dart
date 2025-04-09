import 'dart:convert';

import 'package:cjmshimlaparent/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;

import 'OtpVerify/otp_verify.dart';



class ForgotPasswordPage extends StatefulWidget {



  ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final _focusNode = FocusNode();

  String email = "";

  String password = "";

  bool _isLoading = false;

  Future<void> forgotPasswordApi(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.orangeAccent,
              ),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    try {
      if (formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        String apiUrl = ApiRoutes.forgotPassword; // Replace with your API endpoint

        final response = await http.post(
          Uri.parse(apiUrl),
          // Uri.parse('http://192.168.1.2/cjm_shimla/api/forgot-password'),
          body: {
            'email': emailController.text,
          },
        );
        setState(() {
          _isLoading =
          false; // Set loading state to false after registration completes
        });
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerifyPage(email: emailController.text, otp: responseData['otp'].toString(),),
            ),
          );
          // Fluttertoast.showToast(
          //   msg: "${'Otp :- '}${responseData['otp']}",
          //   toastLength: Toast.LENGTH_LONG,
          //   gravity: ToastGravity.BOTTOM,
          //   timeInSecForIosWeb: 1,
          //   backgroundColor: Colors.black,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );


          print('OTP Send successfully!');
          // print(token);
          print(response.body);
        } else if(response.statusCode == 404){

          Navigator.pop(context); // Close the progress dialog


          showEmailNotFoundDialog(context);

        }


        else {
          Navigator.pop(context); // Close the progress dialog

          // Registration failed
          // You may handle the error response here, e.g., show an error message
          print('otp failed!');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to forgot password in. Please try again.'),
          ));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading =
        false; // Set loading state to false after registration completes
      });
      Navigator.pop(context); // Close the progress dialog
      // Handle errors appropriately
      print('Error during login: $e');
      // Show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log in. Please try again.'),
      )
      );
    }
  }


  void showEmailNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.grey, size: 24),
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/alert.png',
                height: 80.sp,
                fit: BoxFit.contain,
              ),
               SizedBox(height: 20.sp),
               Text(
                'Email Not Found',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
               SizedBox(height: 10.sp),
               Text(
               "Please consult with the administration to ensure that your app's email address is accurate and up to date.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
               SizedBox(height: 20.sp),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child:  Text(
                    'Close',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 300.sp,
                child: Stack(
                  children: [

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.secondary,


                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50.sp),
                          bottomRight: Radius.circular(50.sp),
                        ),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: SizedBox(
                                height: 120.sp,
                                // child: Image.asset('assets/log_in.png')
                                child: Image.asset(AppAssets.changePawword,color: Colors.white,)
                            )),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(16.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Forgot Password?",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),

                            SizedBox(height: 20.sp),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(left:10.sp,top: 40.sp),
                      child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);

                          }, icon: Icon(Icons.arrow_back,color: Colors.white,size: 25.sp,)),
                    ),

                  ],
                ),
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 13.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Email Id",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.black),
                            ),
                          ),
                          Text('')
                        ],
                      ),
                      SizedBox(height: 20.sp),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 50.sp,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 10,
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                            child: Container(
                              width: double.infinity,

                              height: 50.sp,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                      child: TextField(
                                        controller: emailController ,
                                        keyboardType: TextInputType.emailAddress,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.normal, color: Colors.black),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email',
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.email, color: Colors.black),
                                        ),
                                        textInputAction: TextInputAction.next, // This sets the keyboard action to "Next"
                                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 50.sp),
                      SizedBox(
                        width: double.infinity,
                        height: 50.sp,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Text(
                            "Send OTP",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal, color: Colors.white),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {

                              forgotPasswordApi(context);
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => OtpVerifyPage(email: emailController.text, otp: '',),
                              //   ),
                              // );

                            }

                          },
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
