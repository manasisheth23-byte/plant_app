import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, rootBundle;

import '../../Dashboard.dart';
import '../../app_colors.dart';

class BoldReportViewerScreenwithparam extends StatefulWidget {
  final String reportServiceUrl;
  final String reportPath;
  final String xmlPayload;
  final String htmlPath;
  final String label;
  const BoldReportViewerScreenwithparam({
    super.key,
    required this.reportServiceUrl,
    required this.reportPath,
    required this.xmlPayload,
    required this.htmlPath,
    required this.label
  });
  @override
  State<BoldReportViewerScreenwithparam> createState() => _BoldReportViewerScreenwithparamState();
}

class _BoldReportViewerScreenwithparamState extends State<BoldReportViewerScreenwithparam> {
  late final WebViewController _controller;

 /* final String xmlPayload = '''
<XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" RULEID="583" USERID="3242" />
  </SPXML>
</XMLFILE>
''';*/

  @override
  void initState() {
    super.initState();

    // Lock orientation to landscape only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    //final htmlContent = await rootBundle.loadString('assets/js/bold_reportwithparameters.html');
    final htmlContent = await rootBundle.loadString(widget.htmlPath);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // Send the XML payload using postMessage
           // String sanitizedXml = widget.xmlPayload.replaceAll('\n', '').replaceAll("'", "\\'");
            String js = """
  window.postMessage(${jsonEncode({
              'reportServiceUrl': widget.reportServiceUrl,
              'reportPath': widget.reportPath,
              'xmlPayload': widget.xmlPayload,
            })}, '*');
""";
            _controller.runJavaScript(js);
           // await _controller.runJavaScript("window.postMessage('$sanitizedXml');");
          },
        ),
      )
     ..loadHtmlString(htmlContent);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        foregroundColor: Colors.white,
        title: Text("Product Wise Skill"),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Dashboard(),
            ));
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
