import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../HexColorCode/HexColor.dart';
import '../../PaymentGateway/PayButton/pay_button.dart';
import '../../constants.dart';
import '../Assignment/assignment.dart';
import '../Auth/login_screen.dart';
import '../Gallery/gallery_tab.dart';
import '../HomeWork/home_work.dart';
import '../Notice/notice.dart';
import '../Report/report_card.dart';
import '../Subject/subject.dart';
import '../TimeTable/time_table.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../bottom_navigation.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? studentData;
  List assignments = []; // Declare a list to hold API data
  bool isLoading = true;
   late final String pass;
  bool _isVisible = true;

  late CleanCalendarController calendarController;
  final List<Map<String, String>> items = [
    {
      'name': 'Home Work',
      'image': 'assets/assignments.png',
    },
    {
      'name': 'Time Table',
      'image': 'assets/watch.png',
    },
    // {
    //   'name': 'Home Work',
    //   'image': 'assets/home_work.png',
    // },
    // {
    //   'name': 'Subject',
    //   'image': 'assets/physics.png',
    // },
    {
      'name': 'News & Events',
      'image': 'assets/event_planner.png',
    },
    {
      'name': 'Gallery',
      'image': 'assets/gallery.png',
    },
    {
      'name': 'Report Card',
      'image': 'assets/report.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    calendarController = CleanCalendarController(
      minDate: DateTime.now().subtract(const Duration(days: 30)),
      maxDate: DateTime.now().add(const Duration(days: 365)),
    );
    fetchStudentData();
    fetchDasboardData();

    Timer(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
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
      // _showLoginDialog();
    }
  }

  Future<void> fetchDasboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
      _showLoginDialog();
      return;
    }

    final response = await http.get(
      Uri.parse(ApiRoutes.getDashboard),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        assignments = data['data']['assignments'];
        isLoading = false;
        print(assignments);
      });
    } else {
      // _showLoginDialog();
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




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselExample(),
                  SizedBox(height: 10.sp),

                  // _isVisible
                  //     ? CarouselFees(
                  //   status: 'due',
                  //   dueDate: '',
                  //   onPayNow: () {
                  //     // Handle payment logic
                  //   },
                  //   custFirstName: studentData?['student_name'] ?? '',
                  //   custLastName: 'N/A',
                  //   mobile: studentData?['contact_no'] ?? '',
                  //   email: studentData?['email'] ?? '',
                  //   address: studentData?['address'] ?? '',
                  //   payDate: '',
                  //   dueAmount: '0',
                  // )
                  //     : SizedBox(),
                   SizedBox(height: 15.sp),

                  _buildsellAll('Category', ''),

                  _buildGridview(),
                   SizedBox(height: 10.sp),

                  _buildsellAll('Latest Photo', ''),

                  Container(
                    height: 150.sp,
                    width: double.infinity,
                    child:CachedNetworkImage(
                      imageUrl: 'https://webcjm.cjmshimla.in/upload/banners/1740211256_cjmshimlabanner3.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Center(
                        child: CupertinoActivityIndicator(radius: 20, color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(Icons.image, color: Colors.red),
                      ),
                      fadeInDuration: Duration.zero, // Removes fade-in effect
                    ),



                  ),
                  Divider(
                    thickness: 1.sp,
                    color: Colors.grey,
                  ),
                  Container(
                    height: 150.sp,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: 'https://webcjm.cjmshimla.in/upload/banners/1740211232_cjmshimlabanner1.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Center(
                        child: CupertinoActivityIndicator(radius: 20, color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(Icons.image, color: Colors.red),
                      ),
                      fadeInDuration: Duration.zero, // Removes fade-in effect
                    ),

                  ),


                ],
              ),
            ),
    );
  }



  Widget _buildGridview() {
    return Padding(
      padding:  EdgeInsets.all(5.sp),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: items.length,
        // Kitne bhi items set kar sakte hain
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (items[index]['name'] == 'Home Work') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AssignmentListScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Subject') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SubjectScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Gallery') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return GalleryVideoTabScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Report Card') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ReportCardScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'News & Events') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CalendarScreen();
                    },
                  ),
                );
              } else if (items[index]['name'] == 'Time Table') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TimeTableScreen();
                    },
                  ),
                );
              }
            },
            child: Card(
              elevation: 5,
              color: AppColors.primary,
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10)
              // ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      items[index]['image']!,
                      height: 50.sp, // Adjust the size as needed
                      width: 50.sp,
                    ),
                    SizedBox(
                      height: 15.sp,
                    ),
                    Text(
                      items[index]['name']!,
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        color: AppColors.textwhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildsellAll(String title, String see) {
    return Padding(
      padding:  EdgeInsets.only(left: 10.sp, right: 5.sp, bottom: 5.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: MediaQuery.of(context).size.width*0.04,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              color: AppColors.textwhite,
            ),
          ),
          Text(
            see,
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.displayLarge,
              fontSize: MediaQuery.of(context).size.width*0.04,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.normal,
              color: AppColors.textwhite,
            ),
          ),
        ],
      ),
    );
  }
}


class CarouselExample extends StatefulWidget {
  @override
  _CarouselExampleState createState() => _CarouselExampleState();
}

class _CarouselExampleState extends State<CarouselExample> {
  final List<String> imgList = [
    'https://webcjm.cjmshimla.in/upload/banners/1740211232_cjmshimlabanner1.png',
    'https://webcjm.cjmshimla.in/upload/banners/1740211243_cjmshimlabanner2.png',
    'https://webcjm.cjmshimla.in/upload/banners/1740211256_cjmshimlabanner3.png',
  ];

  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carousel
        SizedBox(
          width: MediaQuery.of(context).size.width*095, // Ensure proper width
          child: CarouselSlider(
            controller: _controller,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height*0.18,
              autoPlay: true,
              viewportFraction: 1,
              enableInfiniteScroll: true,
              autoPlayInterval: Duration(seconds: 2),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: imgList.map((item) {
              return Padding(
                padding:  EdgeInsets.all(5.sp),
                child: GestureDetector(
                  onTap: () {
                    print('Image Clicked: $item');
                  },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.sp),
                  child: CachedNetworkImage(
                    imageUrl: item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Center(
                      child: CupertinoActivityIndicator(radius: 20, color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Icon(Icons.image, color: Colors.red),
                    ),
                    fadeInDuration: Duration.zero, // Removes fade-in effect
                  ),
                ),

                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(8.sp),
                  //   child: Image.network(
                  //     item,
                  //     fit: BoxFit.cover,
                  //     width: double.infinity,
                  //     loadingBuilder: (context, child, loadingProgress) {
                  //       if (loadingProgress == null) return child;
                  //       return  Center(
                  //         child: CupertinoActivityIndicator(radius: 20,color: Colors.white,),
                  //       ); // Show loader while loading
                  //     },
                  //     errorBuilder: (context, error, stackTrace) {
                  //       return Center(
                  //           child: Icon(Icons.image,
                  //               color: Colors
                  //                   .red)); // Show error icon if image fails
                  //     },
                  //   ),
                  // ),
                ),
              );
            }).toList(),
          ),
        ),

        // Dots Indicator
        SizedBox(height: 1.sp),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: imgList.length,
          effect: ExpandingDotsEffect(
            dotHeight: 5.sp,
            dotWidth: 12.sp,
            activeDotColor: Colors.redAccent,
            dotColor: Colors.grey.shade400,
          ),
          onDotClicked: (index) {
            _controller.animateToPage(index);
          },
        ),
      ],
    );
  }
}

class CarouselFees extends StatelessWidget {
  final String dueAmount;
  final VoidCallback onPayNow;
  final String status;
  final String dueDate;
  final String payDate;
  final String custFirstName; //optional
  final String custLastName; //optional
  final String mobile; //optional
  final String email; //optional
  final String address;

  final List<Map<String, String>> imgList = [
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Welcome to CJM Ambala'
    },
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Best School for Excellence'
    },
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Learn, Grow & Succeed'
    },
    {
      'image': 'https://cjmambala.in/images/building.png',
      'text': 'Join Our Community'
    },
  ];

   CarouselFees({super.key, required this.dueAmount, required this.onPayNow, required this.status, required this.dueDate, required this.payDate, required this.custFirstName, required this.custLastName, required this.mobile, required this.email, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height*0.18,
            autoPlay: false,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(seconds: 1),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            scrollDirection: Axis.horizontal,
          ),
          items: imgList.map((item) {
            return DueAmountCard(
              dueAmount: dueAmount,
              status: status,
              dueDate: dueDate,
              onPayNow: () {
                // print("Processing payment for ₹${fess[index]['to_pay_amount']}");

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => HomeGateway()),
                // );
              },
              custFirstName: custLastName,
              custLastName: 'N/A',
              mobile: mobile,
              email:email,
              address: address,
              payDate: payDate,
            );

          }).toList(),
        ),
      ),
    );
  }
}

class DueAmountCard extends StatelessWidget {
  final String dueAmount;
  final VoidCallback onPayNow;
  final String status;
  final String dueDate;
  final String payDate;
  final String custFirstName; //optional
  final String custLastName; //optional
  final String mobile; //optional
  final String email; //optional
  final String address;

  DueAmountCard({required this.dueAmount, required this.onPayNow, required this.status, required this.dueDate, required this.payDate, required this.custFirstName, required this.custLastName, required this.mobile, required this.email, required this.address});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.93,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.red, Colors.white, Colors.red], // Gradient Colors
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              "Due Amount",
              style: GoogleFonts.montserrat(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: HexColor('#f62c13'), // Highlight in Yellow
              ),
            ),
            SizedBox(height: 8),

            // Amount
            Text(
              "₹ ${dueAmount}",
              style: GoogleFonts.montserrat(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: HexColor('#f62c13'), // Highlight in Yellow
              ),
            ),
            SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child:GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNavBarScreen(initialIndex: 3,),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.redAccent.shade100,
                      borderRadius: BorderRadius.circular(10.sp)
                  ),
                  child: Center(child: Text('Pay',style: TextStyle(color: Colors.white,fontSize: 16.sp),)),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.textwhite, // You can change the color as needed
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Image.asset(
                AppAssets.logo,
                color: AppColors.textwhite,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '3D Design \nFundamentals',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textwhite,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: HexColor('#e16a54'),
                        // You can change the color as needed
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Click',
                          style: GoogleFonts.montserrat(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: AppColors.textwhite,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
