import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import '../UI/Dashboard/HomeScreen%20.dart';
import '../constants.dart';
import '../strings.dart';
import 'Assignment/assignment.dart';
import 'Attendance/AttendanceScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Auth/login_screen.dart';
import 'Auth/login_student.dart';
import 'Fees/fee_demo.dart';
import 'Gallery/gallery_tab.dart';
import 'Help/help.dart';
import 'Library/LibraryScreen.dart';
import 'Notice/notice.dart';
import 'Notification/notification.dart';
import 'Profile/ProfileScreen.dart';
import 'Report/report_card.dart';
import 'TimeTable/time_table.dart';
import 'WebView/webview.dart';

class BottomNavBarScreen extends StatefulWidget {
  // final String token;
  final int initialIndex;
  const BottomNavBarScreen({super.key, required this.initialIndex,});
  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  List<dynamic> studentList = []; // ✅ Dropdown ke liye data list
  String? selectedStudent; // ✅ Selected student ka value
  String? selectedOption;
  String currentVersion ='';
  final Dio _dio = Dio(); // Initialize Dio
  bool _isLoading = false;
  // List of screens
  final List<Widget> _screens = [
    HomeScreen(),
    AttendanceScreen(),
    // AttendanceCalendar(),
    LibraryScreen(),
    // FeesScreen(),
    FeesDemoScreen(),
    ProfileScreen(),
  ];

  // List of titles corresponding to the screens
  final List<String> _titles = [
    AppStrings.homeLabel,
    AppStrings.attendanceLabel,
    AppStrings.libraryLabel,
    AppStrings.feesLabel,
    AppStrings.profileLabel,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    checkForVersion(context);
    fetchStudentData();

    _selectedIndex = widget.initialIndex; // Set the initial tab index



  }

   Future<void> checkForVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
     currentVersion = packageInfo.version;
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


  Widget _buildAppBar() {
    return Row(
      children: [

        Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.all(0),
            child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              child: SizedBox(
                height: MediaQuery.of(context).size.width*0.1,
                width: MediaQuery.of(context).size.width*0.08,
                child: Image.asset('assets/menu.png'),
              ),
            ),
          ), // Ensure Scaffold is in context
        ),


         SizedBox(width: 12.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome !',
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.displayLarge,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                color: AppColors.textwhite,
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginStudentPage(pass: '',),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    studentData?['student_name'].toString()??'Student Name',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textwhite,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),



          ],
        ),
      ],
    );
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


  @override
  Widget build(BuildContext context) {

    return UpgradeAlert(
      showIgnore: true,
      showLater: true,
      showReleaseNotes: false,
      shouldPopScope: () => false,
      cupertinoButtonTextStyle: TextStyle(
          color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13.sp),
      barrierDismissible: true,
      dialogStyle: UpgradeDialogStyle.cupertino,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: AppColors.secondary,
          drawerEnableOpenDragGesture: false,



          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(
                color: AppColors.textwhite
            ),
            title: Column(
              children: [
                _buildAppBar(),
              ],
            ),
            actions: [
              Padding(
                padding:  EdgeInsets.all(12.sp),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NotificationScreen();
                          },
                        ),
                      );
                    },
                    child: Icon(
                      Icons.notification_add,
                      size: 20.sp,
                      color: Colors.white,
                    )),
              )

              // Container(child: Icon(Icons.ice_skating)),
            ],
          ),
          body: _screens[_selectedIndex], // Display the selected screen
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: AppColors.secondary,
            selectedItemColor: AppColors.textwhite,
            selectedLabelStyle: TextStyle(fontSize: 12.sp), // Change font size for selected item
            unselectedLabelStyle: TextStyle(fontSize: 11.sp), // Change font s
            unselectedItemColor: AppColors.grey,
            showSelectedLabels: true,  // ✅ Ensures selected labels are always visible
            showUnselectedLabels: true, // ✅ Ensures unselected labels are also visible
            type: BottomNavigationBarType.fixed,
            items:  <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home,size: 20.sp,),
                label: AppStrings.homeLabel,
                backgroundColor: AppColors.primary,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.clock,size: 20.sp,),
                label: AppStrings.attendanceLabel,
                backgroundColor: AppColors.primary,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book_fill,size: 20.sp,),
                label: AppStrings.libraryLabel,
                backgroundColor: AppColors.primary,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.currency_rupee,size: 20.sp,),
                label: AppStrings.feesLabel,
                backgroundColor: AppColors.primary,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_alt_circle_fill,size: 20.sp,),
                label: AppStrings.profileLabel,
                backgroundColor: AppColors.primary,
              ),
            ],
          ),
          drawer: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            width: MediaQuery.sizeOf(context).width * .65,
            // backgroundColor: Theme.of(context).colorScheme.background,
            backgroundColor: AppColors.secondary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 50.sp,
                  ),

                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 4; // Profile screen index in _screens
                      });
                    },
                    child: CircleAvatar(
                      radius: 30.sp,
                      backgroundImage: studentData != null && studentData?['photo'] != null
                          ? NetworkImage(studentData?['photo'])
                          : null,
                      child: studentData == null || studentData?['photo'] == null
                          ? Image.asset(AppAssets.cjmlogo,
                          fit: BoxFit.cover)
                          : null,

                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Center(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(top: 0, bottom: 15.sp),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            studentData?['student_name'] ?? 'Student', // Fallback to 'Student' if null
                            style: GoogleFonts.montserrat(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              color: AppColors.textwhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    // Set the color of the divider
                    thickness: 2.sp,
                    // Set the thickness of the divider
                    height: 1.sp, // Set the height of the divider
                  ),

                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(0.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              ListTile(
                                title: Text(
                                  'Dashboard',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing: Icon(Icons.dashboard,color: Colors.white,size: 20.sp,),
                                onTap: () {
                                  Navigator.pop(context);

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) {
                                  //       return DownloadPdf();
                                  //     },
                                  //   ),
                                  // );
                                },
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: 10.sp, right: 10.sp),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade200,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Attendance',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing:  Icon(CupertinoIcons.clock,color: Colors.white,size: 20.sp,),
                                onTap: () {
                                  Navigator.pop(context);

                                  // Navigate to the Profile screen in the BottomNavigationBar
                                  setState(() {
                                    _selectedIndex = 1; // Index of the Profile screen in _screens
                                  });
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) {
                                  //       return DownloadPdf();
                                  //     },
                                  //   ),
                                  // );
                                },
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: 10.sp, right: 10.sp),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade200,
                                  thickness: 1.sp,
                                ),
                              ),



                              ListTile(
                                title: Text(
                                  'Home Work',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing:Image.asset(
                                  'assets/assignments.png',
                                  height: 20.sp, // Adjust the size as needed
                                  width: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AssignmentListScreen();
                                      },
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: 10.sp, right: 10.sp),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade200,
                                  thickness: 1.sp,
                                ),
                              ),


                              ListTile(
                                title: Text(
                                  'Fees',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing:Icon(Icons.currency_rupee,color: Colors.white,size: 20.sp,),
                                onTap: () {
                                  Navigator.pop(context);

                                  // Navigate to the Profile screen in the BottomNavigationBar
                                  setState(() {
                                    _selectedIndex = 3; // Index of the Profile screen in _screens
                                  });

                                },
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: 10.sp, right: 10.sp),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade200,
                                  thickness: 1.sp,
                                ),
                              ),

                              ListTile(
                                title: Text(
                                  'Time Table',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing:  Image.asset(
                                  'assets/watch.png',
                                  height: 20.sp, // Adjust the size as needed
                                  width: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return TimeTableScreen();
                                      },
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: 10.sp, right: 10.sp),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade200,
                                  thickness: 1.sp,
                                ),
                              ),

                              // ListTile(
                              //   title: Text(
                              //     'Report Card',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 13.sp,
                              //           fontWeight: FontWeight.w500),
                              //     ),
                              //   ),
                              //   trailing: Icon(Icons.report,color: Colors.white,size: 20.sp,),
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return ReportCardScreen();
                              //         },
                              //       ),
                              //     );
                              //
                              //   },
                              // ),
                              // Padding(
                              //   padding:
                              //   EdgeInsets.only(left: 10.sp, right: 10.sp),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade200,
                              //     thickness: 1.sp,
                              //   ),
                              // ),

                              ListTile(
                                title: Text(
                                  'Gallery',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing: Image.asset(
                                  'assets/gallery.png',
                                  height: 20.sp, // Adjust the size as needed
                                  width: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return GalleryVideoTabScreen();
                                      },
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: 10.sp, right: 10.sp),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade200,
                                  thickness: 1.sp,
                                ),
                              ),


                              ListTile(
                                title: Text(
                                  'Notices',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing: Image.asset(
                                  'assets/document.png',
                                  height: 20.sp, // Adjust the size as needed
                                  width: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CalendarScreen();
                                      },
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding:
                                EdgeInsets.only(left: 10.sp, right: 10.sp),
                                child: Divider(
                                  height: 1.sp,
                                  color: Colors.grey.shade200,
                                  thickness: 1.sp,
                                ),
                              ),




                              // ListTile(
                              //   title: Text(
                              //     'Help',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 13.sp,
                              //           fontWeight: FontWeight.w500),
                              //     ),
                              //   ),
                              //   trailing: Image.asset('assets/help.png',
                              //     color: Colors.white,
                              //     height: 20.sp, // Adjust the size as needed
                              //     width: 20.sp,
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return HelpScreen(appBar: 'Help',);
                              //         },
                              //       ),
                              //     );
                              //
                              //   },
                              // ),
                              //
                              // Padding(
                              //   padding:
                              //   EdgeInsets.only(left: 10.sp, right: 10.sp),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade200,
                              //     thickness: 1.sp,
                              //   ),
                              // ),


                              // ListTile(
                              //   title: Text(
                              //     'Privacy',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 13.sp,
                              //           fontWeight: FontWeight.w500),
                              //     ),
                              //   ),
                              //   trailing:Icon(
                              //     Icons.privacy_tip,
                              //     color: Colors.white,
                              //     size: 20.sp,
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return WebViewExample(
                              //             title: 'Privacy',
                              //             url: 'https://cjmshimla.in/%20privacy_policy.html',
                              //           );
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              // Padding(
                              //   padding:
                              //   EdgeInsets.only(left: 10.sp, right: 10.sp),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade200,
                              //     thickness: 1.sp,
                              //   ),
                              // ),
                              //
                              // ListTile(
                              //   title: Text(
                              //     'Terms & Condition',
                              //     style: GoogleFonts.cabin(
                              //       textStyle: TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 13.sp,
                              //           fontWeight: FontWeight.w500),
                              //     ),
                              //   ),
                              //   trailing: Icon(
                              //     Icons.event_note_outlined,
                              //     color: Colors.white,
                              //     size: 20.sp,
                              //   ),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) {
                              //           return WebViewExample(
                              //             title: 'Terms & Condition',
                              //             url:
                              //             'https://cjmshimla.in/%20privacy_policy.html',
                              //           );
                              //         },
                              //       ),
                              //     );
                              //   },
                              // ),
                              //
                              //
                              //
                              // Padding(
                              //   padding:
                              //   EdgeInsets.only(left: 10.sp, right: 10.sp),
                              //   child: Divider(
                              //     height: 1.sp,
                              //     color: Colors.grey.shade200,
                              //     thickness: 1.sp,
                              //   ),
                              // ),
                              ListTile(
                                title: Text(
                                  'Logout',
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.clear(); // Clear the stored token
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15.sp),
                        ),
                        Center(
                          child: Text('Version :-  $currentVersion',
                            style: GoogleFonts.cabin(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      ],
                    ),
                  )

                ],
              ),
            ),
          ),

        ),

      ),

    );

  }
}



