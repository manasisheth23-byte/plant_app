
import 'dart:io';

import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Constants.dart';
import '../../Dashboard.dart';
import '../../app_colors.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/activity_response_model.dart';
import '../../models/activity_task_request_model.dart';
import '../../models/add_task_request_model.dart';
import '../../models/add_task_response_model.dart';
import '../../models/fill_status_list_model.dart';
import '../../models/fill_user_list_model.dart';
import '../../models/sync_s_ledger_model.dart';
import '../../provider/themecontroller.dart';
import '../../repository/LoginApiRepository.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../activity/activity_controller.dart';
import '../activity/activity_list_screen.dart';
import 'alerts_list.dart';



class EditTaskAlertsScreen extends StatefulWidget {
  LoginResponseModel? loginResponseModel;
  String? strActivityId;

  EditTaskAlertsScreen({required this.loginResponseModel,required this.strActivityId});

  @override
  State<EditTaskAlertsScreen> createState() => _EditTaskAlertsScreenState(loginResponseModel,strActivityId);
}

class _EditTaskAlertsScreenState extends State<EditTaskAlertsScreen> {
  // Define separate variables for the selected values
  LoginResponseModel? loginResponseModel;
  String? selectSubject;
  String? selectRemark;
  String? strActivityId;
  static DateTime? selectedDueDate;
  String? strSubject;
  String? strDueDate;
  String? strAssignedTo;
  String? strAssignedtoID;
  String? strStatus;
  String? strPriority;
  String? strBusinessParners;
  ActivityResponseModel getactivityresponsemodel1 = new ActivityResponseModel();
  static String? selectedContactTo;
  static String? selectedStatus;
  static String? selectedPriority;
  static String? selectedBusinessPartners;
  TextEditingController subjectController = TextEditingController();
  TextEditingController taskdetailsController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy hh:mm a');
  List<LISTSTATUS> statusList = [];
  List<LISTSTATUS> statusListOnSearch = [];
  List<LISTSTATUS> priorotyList = [];
  List<LISTSTATUS> priorotyListOnSearch = [];
  List<LISTUSER> glossarList = [];
  List<LISTUSER> glossarListOnSearch = [];
  List<LISTSLEDEGER> businessprtnersList = [];
  List<LISTSLEDEGER> businessprtnersListOnSearch = [];
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingStatusController = TextEditingController();
  TextEditingController _textEditingpriorotyController = TextEditingController();
  TextEditingController _textEditingbusinessprtnersController = TextEditingController();
  String? selectedAssignedTo;
  String? strDefaultAssignedTo="Select Assigned To";
  String? strDefaultStatus="Select Status";
  String? strstatusid;
  String? strDefaultprioroty="Select Priority";
  String? strDefaultbusinessprtners="Select Business Partner";
  late TextStyle titleStyle;
  late ThemeController themeController;

  _EditTaskAlertsScreenState(this.loginResponseModel,this.strActivityId);

  Map<String, dynamic>? line;
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);


    WidgetsBinding.instance.addPostFrameCallback((_) {

      Provider.of<ActivityController>(context, listen: false).fetchData();
      GetActivityListapicall(
          loginResponseModel!.data!.token,
          loginResponseModel!.data!.userid,
          loginResponseModel!.data!.orgstrucid.toString(),
          loginResponseModel!.data!.posid.toString(),
          "",strActivityId!);



    });



  }
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
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

    // Check if the controller has a selected date, and parse it
    if (controller.text.isNotEmpty) {
      initialDate = _dateFormat.parse(controller.text);
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        controller.text = _dateFormat.format(selectedDate);
      });
    }
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
  Widget buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color:Color(0xFF12426E),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required)
          const Text(
            " *",
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
  Widget buildField({
    TextEditingController? controller,
    String? hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
  int _idx = 1;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of(context, listen: false);
    titleStyle = TextStyle(color:themeController.primaryColor, fontSize: 16, fontWeight: FontWeight.normal);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
         /* Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
          ));*/

          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
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
                  appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                child: SizedBox(
                width: isDesktop ? 700 : double.infinity,
                child:AppBar(
            centerTitle: Platform.isWindows ? true : false,
            foregroundColor:Colors.white ,
            backgroundColor: themeController.primaryColor,
            title: Text('Edit Task',style:   GoogleFonts.lato(

              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),),
            actions: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () async {

                  if (subjectController.text == null || subjectController.text.isEmpty) {
                    _showSnackBar("Please enter Subject");
                    return;
                  } else if (selectedContactTo == null ||
                      selectedContactTo!.isEmpty) {
                    _showSnackBar("Please select AssignTo field");
                    return;
                  }else if (selectedDueDate == null ||
                      selectedDueDate.toString().isEmpty) {
                    _showSnackBar("Please Enter Due Date");
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
                    CommonUtils commonUtils = new CommonUtils();
                    bool isConnectivity = await commonUtils.check();
                    if (isConnectivity) {
                      AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                      activityRequestModel.xMLFILE = new XMLFILETASK();
                      activityRequestModel.xMLFILE!.aCTIVITYID = strActivityId;
                      activityRequestModel.xMLFILE!.aSSIGNEDTO = selectedContactTo;
                      activityRequestModel.xMLFILE!.BUSINESSPARTNERID = selectedBusinessPartners;
                      activityRequestModel.xMLFILE!.cONTACT = "";
                      activityRequestModel.xMLFILE!.rEFDOCID = "0";
                      activityRequestModel.xMLFILE!.rEFMID = "0";
                      activityRequestModel.xMLFILE!.rEMARKS = taskdetailsController.text;
                      activityRequestModel.xMLFILE!.fLAG = "E";
                      activityRequestModel.xMLFILE!.oRGSTRUCTID =orgStructId;
                      activityRequestModel.xMLFILE!.controlno =controlno;
                      activityRequestModel.xMLFILE!.pOSID = loginResponseModel!.data!.posid!;
                      activityRequestModel.xMLFILE!.sUBJECT = subjectController.text;
                      activityRequestModel.xMLFILE!.tYPEID = 2;
                      activityRequestModel.xMLFILE!.tOKEN = loginResponseModel!.data!.token!;
                      activityRequestModel.xMLFILE!.sTARTTIME = "";
                      activityRequestModel.xMLFILE!.eNDTIME = "";
                      activityRequestModel.xMLFILE!.dUEDATE =DateFormat('dd-MMM-yyyy hh:mm a').format(selectedDueDate!);
                      activityRequestModel.xMLFILE!.sTATUSID = selectedStatus;
                      activityRequestModel.xMLFILE!.pRIORITYID = selectedPriority;
                      activityRequestModel.xMLFILE!.uSERID = loginResponseModel!.data!.userid!;
                      activityRequestModel.xMLFILE!.tASKDETAILS = taskdetailsController.text;

                      AddActivityTaskResponseModel? response;  response = await Provider.of<ActivityController>(context, listen: false)
                          .AddActivityTaskDetails(activityRequestModel,context);

                      // response = await _repository.getLoginData(loginRequestModel);
            //          await Provider.of<UserProvider>(context, listen: false).login(username, password);
                      if (response != null) {
                        Navigator.pop(context); //for dissmiss progres dialog
                        _showAddedSnackbar(response!.sysmsgs!.errormsgs!.toString());
                      /*  Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
                        ));*/
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 10),
                            reverseTransitionDuration: const Duration(milliseconds: 10),
                            pageBuilder: (_, animation, secondaryAnimation) =>
                                AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
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

                icon: Icon(Icons.delete),
                onPressed: () async{

                  bool? confirmDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Delete"),
                        content: Text("Are you sure you want to delete this note?"),
                        actions: [
                          TextButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop(false); // Return false if No is pressed
                            },
                          ),
                          TextButton(
                            child: Text("Yes"),
                            onPressed: () async{
                              AlertDialog alert = AlertDialog(
                                content: Row(children: [
                                  CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
                                ]),
                              );

                           /*   showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );*/
                              CommonUtils commonUtils = new CommonUtils();
                              bool isConnectivity = await commonUtils.check();
                              if (isConnectivity) {
                                AddTaskRequestModel activityRequestModel = new AddTaskRequestModel();
                                activityRequestModel.xMLFILE = new XMLFILETASK();
                                activityRequestModel.xMLFILE!.aCTIVITYID = strActivityId;
                                activityRequestModel.xMLFILE!.aSSIGNEDTO = "";
                                activityRequestModel.xMLFILE!.BUSINESSPARTNERID = "0";
                                activityRequestModel.xMLFILE!.cONTACT = "";
                                activityRequestModel.xMLFILE!.rEFDOCID = "0";
                                activityRequestModel.xMLFILE!.rEFMID = "0";
                                activityRequestModel.xMLFILE!.rEMARKS = taskdetailsController.text;
                                activityRequestModel.xMLFILE!.fLAG = "D";
                                activityRequestModel.xMLFILE!.oRGSTRUCTID =orgStructId;
                                activityRequestModel.xMLFILE!.controlno =controlno;
                                activityRequestModel.xMLFILE!.pOSID = loginResponseModel!.data!.posid!;
                                activityRequestModel.xMLFILE!.sUBJECT = "";
                                activityRequestModel.xMLFILE!.tYPEID = 2;
                                activityRequestModel.xMLFILE!.tOKEN = loginResponseModel!.data!.token!;
                                activityRequestModel.xMLFILE!.sTARTTIME = "";
                                activityRequestModel.xMLFILE!.eNDTIME = "";
                                activityRequestModel.xMLFILE!.dUEDATE ="";
                                activityRequestModel.xMLFILE!.sTATUSID = "";
                                activityRequestModel.xMLFILE!.pRIORITYID = "";
                                activityRequestModel.xMLFILE!.uSERID = loginResponseModel!.data!.userid!;
                                activityRequestModel.xMLFILE!.tASKDETAILS = taskdetailsController.text;

                                AddActivityTaskResponseModel? response;  response = await Provider.of<ActivityController>(context, listen: false)
                                    .AddActivityTaskDetails(activityRequestModel,context);

                                if (response != null) {
                                  Navigator.pop(context); //for dissmiss progres dialog
                                  // Show a success SnackBar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Task deleted successfully!'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                 /* Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
                                  ));*/
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 10),
                                      reverseTransitionDuration: const Duration(milliseconds: 10),
                                      pageBuilder: (_, animation, secondaryAnimation) =>
                                          AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
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
                            },
                          ),
                        ],
                      );
                    },
                  );

                },
              ),

            ],
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
               // Navigator.pop(context);
               /* Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
                ));*/
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
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
                  )))),
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
           /*         Navigator.pushReplacement(
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
                  body:Consumer<ActivityController>(
              builder: (context, data, _) {
              //  remarkController.text=data.strRemark!;

                return      SingleChildScrollView(
                  child:  Center(
                      child: Container(
                      color: const Color(0xFFF3F5F7),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: isDesktop ? 700 : double.infinity,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// Top blue header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeController.primaryColor,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [

                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.assignment_outlined,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            subjectController.text,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 22,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            loginResponseModel!.data!.username!,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(.9),
                                              fontSize: 16,fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              buildLabel("Subject", required: true),
                              const SizedBox(height: 5),

                              buildField(
                                controller: subjectController,
                                maxLines: 3,
                              ),

                              const SizedBox(height: 18),

                              buildLabel("Task Owner"),

                              const SizedBox(height: 5),

                              buildField(
                                hintText: loginResponseModel!.data!.username!,
                              ),

                              const SizedBox(height: 18),

                              buildLabel("Assigned To", required: true),

                              const SizedBox(height: 5),

                              // Your Assigned-To widget here
                              if(data.fillUserListModel != null)...[
                                if(data.fillUserListModel!.dATA != null)...[
                                  /*    Container(
                                    height: 60,
                                    width: double.infinity,
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Text('Please Select'),
                                      items: data.fillUserListModel!.dATA!.lIST!.map((option) {
                                        return DropdownMenuItem<String>(
                                            value: option.uSERID,
                                            child: Text(option.uSERNAME ?? ''));
                                      }).toList(),
                                      value: selectedContactTo,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedContactTo = value ?? selectedContactTo;
                                        });
                                      },
                                    ),
                                  ),*/
                                  InkWell(
                                      onTap: (){
                                        // Add what you want to do on tap
                                        //  setState(() {
                                        _asyncAssignedToDialog(context, data.fillUserListModel!.dATA!.lIST!);
                                        // });


                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,  // same as TextFormField

                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(strDefaultAssignedTo ?? "Select Assigned to", style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w700,),),


                                            Row(
                                                children: [
                                                  Text("", style: GoogleFonts.lato(
                                                      color: Color(0xFF12426E),fontWeight: FontWeight.w700,),),
                                                  Padding(
                                                      padding: EdgeInsets.all(.0),
                                                      child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                ]),

                                          ],
                                        ),
                                      )),

                                ]],
                              const SizedBox(height: 18),

                              buildLabel("Business Partners"),

                              const SizedBox(height: 5),

                              // Your Business Partner widget
                              if(data.syncSLedgerModel != null)...[
                                if(data.syncSLedgerModel!.dATA != null)...[
                                  InkWell(
                                      onTap: (){
                                        // Add what you want to do on tap
                                        setState(() {
                                          _asyncBusinessPartnersDialog(context, data.syncSLedgerModel!.dATA!.lIST!);
                                        });


                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,  // same as TextFormField

                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(strDefaultbusinessprtners ?? "Select Business Partners", style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w700,),),


                                            Row(
                                                children: [
                                                  Text("", style: const TextStyle(
                                                      fontFamily: 'Roboto', color: Color(0xFF12426E),fontWeight: FontWeight.w700,),),
                                                  Padding(
                                                      padding: EdgeInsets.all(.0),
                                                      child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                ]),

                                          ],
                                        ),
                                      )),

                                ]],
                                 SizedBox(height: 18),

                              buildLabel("Status", required: true),

                               SizedBox(height: 5),

                              // Status widget
                            if(data.typeList != null)...[
                      if(data.typeList!.dATA != null)...[
                        /*  Container(
                                    height: 60,
                                    width: double.infinity,
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      items: data.typeList!.dATA!.lIST!.map((option) {
                                        return DropdownMenuItem<String>(
                                            value: option.statusid,
                                            child: Text(option.name!));
                                      }).toList(),
                                      value: selectedStatus,
                                      hint: Text('Select Status'),
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedStatus = value ?? selectedStatus;
                                        });
                                      },
                                    ),
                                  ),*/

                        InkWell(
                        onTap: (){
                      // Add what you want to do on tap
                      setState(() {
                      _asyncStatusDialog(context, data.typeList!.dATA!.lIST!);
                      });


                  },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,  // same as TextFormField

                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(strDefaultStatus ?? "Select Status", style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,),),


                            Row(
                                children: [
                                  Text("", style: const TextStyle(
                                      fontFamily: 'Roboto', color: Color(0xFF12426E),fontWeight: FontWeight.w700,),),
                                  Padding(
                                      padding: EdgeInsets.all(.0),
                                      child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                ]),

                          ],
                        ),
                      )),
                    ]],
                              const SizedBox(height: 18),

                              buildLabel("Details"),

                              const SizedBox(height: 5),

                              buildField(
                                controller: taskdetailsController,
                                maxLines: 4,
                                hintText: "Enter Details",
                              ),

                              const SizedBox(height: 18),

                              buildLabel("Priority", required: true),

                              const SizedBox(height: 5),

                              // Priority widget
                              if(data.priorityList != null)...[
                                if(data.priorityList!.dATA != null)...[
                                  /*     Container(
                                    height: 60,
                                    width: double.infinity,
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      items: data.priorityList!.dATA!.lIST!.map((option) {
                                        return DropdownMenuItem<String>(
                                            value: option.statusid,
                                            child: Text(option.name!));
                                      }).toList(),
                                      value: selectedPriority,
                                      hint: Text('Select Priority'),
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedPriority = value ?? selectedPriority;
                                        });
                                      },
                                    ),
                                  ),*/

                                  InkWell(
                                      onTap: (){
                                        // Add what you want to do on tap
                                        setState(() {
                                          _asyncPriorityDialog(context, data.priorityList!.dATA!.lIST!);
                                        });


                                      },
                                      child: Container(

                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,  // same as TextFormField
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(strDefaultprioroty ?? "Select Priority", style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w700,),),


                                            Row(
                                                children: [
                                                  Text("", style: const TextStyle(
                                                      fontFamily: 'Roboto', color: Color(0xFF12426E),fontWeight: FontWeight.w700,),),
                                                  Padding(
                                                      padding: EdgeInsets.all(.0),
                                                      child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                ]),

                                          ],
                                        ),
                                      )),
                                ]],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                    ),

                );
              }
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
            color: themeController.primaryColor,
            fontWeight: FontWeight.w700,
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


  Future<ActivityResponseModel> GetActivityListapicall(
      String strToken,
      String strUserId,
      String strOrgstructId,
      String strPostId,
      String strSearchText,String strActivityId) async {
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
        ActivityTaskRequestModel getactivityrequestmodel = ActivityTaskRequestModel();
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
        if (getactivityresponsemodel1 != null && (getactivityresponsemodel1.data!.list.length > 0))
        {
          Navigator.of(context).pop();

          setState(() {

            subjectController.text=getactivityresponsemodel1.data!.list![0].subject ??"";
            taskdetailsController.text=getactivityresponsemodel1.data!.list![0].activitydetails ??"";
            selectedContactTo=getactivityresponsemodel1.data!.list![0].assignedto??"";
            strDueDate=getactivityresponsemodel1.data!.list![0].duedate ??"";
            selectedPriority=getactivityresponsemodel1.data!.list![0].priorityid??"";
            selectedStatus=getactivityresponsemodel1.data!.list![0].statusid??"";
            selectedBusinessPartners=getactivityresponsemodel1.data!.list![0].businesspartnerid??"";
            remarkController.text=getactivityresponsemodel1.data!.list![0].remarks??"";
            strDefaultAssignedTo =getactivityresponsemodel1.data!.list![0].assignedtoname??"";
            strAssignedtoID = getactivityresponsemodel1.data!.list![0].assignedto ?? "";
            strDefaultbusinessprtners =getactivityresponsemodel1.data!.list![0].businesspartner;
            strDefaultStatus =getactivityresponsemodel1.data!.list![0].status;
            strstatusid = getactivityresponsemodel1.data!.list![0].statusid;
            strDefaultprioroty =getactivityresponsemodel1.data!.list![0].priority;
            // Define the date format
            DateFormat format = DateFormat("dd-MMM-yyyy hh:mm a");

            try {
              // Parse the date
              DateTime dateTime = format.parse(strDueDate!);
              // startDateController.text=dateTime.toString()??"";
              selectedDueDate=dateTime;
              print("Parsed Date: $dateTime"); // Output: Parsed Date: 2024-09-24 00:00:00.000
            } catch (e) {
              print("Error parsing date: $e");
            }
            print(selectedStatus);
            print(selectedPriority);
            print(selectedContactTo);
            print(selectedBusinessPartners);
            //  Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("The activity is already deleted."),
          ));
         /* Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
          ));*/
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
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
       //   Navigator.of(context).pop();
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
  Future<Future<ConfirmAction?>> _asyncAssignedToDialog(BuildContext context,
      List<LISTUSER> lossreasonlist  ) async {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    glossarList=lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Center(
            child: SizedBox(
                width: isDesktop ? 500 : double.infinity,
                child:AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  width: SizeConfig.blockSizeHorizontal!*100,
                  child:  Scaffold(
                    appBar: AppBar(

                      /*  leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.black,),
                  onPressed: ()
                  {

                    Navigator.of(context).pop();
                  }

              ),*/
                      actions: [
                        IconButton(
                            icon: Icon(Icons.close, color: Colors.black,),
                            onPressed: ()
                            {

                              Navigator.of(context).pop();
                            }

                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: Text('Assigned To',style: GoogleFonts.lato(
                          color: themeController.primaryColor,
                        fontWeight: FontWeight.w700,
                          fontSize: 20,
                          ),),

                      bottom: PreferredSize(
                        preferredSize: Size(0, 40),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,0, 0, 0),
                              child:
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [Colors.white, Colors.white],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: TextField(
                                    autofocus: false,
                                    textAlign: TextAlign.left,

                                    onChanged: (value) async{
                                      setState(() {
                                        glossarListOnSearch = glossarList
                                            .where((element) => element.uSERNAME!
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                            .toList();
                                        Navigator.of(context).pop(ConfirmAction.Cancel);
                                        ( _asyncAssignedToDialog(
                                            context,
                                            glossarList ));
                                      });
                                    },
                                    controller: _textEditingController,
                                    decoration:  InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: themeController.primaryColor, width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: themeController.primaryColor, width: 1.0),
                                      ),
                                      labelText: 'Search',

                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                        ),
                        child: _textEditingController.text.isNotEmpty &&
                            glossarListOnSearch.isEmpty
                            ? Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  'No results',
                                  style: TextStyle(
                                      fontFamily: 'Avenir',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff848484)),
                                ),
                              ),
                            )
                          ],
                        )
                            : ListView.builder(
                          itemCount: _textEditingController.text.isNotEmpty
                              ? glossarListOnSearch.length
                              : glossarList.length,

                          itemBuilder: (context, index) {

                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    strDefaultAssignedTo  =
                                    _textEditingController.text.isNotEmpty
                                        ? glossarListOnSearch[index].uSERNAME
                                        : glossarList[index].uSERNAME;
                                    selectedAssignedTo=_textEditingController.text.isNotEmpty
                                        ? glossarListOnSearch[index].uSERID
                                        : glossarList[index].uSERID;

                                  });


                                  Navigator.of(context).pop();
                                },

                                child:Column(
                                  children: [ Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child:Container(
                                        height: 30, // Set your desired height here
                                        child:
                                        ListTile(
                                          tileColor:Constant.isSelected? Colors.black : Colors.black,

                                          title: Text(

                                            _textEditingController.text.isNotEmpty
                                                ?glossarListOnSearch[index].uSERNAME!
                                                : glossarList[index].uSERNAME! ,
                                            style: TextStyle(
                                              color: Constant.isSelected? Colors.black : Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),)),

                                  ),
                                    SizedBox(

                                        height: 15),
                                    Divider(), // Add Divider here


                                  ],
                                )
                            );
                          },
                        )),
                  )),

              actions: <Widget>[




              ],
            )));




      },
    );
  }

  Future<Future<ConfirmAction?>> _asyncStatusDialog(BuildContext context,
      List<LISTSTATUS> lossreasonlist  ) async {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    statusList=lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Center(
            child: SizedBox(
                width: isDesktop ? 500 : double.infinity,
                child:AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  height: (80.0 * statusList!.length),
                  width: SizeConfig.blockSizeHorizontal!*100,
                  child:  Scaffold(
                    appBar: AppBar(

                      /*  leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.black,),
                  onPressed: ()
                  {

                    Navigator.of(context).pop();
                  }

              ),*/
                      actions: [
                        IconButton(
                            icon: Icon(Icons.close, color: Colors.black,),
                            onPressed: ()
                            {

                              Navigator.of(context).pop();
                            }

                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: Text('Status',style: TextStyle(
                          color: Color(0xFF12426E),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          fontFamily: 'Avenir'),),

                      bottom: PreferredSize(
                        preferredSize: Size(0, 40),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,0, 0, 0),
                              child:
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [Colors.white, Colors.white],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: TextField(
                                    autofocus: false,
                                    textAlign: TextAlign.left,

                                    onChanged: (value) async{
                                      setState(() {
                                        statusListOnSearch = statusList
                                            .where((element) => element.name!
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                            .toList();
                                        Navigator.of(context).pop(ConfirmAction.Cancel);
                                        ( _asyncStatusDialog(
                                            context,
                                            statusList ));
                                      });
                                    },
                                    controller: _textEditingStatusController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF12426E), width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF12426E), width: 1.0),
                                      ),
                                      labelText: 'Search',

                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                        ),
                        child: _textEditingStatusController.text.isNotEmpty &&
                            statusListOnSearch.isEmpty
                            ? Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  'No results',
                                  style: TextStyle(
                                      fontFamily: 'Avenir',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff848484)),
                                ),
                              ),
                            )
                          ],
                        )
                            : ListView.builder(
                          itemCount: _textEditingStatusController.text.isNotEmpty
                              ? statusListOnSearch.length
                              : statusList.length,

                          itemBuilder: (context, index) {

                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    strDefaultStatus  =
                                    _textEditingStatusController.text.isNotEmpty
                                        ? statusListOnSearch[index].name
                                        : statusList[index].name;
                                    selectedStatus=_textEditingStatusController.text.isNotEmpty
                                        ? statusListOnSearch[index].statusid
                                        : statusList[index].statusid;

                                  });


                                  Navigator.of(context).pop();
                                },

                                child:Column(
                                  children: [ Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child:Container(
                                        height: 30, // Set your desired height here
                                        child:
                                        ListTile(
                                          tileColor:Constant.isSelected? Colors.black : Colors.black,

                                          title: Text(

                                            _textEditingStatusController.text.isNotEmpty
                                                ?statusListOnSearch[index].name!
                                                : statusList[index].name! ,
                                            style: TextStyle(
                                              color: Constant.isSelected? Colors.black : Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),)),

                                  ),
                                    SizedBox(

                                        height: 15),
                                    Divider(), // Add Divider here


                                  ],
                                )
                            );
                          },
                        )),
                  )),

              actions: <Widget>[




              ],
            )));




      },
    );
  }
  Future<Future<ConfirmAction?>> _asyncPriorityDialog(BuildContext context,
      List<LISTSTATUS> lossreasonlist  ) async {
    final isDesktop = MediaQuery.of(context).size.width >= 700;


    priorotyList=lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Center(
            child: SizedBox(
                width: isDesktop ? 500 : double.infinity,
                child:AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  height: (80.0 * priorotyList!.length),
                  width: SizeConfig.blockSizeHorizontal!*100,
                  child:  Scaffold(
                    appBar: AppBar(

                      /*  leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.black,),
                  onPressed: ()
                  {

                    Navigator.of(context).pop();
                  }

              ),*/
                      actions: [
                        IconButton(
                            icon: Icon(Icons.close, color: Colors.black,),
                            onPressed: ()
                            {

                              Navigator.of(context).pop();
                            }

                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: Text('Priority',style: TextStyle(
                          color: Color(0xFF12426E),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          fontFamily: 'Avenir'),),

                      bottom: PreferredSize(
                        preferredSize: Size(0, 40),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,0, 0, 0),
                              child:
                              Container(

                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [Colors.white, Colors.white],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: TextField(
                                    autofocus: false,
                                    textAlign: TextAlign.left,

                                    onChanged: (value) async{
                                      setState(() {
                                        priorotyListOnSearch = priorotyList
                                            .where((element) => element.name!
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                            .toList();
                                        Navigator.of(context).pop(ConfirmAction.Cancel);
                                        ( _asyncPriorityDialog(
                                            context,
                                            priorotyList ));
                                      });
                                    },
                                    controller: _textEditingpriorotyController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF12426E), width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF12426E), width: 1.0),
                                      ),
                                      labelText: 'Search',

                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                        ),
                        child: _textEditingpriorotyController.text.isNotEmpty &&
                            priorotyListOnSearch.isEmpty
                            ? Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  'No results',
                                  style: TextStyle(
                                      fontFamily: 'Avenir',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff848484)),
                                ),
                              ),
                            )
                          ],
                        )
                            : ListView.builder(
                          itemCount: _textEditingpriorotyController.text.isNotEmpty
                              ? priorotyListOnSearch.length
                              : priorotyList.length,

                          itemBuilder: (context, index) {

                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    strDefaultprioroty  =
                                    _textEditingpriorotyController.text.isNotEmpty
                                        ? priorotyListOnSearch[index].name
                                        : priorotyList[index].name;
                                    selectedPriority=_textEditingpriorotyController.text.isNotEmpty
                                        ? priorotyListOnSearch[index].statusid
                                        : priorotyList[index].statusid;

                                  });


                                  Navigator.of(context).pop();
                                },

                                child:Column(
                                  children: [ Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child:Container(
                                        height: 30, // Set your desired height here
                                        child:
                                        ListTile(
                                          tileColor:Constant.isSelected? Colors.black : Colors.black,

                                          title: Text(

                                            _textEditingpriorotyController.text.isNotEmpty
                                                ?priorotyListOnSearch[index].name!
                                                : priorotyList[index].name! ,
                                            style: TextStyle(
                                              color: Constant.isSelected? Colors.black : Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),)),

                                  ),
                                    SizedBox(

                                        height: 15),
                                    Divider(), // Add Divider here


                                  ],
                                )
                            );
                          },
                        )),
                  )),

              actions: <Widget>[




              ],
            )));




      },
    );
  }
  Future<Future<ConfirmAction?>> _asyncBusinessPartnersDialog(BuildContext context,
      List<LISTSLEDEGER> lossreasonlist  ) async {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    businessprtnersList=lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return   Center(
            child: SizedBox(
                width: isDesktop ? 500 : double.infinity,
                child:AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  height: (80.0 * businessprtnersList!.length),
                  width: SizeConfig.screenWidth!*95,
                  child:  Scaffold(
                    appBar: AppBar(

                      /*  leading: IconButton(
                  icon: Icon(Icons.close, color: Colors.black,),
                  onPressed: ()
                  {

                    Navigator.of(context).pop();
                  }

              ),*/
                      actions: [
                        IconButton(
                            icon: Icon(Icons.close, color: Colors.black,),
                            onPressed: ()
                            {

                              Navigator.of(context).pop();
                            }

                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: Text('Business Partners',style: TextStyle(
                          color: Color(0xFF12426E),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          fontFamily: 'Avenir'),),

                      bottom: PreferredSize(
                        preferredSize: Size(0, 40),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,0, 0, 0),
                              child:
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [Colors.white, Colors.white],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: TextField(
                                    autofocus: false,
                                    textAlign: TextAlign.left,

                                    onChanged: (value) async{
                                      setState(() {
                                        businessprtnersListOnSearch = businessprtnersList
                                            .where((element) => element.cUSTOMERNAME!
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                            .toList();
                                        Navigator.of(context).pop(ConfirmAction.Cancel);
                                        ( _asyncBusinessPartnersDialog(
                                            context,
                                            businessprtnersList ));
                                      });
                                    },
                                    controller: _textEditingbusinessprtnersController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF12426E), width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF12426E), width: 1.0),
                                      ),
                                      labelText: 'Search',

                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                        ),
                        child: _textEditingbusinessprtnersController.text.isNotEmpty &&
                            businessprtnersListOnSearch.isEmpty
                            ? Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  'No results',
                                  style: TextStyle(
                                      fontFamily: 'Avenir',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff848484)),
                                ),
                              ),
                            )
                          ],
                        )
                            : ListView.builder(
                          itemCount: _textEditingbusinessprtnersController.text.isNotEmpty
                              ? businessprtnersListOnSearch.length
                              : businessprtnersList.length,

                          itemBuilder: (context, index) {

                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    strDefaultbusinessprtners  =
                                    _textEditingbusinessprtnersController.text.isNotEmpty
                                        ? businessprtnersListOnSearch[index].cUSTOMERNAME
                                        : businessprtnersList[index].cUSTOMERNAME;
                                    selectedBusinessPartners=_textEditingbusinessprtnersController.text.isNotEmpty
                                        ? businessprtnersListOnSearch[index].sLID
                                        : businessprtnersList[index].sLID;

                                  });


                                  Navigator.of(context).pop();
                                },

                                child:Column(
                                  children: [ Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child:Container(
                                        height: 30, // Set your desired height here
                                        child:
                                        ListTile(
                                          tileColor:Constant.isSelected? Colors.black : Colors.black,

                                          title: Text(

                                            _textEditingbusinessprtnersController.text.isNotEmpty
                                                ?businessprtnersListOnSearch[index].cUSTOMERNAME!
                                                : businessprtnersList[index].cUSTOMERNAME! ,
                                            style: TextStyle(
                                              color: Constant.isSelected? Colors.black : Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),)),

                                  ),
                                    SizedBox(

                                        height: 15),
                                    Divider(), // Add Divider here


                                  ],
                                )
                            );
                          },
                        )),
                  )),

              actions: <Widget>[




              ],
            )));




      },
    );
  }

}

// Modify SelectProductCode widget to accept a callback for selected value

class DueDateWidget extends StatefulWidget {
  const DueDateWidget({super.key, this.title, this.onDateSelected,this.strDueDate});

  final String? title;
  final String? strDueDate;
  final Function(DateTime)? onDateSelected;

  @override
  State<DueDateWidget> createState() => _DueDateWidget(strDueDate);
}

class _DueDateWidget extends State<DueDateWidget> {
  DateTime? selectedDate;
  String? strDueDate;
  _DueDateWidget(this.strDueDate);

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(selectedDate!);
      }
    }
  }
  Future<void> _selectDateTime(BuildContext context) async {
    // Step 1: Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return; // user cancelled

    // Step 2: Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
    );

    if (pickedTime == null) return; // user cancelled

    // Combine Date + Time
    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      selectedDate = finalDateTime;
    });

    // Callback
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(finalDateTime);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toString(),
            style: GoogleFonts.lato(
              color: Color(0xFF12426E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () => _selectDateTime(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,  // same as TextFormField

                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? DateFormat('dd-MMM-yyyy hh:mm a').format(selectedDate!)
                        : widget.strDueDate.toString() ?? "Select Date",
                    style: GoogleFonts.lato(fontSize: 16,fontWeight: FontWeight.w700,),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
