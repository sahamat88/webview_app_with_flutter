import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewAppScreen extends StatefulWidget {
  const WebViewAppScreen({super.key});

  @override
  State<WebViewAppScreen> createState() => _WebViewAppScreenState();
}

class _WebViewAppScreenState extends State<WebViewAppScreen> {
  late StreamSubscription<ConnectivityResult> streamSubscription;
  late ConnectivityResult connectivityResult;
  final Connectivity connectivity = Connectivity();
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  var urlController = TextEditingController();
  late dynamic url;
  var initialUrl = "https://www.google.com/";
  double progress = 0;
  bool isLoading = false;

  bool isConnected = false;

  void checkInternet() async {
    connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.wifi) {
      print("internet connected with wifi");
    } else if (connectivityResult == ConnectivityResult.mobile) {
      print("internet connected with mobile data");
    } else {
      setDialog(title: "No internet");
    }
  }

  setDialog({required String title}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
          );
        });
  }

  @override
  void initState() {
    streamSubscription = connectivity.onConnectivityChanged.listen((event) {
      checkInternet();
    });
    pullToRefreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.blue));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              if (await webViewController!.canGoBack()) {
                webViewController!.goBack();
              }
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: TextField(
            // onChanged: (value) {
            //   url = Uri.parse(value);

            //   if (url.scheme.isEmpty) {
            //     url = Uri.parse("${initialUrl}search?q=$value");
            //   }

            //   webViewController!
            //       .loadUrl(urlRequest: URLRequest(url: Uri.parse("$url")));
            // },
            controller: urlController,
            decoration: const InputDecoration(
                hintText: "eg. google.com", prefixIcon: Icon(Icons.search)),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                webViewController!.reload();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
          child: Stack(
        alignment: Alignment.topCenter,
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
                urlController.text = url.toString();
                ;
              });
            },
            onLoadStop: (controller, url) {
              pullToRefreshController!.endRefreshing();

              setState(() {
                isLoading = false;
              });
            },
            pullToRefreshController: pullToRefreshController,
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController!.endRefreshing();
              }

              setState(() {
                this.progress = progress / 100;
              });
            },
          ),
          Visibility(
              visible: isLoading,
              child: LinearProgressIndicator(
                value: progress,
                valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
              ))
        ],
      )),
    );
  }
}
