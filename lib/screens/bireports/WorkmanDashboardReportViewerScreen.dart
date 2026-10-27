import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, rootBundle;

import '../../Dashboard.dart';

class Workmandashboardreportviewerscreen extends StatefulWidget {
  @override
  State<Workmandashboardreportviewerscreen> createState() => _WorkmandashboardreportviewerscreenState();
}

class _WorkmandashboardreportviewerscreenState extends State<Workmandashboardreportviewerscreen> {
  late final WebViewController _controller;

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

    // Lock orientation to landscape only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _initializeWebView();
  }


  Future<void> _initializeWebView() async {
    final htmlContent = await rootBundle.loadString('assets/js/bold_reportworkmandashboard.html');

    final xml1 = xmlPayload.replaceAll('\n', '').replaceAll("'", "\\'");
    final xml2 = xmlPayload2.replaceAll('\n', '').replaceAll("'", "\\'");

    final message = jsonEncode({
      'xml1': xml1,
      'xml2': xml2,
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            await _controller.runJavaScript("window.postMessage($message);");
          },
        ),
      )
      ..loadHtmlString(htmlContent);

    setState(() {});
  }

  /*Future<void> _initializeWebView() async {
    final htmlContent = await rootBundle.loadString('assets/js/bold_reportworkmandashboard.html');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // Send the XML payload using postMessage
            String sanitizedXml = xmlPayload.replaceAll('\n', '').replaceAll("'", "\\'");
            await _controller.runJavaScript("window.postMessage('$sanitizedXml');");
          },
        ),
      )
      ..loadHtmlString(htmlContent);

    setState(() {});
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Workmen Dashboard Report"),
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
