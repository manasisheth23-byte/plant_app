import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/models/getproductcode_model.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Dashboard.dart';
import '../../database/database_service.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/add_activity_request_model.dart';
import '../../models/add_activity_response_model.dart';
import '../../utils/CommonUtils.dart';
import 'activity_controller.dart';
import 'activity_list_screen.dart';

class AddNotesScreen extends StatefulWidget {
  LoginResponseModel? loginResponseModel;

  AddNotesScreen({required this.loginResponseModel});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState(loginResponseModel);
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  // Define separate variables for the selected values
  LoginResponseModel? loginResponseModel;
  String? selectSubject;
  String? selectContent;
  _AddNotesScreenState(this.loginResponseModel);


  Map<String, dynamic>? line;

  void _showSnackBar(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      // You can also use Toast.LENGTH_SHORT
      gravity: ToastGravity.BOTTOM,
      // Position of the toast
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showAddedSnackbar(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      // You can also use Toast.LENGTH_SHORT
      gravity: ToastGravity.BOTTOM,
      // Position of the toast
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  Widget _buildTitle(
      String title, {
        bool required = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF12426E),
            ),
          ),
          if (required)
            const Text(
              " *",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
        //  Navigator.pop(context);
         /* Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ActivityListFragment(loginResponseModel: loginResponseModel,)),
          );*/
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  ActivityListFragment(loginResponseModel: loginResponseModel,),
              transitionsBuilder: (_, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child:Center(
          child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: Scaffold(
                  resizeToAvoidBottomInset: false,

                  appBar: AppBar(
            centerTitle: Platform.isWindows ? true : false,
            elevation: 0,
            backgroundColor: const Color(0xFF12426E),
            foregroundColor: Colors.white,
            title: Text('Add Notes',style: GoogleFonts.lato(

              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),),
            actions: [
              IconButton(
                icon: Icon(Icons.check_circle_outline,color: Colors.white,),
                onPressed: () async {
                  if (selectSubject == null || selectSubject!.isEmpty) {
                    _showSnackBar("Please enter Subject");
                    return;
                  } else if (selectContent == null ||
                      selectContent!.isEmpty) {
                    _showSnackBar("Please enter Content");
                    return;
                  }else
                    {
                      AlertDialog alert = AlertDialog(
                        content: Row(children: [
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
                        ]),
                      );

                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                      CommonUtils commonUtils = CommonUtils();
                      bool isConnectivity = await commonUtils.check();
                      if (isConnectivity) {
                        AddActivityRequestModel activityRequestModel = new AddActivityRequestModel();
                        activityRequestModel.xMLFILE = new XMLFILEACTIVITY();
                        activityRequestModel.xMLFILE!.aCTIVITYID = "0";
                        activityRequestModel.xMLFILE!.aSSIGNEDTO = 0;
                        activityRequestModel.xMLFILE!.uSERID = loginResponseModel!.data!.userid!;
                        activityRequestModel.xMLFILE!.cALLPLANTYPEID = 0;
                        activityRequestModel.xMLFILE!.cALLTYPEID = 0;
                        activityRequestModel.xMLFILE!.cONTACTPERSONID = 0;
                        activityRequestModel.xMLFILE!.cONTENT = selectContent;
                        activityRequestModel.xMLFILE!.fLAG = "I";
                        activityRequestModel.xMLFILE!.oRGSTRUCTID =orgStructId;
                        activityRequestModel.xMLFILE!.pOSID = posId;
                        activityRequestModel.xMLFILE!.sUBJECT = selectSubject;
                        activityRequestModel.xMLFILE!.tYPEID = 3;
                        activityRequestModel.xMLFILE!.tOKEN = token;
                        activityRequestModel.xMLFILE!.controlno = controlno;
                        AddActivityResponseModel? response;  response = await Provider.of<ActivityController>(context, listen: false)
                            .AddActivityDetails(activityRequestModel,context);

                        // response = await _repository.getLoginData(loginRequestModel);
            //          await Provider.of<UserProvider>(context, listen: false).login(username, password);
                        if (response != null) {
                          Navigator.pop(context); //for dissmiss progres dialog
                          _showAddedSnackbar(response!.sysmsgs!.errormsgs!.toString());
                         /* Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ActivityListFragment(loginResponseModel: loginResponseModel,)),
                          );*/
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 10),
                              reverseTransitionDuration: const Duration(milliseconds: 10),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  ActivityListFragment(loginResponseModel: loginResponseModel,),
                              transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          Navigator.pop(context); //for dissmiss progres dialog


                        }
                      } else {
                        Navigator.pop(context); //for dissmiss progres dialog
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please check Internet Connection"),
                        ));
                      }
                      }
                },
              ),

              IconButton(
                icon: Icon(Icons.home_outlined,color: Colors.white,),
                onPressed: () {
                 /* Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Dashboard(),));*/
                  final plantName = context.read<PlantProvider>().plantName;
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 10),
                      reverseTransitionDuration: const Duration(milliseconds: 10),
                      pageBuilder: (_, animation, secondaryAnimation) =>
                          AppShell(
                            role: "Admin",
                            plant: plantName,
                            selectedIndex: 0,

                          ),
                      transitionsBuilder: (_, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);

             /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityListFragment(loginResponseModel: loginResponseModel,)),
                );*/
              },
            ),
                  ),
              bottomNavigationBar: NavigationBarTheme(
                data: NavigationBarThemeData(
                  labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                        (states) {
                      if (states.contains(MaterialState.selected)) {
                        return const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        );
                      }
                      return const TextStyle(
                        fontSize: 9,
                      );
                    },
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _idx,
                  onDestinationSelected: (index) async {
                    if (index == 3) {
                      showDialog( context: context, builder: (context) =>
                          AlertDialog( title: const Text("Coming Soon 🚀"),
                            content: const Text( "This feature is under development and will be available soon.", ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text("OK"), ), ], ), ); return; }
                    final plantName = context.read<PlantProvider>().plantName;
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 10),
                        reverseTransitionDuration: const Duration(milliseconds: 10),
                        pageBuilder: (_, animation, secondaryAnimation) =>
                            AppShell(
                              role: "Admin",
                              plant: plantName,
                              selectedIndex: index,

                            ),
                        transitionsBuilder: (_, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
              /*      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppShell(
                          role: "Admin",
                          plant: plantName,
                          selectedIndex: index,

                        ),
                      ),
                    );*/
                  },
                  height: 60,

                  backgroundColor: Colors.white,
                  indicatorColor: C.bluep,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.home_outlined, size: 30),
                      selectedIcon: Icon(Icons.home, color: C.blue, size: 30),
                      label: 'Home',
                    ),

                   /* const NavigationDestination(icon: Icon(Icons.grid_view_outlined,size: 30), selectedIcon: Icon(Icons.grid_view,size: 30, color: C.blue), label: 'Shop Floor'),*/
                    NavigationDestination(
                      icon: Badge( label: Text(unreadProvider.unreadCount.toString()), child: const Icon(Icons.notifications_outlined,size: 30)),
                      selectedIcon: const Icon(Icons.notifications,size: 30, color: C.blue),
                      label: 'Alerts',
                    ),
                    const NavigationDestination(icon: Icon(Icons.bar_chart_outlined,size: 30), selectedIcon: Icon(Icons.bar_chart,size: 30, color: C.blue), label: 'Reports'),
                    const NavigationDestination(icon: Icon(Icons.chat_bubble_outline,size: 30), selectedIcon: Icon(Icons.chat_bubble,size: 30, color: C.blue), label: 'Assistant'),
                    const NavigationDestination(
                      icon: Icon(Icons.person,size: 30),
                      selectedIcon: Icon(Icons.person,size: 30, color: C.blue),
                      label: 'Profile',
                    ),

                    /*const NavigationDestination(
                      icon: Icon(Icons.menu,size: 30),
                      selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                      label: 'More',
                    ),*/

                  ],
                ),
              ),

                  body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(

                   /* width: Platform.isAndroid
                        ? double.infinity                       // FULL width on Android
                        : (MediaQuery.of(context).size.width * 0.40),*/
                    height: Platform.isAndroid
                        ? double.infinity                       // FULL width on Android
                        : (MediaQuery.of(context).size.width * 0.20),
                    decoration: Platform.isAndroid
                        ? null                                   // 🔥 No border on Android
                        : BoxDecoration(
                      color: const Color(0xFFF6F9FC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          _buildTitle("Subject", required: false),
                         /* Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subject',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              Container(
                                width: Platform.isAndroid
                                    ? double.infinity                 // full width on Android
                                    : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                height: Platform.isAndroid
                                    ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                    : MediaQuery.of(context).size.height * 0.055,

                                child: TextFormField(
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Subject',
                                    hintStyle: GoogleFonts.lato(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    selectSubject = value;
                                  },
                                ),
                              ),

                            ],
                          ),*/
                          SizedBox(
                            width: Platform.isAndroid
                                ? double.infinity
                                : MediaQuery.of(context).size.width * 0.40,
                            child: TextFormField(
                              autofocus: false,
                              minLines: 2,
                              maxLines: null,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter Subject",
                                hintStyle: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),

                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.APPCOLOR.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.subject_outlined,
                                    color: AppColors.APPCOLOR,
                                    size: 20,
                                  ),
                                ),

                                filled: true,
                                fillColor: Colors.grey.shade50,

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.APPCOLOR,
                                    width: 1.2,
                                  ),
                                ),

                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) {
                                selectSubject = value;
                              },
                            ),
                          ),
                          SizedBox(height: 10),

                          _buildTitle("Content", required: false),
                          TextFormField(
                            autofocus: false,
                            minLines: 2,
                            maxLines: null,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter Content",
                              hintStyle: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.APPCOLOR.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.description_outlined,
                                  color: AppColors.APPCOLOR,
                                  size: 20,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.APPCOLOR,
                                  width: 1.2,
                                ),
                              ),

                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              selectContent = value;
                            },
                          ),
                         /* Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Content',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              Container(
                                width: Platform.isAndroid
                                    ? double.infinity                 // full width on Android
                                    : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                height: Platform.isAndroid
                                    ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                    : MediaQuery.of(context).size.height * 0.055,

                                child: TextFormField(
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Content',
                                    hintStyle: GoogleFonts.lato(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    selectContent = value;
                                  },
                                ),
                              ),

                            ],
                          ),*/

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
                  ),
                ),
          ),
        ));
  }

  // Validation method

  // Modified buildTextFieldWithLabel to accept onChanged callback
  Widget buildNumericTextFieldWithLabel(
      String label, String hint, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue,
          ),
        ),
        TextFormField(
          autofocus: false,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          onChanged: onChanged,
        ),
        Divider(color: Colors.grey),
      ],
    );
  }
}

// Modify SelectProductCode widget to accept a callback for selected value

