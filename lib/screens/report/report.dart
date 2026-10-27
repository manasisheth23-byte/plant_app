import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/report/reportview.dart';
import 'package:erpflutter/screens/report/reportviewWindows.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Dashboard.dart';
import '../../models/get_page_sheet_request_model.dart';
import '../../models/get_page_sheet_response_model.dart';
import '../../provider/themecontroller.dart';
import '../../repository/LoginApiRepository.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../login/login_controller.dart';

class Report extends StatefulWidget {

  @override
  _Report createState() => _Report();
}

class _Report extends State<Report> {
  GetBiPageSheetResponseModel getbipagesheetresponsemodel1 =
      new GetBiPageSheetResponseModel();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  String? strUserName;
  String? strUserDesignation;
  GetBiPageSheetResponseModel? getbisheetResponseModel;
  late ThemeController themeController;

  bool searchBarEnabled = false;

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Add listener to searchController
    searchController.addListener(() async {
      // Check if the text field is empty
      if (searchController.text.isEmpty) {
        // Reset the list to the initial data
        setState(() {
          getbisheetResponseModel = null;
        });

        getbisheetResponseModel = await GetBiPageSheetapicall(
          context,
          token ?? '',
          userId ?? '',
          '',
        );

        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getbisheetResponseModel = await GetBiPageSheetapicall(
          context, token ?? '', userId ?? '', '');
      setState(() {});
    });

  }
@override
  void dispose() {
    // TODO: implement dispose

    searchController.text="";
    searchBarEnabled = false;
    getbisheetResponseModel = null;
    super.dispose();
  }
  int _idx = 2;
  @override
  Widget build(BuildContext context) {

    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: themeController.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Consumer<LoginController>(builder: (context, data, _) {

      return Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child:AppBar(
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              title: searchBarEnabled ? Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) async{
                      setState(() {
                        getbisheetResponseModel = null;
                      });

                      if (value != null && value == "" && value.length < 2) {
                      } else {
                        getbisheetResponseModel = await GetBiPageSheetapicall(
                            context,
                            token ?? '',
                            userId ?? '', value);
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () async {
                            setState(() {
                              searchController.text = '';  // Clear the search field
                              searchBarEnabled = false;    // Disable the search bar
                              getbisheetResponseModel = null;  // Clear current list
                            });

                            // Fetch the initial list again without any search filter
                            getbisheetResponseModel = await GetBiPageSheetapicall(
                                context,
                                token ?? '',
                                userId ?? '', '');  // Empty search string to load the full initial list

                            setState(() {});  // Update the UI
                          },
                        ),
                        hintText: 'Search...',
                        border: InputBorder.none),
                  ),
                ),
              ) : Text(
                'Report',
                style:  GoogleFonts.lato(

                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              leading: IconButton(
                icon:  Icon(Icons.arrow_back),
                onPressed: () async{

                    final plantName = context.read<PlantProvider>().plantName;

                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 10),
                        reverseTransitionDuration: const Duration(milliseconds: 10),
                        pageBuilder: (_, animation, secondaryAnimation) =>
                            AppShell(role: "Admin", plant: plantName),
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
                 //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(role: "Admin", plant: plantName)));




                },
              ),
              actions: [
                searchBarEnabled ? Container() : IconButton(onPressed: (){
                  setState(() {
                    searchBarEnabled = true;
                  });
                }, icon: Icon(Icons.search, size: 27))
              ],

            )))),
            resizeToAvoidBottomInset: false,
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
              /*    Navigator.pushReplacement(
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

                  /* const NavigationDestination(
                    icon: Icon(Icons.menu,size: 30),
                    selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                    label: 'More',
                  ),*/

                ],
              ),
            ),
            body: /*Container(
              child: getbisheetResponseModel != null ? getbisheetResponseModel!.data != null ?
              Center(
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    color:const Color(0xFFF5F7FB),
                    width: isDesktop ? 700 : double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          for (int i = 0; i < getbisheetResponseModel!.data!.list.length; i++) ...[
                            Builder(
                              builder: (context) {
                                final color = getMenuColor(
                                  getbisheetResponseModel!.data!.list[i].pagesheetid,
                                );

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 42,
                                    height: 42,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.assessment_outlined,
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    getbisheetResponseModel!.data!.list[i].description ?? '',
                                    style: body(
                                      13.5,
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    getbisheetResponseModel!.data!.list[i].entrydate ?? '',
                                    style: body(
                                      11.5,
                                      c: C.mut,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFFB8C5D4),
                                  ),
                                  onTap: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String? stringValuebaseTOKEN = prefs.getString('TOKEN');
                                    String? stringValuebaseUSERID = prefs.getString('USERID');
                                    Provider.of<LoginController>(context,
                                        listen: false)
                                        .getReportView(
                                        data.UserId,
                                        data.Token,
                                        getbisheetResponseModel!
                                            .data!.list[i].pagesheetid!);
                                    if(Platform.isWindows){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReportViewWindows(
                                            pagesheetId: getbisheetResponseModel!.data!.list[i].pagesheetid!,
                                            userId:stringValuebaseUSERID!,
                                            token:stringValuebaseTOKEN!,
                                          ),
                                        ),
                                      );
                                     *//* Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ReportViewWindows(pagesheetId:  getbisheetResponseModel!
                                                .data!.list[i].pagesheetid!,)),
                                      );*//*
                                    }
                                    else{
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ReportView(  pagesheetId: getbisheetResponseModel!.data!.list[i].pagesheetid!,
                                              userId:stringValuebaseUSERID!,
                                              token:stringValuebaseTOKEN!,)),
                                      );
                                    }

                                  },
                                );
                              },
                            ),
                            const Divider(
                              height: 1,
                              color: Color(0xFFE6EDF5),
                            ),
                          ]
                        ],
                      ),
                    )),
              ) : Center(
                     child: Text("No Records to display")) : Center(child: CircularProgressIndicator())
            ),*/
            getbisheetResponseModel == null
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : (getbisheetResponseModel!.data == null ||
                getbisheetResponseModel!.data!.list == null ||
                getbisheetResponseModel!.data!.list.isEmpty)
                ? const Center(
              child: Text(
                "No Records to display",
                style: TextStyle(fontSize: 16),
              ),
            )
                : Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: isDesktop ? 700 : double.infinity,
                color: const Color(0xFFF5F7FB),
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      for (int i = 0; i < getbisheetResponseModel!.data!.list.length; i++) ...[
                        Builder(
                          builder: (context) {
                            final color = getMenuColor(
                              getbisheetResponseModel!.data!.list[i].pagesheetid,
                            );

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              leading: Container(
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.assessment_outlined,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                getbisheetResponseModel!.data!.list[i].description ?? '',
                                style: body(
                                  13.5,
                                  w: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                getbisheetResponseModel!.data!.list[i].entrydate ?? '',
                                style: body(
                                  11.5,
                                  c: C.mut,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Color(0xFFB8C5D4),
                              ),
                              onTap: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                String? stringValuebaseTOKEN = prefs.getString('TOKEN');
                                String? stringValuebaseUSERID = prefs.getString('USERID');
                                Provider.of<LoginController>(context,
                                    listen: false)
                                    .getReportView(
                                    data.UserId,
                                    data.Token,
                                    getbisheetResponseModel!
                                        .data!.list[i].pagesheetid!);
                                if(Platform.isWindows){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportViewWindows(
                                        pagesheetId: getbisheetResponseModel!.data!.list[i].pagesheetid!,
                                        userId:stringValuebaseUSERID!,
                                        token:stringValuebaseTOKEN!,
                                      ),
                                    ),
                                  );
                                /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => ReportViewWindows(pagesheetId:  getbisheetResponseModel!
                                    .data!.list[i].pagesheetid!,)),
                                );*/
                                }
                                else{
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => ReportView(  pagesheetId: getbisheetResponseModel!.data!.list[i].pagesheetid!,
                                userId:stringValuebaseUSERID!,
                                token:stringValuebaseTOKEN!,)),
                                );
                                }

                              },
                            );
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: Color(0xFFE6EDF5),
                        ),
                      ]

                    ],
                  ),
                ),
              ),
            ),

          ),
        ),
      );
    });
  }
  Color getMenuColor(String? id) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.deepOrange,
      Colors.brown,
    ];

    if (id == null || id.isEmpty) return C.blue;

    return colors[id.hashCode.abs() % colors.length];
  }
  Future<GetBiPageSheetResponseModel> GetBiPageSheetapicall(
      BuildContext context, String strToken, String strUserId, String pageSheetName) async {
    try {
      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        GetBIPageSheetRequestModel fgqualityrequestmodel =
            GetBIPageSheetRequestModel();
        fgqualityrequestmodel.xMLFILE = XMLFILEPAGESHEET();
        fgqualityrequestmodel.xMLFILE!.fLAG = "0";
        fgqualityrequestmodel.xMLFILE!.pAGESHEETID = "0";
        fgqualityrequestmodel.xMLFILE!.pAGESHEETNAME = pageSheetName;
        fgqualityrequestmodel.xMLFILE!.tOKEN = strToken;

        fgqualityrequestmodel.xMLFILE!.uSERID = strUserId;

        getbipagesheetresponsemodel1 =
            await Provider.of<LoginController>(context, listen: false)
                .GetBIPageSheetDetails(context,fgqualityrequestmodel,);
        if (getbipagesheetresponsemodel1 != null) {
        } else {}
      } else {
        return getbipagesheetresponsemodel1;
      }
    } catch (error, stacktrace) {
      // print("Exception occured: $error stackTrace: $stacktrace");
    }
    return getbipagesheetresponsemodel1;
  }
}