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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:vatandar_iran/data/classes/login_suggestion.dart';

// import 'main.dart';

class WebViewMobileScreen extends StatefulWidget {
  // final (Uri, String) details;
  // final bool hasAppBar;
  WebViewMobileScreen();
  @override
  _WebViewMobileScreenState createState() =>
      _WebViewMobileScreenState();
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
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // contextMenu = ContextMenu(
    //     menuItems: [
    //       ContextMenuItem(
    //           // id: 1,
    //           title: "Special",
    //           action: () async {
    //             print("Menu item Special clicked!");
    //             print(await webViewController?.getSelectedText());
    //             await webViewController?.clearFocus();
    //           })
    //     ],
    //     // settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
    //     onCreateContextMenu: (hitTestResult) async {
    //       print("onCreateContextMenu");
    //       print(hitTestResult.extra);
    //       print(await webViewController?.getSelectedText());
    //     },
    //     onHideContextMenu: () {
    //       print("onHideContextMenu");
    //     },
    //     // onContextMenuActionItemClicked: (contextMenuItemClicked) async {
    //     //   // var id = contextMenuItemClicked.id;
    //     //   print("onContextMenuActionItemClicked: " +
    //     //       id.toString() +
    //     //       " " +
    //     //       contextMenuItemClicked.title);
    //     // }
    //     );

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        if(kIsWeb ? false : await webViewController!.canGoBack()) {
          webViewController?.goBack();
          return false;
        }
        else {
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
          body: SafeArea(
              child: Column(children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        onPermissionRequest:(controller, origin) async {
                          return PermissionResponse(action: PermissionResponseAction.GRANT);
                        },
                        initialUrlRequest: URLRequest(url: WebUri("https://hm-pl.waveitoman.net/indexof/")),
                        initialUserScripts: UnmodifiableListView<UserScript>([]),
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
                                  deepLink.toString().contains("external=true"))) {
                            launchUrl(deepLink,
                                mode: LaunchMode.externalNonBrowserApplication);
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

              ]))),
    );
  }
}

