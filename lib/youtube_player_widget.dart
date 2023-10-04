import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef VideoStatusCallback = void Function(String status);

class YouTubeWebView extends StatefulWidget {
  final String videoId;
  final double height;
  final double width;
  final VideoStatusCallback onVideoStatusChanged;

  const YouTubeWebView({
    super.key,
    required this.videoId,
    this.height = 300.0,
    this.width = 400.0,
    required this.onVideoStatusChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _YouTubeWebViewState createState() => _YouTubeWebViewState();
}

class _YouTubeWebViewState extends State<YouTubeWebView> {
  late InAppWebViewController _webViewController;
  final Completer<void> _loadCompleter = Completer<void>();
  late String htmlData = '';
  bool videoLoadedSuccessfully = false;
  Timer? retryTimer;
  int retryCount = 0;
  int maxRetries = 5;
  @override
  void initState() {
    super.initState();
    // Load the HTML data
    rootBundle.loadString('assets/youtube_template.html').then((data) {
      setState(() {
        htmlData = data;
      });
    });
  }

  @override
  void dispose() {
    retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (htmlData.isEmpty) {
      return const CircularProgressIndicator(); // Show a loader while HTML data is being loaded
    }

    String modifiedHtmlData = htmlData
        .replaceAll('HEIGHT_PLACEHOLDER', '${widget.height * 2}px')
        .replaceAll('WIDTH_PLACEHOLDER', '${widget.width * 2}px')
        .replaceAll('DEFAULT_OR_BLANK_VIDEO_ID', widget.videoId);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width,
      child: InAppWebView(
          initialData: InAppWebViewInitialData(data: modifiedHtmlData),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
            _webViewController.evaluateJavascript(
                source: 'window.bootstrapVideoId = "${widget.videoId}";');

            _webViewController.addJavaScriptHandler(
                handlerName: 'videoStatus',
                callback: (args) {
                  String status = args[0];
                  widget.onVideoStatusChanged(status);
                });
          },
          onLoadStop: (controller, url) async {
            if (!_loadCompleter.isCompleted) {
              final script = '''
              player.loadVideoById("${widget.videoId}");
            ''';
              await _webViewController.evaluateJavascript(source: script);
              videoLoadedSuccessfully = true;
              retryTimer?.cancel();
              _loadCompleter.complete();
            }

            String preventNavigationScript = """
              document.addEventListener('click', function(event) {
                var target = event.target;
                if (target.tagName === 'A') {
                  event.preventDefault();
                }
              });
            """;

            await controller.evaluateJavascript(
                source: preventNavigationScript);
          },
          onLoadError: (controller, url, code, message) {
            videoLoadedSuccessfully = false;
            retryTimer =
                Timer.periodic(const Duration(milliseconds: 500), (timer) {
              if (!videoLoadedSuccessfully && retryCount < maxRetries) {
                controller.reload();
                retryCount++;
              } else {
                timer.cancel();
              }
            });
          },
          shouldOverrideUrlLoading: (controller, navigationAction) {
            var uri = navigationAction.request.url!;

            if (uri.host.contains('youtube.com') &&
                !uri.toString().contains(widget.videoId)) {
              return Future.value(NavigationActionPolicy.CANCEL);
            }
            return Future.value(NavigationActionPolicy.ALLOW);
          }),
    );
  }
}
