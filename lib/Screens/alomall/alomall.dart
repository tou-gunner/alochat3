import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class Alomall extends StatefulWidget {
  const Alomall({Key? key}) : super(key: key);

  @override
  State<Alomall> createState() => _AlomallState();
}

class _AlomallState extends State<Alomall> {
  InAppWebViewController? _controller;
  final _urlController = TextEditingController();
  Uri? _url;
  late PullToRefreshController _pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _controller?.reload();
        } else if (Platform.isIOS) {
          _controller?.loadUrl(
            urlRequest: URLRequest(url: await _controller?.getUrl()));
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse('https://alomall.la/mobile/')
      ),
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
          )
      ),
      pullToRefreshController: _pullToRefreshController,
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onLoadStart: (controller, url) {
        setState(() {
          _url = url;
          _urlController.text = _url!.toString();
        });
      },
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url!;

        if (![ "http", "https", "file", "chrome",
          "data", "javascript", "about"].contains(uri.scheme)) {
          if (await canLaunchUrl(_url!)) {
            // Launch the App
            await launchUrl(_url!);
            // and cancel the request
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
      onLoadStop: (controller, url) async {
        _pullToRefreshController.endRefreshing();
        setState(() {
          _url = url;
          _urlController.text = _url.toString();
        });
      },
      onLoadError: (controller, url, code, message) {
        _pullToRefreshController.endRefreshing();
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          _pullToRefreshController.endRefreshing();
        }
        setState(() {
          this.progress = progress / 100;
          _urlController.text = _url.toString();
        });
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        setState(() {
          _url = url;
          _urlController.text = _url.toString();
        });
      },
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
    );
  }
}
