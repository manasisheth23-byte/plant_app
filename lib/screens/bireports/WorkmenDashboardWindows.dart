import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

class WorkmenDashboardWindowsScreen extends StatefulWidget {
  @override
  _WorkmenDashboardWindowsScreenState createState() => _WorkmenDashboardWindowsScreenState();
}

class _WorkmenDashboardWindowsScreenState extends State<WorkmenDashboardWindowsScreen> {
  // Android controller
  late WebViewController _androidController;

  // Windows controller
  final _windowsController = WebviewController();
  bool _isWindowsWebViewInitialized = false;

  final navigatorKey = GlobalKey<NavigatorState>();

  final String xmlPayload = '''
<XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="4" ORGSTRUCID="0" Ruleid="590" StartDate="2025-06-03T00:00:00" EndDate="2025-06-03T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="0" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>


''';
  final String xmlPayload2 = '''
 <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="5" ORGSTRUCID="0" Ruleid="590" StartDate="2025-06-03T00:00:00" EndDate="2025-06-03T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="0" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>
  ''';


  @override
  void initState() {
    super.initState();
    _initializeWindowsWebView(xmlPayload,xmlPayload2);
  }

  // --- Android WebView ---
  // Declare the controller at the class level


  // --- Windows WebView ---
  Future<void> _initializeWindowsWebView(String xmlPayload, String xmlPayload2) async {
    try {
      await _windowsController.initialize();
      await _windowsController.setBackgroundColor(Colors.white);

      final htmlContent = await rootBundle.loadString('assets/js/bold_reportworkmandashboard.html');
      final uri = Uri.dataFromString(
        htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      );

      await _windowsController.loadUrl(uri.toString());

      // Wait for WebView to fully render the content
      await Future.delayed(Duration(seconds: 5));

      // Sanitize both XML payloads
      final xml1 = xmlPayload.replaceAll('\n', '').replaceAll("'", "\\'");
      final xml2 = xmlPayload2.replaceAll('\n', '').replaceAll("'", "\\'");

      // Encode message as JSON
      final message = jsonEncode({
        'xml1': xml1,
        'xml2': xml2,
      });

      // Send message to the WebView
      await _windowsController.executeScript("window.postMessage($message);");

      setState(() {
        _isWindowsWebViewInitialized = true;
      });
    } catch (e) {
      print('WebView initialization failed: $e');
    }
  }


  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission for "$kind"'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return decision ?? WebviewPermissionDecision.none;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workmen Dashboard Report"),
      ),
      body: Platform.isWindows
          ? _isWindowsWebViewInitialized
          ? Webview(
        _windowsController,
        permissionRequested: _onPermissionRequested,
      )
          : Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _androidController),
    );
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      _windowsController.dispose();
    }
    super.dispose();
  }
}
