import 'dart:convert';

import 'package:erpflutter/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Dashboard.dart';
import '../../app_config.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/SalesOrderListModel.dart';
import '../../models/get_approval_list_response_model.dart';
import '../../utils/SizeConfig.dart';
import '../alerts/alerts_list.dart';
import '../login/login_controller.dart';
import 'approvals_details_screen.dart';
import 'approvals_history_details.dart';

class ApprovalView extends StatefulWidget {
  String? webviewurl;
  String? strActivityName;
  LISTAPPROVAL listapprovaldata;
  ApprovalView({required this.webviewurl,required this.listapprovaldata,required this.strActivityName});
  @override
  _ApprovalView createState() => _ApprovalView(webviewurl,listapprovaldata,strActivityName);
}

class _ApprovalView extends State<ApprovalView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  String? webviewurl;
  LISTAPPROVAL listapprovaldata;
  String? strActivityName;

  LoginResponseModel? loginResponseModel;
  _ApprovalView(this.webviewurl,this.listapprovaldata,this.strActivityName);
  final _key = UniqueKey();
  @override
  initState()  {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);



  }






  @override
  Widget build(BuildContext context) {




    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);

    return Consumer<LoginController>(

        builder: (context, data, _) {

          print(webviewurl);
          var controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {
                  // Update loading bar.
                },
                onPageStarted: (String url) {},
                onPageFinished: (String url) {},
                onHttpError: (HttpResponseError error) {},
                onWebResourceError: (WebResourceError error) {},
                onNavigationRequest: (NavigationRequest request) {
                  if (request.url.startsWith(webviewurl!)) {
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
            )
            ..loadRequest(Uri.parse(webviewurl!));
          return PopScope(
            canPop: true,
            onPopInvoked: (didPop) async{
              SharedPreferences prefs = await SharedPreferences.getInstance();

              prefs = await SharedPreferences.getInstance();
              setState(() {
                loginResponseModel = LoginResponseModel.fromJson(
                    jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;

              });
             if(strActivityName != null && strActivityName == "ApprovalDetails")
               {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                       builder: (context) =>
                           ApprovalsDetailsScreen(
                               listapprovaldata, loginResponseModel)),
                 );
               }else  if(strActivityName != null && strActivityName == "ApprovalHistoryDetails")
             {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => ApprovalsHistoryDetailsScreen(listapprovaldata, loginResponseModel)),
               );
             }else
               {
                 Navigator.pop(context);
               }

            },
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: AppColors.APPCOLOR,
                  foregroundColor: Colors.white,
                  title:
                  Text(
                    '', style: TextStyle(fontFamily: 'Roboto'),),

                  automaticallyImplyLeading: false,
                  leading: new IconButton(
                    icon: new Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async{

                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      prefs = await SharedPreferences.getInstance();
                      setState(() {
                        loginResponseModel = LoginResponseModel.fromJson(
                            jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;

                      });

  Navigator.pop(context);


                    },
                  ),
                ),

                resizeToAvoidBottomInset: false,
                body:WebViewWidget(controller: controller)
            ),
          );
        }
    );


  }



}
