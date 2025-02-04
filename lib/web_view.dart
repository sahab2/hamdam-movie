// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:vatandar_iran/data/classes/login_suggestion.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class WebViewMobileScreen extends StatefulWidget {
//   final (Uri, String) details;
//   const WebViewMobileScreen({super.key, required this.details});
//
//   @override
//   State<WebViewMobileScreen> createState() => _WebViewMobileScreenState();
// }
//
// class _WebViewMobileScreenState extends State<WebViewMobileScreen> {
//   double progress = 0;
//   // late InAppWebViewController webView;
//
//   late final WebViewController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     // controller = WebViewController()
//     //   ..setNavigationDelegate(NavigationDelegate(
//     //     onPageStarted: (url) {
//     //       setState(() {
//     //         loadingPercentage = 0;
//     //       });
//     //     },
//     //     onProgress: (progress) {
//     //       setState(() {
//     //         loadingPercentage = progress;
//     //       });
//     //     },
//     //     onPageFinished: (url) {
//     //       setState(() {
//     //         loadingPercentage = 100;
//     //       });
//     //     },
//     //   ))
//     //   ..loadRequest(
//     //     widget.details.$1,
//     //   );
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     // InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
//     //     crossPlatform: InAppWebViewOptions(
//     //       useShouldOverrideUrlLoading: true,
//     //       mediaPlaybackRequiresUserGesture: false,
//     //     ),
//     //     android: AndroidInAppWebViewOptions(
//     //       useHybridComposition: true,
//     //     ),
//     //     ios: IOSInAppWebViewOptions(
//     //       allowsInlineMediaPlayback: true,
//     //     ));
//     return WillPopScope(
//       onWillPop: ()async{
//         await LoginSuggestion.show(context);
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             widget.details.$2,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             InAppWebView(initialUrlRequest: URLRequest(url: widget.details.$1),
//               onProgressChanged: (controller, progress) {
//                 if (progress == 100) {
//                   pullToRefreshController?.endRefreshing();
//                 }
//                 setState(() {
//                   this.progress = progress / 100;
//                   // urlController.text = this.url;
//                 });
//               },
//             //   initialOptions: options,onWebViewCreated: (InAppWebViewController controller) {
//             //   webView = controller;
//             // },
//             //     onProgressChanged:
//             //         (InAppWebViewController controller, int progress) {
//             //       print(progress);
//             //       if (progress == 100) {
//             //         setState(() {
//             //           this.loadingPercentage = (progress / 100).floor();
//             //         });
//             //       }
//             //     },
//                 ),
//             progress < 1.0
//                 ? LinearProgressIndicator(value: progress)
//                 : Container(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
// import 'package:vatandar_iran/data/classes/login_suggestion.dart';

// import 'main.dart';

class WebViewMobileScreen extends StatefulWidget {
  // final (Uri, String) details;
  // final bool hasAppBar;
  WebViewMobileScreen();
  @override
  _WebViewMobileScreenState createState() => _WebViewMobileScreenState();
}

class _WebViewMobileScreenState extends State<WebViewMobileScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  // InAppWebViewSettings settings = InAppWebViewSettings(
  //     isInspectable: kDebugMode,
  //     mediaPlaybackRequiresUserGesture: false,
  //     allowsInlineMediaPlayback: true,
  //     iframeAllow: "camera; microphone",
  //     iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;

  // late ContextMenu contextMenu;
  // String url = "";
  double progress = 0;
  bool isConnectionOk = false;
  bool isLoading = true;
  String url = "https://hm-pl.waveitoman.net/indexof/";
  final urlController = TextEditingController();

  bool containsMediaFormat(String url) {
    // Comprehensive list of supported video and audio file extensions
    final mediaFormats = [
      // Video formats
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.wmv',
      '.flv',
      '.webm',
      '.3gp',
      '.m4v',
      '.ts',
      '.m2ts',
      '.mts',
      '.vob',
      '.ogv',

      // Audio formats
      '.mp3',
      '.wav',
      '.aac',
      '.flac',
      '.ogg',
      '.wma',
      '.m4a',
      '.m4b',
      '.m4p',
      '.opus',
      '.amr',
      '.aiff',
      '.alac',
      '.ape',
      '.mid', // MIDI
      '.midi',
    ];

    // Convert the URL to lowercase to ensure case-insensitive matching
    final lowerCaseUrl = url.toLowerCase();

    // Check if any of the media formats exist in the URL
    for (final format in mediaFormats) {
      if (lowerCaseUrl.endsWith(format)) {
        return true;
      }
    }

    return false;
  }

  Future<void> showInSnackBar(
      String value, BuildContext context, int counter) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: counter),
    ));
    await Future.delayed(Duration(seconds: counter));
    return;
  }

  @override
  void initState() {
    super.initState();

    checkConnection();
    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            // settings: PullToRefreshSettings(
            //   color: Colors.blue,
            // ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  checkConnection() async {
    setState(() {
      isLoading = true;
    });

    if (isLoading) {
      http.Response? response;
      try {
        response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 30));
        setState(() {
          isLoading = false;
          print('status code is ${response?.statusCode}');
          if (response != null && response.statusCode == 200) {
            isConnectionOk = true;
          } else {
            isConnectionOk = false;
          }
        });
      } catch (e) {
        isConnectionOk = false;
        setState(() {
          isLoading = false;
          isConnectionOk = false;
        });
        showInSnackBar(e.toString(), context, 5);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (kIsWeb ? false : await webViewController!.canGoBack()) {
          webViewController?.goBack();
          return false;
        } else {
          // await LoginSuggestion.show(context);
          return true;
        }
      },
      child: Scaffold(
          // appBar: widget.details.$2.isNotEmpty ? AppBar(
          //   title: Text(
          //     widget.details.$2,
          //     style: const TextStyle(
          //       fontSize: 16,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          //   // leading: GestureDetector(onTap: ()async{if(await webViewController!.canGoBack()) webViewController?.goBack();
          //   // else Navigator.pop(context);},child: Icon(Icons.arrow_back)),
          //   // actions: [Icon(Icons.arrow_back)],
          // ):null,
          // drawer: myDrawer(context: context),
          body:  isConnectionOk
              ? SafeArea(
                  child: Column(children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: [
                      Container(
                      width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color.fromRGBO(28, 28, 34, 1),),
                        InAppWebView(
                          key: webViewKey,
                          onPermissionRequest: (controller, origin) async {
                            return PermissionResponse(
                                action: PermissionResponseAction.GRANT);
                          },
                          initialUrlRequest: URLRequest(url: WebUri(url)),
                          initialUserScripts:
                              UnmodifiableListView<UserScript>([]),
                          pullToRefreshController: pullToRefreshController,
                          onWebViewCreated: (controller) async {
                            webViewController = controller;
                          },
                          onLoadStart: (controller, url) async {
                            setState(() {
                              this.url = url.toString();
                              urlController.text = this.url;
                            });
                          },
                          shouldOverrideUrlLoading:
                              (controller, navigationAction) async {
                            final url = await controller.getUrl();
                            final deepLink = navigationAction.request.url;
                            if (deepLink != null &&
                                url != navigationAction.request.url &&
                                ((deepLink.scheme != 'https' &&
                                        deepLink.scheme != 'http') ||
                                    deepLink
                                        .toString()
                                        .contains("external=true") ||
                                    containsMediaFormat(deepLink.toString()))) {
                              launchUrl(deepLink,
                                  mode:
                                      LaunchMode.externalNonBrowserApplication);
                              return NavigationActionPolicy.CANCEL;
                            }
                            return NavigationActionPolicy.ALLOW;
                          },
                          onLoadStop: (controller, url) async {
                            pullToRefreshController?.endRefreshing();
                            setState(() {
                              this.url = url.toString();
                              urlController.text = this.url;
                            });
                          },
                          // onReceivedError: (controller, request, error) {
                          //   pullToRefreshController?.endRefreshing();
                          // },
                          onProgressChanged: (controller, progress) {
                            if (progress == 100) {
                              pullToRefreshController?.endRefreshing();
                            }
                            setState(() {
                              this.progress = progress / 100;
                              urlController.text = this.url;
                            });
                          },
                          onUpdateVisitedHistory: (controller, url, isReload) {
                            setState(() {
                              this.url = url.toString();
                              urlController.text = this.url;
                            });
                          },
                          onConsoleMessage: (controller, consoleMessage) {
                            print(consoleMessage);
                          },
                        ),
                        progress < 1.0
                            ? LinearProgressIndicator(value: progress)
                            : Container(),
                      ],
                    ),
                  ),
                ]))
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromRGBO(28, 28, 34, 1),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: isLoading ? [
                      CupertinoActivityIndicator(color: Colors.white,),
                      SizedBox(height:20),
                      Text('در حال بررسی اینترنت شما',style: TextStyle(color: Colors.white,fontFamily: "yekan",fontSize: 16,fontWeight: FontWeight.bold),textDirection: TextDirection.rtl,textAlign: TextAlign.center,),

                    ]
                        :
                      [
                      Container(
                      padding: EdgeInsets.all(5),
            decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.red.withOpacity(0.2),),
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text(
                          "دسترسی به اینترنت وجود ندارد!\n\nاگر به اینترنت متصل هستید و هنوز مشکل باقیست\nلطفا از فیلتر شکن استفاده کنید و مجدد تلاش کنید.",style: TextStyle(color: Colors.white,fontFamily: "yekan",fontSize: 16,fontWeight: FontWeight.bold),textDirection: TextDirection.rtl,textAlign: TextAlign.center,),
                      SizedBox(height: 15,),
                      ElevatedButton(
                          onPressed: () async {
                            if (!isLoading) await checkConnection();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            backgroundColor: Colors.red.shade100,
                            // side: BorderSide(width: 2, color: Colors.red),
                          ),
                          child: Text("تلاش مجدد",style: TextStyle(fontFamily: "yekan",fontSize: 16,fontWeight: FontWeight.bold)))
                    ],
                  ),
                )),
    );
  }
}
