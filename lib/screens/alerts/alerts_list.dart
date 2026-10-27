import 'dart:convert';
import 'dart:io';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/helpers/api_helpers.dart';
import 'package:erpflutter/models/getnotificationmodel.dart' as nmodel;
import 'package:erpflutter/Dashboard.dart';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/helpers/api_request.dart';
import 'package:erpflutter/models/LoginResponseModel.dart';
import 'package:erpflutter/models/activity_response_model.dart';
import 'package:erpflutter/models/activity_task_request_model.dart';
import 'package:erpflutter/models/add_task_request_model.dart';
import 'package:erpflutter/models/add_task_response_model.dart';
import 'package:erpflutter/models/get_approval_list_response_model.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/provider/get_notification_provider.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/activity/activity_controller.dart';
import 'package:erpflutter/screens/activity/add_phone_call_screen.dart';
import 'package:erpflutter/screens/activity/edit_event_screen.dart';
import 'package:erpflutter/screens/alerts/NotificationDetailScreen.dart';
import 'package:erpflutter/screens/alerts/approval_edit_screen.dart';
import 'package:erpflutter/screens/alerts/edit_task_alerts_screens.dart';
import 'package:erpflutter/screens/report/reportview.dart' show ReportView;
import 'package:erpflutter/services/ApiProvider.dart';
import 'package:erpflutter/utils/CommonUtils.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/fill_user_list_model.dart';
import '../../models/getnotificationmodel.dart';
import '../../plantappscreen/app_shell.dart';
import '../../provider/themecontroller.dart';
import '../activity/edit_task_screen.dart';
import '../plantlist/plant_provider.dart';
import '../report/reportviewWindows.dart';
class AlertsList extends StatefulWidget {
  final  bool showAppBar ;
  final LoginResponseModel? loginResponseModel;

     AlertsList({
      super.key,
      this.loginResponseModel,
      this.showAppBar = true,
    });


  @override
  State<AlertsList> createState() => _AlertsListState();
}

class _AlertsListState extends State<AlertsList> {
  ActivityResponseModel getactivityresponsemodel1 = ActivityResponseModel();
  ApiProvider getResponse = ApiProvider();
  late final LoginResponseModel? loginResponseModel;

  late ThemeController themeController;

  late NavigatorState _rootNavigator;
  BuildContext? _loaderContext;

  // 🔍 SEARCH ADDITION
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoginData();
      Provider.of<GetNotificationProvider>(context, listen: false)
          .GetNotification("0");
    });
  }
  void getLoginData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    setState(() {
      loginResponseModel = LoginResponseModel.fromJson(
          jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;
    });

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rootNavigator = Navigator.of(context, rootNavigator: true);
  }

  @override
  void dispose() {
    _searchController.dispose(); // 🔍 SEARCH ADDITION
    super.dispose();
  }
  bool _isLoaderShowing = false;
  void showLoader() {
    if (_isLoaderShowing) return;

    _isLoaderShowing = true;

    showDialog(
      context: context, // ❗ use widget context, NOT rootNavigator.context
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
  /*void showLoader() {
    if (_loaderContext != null) return;
    showDialog(
      context: _rootNavigator.context,
      barrierDismissible: false,
      builder: (ctx) {
        _loaderContext = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }*/

/*  void hideLoader() {
    if (_loaderContext != null && _rootNavigator.canPop()) {
      _rootNavigator.pop();
      _loaderContext = null;
    }
  }*/

  void hideLoader() {
    if (!_isLoaderShowing) return;

    _isLoaderShowing = false;

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  DateTime _parseNotificationDate(String? date, String? time) {
    try {
      if (date == null || date.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      final formatter = DateFormat("dd/MM/yyyy HH:mm");
      return formatter.parse("${date.trim()} ${time?.trim() ?? '00:00'}");
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

/*  List<NitificationLIST> _getFilteredNotifications(
      List<NitificationLIST> list) {

    // 🔹 Sort by latest date first
    final sortedList = List<NitificationLIST>.from(list)
      ..sort((a, b) {
        final dateA = _parseNotificationDate(a.nOTIFYDATE, a.notifytime);
        final dateB = _parseNotificationDate(b.nOTIFYDATE, b.notifytime);
        return dateB.compareTo(dateA);
      });

    // 🔹 If no search text, return sorted list
    if (_searchText.trim().isEmpty) return sortedList;

    final query = _searchText.toLowerCase();

    // 🔹 Filter by title, body, notify by
    return sortedList.where((n) {
      return (n.tITLE ?? "").toLowerCase().contains(query) ||
          (n.mSGBODY ?? "").toLowerCase().contains(query) ||
          (n.nOTIFYBYNAME ?? "").toLowerCase().contains(query);
    }).toList();
  }*/

  // 🔽 FILTER
  String _selectedNType = "ALL";


  // ================= BUILD FILTER OPTIONS (NO HARDCODE) =================
  Map<String, String> _buildFilterMap(List<NitificationLIST> list) {
    final Map<String, String> map = {
      "ALL": "All",
    };

    final uniqueItems = list
        .where((e) =>
    e.nTYPE != null &&
        e.nTYPE!.isNotEmpty &&
        e.tITLE != null &&
        e.tITLE!.isNotEmpty)
        .toSet();

    for (final item in uniqueItems) {
      map[item.nTYPE!] = item.tITLE!;
    }

    return map;
  }
    // 🔹 Sort by latest date first
    List<NitificationLIST> _getFilteredNotifications(
        List<NitificationLIST> list)
    {
      // Sort (latest first)
      final sortedList = List<NitificationLIST>.from(list)
        ..sort((a, b) {
          final dateA = _parseNotificationDate(a.nOTIFYDATE, a.notifytime);
          final dateB = _parseNotificationDate(b.nOTIFYDATE, b.notifytime);
          return dateB.compareTo(dateA);
        });

      // Filter by nTYPE
      final typeFilteredList = _selectedNType == "ALL"
          ? sortedList
          : sortedList.where((n) => n.nTYPE == _selectedNType).toList();

      // Search
      if (_searchText.trim().isEmpty) return typeFilteredList;

      final query = _searchText.toLowerCase();

      return typeFilteredList.where((n) {
        return (n.tITLE ?? "").toLowerCase().contains(query) ||
            (n.mSGBODY ?? "").toLowerCase().contains(query) ||
            (n.nOTIFYBYNAME ?? "").toLowerCase().contains(query);
      }).toList();
    }
  int _idx = 1;
    @override
  Widget build(BuildContext context) {
      final isDesktop = MediaQuery.of(context).size.width >= 700;
      themeController = Provider.of(context, listen: false);
      final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
      return  Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: const Color(0xffF5F2F7),
            appBar:widget.showAppBar
                ?  PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child:AppBar(
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon:  Icon(Icons.arrow_back),
                onPressed: () {

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
            /*      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(role: "Admin", plant: plantName)));*/

                },
              ),
              actions: [
                Consumer<GetNotificationProvider>(
                  builder: (context, provider, _) {
                    final list = provider.getNotificationModel?.dATA?.lIST ?? [];
                    final filterMap = _buildFilterMap(list);

                    return Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedNType,
                          dropdownColor: Colors.white,
                          isDense: true,
                        alignment: Alignment.centerRight,
                          padding: EdgeInsets.zero,
                          // 🔥 Icon color
                          icon: const Icon(Icons.filter_list),
                          iconEnabledColor: Colors.white,

                          // 🔥 Style for dropdown menu items
                          style:  TextStyle(
                            color: Colors.black,
                            fontSize: Platform.isIOS ? 17 : 14,
                          ),

                          // 🔥 FIX: Selected text color in AppBar
                          selectedItemBuilder: (BuildContext context) {
                            return filterMap.entries.map((e) {
                              return Align(
                                alignment: Alignment.center,
                                child: Text(
                                  e.value,
                                  style:  TextStyle(
                                    color: Colors.white, // 👈 FIX HERE
                                    fontSize:  Platform.isIOS ? 17 :14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList();
                          },

                          items: filterMap.entries.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(
                                e.value,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),

                          onChanged: (val) {
                            setState(() {
                              _selectedNType = val!;
                            });
                          },
                        ),
                      ),
                    ));
                  },
                ),
              ],



              title:  Text("Alerts", style:
              GoogleFonts.lato(

                color: Colors.white,
                fontSize: Platform.isIOS ? 17 : 14,
                fontWeight: FontWeight.normal,
              )),
            ))))  : null,
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                      (states) {
                    if (states.contains(MaterialState.selected)) {
                      return  TextStyle(
                        fontSize: Platform.isIOS ? 13 : 10,
                        fontWeight: FontWeight.w600,
                      );
                    }
                    return  TextStyle(
                      fontSize: Platform.isIOS ? 12 : 9,
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
                 /* Navigator.pushReplacement(
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
            body: Consumer<GetNotificationProvider>(
              builder: (context, provider, child) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.getNotificationModel?.dATA?.lIST == null ||
                    provider.getNotificationModel!.dATA!.lIST!.isEmpty) {
                  return const Center(child: Text("No notifications available"));
                }

                // 🔍 SEARCH ADDITION
                final notifications = _getFilteredNotifications(
                  provider.getNotificationModel!.dATA!.lIST!,
                );

                return Center(
                    child:Container(
                        height: MediaQuery.of(context).size.height,
                        color:const Color(0xFFF5F7FB),
                        width: isDesktop ? 700 : double.infinity,
                        padding: const EdgeInsets.all(0),
                        child: Column(
                  children: [
                    // 🔍 SEARCH BAR
                    Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:  Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                          height: 40,
                          child:TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search notifications",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchText.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchText = "";
                                _searchController.clear();
                              });
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchText = value.toLowerCase();
                          });
                        },
                      )),
                    )),

                    Expanded(
                      child: notifications.isEmpty
                          ? const Center(
                        child: Text("No matching notifications"),
                      )
                          : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          // ⬇️ ⬇️ ⬇️
                          // 🔴 FROM HERE YOUR ORIGINAL CODE CONTINUES
                          // 🔴 onTap, Card, NotificationTile – UNCHANGED
                          // ⬇️ ⬇️ ⬇️

                          return GestureDetector(
                            onTap: () async {
                              showLoader();

                              try {
                                final prefs = await SharedPreferences.getInstance();
                                final orStID = prefs.getString('ORGSTRUCTID');
                                final controlno = prefs.getString('CONTROLNO');

                                if (notification.ISREAD != "1") {
                                  await getResponse.UpdateNotificationStatus(
                                    _rootNavigator.context,
                                    notification.nID!,
                                  );
                                }
                                int pageSheetId = int.tryParse(notification.pAGESHEETID?? "0") ?? 0;
                                print("*********");
                                print(notification.pAGESHEETID);
                                print(pageSheetId);
                                if(pageSheetId > 0){
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  String? stringValuebaseTOKEN = prefs.getString('TOKEN');
                                  String? stringValuebaseUSERID = prefs.getString('USERID');
                                  hideLoader();

                             /*     Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportView( pagesheetId:notification.pAGESHEETID!,
                                          userId:stringValuebaseUSERID!,
                                          token:stringValuebaseTOKEN!,)),
                                  );*/

                                  if(Platform.isWindows){
                             /*       Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReportViewWindows(
                                          pagesheetId: getbisheetResponseModel!.data!.list[i].pagesheetid!,
                                          userId:stringValuebaseUSERID!,
                                          token:stringValuebaseTOKEN!,
                                        ),
                                      ),
                                    );*/
                                    _rootNavigator.push(
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(milliseconds: 10),
                                        reverseTransitionDuration: const Duration(milliseconds: 10),
                                        pageBuilder: (_, animation, secondaryAnimation) {
                                          return ReportViewWindows(
                                            pagesheetId: notification.pAGESHEETID!,
                                            userId:stringValuebaseUSERID!,
                                            token:stringValuebaseTOKEN!,
                                          );
                                        },
                                        transitionsBuilder: (_, animation, secondaryAnimation,
                                            child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: Offset.zero,
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOutCubic,
                                                ),
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }

                                  else {
                                  _rootNavigator.push(
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 10),
                                      reverseTransitionDuration: const Duration(milliseconds: 10),
                                      pageBuilder: (_, animation, secondaryAnimation) {
                                        return ReportView(pagesheetId: notification.pAGESHEETID!,
                                          userId: stringValuebaseUSERID!,
                                          token: stringValuebaseTOKEN!,);
                                      },
                                      transitionsBuilder: (_, animation, secondaryAnimation,
                                          child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset.zero,
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              ),
                                            ),
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                                }
                                else
                                {
                                  print(notification.nTYPE);
                                  if (notification.nTYPE == "7") {
                                    await GetActivityListapicall(
                                      loginResponseModel!.data!.token,
                                      loginResponseModel!.data!.userid,
                                      orStID!,
                                      loginResponseModel!.data!.posid.toString(),
                                      controlno!,
                                      "",
                                      notification.mID!,
                                    );
                                    hideLoader();
                                  }
                                  else if (notification.nTYPE == "2") {
                                    final prefs = await SharedPreferences.getInstance();
                                    final userID = prefs.getString('USERID');
                                    final token = prefs.getString('TOKEN');
                                    final posID = prefs.getString('POSID');

                                    ActivityTaskRequestModel request =
                                    ActivityTaskRequestModel()
                                      ..xMLFILE = (XMLFILETaskACTIVITY()
                                        ..fLAG = "0"
                                        ..aCTIVITYID = notification.mID
                                        ..tOKEN = token
                                        ..oRGSTRUCTID = orStID
                                        ..pOSID = posID
                                        ..uSERID = userID
                                        ..controlno = controlno);

                                    getactivityresponsemodel1 =
                                    await Provider.of<ActivityController>(
                                        context,
                                        listen: false)
                                        .GetActivityListDetails(request, context);



                                    if (getactivityresponsemodel1?.data?.list == null ||
                                        getactivityresponsemodel1!.data!.list!.isEmpty ||
                                        getactivityresponsemodel1!.data!.list![0].refdocid == '0')
                                    {
                                      hideLoader();
                                      /*      _rootNavigator.pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => EditTaskAlertsScreen(
                                          loginResponseModel: widget.loginResponseModel,
                                          strActivityId: notification.mID,
                                        ),
                                      ),
                                    );
*/
                                      _rootNavigator.pushReplacement(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 10),
                                          reverseTransitionDuration: const Duration(milliseconds: 10),
                                          pageBuilder: (_, animation, secondaryAnimation) {
                                            return EditTaskAlertsScreen(
                                              loginResponseModel:loginResponseModel,
                                              strActivityId: notification.mID,
                                            );
                                          },
                                          transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: Offset.zero,
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );



                                      return;

                                    }
                                    final refDocId = getactivityresponsemodel1!.data!.list![0].refdocid!;

                                    final notificationProvider =
                                    Provider.of<GetNotificationProvider>(context, listen: false);

                                    await notificationProvider.GetNotification(refDocId);
                                    final model = notificationProvider.getNotificationModelDetail;

                                    final notificationItem = model?.dATA?.lIST?.firstWhere(
                                          (e) => e.dOCID == refDocId,
                                      orElse: () => NitificationLIST(),
                                    );
                                    print("@@@@@@");
                                    if (notificationItem == null){
                                      hideLoader();

                                      return;}
                                    // ------------------ SAFE NAVIGATION ------------------

                                    if (notificationItem.nTYPE == "1") {
                                      hideLoader();
                                      /*   _rootNavigator.push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ApprovalsEditScreen(notification, widget.loginResponseModel),
                                      ),
                                    );*/

                                      _rootNavigator.push(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 10),
                                          reverseTransitionDuration: const Duration(milliseconds: 10),
                                          pageBuilder: (_, animation, secondaryAnimation) {
                                            return ApprovalsEditScreen(notification, loginResponseModel);
                                          },
                                          transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: Offset.zero,
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    else if (notificationItem.nTYPE == "2") {
                                      hideLoader();
                                      /*     _rootNavigator.pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => EditTaskAlertsScreen(
                                          loginResponseModel: widget.loginResponseModel,
                                          strActivityId: notification.mID,
                                        ),
                                      ),
                                    );*/
                                      _rootNavigator.pushReplacement(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 10),
                                          reverseTransitionDuration: const Duration(milliseconds: 10),
                                          pageBuilder: (_, animation, secondaryAnimation) {
                                            return EditTaskAlertsScreen(
                                              loginResponseModel: loginResponseModel,
                                              strActivityId: notification.mID,
                                            );
                                          },
                                          transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: Offset.zero,
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );

                                    }
                                    else
                                      if (notificationItem.nTYPE == "7") {

                                      GetActivityListapicall(
                                        loginResponseModel!.data!.token,
                                        loginResponseModel!.data!.userid,
                                        orStID!,
                                        loginResponseModel!.data!.posid.toString(),
                                        controlno!,
                                        "",
                                        notification.mID!,
                                      );
                                      hideLoader();
                                    }
                                    else
                                    {
                                      print("@@@@@@");
                                      hideLoader();
                                      notification.nID = refDocId;
                                      _rootNavigator.push(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 10),
                                          reverseTransitionDuration: const Duration(milliseconds: 10),
                                          pageBuilder: (_, animation, secondaryAnimation) {
                                            return NotificationDetailScreen(
                                              notificationitem: notification,
                                            );
                                          },
                                          transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: Offset.zero,
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                      /*       _rootNavigator.push(
                                      MaterialPageRoute(
                                        builder: (_) => NotificationDetailScreen(
                                          notificationitem: notification,
                                        ),
                                      ),
                                    );*/
                                    }








                                  }

                                  else if (notification.nTYPE == "1") {
                                    GetApprovalListResponseModel? getApprovalListResponseModel;
                                    getApprovalListResponseModel = await getData(notification!);
                                    print(
                                        'getApprovalListResponseModel---------------->${getApprovalListResponseModel!.toJson()}');
                                    //if(getApprovalListResponseModel!.dATA!.lIST != null)
                                    if(getApprovalListResponseModel!.dATA!.lIST ==  null){
                                      hideLoader();
                                      print("2222222222");
                                      _rootNavigator.push(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 10),
                                          reverseTransitionDuration: const Duration(milliseconds: 10),
                                          pageBuilder: (_, animation, secondaryAnimation) {
                                            return NotificationDetailScreen(
                                              notificationitem: notification,
                                            );
                                          },
                                          transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: Offset.zero,
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                      /*    _rootNavigator.push(
                                      MaterialPageRoute(
                                        builder: (_) => NotificationDetailScreen(
                                          notificationitem: notification,
                                        ),
                                      ),
                                    );*/
                                    }else{

                                      // Navigator.of(context, rootNavigator: true).pop();
                                      /* Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ApprovalsEditScreen(notification,widget.loginResponseModel),
                                    ));*/
                                      _rootNavigator.push(
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 10),
                                          reverseTransitionDuration: const Duration(milliseconds: 10),
                                          pageBuilder: (_, animation, secondaryAnimation) {
                                            return ApprovalsEditScreen(notification,loginResponseModel);
                                          },
                                          transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: Offset.zero,
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }

                                  }

                                  else {
                                    hideLoader();
                                    /*    _rootNavigator.push(
                                    MaterialPageRoute(
                                      builder: (_) => NotificationDetailScreen(
                                        notificationitem: notification,
                                      ),
                                    ),
                                  );*/
                                    print("333333");
                                    _rootNavigator.push(
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(milliseconds: 10),
                                        reverseTransitionDuration: const Duration(milliseconds: 10),
                                        pageBuilder: (_, animation, secondaryAnimation) {
                                          return NotificationDetailScreen(
                                            notificationitem: notification,
                                          );
                                        },
                                        transitionsBuilder: (_, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: Offset.zero,
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOutCubic,
                                                ),
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }


                              } catch (e) {
                                hideLoader();
                                print(e.toString());
                                Get.snackbar(
                                  'Error',
                                  e.toString(),
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            child:  NotificationTile(
                                description:
                                notification.nOTIFYBYNAME ?? 'No Subject',
                                subdescription:
                                notification.mSGBODY ?? 'No Title',
                                dateTime:
                                notification.nOTIFYDATE ?? 'Unknown Date',
                                time: notification.notifytime ?? 'Unknown Time',
                                imageAsset: 'assets/meeting.png',
                                titleText: notification.tITLE ?? "",
                                titlecolor: Colors.blue,
                                backgroundColor:
                                notification.ISREAD == "1"
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                isRead: notification.ISREAD!,
                                list: notification,
                                notifyby: notification.nOTIFYBYNAME!,
                                notifybyid: notification.nOTIFYBY!,
                                taskdetails: notification.mSGBODY!,
                              ),

                          );
                        },
                      ),
                    ),
                  ],
                )));
              },
            ),
          ),
        ),
      );
  }

  Future<GetApprovalListResponseModel> getData(nmodel.NitificationLIST data) async {

    var response = await ApiRequest.post(
      url: AppConfig.BASE_URL + GetApprovalList,
      body: json.encode(
        {
          "XMLFILE": {
            "DOCID": data.dOCID,
            "DUEDATE": "",
            "FLAG": "1",
            "FROMDATE": "",
            "MENUID": "0",
            "MID": data.mID,
            "ORGSTRUCTID": orgStructId,
            "PAGENO": 1,
            "POSID": posId,
            "TODATE": "",
            "TOKEN": token,
            "USERID": userId
          }
        },
      ),
    );

    return GetApprovalListResponseModel.fromJson(json.decode(response.body));
  }



  Future<ActivityResponseModel> GetActivityListapicall(
      String strToken,
      String strUserId,
      String strOrgstructId,
      String strPostId,
      String strSearchText,String strActivityId,String nid) async
  {
    try {

      //final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        ActivityTaskRequestModel getactivityrequestmodel = ActivityTaskRequestModel();
        getactivityrequestmodel.xMLFILE = XMLFILETaskACTIVITY();
        getactivityrequestmodel.xMLFILE!.fLAG = "0";
        getactivityrequestmodel.xMLFILE!.aCTIVITYID = nid;
        getactivityrequestmodel.xMLFILE!.dESC = strSearchText;
        getactivityrequestmodel.xMLFILE!.tOKEN = strToken;
        getactivityrequestmodel.xMLFILE!.oRGSTRUCTID = strOrgstructId;
        getactivityrequestmodel.xMLFILE!.pOSID = strPostId;
        getactivityrequestmodel.xMLFILE!.uSERID = strUserId;

        getactivityresponsemodel1 =
        await Provider.of<ActivityController>(context, listen: false)
            .GetActivityListDetails(getactivityrequestmodel, context);
        if (getactivityresponsemodel1 != null) {
          if (getactivityresponsemodel1.data!.list != null && getactivityresponsemodel1.data!.list.length > 0) {
            if (getactivityresponsemodel1!
                .data!.list![0].typeid ==
                "4") {
              hideLoader();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    EditEventScreen(
                      loginResponseModel: loginResponseModel,
                      strActivityId: strActivityId,
                      strActivityName: 'EditEventNotification',
                    ),
              ));
            }else if (getactivityresponsemodel1!
                .data!.list![0].typeid ==
                "1") {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => AddPhoneCallScreen(
                    editPhoneCallInfo:
                    getactivityresponsemodel1!
                        .data!.list![0], loginResponseModel: loginResponseModel,),
                ),
              );

            }
          } else
          {
            _showSnackBar("Data is not available for this notifications",context);
          }


        } else {
          _showSnackBar("Data is not available for this notifications",context);
        }
      } else {
        return getactivityresponsemodel1;
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
    }
    return getactivityresponsemodel1;
  }
  void _showSnackBar(String message,BuildContext context) {

    if (Platform.isAndroid || Platform.isIOS) {
      // ✅ Mobile → use Fluttertoast
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: Platform.isIOS ? 19 : 16.0,
      );
    } else {
      // ✅ Windows / macOS / Linux / Web → use SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

}
class NotificationTile extends StatelessWidget {
  final String dateTime;
  final String description;
  final String subdescription;
  final String time;
  final String imageAsset;
  final String titleText;
  final Color titlecolor;
  final Color backgroundColor;
  final String isRead;
  final String notifyby;
  final String notifybyid;
  final String taskdetails;
  final NitificationLIST list;
  late ThemeController themeController;

  void _showSnackBar(String message,BuildContext context) {

    if (Platform.isAndroid || Platform.isIOS) {
      // ✅ Mobile → use Fluttertoast
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: Platform.isIOS ? 19 : 16.0,
      );
    } else {
      // ✅ Windows / macOS / Linux / Web → use SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

   NotificationTile({
    Key? key,
    required this.dateTime,
    required this.description,
    required this.subdescription,
    required this.time,
    required this.imageAsset,
    required this.titleText,
    required this.titlecolor,
    required this.backgroundColor,
    required this.isRead,
    required this.notifyby,
    required this.notifybyid,
    required this.taskdetails,
    required this.list,
  }) : super(key: key);

  Color getLeftColor() {
    if (list.nTYPE == "1") {
      return Colors.red;
    } else if (list.nTYPE == "2") {
      return Colors.orange;
    } else if (list.nTYPE == "7") {
      return Colors.blue;
    }
    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blueGrey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.10),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Left colored indicator
          Container(
            width: 4,
            height:  isDesktop ? 135 : 160,
            margin: const EdgeInsets.only(
                left: 12, top: 14, bottom: 14),
            decoration: BoxDecoration(
              color: getLeftColor(),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Top Row
                  /// Top Row
            /*      Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Title + Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleText.toUpperCase(),
                              style: TextStyle(
                                color: getLeftColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "$dateTime | $time",
                              style: TextStyle(
                                color: Colors.blueGrey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Forward & Share icons

                    ],
                  ),*/
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleText.toUpperCase(),
                              style: TextStyle(
                                color: getLeftColor(),
                                fontSize: Platform.isIOS ? 14 : 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$dateTime | $time",
                              style: TextStyle(
                                color: Colors.blueGrey.shade600,
                                fontSize: Platform.isIOS ? 15 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Read Status
                      Icon(
                        isRead == "1" ? Icons.done_all : Icons.done,
                        color: isRead == "1" ? Colors.blue : Colors.grey,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  /// Main message
                  Text(
                    subdescription,
                    style:  TextStyle(
                      fontSize: isDesktop ? 17 : 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1E293B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Details
                  Text(
                    "From : $notifyby",
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 17 : 14,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Column(
                    children: [

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //  if(list.nTYPE =="2" || list.nTYPE =="7" || list.nTYPE =="1")...[
                          if(list.nTYPE =="2" )...[
                            /// Forward
                            Align(
                              alignment: Alignment.bottomRight,
                            child: ElevatedButton.icon(
                                  onPressed: () async {

                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        String searchText = "";
                                        List<LISTUSER> fullList = [];
                                        List<LISTUSER> filteredList = [];
                                        String? selectedUserName;
                                        String? selectedUserId;
                                        TextEditingController messageController = TextEditingController();

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return Consumer<ActivityController>(
                                              builder: (context, data, _) {
                                                fullList = data.fillUserListModel?.dATA?.lIST ?? [];
                                                filteredList = searchText.isEmpty
                                                    ? List.from(fullList)
                                                    : fullList
                                                    .where((element) => element.uSERNAME!
                                                    .toLowerCase()
                                                    .contains(searchText.toLowerCase()))
                                                    .toList();

                                                return AlertDialog(
                                                  title: Text('Forward Notification',style: TextStyle(color: const Color(0xFF12426E),fontWeight: FontWeight.w700,),),
                                                  content: Container(
                                                    width: Platform.isAndroid
                                                        ? double.infinity
                                                        : MediaQuery.of(context).size.width * .35,
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // Section: Assigned To
                                                          Text(
                                                            'Assigned To',
                                                            style: TextStyle(
                                                              fontSize: Platform.isIOS ? 19 : 16, fontWeight: FontWeight.w700,),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Container(
                                                            padding: EdgeInsets.all(8),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.grey.shade300),
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: Colors.grey.shade100,
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                TextField(
                                                                  decoration: InputDecoration(
                                                                    labelText: 'Search User',
                                                                    prefixIcon: Icon(Icons.search),
                                                                    border: OutlineInputBorder(),
                                                                  ),
                                                                  onChanged: (value) {
                                                                    if (searchText == value.toLowerCase()) return;
                                                                    setState(() {
                                                                      searchText = value.toLowerCase();
                                                                    });
                                                                    /*setState(() {
                                                      searchText = value;
                                                    });*/
                                                                  },
                                                                ),
                                                                SizedBox(height: 10),
                                                                ConstrainedBox(
                                                                  constraints: BoxConstraints(
                                                                    maxHeight:
                                                                    MediaQuery.of(context).size.height * 0.3,
                                                                  ),
                                                                  child: filteredList.isNotEmpty
                                                                      ? ListView.separated(
                                                                    shrinkWrap: true,
                                                                    physics: const BouncingScrollPhysics(),
                                                                    itemCount: filteredList.length,
                                                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                                                    itemBuilder: (context, index) {
                                                                      final user = filteredList[index];
                                                                      final isSelected = selectedUserName == user.uSERNAME;

                                                                      return InkWell(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                        onTap: () {
                                                                          setState(() {
                                                                            selectedUserName = user.uSERNAME;
                                                                            selectedUserId = user.uSERID;
                                                                          });
                                                                        },
                                                                        child: AnimatedContainer(
                                                                          duration: const Duration(milliseconds: 200),
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal: 14,
                                                                            vertical: 12,
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color: isSelected
                                                                                ? Colors.blue.shade50
                                                                                : Colors.grey.shade50,
                                                                            borderRadius: BorderRadius.circular(16),
                                                                            border: Border.all(
                                                                              color: isSelected
                                                                                  ? Colors.blue
                                                                                  : Colors.grey.shade300,
                                                                              width: isSelected ? 1.5 : 1,
                                                                            ),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.black.withOpacity(0.04),
                                                                                blurRadius: 5,
                                                                                offset: const Offset(0, 2),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child: Row(
                                                                            children: [
                                                                              CircleAvatar(
                                                                                radius: 22,
                                                                                backgroundColor: isSelected
                                                                                    ? Colors.blue
                                                                                    : Colors.blue.shade100,
                                                                                child: Text(
                                                                                  user.uSERNAME!
                                                                                      .substring(0, 1)
                                                                                      .toUpperCase(),
                                                                                  style: TextStyle(
                                                                                    color: isSelected
                                                                                        ? Colors.white
                                                                                        : Colors.blue.shade700,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 14),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  user.uSERNAME ?? "",
                                                                                  style: TextStyle(
                                                                                    fontSize: Platform.isIOS ? 18 : 15,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: isSelected
                                                                                        ? Colors.blue.shade800
                                                                                        : Colors.black87,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              if (isSelected)
                                                                                const Icon(
                                                                                  Icons.check_circle,
                                                                                  color: Colors.blue,
                                                                                  size: 24,
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  )
                                                                      : Center(
                                                                    child: Text(
                                                                      'No users found.',
                                                                      style:
                                                                      TextStyle(color: Colors.grey,fontWeight: FontWeight.w700,),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          SizedBox(height: 20),

                                                          // Section: Message
                                                          Text(
                                                            'Message',
                                                            style: TextStyle(
                                                              fontSize: Platform.isIOS ? 19 : 16, fontWeight: FontWeight.w700,),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Container(
                                                            padding: EdgeInsets.all(8),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.grey.shade300),
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: Colors.grey.shade100,
                                                            ),
                                                            child: TextField(
                                                              controller: messageController,
                                                              decoration: InputDecoration(
                                                                labelText: 'Enter your message',
                                                                border: OutlineInputBorder(),
                                                              ),
                                                              maxLines: 4,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:  Color(0xFF12426E), // Set your desired color here
                                                        foregroundColor: Colors.white, // Text color
                                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                        textStyle: TextStyle(fontSize: Platform.isIOS ? 19 : 16,fontWeight: FontWeight.w700,),
                                                      ),
                                                      child: Text('Cancel'),
                                                      onPressed: () => Navigator.of(context).pop(),
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.ICOLOR, // Set your desired color here
                                                        foregroundColor: Colors.white, // Text color
                                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                        textStyle: TextStyle(fontSize: Platform.isIOS ? 19 : 16,fontWeight: FontWeight.w700,),
                                                      ),

                                                      child: Text('OK'),
                                                      onPressed: () async {
                                                        if(selectedUserName == null && selectedUserId == null){

                                                          _showSnackBar("Please select AssignTo field",context);
                                                          return ;
                                                        }
                                                        else if(messageController.text.isEmpty){
                                                          _showSnackBar("Please enter message",context);
                                                          return;
                                                        }
                                                        else  {
                                                          print(
                                                              'Forwarded to: $selectedUserName (ID: $selectedUserId)');
                                                          print('Message: ${messageController.text}');
                                                          late BuildContext loaderDialogContext;
                                                          AlertDialog alert = AlertDialog(
                                                            content: Row(children: [
                                                              CircularProgressIndicator(
                                                                backgroundColor: Colors.white,
                                                              ),
                                                              Container(
                                                                  margin: EdgeInsets.only(left: 7),
                                                                  child: Text(
                                                                      "Loading...")),
                                                            ]),
                                                          );

                                                          showDialog(
                                                            barrierDismissible: false,
                                                            context: context,
                                                            builder: (BuildContext dialogCtx) {
                                                              loaderDialogContext =
                                                                  dialogCtx; // 💡 Assign it here
                                                              return alert;
                                                            },
                                                          );
                                                          SharedPreferences prefs = await SharedPreferences
                                                              .getInstance();
                                                          String? UserID = prefs.getString('USERID');
                                                          String? OrStID = prefs.getString(
                                                              'ORGSTRUCTID');
                                                          String? Token = prefs.getString('TOKEN');
                                                          String? PosID = prefs.getString('POSID');
                                                          CommonUtils commonUtils = new CommonUtils();
                                                          bool isConnectivity = await commonUtils
                                                              .check();
                                                          if (isConnectivity) {
                                                            if(list.nTYPE =="1"){
                                                              AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                                                              activityRequestModel.xMLFILE =
                                                              new XMLFILETASK();
                                                              activityRequestModel.xMLFILE!.aCTIVITYID =
                                                              "0";
                                                              activityRequestModel.xMLFILE!.aSSIGNEDTO =
                                                                  selectedUserId;

                                                              activityRequestModel.xMLFILE!.tASKDETAILS =
                                                                  messageController.text.toString();
                                                              activityRequestModel.xMLFILE!.fLAG = "E";

                                                              activityRequestModel.xMLFILE!.oRGSTRUCTID =orgStructId;
                                                              activityRequestModel.xMLFILE!.controlno =controlno;
                                                              activityRequestModel.xMLFILE!.pOSID =
                                                                  PosID;

                                                              activityRequestModel.xMLFILE!.tYPEID = 1;
                                                              activityRequestModel.xMLFILE!.tOKEN =
                                                                  Token;


                                                              activityRequestModel.xMLFILE!.uSERID =
                                                                  UserID;
                                                              activityRequestModel.xMLFILE!.rEFDOCID =list.dOCID;
                                                              activityRequestModel.xMLFILE!.rEFMID =list.mID;
                                            /* activityRequestModel.xMLFILE!
                                                .tASKDETAILS = getactivityresponsemodel1.data!.list[0].subject;
                                            */

                                                              AddActivityTaskResponseModel? response;
                                                              response =
                                                              await Provider.of<ActivityController>(
                                                                  context, listen: false)
                                                                  .AddActivityTaskDetails(
                                                                  activityRequestModel, context);
                                                              if(response != null){
                                                                Get.snackbar(
                                                                  'Message',
                                                                  response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                                  snackPosition: SnackPosition.BOTTOM,
                                                                  duration: Duration(seconds: 3),
                                                                );
                                                                Navigator.pop(context);
                                                              }else{
                                                                Get.snackbar(
                                                                  'Message',
                                                                  response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                                  snackPosition: SnackPosition.BOTTOM,
                                                                  duration: Duration(seconds: 3),
                                                                );
                                                              }
                                                            }
                                                            else {
                                                              ActivityResponseModel getactivityresponsemodel1 = new ActivityResponseModel();
                                                              ActivityTaskRequestModel getactivityrequestmodel =
                                                              ActivityTaskRequestModel();
                                                              getactivityrequestmodel.xMLFILE = XMLFILETaskACTIVITY();
                                                              getactivityrequestmodel.xMLFILE!.fLAG = "0";
                                                              getactivityrequestmodel.xMLFILE!.aCTIVITYID = list.mID;
                                                              getactivityrequestmodel.xMLFILE!.dESC = '';
                                                              getactivityrequestmodel.xMLFILE!.tOKEN = Token;
                                                              getactivityrequestmodel.xMLFILE!.oRGSTRUCTID = OrStID;
                                                              getactivityrequestmodel.xMLFILE!.pOSID = PosID;
                                                              getactivityrequestmodel.xMLFILE!.uSERID = UserID;
                                                              getactivityrequestmodel.xMLFILE!.controlno = controlno;
                                                              getactivityresponsemodel1 = await Provider.of<ActivityController>(
                                                                  context,
                                                                  listen: false).GetActivityListDetails(
                                                                  getactivityrequestmodel, context);
                                                              if (getactivityresponsemodel1 != null) {
                                                                //  selectedUserId = getactivityresponsemodel1.data!.list[0].assignedto;
                                                                AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                                                                activityRequestModel.xMLFILE =
                                                                new XMLFILETASK();
                                                                activityRequestModel.xMLFILE!.aCTIVITYID =
                                                                    getactivityresponsemodel1.data!.list[0].activityid;
                                                                activityRequestModel.xMLFILE!.aSSIGNEDTO =
                                                                    selectedUserId;
                                                                activityRequestModel.xMLFILE!
                                                                    .BUSINESSPARTNERID =
                                                                    getactivityresponsemodel1.data!.list[0].businesspartnerid;
                                                                activityRequestModel.xMLFILE!.cONTACT =
                                                                "";
                                                                activityRequestModel.xMLFILE!.rEFDOCID =
                                                                    list.dOCID;
                                                                activityRequestModel.xMLFILE!.rEFMID =
                                                                list.mID;
                                                                activityRequestModel.xMLFILE!.rEMARKS =
                                                                    getactivityresponsemodel1.data!.list[0].remarks;

                                                                activityRequestModel.xMLFILE!.tASKDETAILS =
                                                                    messageController.text.toString();
                                                                activityRequestModel.xMLFILE!.fLAG = "E";

                                                                activityRequestModel.xMLFILE!.oRGSTRUCTID = orgStructId;
                                                                activityRequestModel.xMLFILE!.controlno = controlno;
                                                                activityRequestModel.xMLFILE!.pOSID =
                                                                    PosID;
                                                                activityRequestModel.xMLFILE!.sUBJECT =
                                                                    getactivityresponsemodel1.data!.list[0].subject;
                                                                activityRequestModel.xMLFILE!.tYPEID = 2;
                                                                activityRequestModel.xMLFILE!.tOKEN =
                                                                    Token;
                                                                activityRequestModel.xMLFILE!.sTARTTIME =
                                                                "";
                                                                activityRequestModel.xMLFILE!.eNDTIME =
                                                                "";
                                                                String formattedDate = DateFormat('dd-MMM-yyyy hh:mm a').format(
                                                                    DateFormat('dd-MMM-yyyy hh:mm a').parse(
                                                                        getactivityresponsemodel1.data!.list[0]!.duedate!
                                                                    )
                                                                );
                                                                activityRequestModel.xMLFILE!.dUEDATE = formattedDate;

                                            /*DateTime dueDateTime = DateTime.parse(getactivityresponsemodel1.data!.list[0].duedate!);
                                                                                    activityRequestModel.xMLFILE!.dUEDATE =
                                              DateFormat('dd-MMM-yyyy hh:mm a')
                                                  .format(dueDateTime);*/

                                                                if(list.nTYPE == '2'){
                                                                  activityRequestModel.xMLFILE!.sTATUSID =
                                                                      getactivityresponsemodel1.data!.list[0].statusid;
                                                                  activityRequestModel.xMLFILE!.pRIORITYID =
                                                                      getactivityresponsemodel1.data!.list[0].priorityid;
                                                                }
                                                                else{
                                                                  activityRequestModel.xMLFILE!.sTATUSID =
                                                                  "1";
                                                                  activityRequestModel.xMLFILE!.pRIORITYID =
                                                                  "1";
                                                                }


                                                                activityRequestModel.xMLFILE!.uSERID =
                                                                    UserID;

                                            /* activityRequestModel.xMLFILE!
                                              .tASKDETAILS = getactivityresponsemodel1.data!.list[0].subject;*/


                                                                AddActivityTaskResponseModel? response;
                                                                response =
                                                                await Provider.of<ActivityController>(
                                                                    context, listen: false)
                                                                    .AddActivityTaskDetails(
                                                                    activityRequestModel, context);
                                                                if (response != null){
                                                                  Get.snackbar(
                                                                    'Message',
                                                                    response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                                    snackPosition: SnackPosition.BOTTOM,
                                                                    duration: Duration(seconds: 3),
                                                                  );
                                                                  Navigator.pop(context);
                                                                }else{
                                                                  Get.snackbar(
                                                                    'Message',
                                                                    response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                                    snackPosition: SnackPosition.BOTTOM,
                                                                    duration: Duration(seconds: 3),
                                                                  );
                                                                }
                                                              }
                                                            }

                                                            Navigator.of(context).pop();
                                                          } else {
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(
                                                              SnackBar(content: Text(
                                                                  'Please select a user.')),
                                                            );
                                                          }
                                                        }

                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );


                                    print('Forward icon pressed');
                                    // Add your desired action here

                                  },
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label:  Text(
                                    "Share",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Platform.isIOS ? 19 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeController.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                          ),


                          ],

                          SizedBox(
                          width: 10,
                         ),
                          if(list.nTYPE =="2" || list.nTYPE =="7" || list.nTYPE =="1")...[
                            /// Share

                            ElevatedButton.icon(
                              onPressed: () async{
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    String searchText = "";
                                    List<LISTUSER> fullList = [];
                                    List<LISTUSER> filteredList = [];
                                    String? selectedUserName;
                                    String? selectedUserId;
                                    TextEditingController messageController = TextEditingController();
                                    final screenWidth = MediaQuery.of(context).size.width;
                                    final isDesktop = screenWidth >= 768;

                                    final containerWidth = screenWidth * (isDesktop ? 0.4 : 0.7);
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Consumer<ActivityController>(
                                          builder: (context, data, _) {
                                            fullList = data.fillUserListModel!.dATA!.lIST!;
                                            filteredList = searchText.isEmpty
                                                ? List.from(fullList)
                                                : fullList
                                                .where((element) => element.uSERNAME!
                                                .toLowerCase()
                                                .contains(searchText.toLowerCase()))
                                                .toList();

                                            return AlertDialog(
                                              title: Text('Reply  to $notifyby',style: GoogleFonts.lato(color:  Color(0xFF12426E),fontSize: Platform.isIOS ? 17 : 14,fontWeight: FontWeight.w700,),),
                                              content: Container(
                                                width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.9, // Responsive width
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Section: Assigned To


                                                      SizedBox(height: 10),

                                                      // Section: Message
                                                      Text(
                                                        'Message',
                                                        style: TextStyle(
                                                          fontSize: Platform.isIOS ? 17 : 14, fontWeight: FontWeight.w700,),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        padding: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.grey.shade300),
                                                          borderRadius: BorderRadius.circular(8),
                                                          color: Colors.grey.shade100,
                                                        ),
                                                        child: TextField(
                                                          controller: messageController,
                                                          decoration: InputDecoration(
                                                            labelText: 'Enter your message',
                                                            border: OutlineInputBorder(),
                                                          ),
                                                          maxLines: 4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:  Color(0xFF12426E), // Set your desired color here
                                                    foregroundColor: Colors.white, // Text color
                                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                    textStyle: GoogleFonts.lato(fontSize: Platform.isIOS ? 17 : 14,fontWeight: FontWeight.w700,),
                                                  ),
                                                  child: Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.ICOLOR, // Set your desired color here
                                                    foregroundColor: Colors.white, // Text color
                                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                    textStyle: GoogleFonts.lato(fontSize: Platform.isIOS ? 17 : 14),
                                                  ),
                                                  child: Text('OK'),
                                                  onPressed: () async
                                                  {
                                                    if(messageController.text.isEmpty){
                                                      _showSnackBar("Please enter message",context);
                                                      return;
                                                    }
                                                    else  {
                                                      print(
                                                          'Forwarded to: $selectedUserName (ID: $selectedUserId)');
                                                      print('Message: ${messageController.text}');
                                                      late BuildContext loaderDialogContext;
                                                      AlertDialog alert = AlertDialog(
                                                        content: Row(children: [
                                                          CircularProgressIndicator(
                                                            backgroundColor: Colors.white,
                                                          ),
                                                          Container(
                                                              margin: EdgeInsets.only(left: 7),
                                                              child: Text(
                                                                  "Loading...")),
                                                        ]),
                                                      );

                                                      showDialog(
                                                        barrierDismissible: false,
                                                        context: context,
                                                        builder: (BuildContext dialogCtx) {
                                                          loaderDialogContext =
                                                              dialogCtx; // 💡 Assign it here
                                                          return alert;
                                                        },
                                                      );
                                                      SharedPreferences prefs = await SharedPreferences
                                                          .getInstance();
                                                      String? UserID = prefs.getString('USERID');
                                                      String? OrStID = prefs.getString(
                                                          'ORGSTRUCTID');
                                                      String? Token = prefs.getString('TOKEN');
                                                      String? PosID = prefs.getString('POSID');
                                                      CommonUtils commonUtils = new CommonUtils();
                                                      bool isConnectivity = await commonUtils
                                                          .check();
                                                      if (isConnectivity) {
                                                        if(list.nTYPE =="2" || list.nTYPE =="7"){
                                                          ActivityResponseModel getactivityresponsemodel1 = new ActivityResponseModel();
                                                          ActivityTaskRequestModel getactivityrequestmodel =
                                                          ActivityTaskRequestModel();
                                                          getactivityrequestmodel.xMLFILE = XMLFILETaskACTIVITY();
                                                          getactivityrequestmodel.xMLFILE!.fLAG = "0";
                                                          getactivityrequestmodel.xMLFILE!.aCTIVITYID = list.mID;
                                                          getactivityrequestmodel.xMLFILE!.dESC = '';
                                                          getactivityrequestmodel.xMLFILE!.tOKEN = Token;
                                                          getactivityrequestmodel.xMLFILE!.oRGSTRUCTID = OrStID;
                                                          getactivityrequestmodel.xMLFILE!.pOSID = PosID;

                                                          getactivityrequestmodel.xMLFILE!.uSERID = UserID;
                                                          getactivityrequestmodel.xMLFILE!.controlno = controlno;
                                                          getactivityresponsemodel1 = await Provider.of<ActivityController>(
                                                              context,
                                                              listen: false).GetActivityListDetails(getactivityrequestmodel, context);
                                                          if(getactivityresponsemodel1 != null){

                                                            //  selectedUserId = getactivityresponsemodel1.data!.list[0].assignedto;
                                                            AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                                                            activityRequestModel.xMLFILE =
                                                            new XMLFILETASK();
                                                            activityRequestModel.xMLFILE!.aCTIVITYID =
                                                                getactivityresponsemodel1.data!.list[0].activityid;
                                                            activityRequestModel.xMLFILE!.aSSIGNEDTO =
                                                                notifybyid;
                                                            //activityRequestModel.xMLFILE!.tASKDETAILS =taskdetails;
                                                            activityRequestModel.xMLFILE!
                                                                .BUSINESSPARTNERID = getactivityresponsemodel1.data!.list[0].businesspartnerid;
                                                            activityRequestModel.xMLFILE!.cONTACT =
                                                            "";
                                                            activityRequestModel.xMLFILE!.rEFDOCID =
                                                                list.dOCID;
                                                            activityRequestModel.xMLFILE!.rEFMID =
                                                            list.mID;
                                                            activityRequestModel.xMLFILE!.rEMARKS =getactivityresponsemodel1.data!.list[0].remarks;
                                                            activityRequestModel.xMLFILE!.tASKDETAILS =
                                                                messageController.text.toString();
                                                            activityRequestModel.xMLFILE!.fLAG = "E";

                                                            activityRequestModel.xMLFILE!
                                                                .oRGSTRUCTID = OrStID;
                                                            activityRequestModel.xMLFILE!.pOSID =
                                                                PosID;
                                                            activityRequestModel.xMLFILE!.sUBJECT =
                                                                getactivityresponsemodel1.data!.list[0].subject;
                                                            activityRequestModel.xMLFILE!.tYPEID = 2;
                                                            activityRequestModel.xMLFILE!.tOKEN =
                                                                Token;
                                                            activityRequestModel.xMLFILE!.sTARTTIME =
                                                            "";
                                                            activityRequestModel.xMLFILE!.eNDTIME =
                                                            "";
                                                            String formattedDate = DateFormat('dd-MMM-yyyy hh:mm a').format(
                                                                DateFormat('dd-MMM-yyyy hh:mm a').parse(
                                                                    getactivityresponsemodel1.data!.list[0]!.duedate!
                                                                )
                                                            );
                                                            activityRequestModel.xMLFILE!.dUEDATE = formattedDate;

/*DateTime dueDateTime = DateTime.parse(getactivityresponsemodel1.data!.list[0].duedate!);
                                        activityRequestModel.xMLFILE!.dUEDATE =
                                            DateFormat('dd-MMM-yyyy hh:mm a')
                                                .format(dueDateTime);*/

                                                            activityRequestModel.xMLFILE!.sTATUSID =
                                                                getactivityresponsemodel1.data!.list[0].statusid;
                                                            activityRequestModel.xMLFILE!.pRIORITYID =
                                                                getactivityresponsemodel1.data!.list[0].priorityid;
                                                            activityRequestModel.xMLFILE!.uSERID =
                                                                UserID;

/* activityRequestModel.xMLFILE!
                                              .tASKDETAILS = getactivityresponsemodel1.data!.list[0].subject;
*/

                                                            AddActivityTaskResponseModel? response;
                                                            response =
                                                            await Provider.of<ActivityController>(
                                                                context, listen: false)
                                                                .AddActivityTaskDetails(
                                                                activityRequestModel, context);
                                                            if(response != null){
                                                              Get.snackbar(
                                                                'Message',
                                                                response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                                snackPosition: SnackPosition.BOTTOM,
                                                                duration: Duration(seconds: 3),
                                                              );
                                                              Navigator.pop(context);
                                                            }
                                                          }
                                                        }
                                                        else{
                                                          AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                                                          activityRequestModel.xMLFILE =
                                                          new XMLFILETASK();
                                                          activityRequestModel.xMLFILE!.aCTIVITYID = "0";
                                                          activityRequestModel.xMLFILE!.sTATUSID = '1';
                                                          activityRequestModel.xMLFILE!.pRIORITYID = '1';
                                                          activityRequestModel.xMLFILE!.aSSIGNEDTO =
                                                              notifybyid;
                                                          activityRequestModel.xMLFILE!.dUEDATE =
                                                              DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());

                                                          activityRequestModel.xMLFILE!.tASKDETAILS =
                                                              messageController.text.toString();
                                                          activityRequestModel.xMLFILE!.rEMARKS=  messageController.text.toString();
                                                          activityRequestModel.xMLFILE!.fLAG = "I";

                                                          activityRequestModel.xMLFILE!.oRGSTRUCTID =orgStructId;
                                                          activityRequestModel.xMLFILE!.controlno =controlno;
                                                          activityRequestModel.xMLFILE!.pOSID =
                                                              PosID;
                                                          activityRequestModel.xMLFILE!.sUBJECT =  messageController.text.toString();

                                                          activityRequestModel.xMLFILE!.tYPEID = 2;
                                                          activityRequestModel.xMLFILE!.tOKEN =
                                                              Token;


                                                          activityRequestModel.xMLFILE!.uSERID =
                                                              UserID;
                                                          activityRequestModel.xMLFILE!.rEFDOCID =list.nID;

/* activityRequestModel.xMLFILE!
                                              .tASKDETAILS = getactivityresponsemodel1.data!.list[0].subject;
*/

                                                          AddActivityTaskResponseModel? response;
                                                          response =
                                                          await Provider.of<ActivityController>(
                                                              context, listen: false)
                                                              .AddActivityTaskDetails(
                                                              activityRequestModel, context);
                                                          if(response != null){
                                                            Get.snackbar(
                                                              'Message',
                                                              response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                              snackPosition: SnackPosition.BOTTOM,
                                                              duration: Duration(seconds: 3),
                                                            );
                                                            Navigator.pop(context);
                                                          }
                                                        }



                                                        Navigator.of(context).pop();
                                                      }
                                                      else {
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                          SnackBar(content: Text(
                                                              'No internet.')),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.replay,
                                color: Colors.white,
                                size: 20,
                              ),
                              label:  Text(
                                "Respond",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:  Platform.isIOS ? 19 :16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffD78B25),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            )
                          ]
                          else...[


                            ElevatedButton.icon(
                              onPressed: () async{
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    String searchText = "";
                                    List<LISTUSER> fullList = [];
                                    List<LISTUSER> filteredList = [];
                                    String? selectedUserName;
                                    String? selectedUserId;
                                    TextEditingController messageController = TextEditingController();

                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Consumer<ActivityController>(
                                          builder: (context, data, _) {
                                            fullList = data.fillUserListModel!.dATA!.lIST!;
                                            filteredList = searchText.isEmpty
                                                ? List.from(fullList)
                                                : fullList
                                                .where((element) => element.uSERNAME!
                                                .toLowerCase()
                                                .contains(searchText.toLowerCase()))
                                                .toList();

                                            return AlertDialog(
                                              title: Text('Reply  to $notifyby',style: TextStyle(color:  Color(0xFF12426E)),),
                                              content: Container(
                                                width: isDesktop ? 500 : MediaQuery.of(context).size.width * 0.9, // Responsive width
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Section: Assigned To


                                                      SizedBox(height: 20),

                                                      // Section: Message
                                                      Text(
                                                        'Message',
                                                        style: TextStyle(
                                                            fontSize: Platform.isIOS ? 19 : 16, fontWeight: FontWeight.bold),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        padding: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.grey.shade300),
                                                          borderRadius: BorderRadius.circular(8),
                                                          color: Colors.grey.shade100,
                                                        ),
                                                        child: TextField(
                                                          controller: messageController,
                                                          decoration: InputDecoration(
                                                            labelText: 'Enter your message',
                                                            border: OutlineInputBorder(),
                                                          ),
                                                          maxLines: 4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red, // Set your desired color here
                                                    foregroundColor: Colors.white, // Text color
                                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                    textStyle: TextStyle(fontSize: Platform.isIOS ? 19 : 16),
                                                  ),
                                                  child: Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green, // Set your desired color here
                                                    foregroundColor: Colors.white, // Text color
                                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                    textStyle: TextStyle(fontSize: Platform.isIOS ? 19 : 16),
                                                  ),
                                                  child: Text('OK'),
                                                  onPressed: () async
                                                  {
                                                    if(messageController.text.isEmpty){
                                                      _showSnackBar("Please enter message",context);
                                                      return;
                                                    }
                                                    else  {
                                                      print(
                                                          'Forwarded to: $selectedUserName (ID: $selectedUserId)');
                                                      print('Message: ${messageController.text}');
                                                      late BuildContext loaderDialogContext;
                                                      AlertDialog alert = AlertDialog(
                                                        content: Row(children: [
                                                          CircularProgressIndicator(
                                                            backgroundColor: Colors.white,
                                                          ),
                                                          Container(
                                                              margin: EdgeInsets.only(left: 7),
                                                              child: Text(
                                                                  "Loading...")),
                                                        ]),
                                                      );

                                                      showDialog(
                                                        barrierDismissible: false,
                                                        context: context,
                                                        builder: (BuildContext dialogCtx) {
                                                          loaderDialogContext =
                                                              dialogCtx; // 💡 Assign it here
                                                          return alert;
                                                        },
                                                      );
                                                      SharedPreferences prefs = await SharedPreferences
                                                          .getInstance();
                                                      String? UserID = prefs.getString('USERID');
                                                      String? OrStID = prefs.getString(
                                                          'ORGSTRUCTID');
                                                      String? Token = prefs.getString('TOKEN');
                                                      String? PosID = prefs.getString('POSID');
                                                      CommonUtils commonUtils = new CommonUtils();
                                                      bool isConnectivity = await commonUtils
                                                          .check();
                                                      if (isConnectivity) {
                                                        if(list.nTYPE =="2" || list.nTYPE =="7"){
                                                          ActivityResponseModel getactivityresponsemodel1 = new ActivityResponseModel();
                                                          ActivityTaskRequestModel getactivityrequestmodel =
                                                          ActivityTaskRequestModel();
                                                          getactivityrequestmodel.xMLFILE = XMLFILETaskACTIVITY();
                                                          getactivityrequestmodel.xMLFILE!.fLAG = "0";
                                                          getactivityrequestmodel.xMLFILE!.aCTIVITYID = list.mID;
                                                          getactivityrequestmodel.xMLFILE!.dESC = '';
                                                          getactivityrequestmodel.xMLFILE!.tOKEN = Token;
                                                          getactivityrequestmodel.xMLFILE!.oRGSTRUCTID = OrStID;
                                                          getactivityrequestmodel.xMLFILE!.pOSID = PosID;
                                                          getactivityrequestmodel.xMLFILE!.uSERID = UserID;
                                                          getactivityrequestmodel.xMLFILE!.controlno = controlno;
                                                          getactivityresponsemodel1 = await Provider.of<ActivityController>(
                                                              context,
                                                              listen: false).GetActivityListDetails(getactivityrequestmodel, context);
                                                          if(getactivityresponsemodel1 != null){

                                                            //  selectedUserId = getactivityresponsemodel1.data!.list[0].assignedto;
                                                            AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                                                            activityRequestModel.xMLFILE =
                                                            new XMLFILETASK();
                                                            activityRequestModel.xMLFILE!.aCTIVITYID =
                                                                getactivityresponsemodel1.data!.list[0].activityid;
                                                            activityRequestModel.xMLFILE!.aSSIGNEDTO =
                                                                notifybyid;
                                                            //activityRequestModel.xMLFILE!.tASKDETAILS =taskdetails;
                                                            activityRequestModel.xMLFILE!
                                                                .BUSINESSPARTNERID = getactivityresponsemodel1.data!.list[0].businesspartnerid;
                                                            activityRequestModel.xMLFILE!.cONTACT =
                                                            "";
                                                            activityRequestModel.xMLFILE!.rEFDOCID =
                                                                list.dOCID;
                                                            activityRequestModel.xMLFILE!.rEFMID =
                                                            list.mID;
                                                            activityRequestModel.xMLFILE!.rEMARKS =getactivityresponsemodel1.data!.list[0].remarks;
                                                            activityRequestModel.xMLFILE!.tASKDETAILS =
                                                                messageController.text.toString();
                                                            activityRequestModel.xMLFILE!.fLAG = "E";

                                                            activityRequestModel.xMLFILE!
                                                                .oRGSTRUCTID = OrStID;
                                                            activityRequestModel.xMLFILE!.pOSID =
                                                                PosID;
                                                            activityRequestModel.xMLFILE!.sUBJECT =
                                                                getactivityresponsemodel1.data!.list[0].subject;
                                                            activityRequestModel.xMLFILE!.tYPEID = 2;
                                                            activityRequestModel.xMLFILE!.tOKEN =
                                                                Token;
                                                            activityRequestModel.xMLFILE!.controlno = controlno;
                                                            activityRequestModel.xMLFILE!.sTARTTIME =
                                                            "";
                                                            activityRequestModel.xMLFILE!.eNDTIME =
                                                            "";
                                                            String formattedDate = DateFormat('dd-MMM-yyyy hh:mm a').format(
                                                                DateFormat('dd-MMM-yyyy hh:mm a').parse(
                                                                    getactivityresponsemodel1.data!.list[0]!.duedate!
                                                                )
                                                            );
                                                            activityRequestModel.xMLFILE!.dUEDATE = formattedDate;

/*DateTime dueDateTime = DateTime.parse(getactivityresponsemodel1.data!.list[0].duedate!);
                                        activityRequestModel.xMLFILE!.dUEDATE =
                                            DateFormat('dd-MMM-yyyy hh:mm a')
                                                .format(dueDateTime);*/

                                                            if(list.nTYPE =="7"){
                                                              activityRequestModel.xMLFILE!
                                                                  .sTATUSID = "1";
                                                            }else {
                                                              activityRequestModel.xMLFILE!
                                                                  .sTATUSID =
                                                                  getactivityresponsemodel1.data!
                                                                      .list[0].statusid;
                                                            }if(list.nTYPE =="7"){
                                                              activityRequestModel.xMLFILE!
                                                                  .pRIORITYID = "1";
                                                            }else {
                                                              activityRequestModel.xMLFILE!
                                                                  .pRIORITYID =
                                                                  getactivityresponsemodel1.data!
                                                                      .list[0].priorityid;
                                                            }
                                                            activityRequestModel.xMLFILE!.uSERID =
                                                                UserID;

/* activityRequestModel.xMLFILE!
                                              .tASKDETAILS = getactivityresponsemodel1.data!.list[0].subject;
*/

                                                            AddActivityTaskResponseModel? response;
                                                            response =
                                                            await Provider.of<ActivityController>(
                                                                context, listen: false)
                                                                .AddActivityTaskDetails(
                                                                activityRequestModel, context);
                                                            if(response != null){
                                                              Get.snackbar(
                                                                'Message',
                                                                response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                                snackPosition: SnackPosition.BOTTOM,
                                                                duration: Duration(seconds: 3),
                                                              );

/*ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  response.sysmsgs?.errormsgs?.toString() ?? 'Success',
                                                ),
                                              ),
                                            );*/


                                                              Navigator.pop(context);

                                                            }else{
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    response.sysmsgs?.errormsgs?.toString() ?? '',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        }
                                                        else{
                                                          AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                                                          activityRequestModel.xMLFILE =
                                                          new XMLFILETASK();
                                                          activityRequestModel.xMLFILE!.aCTIVITYID =
                                                          "0";
                                                          activityRequestModel.xMLFILE!.aSSIGNEDTO =
                                                              notifybyid;
                                                          activityRequestModel.xMLFILE!.BUSINESSPARTNERID ="";
                                                          activityRequestModel.xMLFILE!.sTATUSID ="1";
                                                          activityRequestModel.xMLFILE!.pRIORITYID ="1";
                                                          activityRequestModel.xMLFILE!.dUEDATE="";
                                                          activityRequestModel.xMLFILE!.cONTACT="";
                                                          activityRequestModel.xMLFILE!.sUBJECT="";
                                                          activityRequestModel.xMLFILE!.rEFDOCID = list.dOCID;
                                                          activityRequestModel.xMLFILE!.rEFMID = list.mID;
                                                          activityRequestModel.xMLFILE!.sTARTTIME ="";
                                                          activityRequestModel.xMLFILE!.eNDTIME = "";
                                                          activityRequestModel.xMLFILE!.tASKDETAILS =
                                                              messageController.text.toString();
                                                          activityRequestModel.xMLFILE!.fLAG = "I";

                                                          activityRequestModel.xMLFILE!
                                                              .oRGSTRUCTID = OrStID;
                                                          activityRequestModel.xMLFILE!.pOSID =
                                                              PosID;
                                                          activityRequestModel.xMLFILE!.controlno=controlno;
                                                          activityRequestModel.xMLFILE!.tYPEID = 2;
                                                          activityRequestModel.xMLFILE!.tOKEN =
                                                              Token;


                                                          activityRequestModel.xMLFILE!.uSERID =
                                                              UserID;

/* activityRequestModel.xMLFILE!
                                              .tASKDETAILS = getactivityresponsemodel1.data!.list[0].subject;
*/

                                                          AddActivityTaskResponseModel? response;
                                                          response =
                                                          await Provider.of<ActivityController>(
                                                              context, listen: false)
                                                              .AddActivityTaskDetails(
                                                              activityRequestModel, context);
                                                          if(response != null){
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(
                                                              SnackBar(content: Text(
                                                                  response!.sysmsgs!.errormsgs!.toString())),
                                                            );

                                                            Navigator.pop(context);
                                                          }
                                                        }



                                                        Navigator.of(context).pop();
                                                      }
                                                      else {
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                          SnackBar(content: Text(
                                                              'No internet.')),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.replay,
                                color: Colors.white,
                                size: 20,
                              ),
                              label:  Text(
                                "Respond",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Platform.isIOS ? 19 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffD78B25),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                             SizedBox(width: 10),
                            const Spacer(),
                            // DELETE BUTTON
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () async {
                                  final bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: Text(
                                          'Dismiss Notification',
                                          style: TextStyle(
                                            color: const Color(0xFF12426E),
                                            fontWeight: FontWeight.w700,
                                            fontSize: Platform.isIOS ? 20 : 17,
                                          ),
                                        ),
                                        content: Text(
                                          'Are you sure you want to Dismiss this notification?',
                                          style: TextStyle(
                                            fontSize: Platform.isIOS ? 17 : 14,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop(false);
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: Platform.isIOS ? 17 : 14,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              ApiProvider getResponse = ApiProvider();
                                              await getResponse.UpdateNotificationStatus(
                                                context,
                                                list.nID!,
                                                dismiss: "1",
                                                isread:"0",
                                                isview: "0"

                                              );
                                              Navigator.of(dialogContext).pop(true);
                                            },
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                fontSize: Platform.isIOS ? 17 : 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    debugPrint('Delete notification: ${list.nID}');

                                    // Call delete API here
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 25,
                                ),
                                tooltip: 'Delete',
                              ),
                            ),
                          ],
                          SizedBox(
                            height: 10,
                          ),

                        ],
                      ),


                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class NotificationTile1 extends StatelessWidget {
  final String dateTime;
  final String description;
  final String subdescription;
  final String time;
  final String imageAsset;
  final String titleText;
  final Color titlecolor;
  final Color backgroundColor;
  final String isRead;
  final String notifyby;
  final String notifybyid;
  final String taskdetails;
  final NitificationLIST list;

  const NotificationTile1({
    Key? key,
    required this.dateTime,
    required this.description,
    required this.subdescription,
    required this.time,
    required this.imageAsset,
    required this.titleText,
    required this.titlecolor,
    required this.backgroundColor,
    required this.isRead,
    required this.notifyby,
    required this.notifybyid,
    required this.taskdetails,
    required this.list,
  }) : super(key: key);

  Color getLeftColor() {
    if (list.nTYPE == "1") {
      return Colors.red;
    } else if (list.nTYPE == "2") {
      return Colors.orange;
    } else if (list.nTYPE == "7") {
      return Colors.blue;
    }
    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blueGrey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.10),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Left colored indicator
          Container(
            width: 4,
            height: 110,
            margin: const EdgeInsets.only(
                left: 12, top: 14, bottom: 14),
            decoration: BoxDecoration(
              color: getLeftColor(),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Top Row
             /*     Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          titleText.toUpperCase(),
                          style: TextStyle(
                            color: getLeftColor(),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),*/
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleText.toUpperCase(),
                              style: TextStyle(
                                color: getLeftColor(),
                                fontSize:  Platform.isIOS ? 14 :11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$dateTime | $time",
                              style: TextStyle(
                                color: Colors.blueGrey.shade600,
                                fontSize: Platform.isIOS ? 15 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Read Status
                      Icon(
                        isRead == "1" ? Icons.done_all : Icons.done,
                        color: isRead == "1" ? Colors.blue : Colors.grey,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  /// Main message
                  Text(
                    subdescription,
                    style: TextStyle(
                      fontSize: isDesktop ? 17 : 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1E293B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Details
                  Text(
                    "From : $notifyby",
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 17 : 14,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    dateTime,
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 16 : 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
