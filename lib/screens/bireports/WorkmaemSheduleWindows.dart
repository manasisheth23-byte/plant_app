import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, rootBundle;

import '../../app_colors.dart';

class WorkmenSheduleWindowsScreen  extends StatefulWidget {
  final String reportServiceUrl;
  final String reportPath;
  final String xmlPayload;
  final String htmlPath;
  final String label;
  const WorkmenSheduleWindowsScreen({
    super.key,
    required this.reportServiceUrl,
    required this.reportPath,
    required this.xmlPayload,
    required this.htmlPath,
    required this.label
  });

  @override
  State<WorkmenSheduleWindowsScreen > createState() => _WorkmenSheduleWindowsScreenState();
}

class _WorkmenSheduleWindowsScreenState extends State<WorkmenSheduleWindowsScreen > {
  final _controller = WebviewController();
  bool _isWebViewReady = false;

 /* final String xmlPayload = '''
<XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" RULEID="583" USERID="3242" />
  </SPXML>
</XMLFILE>
''';
*/
  @override
  void initState() {
    super.initState();



    _initializeWebView();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);

      final htmlContent = await rootBundle.loadString(widget.htmlPath);
      await _controller.loadStringContent(htmlContent);

      // Wait for the page to load then send the XML payload
      _controller.loadingState.listen((event) {
        if (event == LoadingState.navigationCompleted) {
          String sanitizedXml = widget.xmlPayload.replaceAll('\n', '').replaceAll("'", "\\'");
// Prepare your parameters
          //String reportServiceUrl = "http://10.0.0.223:8441/api/ReportViewer";
         // String reportPath = "~/BiReports/Product_Wise_Skill.rdl";


// Use jsonEncode to safely serialize to JavaScript
          String js = """
  window.postMessage(${jsonEncode({
            'reportServiceUrl': widget.reportServiceUrl,
            'reportPath': widget.reportPath,
            'xmlPayload': sanitizedXml,
          })}, '*');
""";

// Execute the JavaScript
          _controller.executeScript(js);
         // _controller.executeScript("window.postMessage('$sanitizedXml', '*');");
        }
      });

      setState(() {
        _isWebViewReady = true;
      });
    } catch (e) {
      print('Error initializing WebView: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.APPCOLOR,
          foregroundColor: Colors.white,
          title: Text(widget.label)),
      body: _isWebViewReady
          ? Webview(_controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
