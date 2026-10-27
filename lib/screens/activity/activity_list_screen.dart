import 'dart:io';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/activity/add_notes_screens.dart';
import 'package:erpflutter/screens/activity/add_phone_call_screen.dart';
import 'package:erpflutter/screens/activity/add_task_screen.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Dashboard.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/activity_response_model.dart';
import '../../models/activity_task_request_model.dart';
import '../../repository/LoginApiRepository.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/global_variables.dart';
import '../login/login_controller.dart';
import 'activity_controller.dart';
import 'add_event_screen.dart';
import 'edit_activity.dart';
import 'edit_event_screen.dart';
import 'edit_task_screen.dart';

class ActivityListFragment extends StatefulWidget {
  LoginResponseModel? loginResponseModel;
  String apibaseurl = "";

  ActivityListFragment({required this.loginResponseModel});

  @override
  _ActivityListFragment createState() =>
      new _ActivityListFragment(loginResponseModel);
}

class _ActivityListFragment extends State<ActivityListFragment>
    with WidgetsBindingObserver {
  bool searchBarEnabled = false;
  TextEditingController searchController = TextEditingController();
  ActivityResponseModel getactivityresponsemodel1 = new ActivityResponseModel();
  SizeConfig sizeConfig = SizeConfig();
  String? strUserName;
  String? strUserDesignation;
  LoginResponseModel? loginResponseModel;
  final _key = GlobalKey<ExpandableFabState>();
  int? myColor1;
  final ScrollController _scrollController = ScrollController();

  _ActivityListFragment(this.loginResponseModel);

  Color hexToColor1(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) {
      buffer.write('FF'); // Add alpha (opacity) for fully opaque
      buffer.write(hexColor.replaceFirst('#', ''));
    } else {
      // Handle cases for invalid hex color string if necessary
      throw FormatException("Invalid hex color string");
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  int hexToColor(String hexColor) {
    // Remove the hash if it's there
    hexColor = hexColor.replaceFirst('#', '');

    // Check if it has 6 or 8 characters
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor; // Add full opacity
    }

    // Convert to an integer and create a Color
    return (int.parse('0x$hexColor'));
  }

  bool noDataFound = false;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    myColor1 = hexToColor('#FF5733'); // RGB

    // Add listener to searchController to respond to changes in the search field
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        // If the search field is empty, load the initial data again
        GetActivityListapicall(
          loginResponseModel!.data!.token,
          loginResponseModel!.data!.userid,
          loginResponseModel!.data!.orgstrucid.toString(),
          loginResponseModel!.data!.posid.toString(),
          "",
          "0",
        );
        setState(() {
          noDataFound = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load the initial data
      GetActivityListapicall(
          loginResponseModel!.data!.token,
          loginResponseModel!.data!.userid,
          loginResponseModel!.data!.orgstrucid.toString(),
          loginResponseModel!.data!.posid.toString(),
          "",
          "0");
      Provider.of<ActivityController>(context, listen: false).fetchData();
      WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Code to execute when the app is resumed
      print("App is resumed");
      // You can also trigger any refresh or update actions here
    }
  }

  @override
  void dispose() {
    // Unregister the observer
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    _scrollController.dispose();

    super.dispose();
  }
  Widget _bottomSheetItem(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.APPCOLOR, size: 28),
      title: Text(label, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  void _openActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bottomSheetItem("Events", Icons.event, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      AddEventScreen(loginResponseModel: loginResponseModel),
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
             /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEventScreen(loginResponseModel: loginResponseModel),
                ),
              );*/
            }),

            _bottomSheetItem("Task", Icons.task, () {
             Navigator.pop(context);
             Navigator.push(
               context,
               PageRouteBuilder(
                 transitionDuration: const Duration(milliseconds: 10),
                 reverseTransitionDuration: const Duration(milliseconds: 10),
                 pageBuilder: (_, animation, secondaryAnimation) =>
                     AddTaskScreen(loginResponseModel: loginResponseModel),
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
             /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(loginResponseModel: loginResponseModel),
                ),
              );*/
            }),

            _bottomSheetItem("Phone Calls", Icons.call, () {
              //Navigator.pop(context);

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      AddPhoneCallScreen(loginResponseModel: loginResponseModel),
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
              ).then((value) {
                if (value == true) {
                  GetActivityListapicall(token!, userId!, orgStructId!, posId!, '', "0");
                }
              });
     /*         Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPhoneCallScreen(loginResponseModel: loginResponseModel),
                ),
              ).then((value) {
                if (value == true) {
                  GetActivityListapicall(token!, userId!, orgStructId!, posId!, '', "0");
                }
              });*/
            }),

            _bottomSheetItem("Notes", Icons.note, () {
              Navigator.pop(context);

              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      AddNotesScreen(loginResponseModel: loginResponseModel),
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
             /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddNotesScreen(loginResponseModel: loginResponseModel),
                ),
              );*/
            }),

            SizedBox(height: 20),
          ],
        );
      },
    );
  }
  Widget _buildWindowsFab() {
    return FloatingActionButton(
      backgroundColor: AppColors.APPCOLOR,
      child: Icon(Icons.add, size: 30, color: Colors.white),
      onPressed: () => _openActionMenu(context),
    );
  }
  Widget _buildAndroidFab() {
    return ExpandableFab(
      key: UniqueKey(),
      closeButtonBuilder: FloatingActionButtonBuilder(
        size: 56,
        builder: (BuildContext context, void Function()? onPressed,
            Animation<double> progress) {
          return IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.close, size: 40),
          );
        },
      ),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.add),
        fabSize: ExpandableFabSize.regular,
        foregroundColor: Colors.white,
        backgroundColor: AppColors.APPCOLOR,
        shape: const CircleBorder(),
      ),
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      overlayStyle: ExpandableFabOverlayStyle(
        blur: 4,
        color: Colors.transparent,
      ),
      children: [
        _buildFabItem('Events', () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  AddEventScreen(loginResponseModel: loginResponseModel),
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
              builder: (context) =>
                  AddEventScreen(loginResponseModel: loginResponseModel),
            ),
          );*/
        }),
        _buildFabItem('Task', () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  AddTaskScreen(loginResponseModel: loginResponseModel),
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
              builder: (context) =>
                  AddTaskScreen(loginResponseModel: loginResponseModel),
            ),
          );*/
        }),
        _buildFabItem('Phone Calls', () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  AddPhoneCallScreen(loginResponseModel: loginResponseModel),
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
          ).then((value) {
            if (value == true) {
              GetActivityListapicall(token!, userId!, orgStructId!, posId!, '', "0");
            }
          });
    /*      Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddPhoneCallScreen(loginResponseModel: loginResponseModel)),
          ).then((value) {
            if (value == true) {
              GetActivityListapicall(token!, userId!, orgStructId!, posId!, '', "0");
            }
          });*/
        }),
        _buildFabItem('Notes', () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  AddNotesScreen(loginResponseModel: loginResponseModel),
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

          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddNotesScreen(loginResponseModel: loginResponseModel),
            ),
          );*/
        }),
      ],
    );
  }
  Widget _buildFabItem(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.APPCOLOR,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
   return Center(
     child: SizedBox(
       width: isDesktop ? 700 : double.infinity,
       child: Scaffold(
         floatingActionButtonLocation:
         Platform.isAndroid ? ExpandableFab.location : FloatingActionButtonLocation.endFloat,

         floatingActionButton: Platform.isAndroid
             ? _buildAndroidFab()  // Expandable FAB
             : _buildWindowsFab(), // Simple FAB

         appBar: PreferredSize(
             preferredSize: const Size.fromHeight(60),
             child: SizedBox(
                 width: isDesktop ? 700 : double.infinity,
                 child:AppBar(

                        elevation: 0,
                        backgroundColor: const Color(0xFF12426E),
                        foregroundColor: Colors.white,
                        title: searchBarEnabled
                            ? Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: TextField(
             controller: searchController,
             textInputAction: TextInputAction.search,
             onSubmitted: (value) async {
               if (value == null ||
                   value.isEmpty ||
                   value.length < 2) {
                 // Show an error or alert the user to enter a valid search term
                 return;
               }

               SharedPreferences prefs =
               await SharedPreferences.getInstance();
               String? UserID = prefs.getString('USERID');
               String? OrStID = prefs.getString('ORGSTRUCTID');
               String? Token = prefs.getString('TOKEN');
               String? PosID = prefs.getString('POSID');

               ActivityTaskRequestModel getactivityrequestmodel =
               ActivityTaskRequestModel();
               getactivityrequestmodel.xMLFILE =
                   XMLFILETaskACTIVITY();
               getactivityrequestmodel.xMLFILE!.fLAG = "0";
               getactivityrequestmodel.xMLFILE!.aCTIVITYID = "0";
               getactivityrequestmodel.xMLFILE!.dESC = value;
               getactivityrequestmodel.xMLFILE!.tOKEN = Token;
               getactivityrequestmodel.xMLFILE!.oRGSTRUCTID = OrStID;
               getactivityrequestmodel.xMLFILE!.pOSID = PosID;
               getactivityrequestmodel.xMLFILE!.uSERID = UserID;
               getactivityrequestmodel.xMLFILE!.controlno =controlno;

               getactivityresponsemodel1 =
               await Provider.of<ActivityController>(context,
                   listen: false)
                   .GetActivityListDetails(
                   getactivityrequestmodel, context);

               setState(() {
                 if (getactivityresponsemodel1 == null ||
                     getactivityresponsemodel1!.data!.list == null) {
                   noDataFound = true;
                 } else {
                   noDataFound = false;
                 }
               });
             },
             decoration: InputDecoration(
               prefixIcon: const Icon(
                 Icons.search,
                 color: Colors.white,
               ),
               suffixIcon: IconButton(
                 icon: const Icon(Icons.clear, color: Colors.white),
                 onPressed: () {
                   setState(() {
                     searchController.clear();
                     searchBarEnabled = false;
                     noDataFound = false;
                   });
                   // Reset the list to the initial state
                   GetActivityListapicall(
                     loginResponseModel!.data!.token,
                     loginResponseModel!.data!.userid,
                     loginResponseModel!.data!.orgstrucid.toString(),
                     loginResponseModel!.data!.posid.toString(),
                     "",
                     "0",
                   );
                 },
               ),
               hintText: 'Search...',
               border: InputBorder.none,
             ),
                            ),
                          ),
                        )
                            :  Text(
                          'Activity',
                          style:  GoogleFonts.lato(

                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          )
                        ),
                        actions: [
                          searchBarEnabled
             ? Container()
             : IconButton(
                            onPressed: () {
             setState(() {
               searchBarEnabled = true;
             });
                            },
                            icon: Icon(Icons.search, color: Colors.white, size: 27),
                          ),
                        ],
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 10),
                                reverseTransitionDuration: const Duration(milliseconds: 10),
                                pageBuilder: (_, animation, secondaryAnimation) =>
                                    AppShell(
                                      role: "Admin",
                                      plant: "",
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

                            /*                     Navigator.pushReplacement(
             context,
             MaterialPageRoute(
               builder: (_) => AppShell(
                 role: "Admin",
                 plant: "",
                 selectedIndex: 0,

               ),
             ),
                            );*/
                          },
                        ),
                      ))),
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

       /*        Navigator.pushReplacement(
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
               ),
       */
             ],
           ),
         ),
          body: Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: const Color(0xFFE3F2FD),
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.all(10),
              child: getactivityresponsemodel1.data == null
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 90,
                  ),
                  itemCount:
                  getactivityresponsemodel1.data!.list?.length ?? 0,
                  itemBuilder: (context, i) {
                    final item =
                    getactivityresponsemodel1.data!.list![i];
                    final color = _getIconColor(item.typeid);
                    return buildActivityCard(
                      typeId: item.typeid ?? "",
                      title: item.subject ?? "",
                      assignedTo:
                      "Assigned : ${item.assignedtoname ?? ''}",
                      priority:
                      "Priority : ${item.priority ?? ''}",
                      status: item.status ?? "",
                      from:
                      "From : ${item.assignedbyname ?? ''}",
                      dueDate: item.duedate ?? "",
                      color:color,


                      onTap: () {

                        if (item.typeid == "2") {

                          Provider.of<ActivityController>(
                            context,
                            listen: false,
                          ).getActivity(
                            item.assignedtoname,
                            item.subject,
                            item.duedate,
                            item.businesspartner,
                            item.status,
                            item.priority,
                            item.remarks,
                          );
                          Navigator.pop(context);
                     /*     Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditTaskScreen(
                                loginResponseModel:
                                loginResponseModel,
                                strActivityId:
                                item.activityid,
                                strSubject:
                                item.subject,
                                strDueDate:
                                item.duedate,
                                strAssignedTo:
                                item.assignedto,
                                strStatus:
                                item.statusid,
                                strBusinessParners:
                                item.businesspartnerid,
                                strPriority:
                                item.priorityid,
                                strRemark:
                                item.remarks,
                                selectedAssignedToData:
                                item.assignedtoname,
                                selectedBusinessPartnersData:
                                item.businesspartner,
                                selectedStatusData:
                                item.status,
                                selectedPriorityData:
                                item.priority,
                                taskOwner:
                                item.assignedbyname,
                                taskdetails:
                                item.activitydetails,
                              ),
                            ),
                          );*/

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 10),
                              reverseTransitionDuration: const Duration(milliseconds: 10),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  EditTaskScreen(
                                    loginResponseModel:
                                    loginResponseModel,
                                    strActivityId:
                                    item.activityid,
                                    strSubject:
                                    item.subject,
                                    strDueDate:
                                    item.duedate,
                                    strAssignedTo:
                                    item.assignedto,
                                    strStatus:
                                    item.statusid,
                                    strBusinessParners:
                                    item.businesspartnerid,
                                    strPriority:
                                    item.priorityid,
                                    strRemark:
                                    item.remarks,
                                    selectedAssignedToData:
                                    item.assignedtoname,
                                    selectedBusinessPartnersData:
                                    item.businesspartner,
                                    selectedStatusData:
                                    item.status,
                                    selectedPriorityData:
                                    item.priority,
                                    taskOwner:
                                    item.assignedbyname,
                                    taskdetails:
                                    item.activitydetails,
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

                        }

                        else if (item.typeid == "3") {

                    /*      Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditActivity(
                                subject:
                                item.subject ?? "",
                                content:
                                item.content ?? "",
                                activityid:
                                item.activityid ?? "",
                                taskOwner:
                                item.assignedbyname,
                                loginResponseModel:
                                loginResponseModel,
                              ),
                            ),
                          );*/

                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 10),
                              reverseTransitionDuration: const Duration(milliseconds: 10),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  EditActivity(
                                    subject:
                                    item.subject ?? "",
                                    content:
                                    item.content ?? "",
                                    activityid:
                                    item.activityid ?? "",
                                    taskOwner:
                                    item.assignedbyname,
                                    loginResponseModel:
                                    loginResponseModel,
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

                        }

                        else if (item.typeid == "1") {
                         // Navigator.pop(context);
                 /*         Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddPhoneCallScreen(
                                    editPhoneCallInfo:
                                    item,
                                    loginResponseModel:
                                    loginResponseModel,
                                  ),
                            ),
                          );*/
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 10),
                              reverseTransitionDuration: const Duration(milliseconds: 10),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  AddPhoneCallScreen(
                                    editPhoneCallInfo:
                                    item,
                                    loginResponseModel:
                                    loginResponseModel,
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

                        }

                        else if (item.typeid == "4") {

                   /*       Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditEventScreen(
                                    loginResponseModel:
                                    loginResponseModel,
                                    strActivityId:
                                    item.activityid,
                                    strActivityName:
                                    'EditEventActivity',
                                  ),
                            ),
                          );*/

                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 10),
                              reverseTransitionDuration: const Duration(milliseconds: 10),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  EditEventScreen(
                                    loginResponseModel:
                                    loginResponseModel,
                                    strActivityId:
                                    item.activityid,
                                    strActivityName:
                                    'EditEventActivity',
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

                        }
                      },
                    );
                  },
                ),
              ),
            ),

        ),
     ),
   );
  }
  Widget buildActivityCard({
    required String typeId,
    required String title,
    required String assignedTo,
    required String priority,
    required String status,
    required String from,
    required String dueDate,
    required Color color,
    required VoidCallback onTap,
  }) {
    final Color accent = color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 2,
        child: Row(
          children: [

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color:
                            accent.withOpacity(.12),
                            borderRadius:
                            BorderRadius.circular(
                                12),
                          ),
                          child: Icon(
                            _getIcon(typeId),
                            color: accent,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            title,
                            style:
                            const TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (typeId == "2") ...[
                      Text(assignedTo),
                      const SizedBox(height: 4),
                      Text(priority),
                    ],

                    const SizedBox(height: 4),

                    Text(
                      from,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                            accent.withOpacity(.15),
                            borderRadius:
                            BorderRadius.circular(
                                20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: accent,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          dueDate,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 6,
              height: 150,
              decoration: BoxDecoration(
                color: accent,
                borderRadius:
                const BorderRadius.only(
                  topRight:
                  Radius.circular(18),
                  bottomRight:
                  Radius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  IconData _getIcon(String? typeId) {
    if (typeId == "1") {
      return Icons.call;
    } else if (typeId == "2") {
      return Icons.assignment;
    } else if (typeId == "3") {
      return Icons.note_alt;
    } else if (typeId == "4") {
      return Icons.event;
    }
    return Icons.work;
  }
  Color _getIconColor(String? typeId) {
    switch (typeId) {
      case "1":
        return Colors.green; // Call
      case "2":
        return Colors.orange; // Task
      case "3":
        return Colors.blue; // Notes
      case "4":
        return Colors.purple; // Event
      default:
        return Colors.grey;
    }
  }
 /* @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Consumer<LoginController>(builder: (context, data, _) {
      // LoginResponseModel user = userProvider.loginResponseModel!;
      DateTime dateTime;
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        },

        child: Scaffold(
          backgroundColor: const Color(0xFFF5F1F7),
          floatingActionButtonLocation:
          Platform.isAndroid ? ExpandableFab.location : FloatingActionButtonLocation.endFloat,

          floatingActionButton: Platform.isAndroid
              ? _buildAndroidFab()  // Expandable FAB
              : _buildWindowsFab(), // Simple FAB

          appBar: AppBar(
            backgroundColor: AppColors.APPCOLOR,
            foregroundColor: Colors.white,
            title: searchBarEnabled
                ? Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) async {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 2) {
                            // Show an error or alert the user to enter a valid search term
                            return;
                          }

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String? UserID = prefs.getString('USERID');
                          String? OrStID = prefs.getString('ORGSTRUCTID');
                          String? Token = prefs.getString('TOKEN');
                          String? PosID = prefs.getString('POSID');

                          ActivityTaskRequestModel getactivityrequestmodel =
                              ActivityTaskRequestModel();
                          getactivityrequestmodel.xMLFILE =
                              XMLFILETaskACTIVITY();
                          getactivityrequestmodel.xMLFILE!.fLAG = "0";
                          getactivityrequestmodel.xMLFILE!.aCTIVITYID = "0";
                          getactivityrequestmodel.xMLFILE!.dESC = value;
                          getactivityrequestmodel.xMLFILE!.tOKEN = Token;
                          getactivityrequestmodel.xMLFILE!.oRGSTRUCTID = OrStID;
                          getactivityrequestmodel.xMLFILE!.pOSID = PosID;
                          getactivityrequestmodel.xMLFILE!.uSERID = UserID;
                          getactivityrequestmodel.xMLFILE!.controlno =controlno;

                          getactivityresponsemodel1 =
                              await Provider.of<ActivityController>(context,
                                      listen: false)
                                  .GetActivityListDetails(
                                      getactivityrequestmodel, context);

                          setState(() {
                            if (getactivityresponsemodel1 == null ||
                                getactivityresponsemodel1!.data!.list == null) {
                              noDataFound = true;
                            } else {
                              noDataFound = false;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                searchBarEnabled = false;
                                noDataFound = false;
                              });
                              // Reset the list to the initial state
                              GetActivityListapicall(
                                loginResponseModel!.data!.token,
                                loginResponseModel!.data!.userid,
                                loginResponseModel!.data!.orgstrucid.toString(),
                                loginResponseModel!.data!.posid.toString(),
                                "",
                                "0",
                              );
                            },
                          ),
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                : const  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Activity",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

            ],
          ),
            actions: [
              searchBarEnabled
                  ? Container()
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          searchBarEnabled = true;
                        });
                      },
                      icon: Icon(Icons.search, color: Colors.white, size: 27),
                    ),
            ],
           leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
            ),
          ),
          resizeToAvoidBottomInset: false,
          body: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                    color: Colors.grey[00],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        if (getactivityresponsemodel1.data != null) ...[
                          for (int i = 0;
                              i < getactivityresponsemodel1.data!.list.length;
                              i++) ...[
                            InkWell(
                              onTap: () {
                                if (getactivityresponsemodel1!
                                        .data!.list![i].typeid ==
                                    "2") {
                                  Provider.of<ActivityController>(context,
                                          listen: false)
                                      .getActivity(
                                          getactivityresponsemodel1!
                                              .data!.list![i].assignedtoname,
                                          getactivityresponsemodel1!
                                              .data!.list![i].subject,
                                          getactivityresponsemodel1!
                                              .data!.list![i].duedate,
                                          getactivityresponsemodel1!
                                              .data!.list![i].businesspartner,
                                          getactivityresponsemodel1!
                                              .data!.list![i].status,
                                          getactivityresponsemodel1!
                                              .data!.list![i].priority,
                                          getactivityresponsemodel1!
                                              .data!.list![i].remarks);
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) => EditTaskScreen(
                                      loginResponseModel: loginResponseModel,
                                      strActivityId: getactivityresponsemodel1!
                                          .data!.list![i].activityid,
                                      strSubject: getactivityresponsemodel1!
                                          .data!.list![i].subject,
                                      strDueDate: getactivityresponsemodel1!
                                          .data!.list![i].duedate,
                                      strAssignedTo: getactivityresponsemodel1!
                                          .data!.list![i].assignedto,
                                      strStatus: getactivityresponsemodel1!
                                          .data!.list![i].statusid,
                                      strBusinessParners:
                                          getactivityresponsemodel1!
                                              .data!.list![i].businesspartnerid,
                                      strPriority: getactivityresponsemodel1!
                                          .data!.list![i].priorityid,
                                      strRemark: getactivityresponsemodel1!
                                          .data!.list![i].remarks,
                                      selectedAssignedToData:
                                          getactivityresponsemodel1!
                                              .data!.list![i].assignedtoname,
                                      selectedBusinessPartnersData:
                                          getactivityresponsemodel1!
                                              .data!.list![i].businesspartner,
                                      selectedStatusData:
                                          getactivityresponsemodel1!
                                              .data!.list![i].status,
                                      selectedPriorityData:
                                          getactivityresponsemodel1!
                                              .data!.list![i].priority,
                                      taskOwner: getactivityresponsemodel1!
                                          .data!.list![i].assignedbyname,
                                      taskdetails: getactivityresponsemodel1!

                                          .data!.list![i].activitydetails,
                                    ),
                                  ));

                                  *//* .then(
                                        (value) async {
                                      if (value) {
                                        GetActivityListapicall(token!, userId!,
                                            orgStructId!, posId!, '',getactivityresponsemodel1!
                                                .data!.list![i].activityid!);
                                      }
                                    },
                                  );*//*
                                } else if (getactivityresponsemodel1!
                                        .data!.list![i].typeid ==
                                    "3") {
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                    builder: (context) => EditActivity(
                                        subject: getactivityresponsemodel1!
                                            .data!.list![i].subject!,
                                        content: getactivityresponsemodel1!
                                            .data!.list![i].content!,
                                        activityid: getactivityresponsemodel1!
                                            .data!.list![i].activityid!,
                                        taskOwner: getactivityresponsemodel1!
                                            .data!.list![i].assignedbyname,
                                    loginResponseModel: loginResponseModel,),
                                  ))
                                      .then(
                                    (value) async {
                                      if (value == true) {
                                        GetActivityListapicall(token!, userId!,
                                            orgStructId!, posId!, '', "0");
                                      }
                                    },
                                  );
                                } else if (getactivityresponsemodel1!
                                        .data!.list![i].typeid ==
                                    "1") {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => AddPhoneCallScreen(
                                          editPhoneCallInfo:
                                              getactivityresponsemodel1!
                                                  .data!.list![i], loginResponseModel: loginResponseModel,),
                                    ),
                                  )
                                      .then(
                                    (value) async {
                                      if (value) {
                                        GetActivityListapicall(token!, userId!,
                                            orgStructId!, posId!, '', "0");
                                      }
                                    },
                                  );
                                }
                                if (getactivityresponsemodel1!
                                        .data!.list![i].typeid ==
                                    "4") {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EditEventScreen(
                                      loginResponseModel: loginResponseModel,
                                      strActivityId: getactivityresponsemodel1!
                                          .data!.list![i].activityid,
                                      strActivityName: 'EditEventActivity',
                                    ),
                                  ));

                                  *//* .then(
                                        (value) async {
                                      if (value) {
                                        GetActivityListapicall(token!, userId!,
                                            orgStructId!, posId!, '',getactivityresponsemodel1!
                                                .data!.list![i].activityid!);
                                      }
                                    },
                                  );*//*
                                }
                              },
                           /*   child: Card(
                                  margin: EdgeInsets.all(10.0),
                                  elevation: 2,
                                  child: Container(
                                      color: Colors.grey[200],
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[

                                          if(Platform.isAndroid)...[
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(0)),
                                                color: (hexToColor1(getactivityresponsemodel1!.data!.list![i].colorcode!)).withOpacity(0.1),
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          0.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[

                                                          if (Platform.isAndroid) ...[

                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              mainAxisSize:
                                                              MainAxisSize.min,
                                                              children: <Widget>[
                                                                if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "1") ...[
                                                                  SizedBox(
                                                                    width: 50,
                                                                    height: 50,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/phonecall.png"),
                                                                    ),
                                                                  ),
                                                                ]
                                                                else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "2") ...[
                                                                  SizedBox(
                                                                    width: 50,
                                                                    height: 50,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/task.png"),
                                                                    ),
                                                                  ),
                                                                ]
                                                                else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "3") ...[
                                                                  SizedBox(
                                                                    width: 50,
                                                                    height: 50,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/notes.png"),
                                                                    ),
                                                                  ),
                                                                ]
                                                                  else if (getactivityresponsemodel1!
                                                                    .data!
                                                                    .list![i]
                                                                    .typeid ==
                                                                    "4") ...[
                                                                  SizedBox(
                                                                    width: 50,
                                                                    height: 50,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/meeting.png"),
                                                                    ),
                                                                  ),
                                                                ],
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: <Widget>[
                                                                        const SizedBox(
                                                                          height:
                                                                          0,
                                                                        ),
                                                                        Text(
                                                                          getactivityresponsemodel1
                                                                              .data!
                                                                              .list[
                                                                          i]
                                                                              .subject!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontSize:
                                                                              15,
                                                                              fontWeight:
                                                                              FontWeight.bold),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),


      Visibility(
      visible: getactivityresponsemodel1.data?.list[i].typeid != "3", // hide when typeid == "4"
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      "Assigned To : ${getactivityresponsemodel1.data?.list[i].assignedtoname ?? ''}",
      style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      ),
      ),
      const SizedBox(height: 5),
      Text(
      "Priority : ${getactivityresponsemodel1.data?.list[i].priority ?? ''}",
      style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      ),
      ),
      ],
      ),
      ),
      *//*if (getactivityresponsemodel1!
          .data!
          .list![i]
          .typeid !=
      "4") ...[
        Text("Assigned To  : "+
            getactivityresponsemodel1!
                .data!
                .list![
            i]
                .assignedtoname!,
          style: const TextStyle(
              color: Colors
                  .black,
              fontWeight:
              FontWeight.normal),
        ),
        const SizedBox(
          height: 5,
        ),
        Text("Priority  : "+
            getactivityresponsemodel1!
                .data!
                .list![
            i]
                .priority!,
          style: const TextStyle(
              color: Colors
                  .black,
              fontWeight:
              FontWeight.normal),
        ),
    ],*//*

                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),

                                                                        Text("Status : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .status!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                          2,
                                                                        ),
                                                                        Text("From : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .assignedbyname!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .blue,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 2,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                          crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                          children: [
                                                                            Text(DateFormat('EEE').format(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(getactivityresponsemodel1!.data!.list![i].duedateday!.toString())))) +
                                                                                " " +
                                                                                getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[0].toString()+"|" + getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[1].toString() +
                                                                                " " +
                                                                                getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[2].toString(),
                                                                                style:
                                                                                const TextStyle(fontSize: 13, color: Colors.grey)),

                                                                            const SizedBox(
                                                                              width:
                                                                              25,
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        const SizedBox(
                                                                          height:
                                                                          0,
                                                                        ),
                                                                      ],
                                                                    )),
                                                                Container(
                                                                    width: 10,
                                                                    // Set your desired width
                                                                    height: SizeConfig
                                                                        .blockSizeVertical! *
                                                                        20,
                                                                    // Set your desired height
                                                                    color: Color(hexToColor(
                                                                        getactivityresponsemodel1!
                                                                            .data!
                                                                            .list![
                                                                        i]
                                                                            .colorcode!)),
                                                                    // Fill color
                                                                    child: Center(
                                                                      child: Text(
                                                                        '',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                            20),
                                                                      ),
                                                                    )),


                                                              ],
                                                            ),



                                                          ]
                                                          else...[
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              mainAxisSize:
                                                              MainAxisSize.min,
                                                              children: <Widget>[
                                                                if (getactivityresponsemodel1!
                                                                    .data!
                                                                    .list![i]
                                                                    .typeid ==
                                                                    "1") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/phonecall.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1!
                                                                    .data!
                                                                    .list![i]
                                                                    .typeid ==
                                                                    "2") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/task.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1!
                                                                    .data!
                                                                    .list![i]
                                                                    .typeid ==
                                                                    "3") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/notes.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1!
                                                                    .data!
                                                                    .list![i]
                                                                    .typeid ==
                                                                    "4") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/meeting.png"),
                                                                    ),
                                                                  ),
                                                                ],
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: <Widget>[
                                                                        Text(
                                                                          getactivityresponsemodel1!
                                                                              .data!
                                                                              .list![
                                                                          i]
                                                                              .subject!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontSize:
                                                                              15,
                                                                              fontWeight:
                                                                              FontWeight.bold),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Visibility(
                                                                          visible: getactivityresponsemodel1.data?.list[i].typeid != "3", // hide when typeid == "4"
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Assigned To : ${getactivityresponsemodel1.data?.list[i].assignedtoname ?? ''}",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 5),
                                                                              Text(
                                                                                "Priority : ${getactivityresponsemodel1.data?.list[i].priority ?? ''}",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                       *//* Text("Assigned To  : "+
                                                                            getactivityresponsemodel1
                                                                                .data!
                                                                                .list[
                                                                            i]
                                                                                .assignedtoname!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text("Priority  : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .priority!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),*//*
                                                                        Text("From : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .assignedbyname!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 2,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                          15,
                                                                        ),
                                                                      ],
                                                                    )),
                                                                const SizedBox(
                                                                  width: 15,
                                                                ),
                                                                if (getactivityresponsemodel1!
                                                                    .data!
                                                                    .list![i]
                                                                    .duedateday !=
                                                                    null) ...[
                                                                  Expanded(
                                                                      flex: 2,
                                                                      child: Container(
                                                                          padding: const EdgeInsets.all(5.0),
                                                                          color: (hexToColor1(getactivityresponsemodel1!.data!.list![i].colorcode!)).withOpacity(0.1),
                                                                          height: SizeConfig.blockSizeVertical! * 15,
                                                                          child: Column(
                                                                            mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                DateFormat('EEE').format(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(getactivityresponsemodel1!.data!.list![i].duedateday!.toString())))) +
                                                                                    " " +
                                                                                    getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[0].toString(),
                                                                                style:
                                                                                const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: 15,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                2,
                                                                              ),
                                                                              Text(
                                                                                getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[1].toString() +
                                                                                    " " +
                                                                                    getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[2].toString(),
                                                                                style:
                                                                                const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: 15,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                2,
                                                                              ),
                                                                              Text(
                                                                                maxLines:
                                                                                1,
                                                                                getactivityresponsemodel1!.data!.list![i].status!,
                                                                                style:
                                                                                const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                2,
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                1,
                                                                                width:
                                                                                15,
                                                                              ),
                                                                            ],
                                                                          ))),
                                                                ],
                                                                Container(
                                                                    width: 10,
                                                                    // Set your desired width
                                                                    height: SizeConfig
                                                                        .blockSizeVertical! *
                                                                        12,
                                                                    // Set your desired height
                                                                    color: Color(hexToColor(
                                                                        getactivityresponsemodel1!
                                                                            .data!
                                                                            .list![
                                                                        i]
                                                                            .colorcode!)),
                                                                    // Fill color
                                                                    child: Center(
                                                                      child: Text(
                                                                        '',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                            20),
                                                                      ),
                                                                    )),
                                                              ],
                                                            )

                                                          ]
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ]
                                          else...[
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(0)),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          0.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[

                                                          if (Platform.isAndroid) ...[

                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              mainAxisSize:
                                                              MainAxisSize.min,
                                                              children: <Widget>[
                                                                if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "1") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/phonecall.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "2") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/task.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "3") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/notes.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "4") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/meeting.png"),
                                                                    ),
                                                                  ),
                                                                ],
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: <Widget>[
                                                                        const SizedBox(
                                                                          height:
                                                                          15,
                                                                        ),
                                                                        Text(
                                                                          getactivityresponsemodel1
                                                                              .data!
                                                                              .list[
                                                                          i]
                                                                              .subject!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontSize:
                                                                              15,
                                                                              fontWeight:
                                                                              FontWeight.bold),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                      *//*  Text("Assigned To  : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .assignedtoname!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text("Priority  : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .priority!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),*//*
                                                                        Visibility(
                                                                          visible: getactivityresponsemodel1.data?.list[i].typeid != "3", // hide when typeid == "4"
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Assigned To : ${getactivityresponsemodel1.data?.list[i].assignedtoname ?? ''}",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 5),
                                                                              Text(
                                                                                "Priority : ${getactivityresponsemodel1.data?.list[i].priority ?? ''}",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Text("From : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .assignedbyname!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .blue,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 2,
                                                                        ),
                                                                        Text("Status : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .status!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .blue,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                          10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                          crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                          children: [
                                                                            Text(DateFormat('EEE').format(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(getactivityresponsemodel1!.data!.list![i].duedateday!.toString())))) +
                                                                                " " +
                                                                                getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[0].toString()+"|" + getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[1].toString() +
                                                                                " " +
                                                                                getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[2].toString(),
                                                                                style:
                                                                                const TextStyle(fontSize: 13, color: Colors.grey)),

                                                                            const SizedBox(
                                                                              width:
                                                                              25,
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        const SizedBox(
                                                                          height:
                                                                          10,
                                                                        ),
                                                                      ],
                                                                    )),
                                                                Container(
                                                                    width: 10,
                                                                    // Set your desired width
                                                                    height: SizeConfig
                                                                        .blockSizeVertical! *
                                                                        26,
                                                                    // Set your desired height
                                                                    color: Color(hexToColor(
                                                                        getactivityresponsemodel1!
                                                                            .data!
                                                                            .list![
                                                                        i]
                                                                            .colorcode!)),
                                                                    // Fill color
                                                                    child: Center(
                                                                      child: Text(
                                                                        '',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                            20),
                                                                      ),
                                                                    )),


                                                              ],
                                                            ),



                                                          ]else...[
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              mainAxisSize:
                                                              MainAxisSize.min,
                                                              children: <Widget>[
                                                                if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "1") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/phonecall.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "2") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/task.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "3") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/notes.png"),
                                                                    ),
                                                                  ),
                                                                ] else if (getactivityresponsemodel1
                                                                    .data!
                                                                    .list[i]
                                                                    .typeid ==
                                                                    "4") ...[
                                                                  SizedBox(
                                                                    width: 70,
                                                                    height: 70,
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                          "assets/meeting.png"),
                                                                    ),
                                                                  ),
                                                                ],
                                                                Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: <Widget>[
                                                                        Text(
                                                                          getactivityresponsemodel1
                                                                              .data!
                                                                              .list[
                                                                          i]
                                                                              .subject!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontSize:
                                                                              15,
                                                                              fontWeight:
                                                                              FontWeight.bold),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Visibility(
                                                                          visible: getactivityresponsemodel1.data?.list[i].typeid != "3", // hide when typeid == "4"
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Assigned To : ${getactivityresponsemodel1.data?.list[i].assignedtoname ?? ''}",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 5),
                                                                              Text(
                                                                                "Priority : ${getactivityresponsemodel1.data?.list[i].priority ?? ''}",
                                                                                style: const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                       *//* Text("Assigned To  : "+
                                                                            getactivityresponsemodel1
                                                                                .data!
                                                                                .list[
                                                                            i]
                                                                                .assignedtoname!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text("Priority  : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .priority!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),*//*
                                                                        const SizedBox(
                                                                          height: 5,
                                                                        ),
                                                                        Text("From : "+
                                                                            getactivityresponsemodel1!
                                                                                .data!
                                                                                .list![
                                                                            i]
                                                                                .assignedbyname!,
                                                                          style: const TextStyle(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight.normal),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 2,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                          15,
                                                                        ),
                                                                      ],
                                                                    )),
                                                                const SizedBox(
                                                                  width: 15,
                                                                ),
                                                                if (getactivityresponsemodel1!
                                                                    .data!
                                                                    .list![i]
                                                                    .duedateday !=
                                                                    null) ...[
                                                                  Expanded(
                                                                      flex: 2,
                                                                      child: Container(
                                                                          padding: const EdgeInsets.all(5.0),
                                                                          color: (hexToColor1(getactivityresponsemodel1!.data!.list![i].colorcode!)).withOpacity(0.1),
                                                                          height: SizeConfig.blockSizeVertical! * 15,
                                                                          child: Column(
                                                                            mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                DateFormat('EEE').format(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(getactivityresponsemodel1!.data!.list![i].duedateday!.toString())))) +
                                                                                    " " +
                                                                                    getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[0].toString(),
                                                                                style:
                                                                                const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: 15,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                2,
                                                                              ),
                                                                              Text(
                                                                                getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[1].toString() +
                                                                                    " " +
                                                                                    getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[2].toString(),
                                                                                style:
                                                                                const TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: 15,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                2,
                                                                              ),
                                                                              Text(
                                                                                maxLines:
                                                                                1,
                                                                                getactivityresponsemodel1!.data!.list![i].status!,
                                                                                style:
                                                                                const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                2,
                                                                              ),
                                                                              const SizedBox(
                                                                                height:
                                                                                1,
                                                                                width:
                                                                                15,
                                                                              ),
                                                                            ],
                                                                          ))),
                                                                ],
                                                                Container(
                                                                    width: 10,
                                                                    // Set your desired width
                                                                    height: SizeConfig
                                                                        .blockSizeVertical! *
                                                                        12,
                                                                    // Set your desired height
                                                                    color: Color(hexToColor(
                                                                        getactivityresponsemodel1!
                                                                            .data!
                                                                            .list![
                                                                        i]
                                                                            .colorcode!)),
                                                                    // Fill color
                                                                    child: Center(
                                                                      child: Text(
                                                                        '',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                            20),
                                                                      ),
                                                                    )),
                                                              ],
                                                            )

                                                          ]
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ]


                                        ],
                                      ))),*/

                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFD6E2EF),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Container(
                                          width: 4,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: hexToColor1(
                                                getactivityresponsemodel1.data!.list[i].colorcode!),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              Text(
                                                getactivityresponsemodel1.data!.list[i].typeid == "1"
                                                    ? "PHONE CALL"
                                                    : getactivityresponsemodel1.data!.list[i].typeid == "2"
                                                    ? "TASK"
                                                    : getactivityresponsemodel1.data!.list[i].typeid == "3"
                                                    ? "NOTES"
                                                    : "EVENT",
                                                style: TextStyle(
                                                  color: hexToColor1(
                                                      getactivityresponsemodel1.data!.list[i].colorcode!),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                  letterSpacing: 1,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              Text(
                                                getactivityresponsemodel1.data!.list[i].subject ?? "",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff1E293B),
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              if (getactivityresponsemodel1.data!.list[i].typeid != "3")
                                                Text(
                                                  "Assigned To : ${getactivityresponsemodel1.data!.list[i].assignedtoname}",
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),

                                              const SizedBox(height: 5),

                                              Text(
                                                "Priority : ${getactivityresponsemodel1.data!.list[i].priority}",
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              Text(
                                                "From : ${getactivityresponsemodel1.data!.list[i].assignedbyname}",
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [

                                            if (getactivityresponsemodel1.data!.list[i].duedateday != null)
                                      Text(
                                      DateFormat('EEE').format(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(getactivityresponsemodel1!.data!.list![i].duedateday!.toString())))) +
                                      " " +
                                      getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[0].toString()+" | " + getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[1].toString() +
                                      " " +
                                      getactivityresponsemodel1!.data!.list![i].duedate!.split(' ')[2].toString(),

                                  style: const TextStyle(
                                    color: Color(0xff64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),



                                            const SizedBox(height: 25),

                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5),
                                              decoration: BoxDecoration(
                                                color: hexToColor1(
                                                    getactivityresponsemodel1.data!.list[i].colorcode!)
                                                    .withOpacity(.15),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                getactivityresponsemodel1.data!.list[i].status ?? "",
                                                style: TextStyle(
                                                  color: hexToColor1(
                                                      getactivityresponsemodel1.data!.list[i].colorcode!),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ]
                      ],
                    ))),
          ),
        ),
      );
    });
  }*/


  Future<ActivityResponseModel> GetActivityListapicall(
      String strToken,
      String strUserId,
      String strOrgstructId,
      String strPostId,
      String strSearchText,
      String strActivityId) async {
    try {
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
      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        ActivityTaskRequestModel getactivityrequestmodel =
            ActivityTaskRequestModel();
        getactivityrequestmodel.xMLFILE = XMLFILETaskACTIVITY();
        getactivityrequestmodel.xMLFILE!.fLAG = "0";
        getactivityrequestmodel.xMLFILE!.aCTIVITYID = strActivityId;
        getactivityrequestmodel.xMLFILE!.dESC = strSearchText;
        getactivityrequestmodel.xMLFILE!.tOKEN = strToken;
        getactivityrequestmodel.xMLFILE!.oRGSTRUCTID = strOrgstructId;
        getactivityrequestmodel.xMLFILE!.pOSID = strPostId;
        getactivityrequestmodel.xMLFILE!.uSERID = strUserId;
        getactivityrequestmodel.xMLFILE!.controlno = controlno;

        getactivityresponsemodel1 =
            await Provider.of<ActivityController>(context, listen: false)
                .GetActivityListDetails(getactivityrequestmodel, context);
        if (getactivityresponsemodel1 != null) {
          Navigator.of(context).pop();
          setState(() {});
        } else {
          Navigator.of(context).pop();
          // if (Get.isDialogOpen ?? false) {
          //   Get.back();
          // }
        }
      } else {
        return getactivityresponsemodel1;
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
    }
    return getactivityresponsemodel1;
  }
}


