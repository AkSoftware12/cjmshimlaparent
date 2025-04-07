import 'dart:async';
import 'dart:convert';
import 'package:cjmshimlaparent/constants.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ChangePassword/change_password.dart';


class OtpVerifyPage extends StatefulWidget {
  final String email;
  final String otp;

  const OtpVerifyPage({super.key, required this.email, required this.otp});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final formKey = GlobalKey<FormState>();

  final _focusNode = FocusNode();

  TextEditingController textEditingController = TextEditingController();

  // ..text = "123456";
  StreamController<ErrorAnimationType>? errorController;
  String email = "";
  String password = "";
  bool _isLoading = false;
  bool hasError = false;

  String currentText = "";


  // Future<void> verifyOtpApi(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Center(
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircularProgressIndicator(
  //               color: Colors.orangeAccent,
  //             ),
  //             // SizedBox(width: 16.0),
  //             // Text("Logging in..."),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //
  //   try {
  //     final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  //     String? deviceToken = await _firebaseMessaging.getToken();
  //     print('Device id: $deviceToken');
  //
  //     String otp = textEditingController.text;
  //
  //     if (formKey.currentState!.validate()) {
  //       setState(() {
  //         _isLoading = true;
  //       });
  //       String apiUrl = verifyOtp; // Replace with your API endpoint
  //
  //       final response = await http.post(
  //         Uri.parse(apiUrl),
  //         body: {
  //           'email': widget.email,
  //           'otp': otp,
  //           'device_id': deviceToken,
  //         },
  //       );
  //       setState(() {
  //         _isLoading =
  //         false; // Set loading state to false after registration completes
  //       });
  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> responseData = json.decode(response.body);
  //         final SharedPreferences prefs = await SharedPreferences.getInstance();
  //         final String token = responseData['token'];
  //         // Save token using shared_preferences
  //         await prefs.setString('tokenForgot', token);
  //
  //         print(responseData);
  //
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ChangePasswordPage(),
  //           ),
  //         );
  //
  //         print('verify otp successfully!');
  //         // print(token);
  //         print(response.body);
  //       } else {
  //         // Registration failed
  //         // You may handle the error response here, e.g., show an error message
  //         print('otp failed!');
  //       }
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading =
  //       false; // Set loading state to false after registration completes
  //     });
  //     Navigator.pop(context); // Close the progress dialog
  //     // Handle errors appropriately
  //     print('Error during login: $e');
  //     // Show a snackbar or display an error message
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Failed to log in. Please try again.'),
  //     ));
  //   }
  // }



  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "OTP Verification",
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "We have sent a verification code to",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.normal, color: Colors.grey),
                          ),
                        ),
                        Text('')
                      ],
                    ),
                    SizedBox(height: 50.sp),
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 30,
                        ),
                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,

                          ),
                          length: 6,
                          obscureText: false,
                          // obscuringCharacter: '*',
                          // obscuringWidget: Icon(Icons.star,size: 24,color: Colors.white,),

                          // const FlutterLogo(
                          //   size: 24,
                          // ),
                          textStyle: TextStyle(color: Colors.white),
                          blinkWhenObscuring: false,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v!.length < 6) {
                              return "I'm from validator";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: AppColors.secondary,
                            inactiveFillColor: AppColors.secondary,
                            selectedFillColor: AppColors.secondary,
                            activeColor: Colors.transparent,
                            inactiveColor: Colors.transparent,
                            selectedColor: Colors.transparent,
                          ),

                          cursorColor: Colors.white,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          boxShadows: const [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: Colors.white,
                              blurRadius: 10,
                            )
                          ],
                          onCompleted: (v) {
                            debugPrint("Completed");
                          },
                          // onTap: () {
                          //   print("Pressed");
                          // },
                          onChanged: (value) {
                            debugPrint(value);
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            debugPrint("Allowing to paste $text");
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        hasError ? "*Please fill up all the cells properly" : "",
                        style:  TextStyle(
                          color:AppColors.secondary ,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.sp),

                    Container(
                      margin:
                      const EdgeInsets.symmetric(vertical: 16.0,),
                      child: ButtonTheme(
                        height: 50,
                        child: TextButton(
                          onPressed: () {

                            if (formKey.currentState!.validate()) {

                              // verifyOtpApi(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordPage(),
                                ),
                              );


                            }


                            // formKey.currentState!.validate();
                            // // conditions for validating
                            // if (currentText.length != 4 || currentText != "1234") {
                            //   errorController!.add(ErrorAnimationType
                            //       .shake); // Triggering error shake animation
                            //   setState(() => hasError = true);
                            // } else {
                            //
                            //
                            //
                            //   // Navigator.push(context, MaterialPageRoute(builder: (context)=> ResetPasswordPage()),);
                            //
                            //   setState(
                            //         () {
                            //       hasError = false;
                            //       snackBar("OTP Verified!!");
                            //     },
                            //   );
                            // }
                          },
                          child: Center(
                            child: Text(
                              "VERIFY".toUpperCase(),
                              style:  TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(5),
                          // boxShadow: [
                          //   BoxShadow(
                          //       color: Colors.orange.shade200,
                          //       offset: const Offset(1, -2),
                          //       blurRadius: 5),
                          //   BoxShadow(
                          //       color: Colors.orange.shade200,
                          //       offset: const Offset(-1, 2),
                          //       blurRadius: 5)
                          // ]
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          "Didn't receive the code? ",
                          style: TextStyle(color: Colors.black54, fontSize: 11.sp),
                        ),
                        TextButton(
                          onPressed: () => snackBar("OTP resend!!"),
                          child:  Text(
                            "RESEND",
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),



                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
