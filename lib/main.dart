import 'dart:io';
import 'package:cjmshimlaparent/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../splash_sreen.dart';
import 'UI/Auth/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart' as html_parser;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'UI/Notification/notification.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyASMmPy8mhABFOGTEHmkI-vv559WTiw814',
        appId: '1:164105009272:android:67e2bc460fd3b44376158d',
        messagingSenderId: '164105009272',
        projectId: 'cjm-shimla-parent',
        storageBucket: "cjm-shimla-parent.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  NotificationService.initNotifications();

  FirebaseMessaging.instance.getToken().then((token) {
    print("🔥 FCM Token: $token");
  });


  // Run app first
  runApp(MyApp(navigatorKey: navigatorKey));

  // Wait 5 seconds then show update dialog
  await Future.delayed(Duration(seconds: 5));
  UpdateChecker.checkForUpdate(navigatorKey.currentContext!);
}


class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // ⬅️ Add this
          home:  SplashScreen(),
        );
      },
    );

  }
}




class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// **🔹 Initialize Notifications**
  static Future<void> initNotifications() async {
    // **Request Permission for Push Notifications**
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Push Notifications Enabled");

      // **Get FCM Token**
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token"); // Send this to your server

      // **Handle Incoming Notifications**
      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

      // **Initialize Local Notifications**
      _initLocalNotifications();
    } else {
      print("❌ Push Notifications Denied");
    }
  }

  /// **🔹 Handle Foreground Notifications**
  static void _onMessage(RemoteMessage message) {
    print("📩 Foreground Notification: ${message.notification?.title}");
    _showLocalNotification(message);
  }

  /// **🔹 Handle Notification Click**
  static void _onMessageOpenedApp(RemoteMessage message) {
    print("📩 Notification Clicked: ${message.notification?.title}");

    // **Navigate to a Specific Screen**
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => NotificationScreen()),
    // );
    // Navigate to the relevant screen based on message.data
  }

  /// **🔹 Handle Background Notifications**
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    print("📩 Background Notification: ${message.notification?.title}");
  }

  /// **🔹 Initialize Local Notifications**
  static void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    _flutterLocalNotificationsPlugin.initialize(settings);
  }

  /// **🔹 Show Local Notification**
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channelId', 'channelName',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails generalNotificationDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      generalNotificationDetails,
    );
  }
}
class UpdateChecker {
  static const String updateApiUrl = "https://yourserver.com/latest_version"; // Backend API URL

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // **Step 1: Get Current App Version**
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      // String latestVersion = '1.0.5';
      // String apkUrl = '';



      // if (_isNewVersionAvailable(currentVersion, latestVersion)) {
      //   _showUpdateDialog(context, apkUrl);
      // }

      // **Step 2: Get Latest Version from API**
      final response = await http.get(Uri.parse(ApiRoutes.updateApk));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String latestVersion = data['data']['version'].toString();
        String apkUrl = data['data']['url'].toString();
        // String releaseNotes = data['data']['release_notes'].toString();
        String releaseNotes = html_parser
            .parse(data['data']['release_notes'].toString())
            .body
            ?.text ??
            '';

        print('Cureent Versuion : $currentVersion');
        print('latestVersion : $latestVersion');


        // **Step 3: Compare Versions**
        if (_isNewVersionAvailable(currentVersion, latestVersion)) {
          _showUpdateDialog(context, apkUrl);
        }

        if (releaseNotes != null && releaseNotes.trim().isNotEmpty && releaseNotes.toLowerCase() != 'null') {
          showNewsDialog(context, releaseNotes, releaseNotes);
        }

      }
    } catch (e) {
      print("Error checking update: $e");
    }
  }

  static bool _isNewVersionAvailable(String current, String latest) {
    List<int> currVer = current.split('.').map(int.parse).toList();
    List<int> latestVer = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestVer.length; i++) {
      if (i >= currVer.length || latestVer[i] > currVer[i]) return true;
      if (latestVer[i] < currVer[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String apkUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.only(top: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
          title: Column(
            children:  [
              SizedBox(height: 25.sp),

              Icon(Icons.system_update, size: 55.sp, color: Colors.blueAccent),
              SizedBox(height: 20.sp),
              Text(
                "New Update Available".toString().toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.sp),

            ],
          ),

          content:  Padding(
            padding:  EdgeInsets.only(bottom: 18.sp),
            child: Text(
              "A new version of the app is available. Please update to continue using the app smoothly.",
              style: TextStyle(fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
          ),

          actions: [
            // Uncomment this if you want a "Later" button
            // TextButton(
            //   onPressed: () => Navigator.pop(context),
            //   child: const Text("Later"),
            // ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                if (await canLaunchUrl(Uri.parse(apkUrl))) {
                  await launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
                } else {
                  print("Could not open APK link.");
                }
              },
              icon: const Icon(Icons.download_rounded,color: Colors.white,),
              label:  Text("Update Now".toString().toUpperCase(),style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600
              ),),
            ),
          ],
        );
      },
    );
  }


  static void showNewsDialog(BuildContext context, String title, String description,) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // News Image

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/construction.gif',
                    height: 100.sp,
                    width: 100.sp,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(height: 16.sp),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600
                  ),
                ),

                SizedBox(height: 20),

                // Dismiss Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close,color: Colors.white,),
                  label: Text("Close",style: TextStyle(color: Colors.white),),
                )
              ],
            ),
          ),
        );
      },
    );
  }

}



class ApkDownloader {
  static Future<void> downloadAndInstallApk(BuildContext context, String apkUrl) async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isDenied) {
        print("Storage permission denied.");
        return;
      }

      // Get device storage directory
      Directory? dir = await getExternalStorageDirectory();
      String filePath = '${dir!.path}/app_latest.apk';

      // Start download
      Dio dio = Dio();
      await dio.download(apkUrl, filePath, onReceiveProgress: (count, total) {
        print("Download Progress: ${(count / total * 100).toStringAsFixed(2)}%");
      });

      // Open the downloaded file to install
      OpenFilex.open(filePath);
    } catch (e) {
      print("Error downloading APK: $e");
    }
  }
}
