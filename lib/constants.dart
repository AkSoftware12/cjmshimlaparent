import 'package:flutter/material.dart';

import 'HexColorCode/HexColor.dart';

class AppColors {
  // static const Color primary = Color(0xFF041B7F); // Example primary color (blue)
  static  Color primary = HexColor('#db7276'); // Example primary color (blue)
  static  Color secondary =HexColor('#7c444f'); // Secondary color (gray)
  // static const Color secondary = Color(0xFF074799); // Secondary color (gray)
  static const Color grey = Color(0xFFAAAEB2); // Secondary color (gray)
  static const Color background = Color(0xFFF8F9FA); // Light background color
  static const Color textblack = Color(0xFF212529); // Dark text color
    static const Color textwhite = Color.fromARGB(255, 255, 255, 255); // Dark text color
    // static  Color textwhite = Colors.grey.shade500; // Dark text color
  static const Color error = Color(0xFFDC3545); // Error color (red)
  static const Color success = Color(0xFF28A745); // Success color (green)
  static const Color yellow = Color(0xFFCCAB21); // Success color (green)
}

class AppAssets {
  static const String logo = 'assets/images/logo.png'; 
  static const String cjm = 'assets/cjm.png';
  static const String cjmlogo = 'assets/playstore.png';
  static const String changePawword = 'assets/changepassword.png';
  // static const String cjmlogo2 = 'assets/playstore2.png';
}

class ApiRoutes {

// Gallery App url
  static const String baseUrl2 = "https://webcjm.cjmshimla.in/api";

  // Main App Url
  // static const String baseUrl = "https://apicjm.cjmshimla.in/api";


  static const String baseUrl = "https://testapi.cjmshimla.in/api";
  static const String downloadUrl = "https://testapi.cjmshimla.in/student/fee-receipt/";





  // Local App url

  // static const String baseUrl = "http://192.168.1.3/cjm_shimla/api";
  // static const String downloadUrl = "http://192.168.1.3/cjm_shimla/student/fee-receipt/";


  static const String login = "$baseUrl/login";
  static const String loginstudent = "$baseUrl/loginstudent";
  static const String clear = "$baseUrl/clear";
  static const String getProfile = "$baseUrl/student-get";
  static const String getPhotos = "$baseUrl2/getPhotos";
  static const String getVideos = "$baseUrl2/getVideos";
  static const String getDashboard = "$baseUrl/dashboard";
  static const String getFees = "$baseUrl/get-fees";
  static const String getAssignments = "$baseUrl/get-assignments";
  static const String getTimeTable = "$baseUrl/get-class-routine?day=";
  static const String getSubject = "$baseUrl/get-subjects";
  static const String studentDashboard = "$baseUrl/dashboard";
  static const String uploadAssignment = "$baseUrl/submit-assignments";
  static const String attendance = "$baseUrl/get-attendance-monthly";
  static const String events = "$baseUrl/events";
  static const String getlibrary = "$baseUrl/library-get";
  static const String notifications = "$baseUrl/notifications";
  static const String getBookTypes = "$baseUrl/book-types";
  static const String getBookCategories = "$baseUrl/book-categories";
  static const String getBookPublishers = "$baseUrl/book-publishers";
  static const String getBookSupplier= "$baseUrl/book-supplier";
  static const String getAtomSettings= "$baseUrl/atom-settings";
  static const String orderCreate= "$baseUrl/bulkpay";
  static const String atompay= "$baseUrl/atompay";
  static const String passwordChange= "$baseUrl/change-password";
  static const String updateApk= "$baseUrl/update-apk";
}
