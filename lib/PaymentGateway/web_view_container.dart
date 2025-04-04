import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../UI/bottom_navigation.dart';
import '../constants.dart';
import 'atom_pay_helper.dart';
import 'package:http/http.dart' as http;

class WebViewContainer extends StatefulWidget {
  final mode;
  final payDetails;
  final responsehashKey;
  final responseDecryptionKey;
  final List<String> selectedFees;
  final String orderId;
  final VoidCallback onReturn;



  WebViewContainer(this.mode, this.payDetails, this.responsehashKey,
      this.responseDecryptionKey, this.selectedFees, this.orderId,   {super.key,required this.onReturn,});

  @override
  createState() => _WebViewContainerState(this.mode, this.payDetails,
      this.responsehashKey, this.responseDecryptionKey);
}

class _WebViewContainerState extends State<WebViewContainer> {
  final mode;
  final payDetails;
  final _responsehashKey;
  final _responseDecryptionKey;
  final _key = UniqueKey();
  late InAppWebViewController _controller;

  final Completer<InAppWebViewController> _controllerCompleter =
      Completer<InAppWebViewController>();

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform  = SurfaceAndroidViewController();

    print('OrderId Webview : ${widget.orderId.toString()}');
    print('OrderId array : ${widget.selectedFees.toString()}');
  }

  _WebViewContainerState(this.mode, this.payDetails, this._responsehashKey,
      this._responseDecryptionKey);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _handleBackButtonAction(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 2,
        ),
        body: SafeArea(
            child: InAppWebView(
          // initialUrl: 'about:blank',
          key: UniqueKey(),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform:
                InAppWebViewOptions(useShouldOverrideUrlLoading: true),
          ),
          onWebViewCreated: (InAppWebViewController inAppWebViewController) {
            _controllerCompleter.future.then((value) => _controller = value);
            _controllerCompleter.complete(inAppWebViewController);

            debugPrint("payDetails from webview $payDetails");
            _loadHtmlFromAssets(mode);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            debugPrint("shouldOverrideUrlLoading called");
            var uri = navigationAction.request.url!;
            debugPrint(uri.scheme);
            if (["upi"].contains(uri.scheme)) {
              debugPrint("UPI URL detected");
              // Launch the App
              await launchUrl(
                uri,
              );
              // and cancel the request
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },

          onLoadStop: (controller, url) async {
            debugPrint("onloadstop_url: $url");

            if (url.toString().contains("AIPAYLocalFile")) {
              debugPrint(" AIPAYLocalFile Now url loaded: $url");
              await _controller.evaluateJavascript(
                  source: "openPay('" + payDetails + "')");
            }

            if (url.toString().contains('/mobilesdk/param')) {
              final String response = await _controller.evaluateJavascript(
                  source: "document.getElementsByTagName('h5')[0].innerHTML");
              debugPrint("HTML response : $response");
              var transactionResult = "";
              var data='';

              if (response.trim().contains("cancelTransaction")) {
                transactionResult = "Transaction Cancelled!";
              } else {
                final split = response.trim().split('|');
                final Map<int, String> values = {
                  for (int i = 0; i < split.length; i++) i: split[i]
                };

                final splitTwo = values[1]!.split('=');
                const platform = MethodChannel('flutter.dev/NDPSAESLibrary');

                try {
                  final String result =
                      await platform.invokeMethod('NDPSAESInit', {
                    'AES_Method': 'decrypt',
                    'text': splitTwo[1].toString(),
                    'encKey': _responseDecryptionKey
                  });
                  var respJsonStr = result.toString();
                  Map<String, dynamic> jsonInput = jsonDecode(respJsonStr);
                  debugPrint("read full respone : $jsonInput");
                  data=jsonInput.toString();


                  //calling validateSignature function from atom_pay_helper file
                  var checkFinalTransaction =
                      validateSignature(jsonInput, _responsehashKey);

                  if (checkFinalTransaction) {
                    if (jsonInput["payInstrument"]["responseDetails"]
                                ["statusCode"] ==
                            'OTS0000' ||
                        jsonInput["payInstrument"]["responseDetails"]
                                ["statusCode"] ==
                            'OTS0551') {
                      debugPrint("Transaction success");
                      transactionResult = "Transaction Success";
                    } else {
                      debugPrint("Transaction failed");
                      transactionResult = "Transaction Failed";
                    }
                  } else {
                    debugPrint("signature mismatched");
                    transactionResult = "failed";
                  }
                  debugPrint("Transaction Response : $jsonInput");
                } on PlatformException catch (e) {
                  debugPrint("Failed to decrypt: '${e.message}'.");
                }
              }
              _closeWebView(context, transactionResult,data.toString());
            }
          },
        )),
      ),
    );
  }

  _loadHtmlFromAssets(mode) async {
    final localUrl =
        mode == 'uat' ? "assets/aipay_uat.html" : "assets/aipay_prod.html";
    String fileText = await rootBundle.loadString(localUrl);
    _controller.loadUrl(
        urlRequest: URLRequest(
            url: Uri.dataFromString(fileText,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))));
  }

  _closeWebView(context, transactionResult,data) {
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // Close current window
    // ignore: use_build_context_synchronously

    if(transactionResult=='Transaction Cancelled!'){
      _showPaymentCanceledDialog(context,data);

    } else if(transactionResult=='Transaction Success'){
      // widget.onReturn();
      print('Ravikant');
      // orderCreate(context, data);

      Future.delayed(Duration(seconds: 5), () {
        widget.onReturn();

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BottomNavBarScreen(initialIndex: 3),
        //   ),
        // );
      });

    }

    else{
      _showPaymentCanceledDialog(context,data);


    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction Status = $transactionResult")));
    print(transactionResult);
  }

  Future<bool> _handleBackButtonAction(BuildContext context) async {
    debugPrint("_handleBackButtonAction called");
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to exit the payment ?'),
              actions: <Widget>[
                // ignore: deprecated_member_use
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                // ignore: deprecated_member_use
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pop(); // Close current window
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Transaction Status = Transaction cancelled")));
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
    return Future.value(true);
  }

  Future<void> orderCreate(BuildContext context, String dataString) async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        print("Error: Token not found");
        return;
      }

      print("Token: $token");

      final url = Uri.parse(ApiRoutes.atompay);

      Map<String, dynamic> body = {
        "fee_ids": widget.selectedFees,
        "order_id": widget.orderId,
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Success: ${response.body}");
        _showPaymentSuccessDialog(context, dataString);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BottomNavBarScreen(initialIndex: 3,),
        //   ),
        // );

      } else {
        print("Failed: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("Unexpected Error: $e");
    }
  }

  void _showPaymentSuccessDialog(BuildContext context,String data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Payment Successful',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:  [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'Your payment has been processed successfully!',
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${data.toString()}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void _showPaymentCanceledDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Transaction Cancelled!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'Your transaction has been canceled.',
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${data.toString()}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

}
