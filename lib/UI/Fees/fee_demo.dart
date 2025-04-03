import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../CommonCalling/data_not_found.dart';
import '../../CommonCalling/progressbarWhite.dart';
import '../../PaymentGateway/PayButton/pay_button.dart';
import '../../PaymentGateway/atom_pay_helper.dart';
import '../../PaymentGateway/web_view_container.dart';
import '../../constants.dart';
import '../Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeesDemoScreen extends StatefulWidget {
  const FeesDemoScreen({super.key});

  @override
  State<FeesDemoScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesDemoScreen> {
   String createOrderId = ""; //optional

  // merchant configuration data
  final String login = "317157"; //mandatory
  final String password = 'Test@123'; //mandatory
  final String prodid = 'NSE'; //mandatory
  final String requestHashKey = 'd6ab820f036a9bc6c3'; //mandatory
  final String responseHashKey = 'd0b70f551f424ecc57'; //mandatory
  // final String requestEncryptionKey = 'A4476C2062FFA58980DC8F79EB6A799E'; //mandatory
  // final String responseDecryptionKey = '75AEF0FA1B94B3C10D4F5B268F757F11'; //mandatory
  final String txnid = 'test240223'; // mandatory // this should be unique each time
  final String clientcode = "NAVIN"; //mandatory
  final String txncurr = "INR"; //mandatory
  final String mccCode = "8220"; //mandatory
  final String merchType = "R"; //mandatory
  // final String amount = "1.00"; //mandatory

  final String mode = "uat"; // change live for production

  // final String custFirstName = 'test'; //optional
  // final String custLastName = 'user'; //optional
  // final String mobile = '8888888888'; //optional
  // final String email = 'test@gmail.com'; //optional
  // final String address = 'mumbai'; //optional
  final String custacc = '639827'; //optional
  final String udf1 = "udf1"; //optional
  final String udf2 = "udf2"; //optional
  final String udf3 = "udf3"; //optional
  final String udf4 = "udf4"; //optional
  final String udf5 = "udf5"; //optional

  final String authApiUrl = "https://caller.atomtech.in/ots/aipay/auth"; // uat

  final String auth_API_url =
      "https://payment1.atomtech.in/ots/aipay/auth"; // prod

  final String returnUrl =
      "https://pgtest.atomtech.in/mobilesdk/param"; //return url uat
  // final String returnUrl =
  //     "https://payment.atomtech.in/mobilesdk/param"; ////return url production

  final String payDetails = '';

  bool isLoading = false;
  List fees = [];
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? atomData;
  Map<String, dynamic>? atomSession;
  Set<int> selectedFees = {}; // Track selected fee IDs
  double totalAmount = 0.0;
  List<String> selectedFees1 = [];

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void initState() {
    super.initState();
    fetchAtomDataKey();
    fetchFeesData();
  }

  Future<void> fetchAtomDataKey() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("token: $token");



    final response = await http.get(
      Uri.parse(ApiRoutes.getAtomSettings),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        atomData = data['atom_settings'];
        atomSession = data['session'];

        print('Atom data : $atomData');
        print('atomSession : $atomSession');
        isLoading = false;
      });
    } else {
      // _showLoginDialog();
    }
  }



   Future<void> fetchFeesData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');



    final response = await http.get(
      Uri.parse(ApiRoutes.getFees),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fees = data['fees'];
        fetchStudentData();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }


  void _toggleSelection(int id, double amount) {
    setState(() {
      if (selectedFees1.contains(id.toString())) {
        selectedFees1.remove(id.toString());
        totalAmount -= amount;
      } else {
        selectedFees1.add(id.toString());
        totalAmount += amount;
      }
    });
  }

  Future<void> fetchStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    if (token == null) {
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
    }
  }

  Future<void> orderCreate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token: $token");

    final url = Uri.parse(ApiRoutes.orderCreate);

    Map<String, dynamic> body = {
      "fee_ids": selectedFees1 ?? [],
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Adding token here
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Success: ${response.body}");
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          createOrderId = data["order_id"]; // ✅ Correct assignment
          print('OrderId: $createOrderId');
          // orderCreateApi(context);

        });
        _initNdpsPayment(context, responseHashKey, atomData!['decResponseKey'].toString());
      } else {
        print("Failed: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

   Future<void> orderCreateApi(BuildContext context) async {
     final prefs = await SharedPreferences.getInstance();
     final token = prefs.getString('token');
     print("Token: $token");

     final url = Uri.parse(ApiRoutes.atompay);

     Map<String, dynamic> body = {
       "fee_ids": selectedFees1 ?? [],
       "order_id": createOrderId,
     };

     try {
       final response = await http.post(
         url,
         headers: {
           "Content-Type": "application/json",
           "Authorization": "Bearer $token", // Adding token here
         },
         body: jsonEncode(body),
       );

       if (response.statusCode == 200) {
         print("Success: ${response.body}");

         Map<String, dynamic> data = jsonDecode(response.body);

         setState(() {
           print('Susses: $data');
         });
         // _initNdpsPayment(context, responseHashKey, atomData!['decResponseKey'].toString());
       } else {
         print("Failed: ${response.statusCode}, Response: ${response.body}");
       }
     } catch (e) {
       print("Error: $e");
     }
   }

   void _refresh() {
     setState(() {
       fetchFeesData();
       // orderCreateApi(context);
     });
   }



   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: isLoading
          ? WhiteCircularProgressWidget()
          : fees.isEmpty
              ? Center(child: DataNotFoundWidget(title: 'Fees Not Available.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: fees.length,
                        itemBuilder: (context, index) {
                          return PaymentCard(
                            amount: fees[index]['to_pay_amount'].toString(),
                            status: fees[index]['pay_status'],
                            dueDate: fees[index]['due_date'].toString(),
                            payDate: fees[index]['pay_date'].toString(),
                            id: fees[index]['id'],
                            isSelected: selectedFees1
                                .contains(fees[index]['id'].toString()),
                            onSelect: (bool selected) {
                              _toggleSelection(
                                  fees[index]['id'],
                                  double.parse(
                                      fees[index]['to_pay_amount'].toString()));
                              print(selectedFees1);
                            },
                            month: months[index],
                          );
                        },
                      ),
                    ),
                    if (selectedFees1.isNotEmpty &&
                        atomSession!['payment'].toString() == '1')
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            // onPressed: () => _initNdpsPayment(context, responseHashKey, responseDecryptionKey),
                            onPressed: () {
                              orderCreate(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 10.sp),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              '${'Pay'} ${'₹'} ${totalAmount.toString()}',
                              style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }


  void _initNdpsPayment(BuildContext context, String responseHashKey, String responseDecryptionKey) {
    showLoadingDialog(context);
    _getEncryptedPayUrl(context, responseHashKey, responseDecryptionKey);
  }

  _getEncryptedPayUrl(context, responseHashKey, responseDecryptionKey) async {
    String reqJsonData = _getJsonPayloadData();
    debugPrint(reqJsonData);
    print('Json Data : $reqJsonData');
    const platform = MethodChannel('flutter.dev/NDPSAESLibrary');
    try {
      final String result = await platform.invokeMethod('NDPSAESInit', {
        'AES_Method': 'encrypt',
        'text': reqJsonData, // plain text for encryption
        'encKey': atomData!['encRequestKey'].toString() // encryption key
      });
      String authEncryptedString = result.toString();
      // here is result.toString() parameter you will receive encrypted string
      // debugPrint("generated encrypted string: '$authEncryptedString'");

      print('Atom Token : $authEncryptedString');
      _getAtomTokenId(context, authEncryptedString);
    } on PlatformException catch (e) {
      debugPrint("Failed to get encryption string: '${e.message}'.");
    }
  }

  _getAtomTokenId(context, authEncryptedString) async {
    var request = http.Request(
        'POST', Uri.parse("https://payment1.atomtech.in/ots/aipay/auth"));
    request.bodyFields = {'encData': authEncryptedString, 'merchId': atomData!['login'].toString()};

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var authApiResponse = await response.stream.bytesToString();
      debugPrint("API Response: $authApiResponse"); // Log the API response for debugging

      final split = authApiResponse.trim().split('&');
      final Map<int, String> values = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };

      final splitTwo = values[1]!.split('=');
      if (splitTwo[0] == 'encData') {
        const platform = MethodChannel('flutter.dev/NDPSAESLibrary');
        try {
          final String result = await platform.invokeMethod('NDPSAESInit', {
            'AES_Method': 'decrypt',
            'text': splitTwo[1].toString(),
            'encKey': atomData!['decResponseKey'].toString()
          });

          debugPrint("Decrypted Response: $result"); // Log the decrypted response for debugging
          var respJsonStr = result.toString();
          Map<String, dynamic> jsonInput = jsonDecode(respJsonStr);

          hideLoadingDialog(context);
          if (jsonInput["responseDetails"]["txnStatusCode"] == 'OTS0000') {
            final atomTokenId = jsonInput["atomTokenId"].toString();
            if (atomTokenId.isEmpty) {
              debugPrint("Error: Atom Token ID is empty.");
              return; // Handle the case where the token is empty
            }
            debugPrint("atomTokenId: $atomTokenId");
            final String payDetails =
                '{"atomTokenId" : "$atomTokenId","merchId": "${atomData!['login'].toString()}","emailId": "${studentData!['email'].toString()}","mobileNumber":"${studentData!['contact_no'].toString()}", "returnUrl":"$returnUrl"}';
            _openNdpsPG(
                payDetails, context, responseHashKey, atomData!['decResponseKey'].toString());
          } else {
            debugPrint("Problem in auth API response, txnStatusCode: ${jsonInput["responseDetails"]["txnStatusCode"]}");
          }
        } on PlatformException catch (e) {
          debugPrint("Failed to decrypt: '${e.message}'.");
        }
      } else {
        debugPrint("Unexpected response format.");
      }
    } else {
      debugPrint("Failed to connect to the API. Status code: ${response.statusCode}");
    }
  }

  _openNdpsPG(payDetails, context, responseHashKey, responseDecryptionKey) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewContainer(
                mode, payDetails, responseHashKey, responseDecryptionKey,selectedFees1,createOrderId, onReturn: _refresh,)));
  }

  _getJsonPayloadData() {
    var payDetails = {};
    payDetails['login'] = atomData!['login'].toString();
    payDetails['userId'] = '686507';
    payDetails['password'] = atomData!['password'].toString();
    payDetails['prodid'] ='SCHOOL';
    payDetails['custFirstName'] = studentData?['student_name'];
    payDetails['custLastName'] = 'N/A';
    payDetails['amount'] = totalAmount.toString();
    payDetails['mobile'] = studentData!['contact_no'].toString();
    payDetails['address'] = studentData!['address'].toString();
    payDetails['email'] = studentData!['email'].toString();
    payDetails['txnid'] = '${createOrderId}';
    payDetails['custacc'] = custacc;
    payDetails['requestHashKey'] = requestHashKey;
    payDetails['responseHashKey'] = responseHashKey;
    payDetails['requestencryptionKey'] = atomData!['encRequestKey'].toString();
    payDetails['responseencypritonKey'] = atomData!['decResponseKey'].toString();
    payDetails['clientcode'] = clientcode;
    payDetails['txncurr'] = txncurr;
    payDetails['mccCode'] = mccCode;
    payDetails['merchType'] = merchType;
    payDetails['returnUrl'] = returnUrl;
    payDetails['mode'] = mode;
    payDetails['udf1'] = '${studentData?['student_id'].toString()}';
    payDetails['udf2'] = '${createOrderId}';
    payDetails['udf3'] = '${selectedFees1}';
    payDetails['udf4'] = udf4;
    payDetails['udf5'] = udf5;
    String jsonPayLoadData = getRequestJsonData(payDetails);
    return jsonPayLoadData;
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User manually dialog close na kar sake
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:  [
              CircularProgressIndicator(),
              SizedBox(height: 15.sp),
              Text("Please wait...")
            ],
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class PaymentCard extends StatelessWidget {
  final String amount;
  final String status;
  final String dueDate;
  final String payDate;
  final String month;
  final int id;
  final bool isSelected;
  final ValueChanged<bool> onSelect;

  PaymentCard({
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.payDate,
    required this.id,
    required this.isSelected,
    required this.onSelect,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(5),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50.sp,
              width: 50.sp,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${month.substring(0, 3).toUpperCase()}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp), // Optional styling
                    ),
                    Text(
                      status.toLowerCase() == 'paid' ? 'Paid' : 'Due',
                      style: GoogleFonts.montserrat(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        color: status.toLowerCase() == 'paid'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "₹$amount",
              style: GoogleFonts.montserrat(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          status.toLowerCase() == 'paid'
              ? (payDate.length >= 10 ? payDate.substring(0, 10) : payDate)
              : '$dueDate',
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: status.toLowerCase() == 'paid' ? Colors.green : Colors.red,
          ),
        ),
        trailing: status.toLowerCase() == 'paid'
            ? Checkbox(
                onChanged: (bool? value) {
                  if (value != null) {}
                },
                value: true,
                activeColor: Colors.green,
              )
            : Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  if (value != null) {
                    onSelect(value);
                  }
                },
              ),
      ),
    );
  }
}
