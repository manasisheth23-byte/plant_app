import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:erpflutter/models/fill_status_list_model.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/utils/SizeConfig.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Constants.dart';
import '../../Dashboard.dart';
import '../../app_colors.dart';
import '../../database/database_service.dart';
import '../../models/LoginResponseModel.dart';

import '../../models/add_task_request_model.dart';
import '../../models/add_task_response_model.dart';
import '../../models/business_partners_list_model.dart';
import '../../models/fill_user_list_model.dart';
import '../../models/sync_s_ledger_model.dart';
import '../../utils/CommonUtils.dart';
import 'activity_controller.dart';
import 'activity_list_screen.dart';

class AddTaskScreen extends StatefulWidget {
  LoginResponseModel? loginResponseModel;

  AddTaskScreen({required this.loginResponseModel});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState(loginResponseModel);
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Define separate variables for the selected values
  LoginResponseModel? loginResponseModel;
  String? selectSubject;
  String? detailstext;
  String? selectRemark;
  DateTime? selectedDueDate;
  BussinessPartnersListModel? selectedContactTo;
  final FocusNode _focusNode = FocusNode();

  _AddTaskScreenState(this.loginResponseModel);

  String? selectedAssignedTo;
  String? selectedStatus;
  String? selectedPriority;
  String? selectedBusinessPartners;
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
  DateTime? selectedDate;
  String? strDefaultAssignedTo = "Select Assigned To";
  String? strDefaultStatus = "Select Status";
  String? strDefaultprioroty = "Select Priority";
  String? strDefaultbusinessprtners = "Select Business Partner";
  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy hh:mm a');
  TextStyle titleStyle = TextStyle(
      color: Colors.blue, fontSize: 16, fontWeight: FontWeight.normal);
  TextEditingController startDateController = TextEditingController();
  Map<String, dynamic>? line;
  void _showSnackBar(String message) {
    Get.rawSnackbar(
      message: message,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }


  @override
  void dispose() {
    _textEditingController.dispose();
    _textEditingStatusController.dispose();
    _textEditingpriorotyController.dispose();
    _textEditingbusinessprtnersController.dispose();
    startDateController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  void _showAddedSnackbar(String message) {
    if(Platform.isWindows){
      Flushbar(
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        messageColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        margin: const EdgeInsets.all(8),
        flushbarPosition: FlushbarPosition.BOTTOM,
      ).show(context);
    }else{
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

  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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

  }
  int _idx = 0;
  final subjectFocus = FocusNode();
  final detailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
      return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
           /* Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ActivityListFragment(loginResponseModel: loginResponseModel,)),
            );*/
          },
          child:Center(
            child: SizedBox(
              width: isDesktop ? 700 : double.infinity,
              child: Scaffold(
                      resizeToAvoidBottomInset: true,

                      appBar: AppBar(
              centerTitle: Platform.isWindows ? true : false,
              elevation: 0,
              backgroundColor: const Color(0xFF12426E),
              foregroundColor: Colors.white,
              title: Text('Add Task',style:  GoogleFonts.lato(

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
                    } else if (selectedAssignedTo == null ||
                        selectedAssignedTo!.isEmpty) {
                      _showSnackBar("Please select AssignTo field");
                      return;
                    } else if (selectedDate == null ||
                        selectedDate
                            .toString()
                            .isEmpty) {
                      _showSnackBar("Please Enter Due Date");
                      return;
                    } else if (selectedStatus == null ||
                        selectedStatus
                            .toString()
                            .isEmpty) {
                      _showSnackBar("Please select Status");
                      return;
                    } else if (selectedPriority == null ||
                        selectedPriority
                            .toString()
                            .isEmpty) {
                      _showSnackBar("Please select Priority");
                      return;
                    } else {
                      AlertDialog alert = AlertDialog(
                        content: Row(children: [
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 7), child: Text(
                              "Loading...")),
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
                        activityRequestModel.xMLFILE!.aCTIVITYID = "0";
                        activityRequestModel.xMLFILE!.aSSIGNEDTO = selectedAssignedTo;
                        activityRequestModel.xMLFILE!.BUSINESSPARTNERID =
                            selectedBusinessPartners ?? "";
                        activityRequestModel.xMLFILE!.cONTACT = "";
                        activityRequestModel.xMLFILE!.rEFDOCID = "0";
                        activityRequestModel.xMLFILE!.rEFMID = "0";
                        activityRequestModel.xMLFILE!.rEMARKS = selectRemark ?? "";
                        activityRequestModel.xMLFILE!.fLAG = "I";
                        activityRequestModel.xMLFILE!.oRGSTRUCTID =orgStructId;
                        activityRequestModel.xMLFILE!.controlno =controlno;
                        activityRequestModel.xMLFILE!.pOSID =
                        loginResponseModel!.data!.posid!;
                        activityRequestModel.xMLFILE!.sUBJECT = selectSubject;
                        activityRequestModel.xMLFILE!.tASKDETAILS =  detailstext ?? "";
                        activityRequestModel.xMLFILE!.tYPEID = 2;
                        activityRequestModel.xMLFILE!.tOKEN =
                        loginResponseModel!.data!.token!;
                        activityRequestModel.xMLFILE!.sTARTTIME = "";
                        activityRequestModel.xMLFILE!.eNDTIME = "";
                        activityRequestModel.xMLFILE!.dUEDATE =
                            DateFormat('dd-MMM-yyyy hh:mm a').format(
                                selectedDate!);
                        activityRequestModel.xMLFILE!.sTATUSID = selectedStatus;
                        activityRequestModel.xMLFILE!.pRIORITYID = selectedPriority;
                        activityRequestModel.xMLFILE!.uSERID =
                        loginResponseModel!.data!.userid!;
                        //activityRequestModel.xMLFILE!.tASKDETAILS = selectSubject;

                        AddActivityTaskResponseModel? response;
                        response =
                        await Provider.of<ActivityController>(context, listen: false)
                            .AddActivityTaskDetails(activityRequestModel, context);

                        if (response != null) {
                          Navigator.pop(context); //for dissmiss progres dialog
                          _showAddedSnackbar(
                              response!.sysmsgs!.errormsgs!.toString());
                        //  Navigator.pop(context, true);
                           /* Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ActivityListFragment(
                                  loginResponseModel: loginResponseModel,)),
                          );*/

                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 10),
                              reverseTransitionDuration: const Duration(milliseconds: 10),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  ActivityListFragment(
                                    loginResponseModel: loginResponseModel,),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ActivityListFragment(
                                  loginResponseModel: loginResponseModel,)),
                          );

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
                   /* Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Dashboard(),));*/
                  },
                ),


              ],
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 10),
                      reverseTransitionDuration: const Duration(milliseconds: 10),
                      pageBuilder: (_, animation, secondaryAnimation) =>
                          ActivityListFragment(
                            loginResponseModel: loginResponseModel,),
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
                 /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        ActivityListFragment(
                          loginResponseModel: loginResponseModel,)),
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
               /*       Navigator.pushReplacement(
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

                      /*const NavigationDestination(icon: Icon(Icons.grid_view_outlined,size: 30), selectedIcon: Icon(Icons.grid_view,size: 30, color: C.blue), label: 'Shop Floor'),*/
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
                      body: Consumer<ActivityController>(
                builder: (context, data, _) {
                  return data.fillUserListModel == null ?

                  CircularProgressIndicator() : SingleChildScrollView(
                    child: Center(
                      child: PopScope(
                        child: Container(

                         /* width: Platform.isAndroid
                              ? double.infinity                       // FULL width on Android
                              : (MediaQuery.of(context).size.width * 0.40),*/
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
                              mainAxisSize: MainAxisSize.min, // Allows column to shrink
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   /* Row(
                                      children: [

                                        Text(
                                          'Subject',
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          '*', // Red star
                                          style: GoogleFonts.lato(color: Colors.red, fontSize: 20),
                                        ),
                                      ],
                                    ),*/
                                    _buildTitle("Subject", required: true),
                                    TextFormField(
                                      autofocus: false,
                                      focusNode: subjectFocus,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).unfocus();
                                      },
                                      maxLines: 2,      // initial height = 2 lines
                                       // expands automatically
                                      decoration: InputDecoration(
                                        hintText: 'Enter Subject',
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Icon(Icons.subject),
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
                                        alignLabelWithHint: true,
                                      ),
                                      onChanged: (value) {
                                        selectSubject = value;
                                      },
                                    ),
                                   /* Container(
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
                                    ),*/

                                  ],
                                ),
                               const SizedBox(height: 10),
                                _buildTitle("Task Owner", required: false),
                                TextFormField(
                                  autofocus: false,
                                  enabled: false,
                                  minLines: 1,      // initial height = 2 lines
                                  maxLines: null,   // expands automatically
                                  decoration: InputDecoration(
                                    hintText: loginResponseModel!.data!.username,
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Icon(Icons.task_outlined),
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
                                    alignLabelWithHint: true,
                                  ),
                                  onChanged: (value) {
                                    selectSubject = value;
                                  },
                                ),
                              /*  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Task Owner',
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
                                          hintText: loginResponseModel!.data!.username!,
                                          hintStyle: GoogleFonts.lato(

                                            color: Colors.grey,
                                          ),
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
                                const SizedBox(height: 10),
                                _buildTitle("Assigned To", required: true),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                               /*     Row(
                                      children: [
                                        Text(
                                          'Assigned To',
                                          style:  GoogleFonts.lato(
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          '*', // Red star
                                          style: GoogleFonts.lato(color: Colors.red, fontSize: 20),
                                        ),
                                      ],
                                    ),*/
                                  /*  if(data.fillUserListModel!.dATA != null)...[

                                      InkWell(
                                          onTap: () {

                                            _showOptionDialog(
                                                context,
                                                data.fillUserListModel!.dATA!.lIST!,
                                                    (newAssignedTo) {
                                                  setState(() {
                                                    strDefaultAssignedTo = newAssignedTo;
                                                  });
                                                },
                                                    (newAssignedToId) {
                                                  setState(() {
                                                    selectedAssignedTo = newAssignedToId;
                                                  });
                                                }
                                            );

                                          },
                                          child:  Container(
                                            width: Platform.isAndroid
                                                ? double.infinity                 // full width on Android
                                                : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                            height: Platform.isAndroid
                                                ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                                : MediaQuery.of(context).size.height * 0.055,

                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                          decoration: BoxDecoration(
                                          border: Border.all(
                                          color: Colors.grey,  // same as TextFormField

                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text(strDefaultAssignedTo ??
                                                    "Select Assigned to",
                                                  style: GoogleFonts.lato(
                                                    color: Colors.grey
                                                  )),


                                                const Row(
                                                    children: [
                                                      Text("", style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          color: AppColors.TEXTCOLOR),),
                                                      Padding(
                                                          padding: EdgeInsets.all(.0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            size: 35.0,)),

                                                    ]),

                                              ],
                                            ),
                                          )),

                                    ],*/
                                    if (data.fillUserListModel!.dATA != null) ...[
                                      InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          _showOptionDialog(
                                            context,
                                            data.fillUserListModel!.dATA!.lIST!,
                                                (newAssignedTo) {
                                              setState(() {
                                                strDefaultAssignedTo = newAssignedTo;
                                              });
                                            },
                                                (newAssignedToId) {
                                              setState(() {
                                                selectedAssignedTo = newAssignedToId;
                                              });
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.APPCOLOR.withOpacity(.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.person_outline,
                                                  color: AppColors.APPCOLOR,
                                                  size: 20,
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              Expanded(
                                                child: Text(
                                                  strDefaultAssignedTo ?? "Select Assigned To",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.lato(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: strDefaultAssignedTo == null
                                                        ? Colors.grey
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ),

                                              Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                color: Colors.grey.shade700,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],

                                  ],
                                ),

                                const SizedBox(height: 10),

                               /* DueDateWidget(
                                  title: "Due Date & Time",

                                  onDateSelected: (date) {
                                    setState(() {
                                      selectedDueDate = date;
                                    });
                                  },
                                ),*/
                                _buildTitle("Due Date & Time", required: true),
                                GestureDetector(
                                  onTap: () => _selectDateTime(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.event_available_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 20,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            selectedDate != null
                                                ? DateFormat(
                                              'dd-MMM-yyyy hh:mm a',
                                            ).format(selectedDate!)
                                                : "Select Date & Time",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: selectedDate == null
                                                  ? Colors.grey
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),

                                        Icon(
                                          Icons.calendar_month_rounded,
                                          color: Colors.grey.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildTitle("Business Partners", required: false),
                               /* Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Business Partners',
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),

                                      InkWell(
                                          onTap: () async{

                                            _showBusinessPartners(
                                                context,
                                                data.syncSLedgerModel!.dATA!.lIST!,
                                                    (newAssignedTo) {
                                                  setState(() {
                                                    strDefaultbusinessprtners = newAssignedTo;
                                                  });
                                                },
                                                    (newAssignedToId) {
                                                  setState(() {
                                                    selectedBusinessPartners = newAssignedToId;
                                                  });
                                                }
                                            );
                                          },
                                          child: Container(
                                            width: Platform.isAndroid
                                                ? double.infinity                 // full width on Android
                                                : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                            height: Platform.isAndroid
                                                ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                                : MediaQuery.of(context).size.height * 0.055,

                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,  // same as TextFormField

                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text(strDefaultbusinessprtners ??
                                                    "Select Business Partners",
                                                  style:  GoogleFonts.lato(
                                                      color: Colors.grey,
                                                      ),),


                                                Row(
                                                    children: [
                                                      Text("", style: const TextStyle(
                                                          fontFamily: 'Roboto',
                                                          color: AppColors.TEXTCOLOR),),
                                                      Padding(
                                                          padding: EdgeInsets.all(.0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            size: 35.0,)),

                                                    ]),

                                              ],
                                            ),
                                          )),
                                    ]
                                ),*/
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    _showBusinessPartners(
                                      context,
                                      data.syncSLedgerModel!.dATA!.lIST!,
                                          (newAssignedTo) {
                                        setState(() {
                                          strDefaultbusinessprtners = newAssignedTo;
                                        });
                                      },
                                          (newAssignedToId) {
                                        setState(() {
                                          selectedBusinessPartners = newAssignedToId;
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.business_center_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 20,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            strDefaultbusinessprtners ??
                                                "Select Business Partner",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: strDefaultbusinessprtners == null
                                                  ? Colors.grey
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),

                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey.shade700,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                _buildTitle("Status", required: true),
                               /* Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [ Text(
                                        'Status',
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                        Text(
                                          '*', // Red star
                                          style: GoogleFonts.lato(color: Colors.red, fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    if(data.typeList!.dATA != null)...[


                                      InkWell(
                                          onTap: () {

                                            _showStatus(
                                                context,
                                                data.typeList!.dATA!.lIST!,
                                                    (newAssignedTo) {
                                                  setState(() {
                                                    strDefaultStatus = newAssignedTo;
                                                  });
                                                },
                                                    (newAssignedToId) {
                                                  setState(() {
                                                    selectedStatus = newAssignedToId;
                                                  });
                                                }
                                            );
                                          },
                                          child: Container(
                                            width: Platform.isAndroid
                                                ? double.infinity                 // full width on Android
                                                : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                            height: Platform.isAndroid
                                                ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                                : MediaQuery.of(context).size.height * 0.055,

                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,  // same as TextFormField

                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text(strDefaultStatus ?? "Select Status",
                                                  style: GoogleFonts.lato(
                          color: Colors.grey),),


                                                Row(
                                                    children: [
                                                      Text("", style: const TextStyle(
                                                          fontFamily: 'Roboto',
                                                          color: AppColors.TEXTCOLOR),),
                                                      Padding(
                                                          padding: EdgeInsets.all(.0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            size: 35.0,)),

                                                    ]),

                                              ],
                                            ),
                                          )),
                                    ],
                                  ],
                                ),*/
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    _showStatus(
                                      context,
                                      data.typeList!.dATA!.lIST!,
                                          (newAssignedTo) {
                                        setState(() {
                                          strDefaultStatus = newAssignedTo;
                                        });
                                      },
                                          (newAssignedToId) {
                                        setState(() {
                                          selectedStatus = newAssignedToId;
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.flag_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 20,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            strDefaultStatus ?? "Select Status",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: strDefaultStatus == null
                                                  ? Colors.grey
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),

                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey.shade700,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                _buildTitle("Details", required: false),
                                SizedBox(
                                  width: Platform.isAndroid
                                      ? double.infinity
                                      : MediaQuery.of(context).size.width * 0.40,
                                  child: TextFormField(
                                    focusNode: detailFocus,
                                    autofocus: false,
                                    minLines: 2,      // initial height = 2 lines
                                    maxLines: null,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter Details',
                                      hintStyle: GoogleFonts.lato(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.only(bottom: 45),
                                        child: Icon(
                                          Icons.description_outlined,
                                          color: AppColors.APPCOLOR,
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
                                        borderSide: BorderSide(
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
                                      detailstext = value;
                                    },
                                  ),
                                ),
                           /*     Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [

                                        Text(
                                          'Details',
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),

                                      ],
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
                                          hintText: 'Enter Details',
                                          hintStyle: GoogleFonts.lato(
                                            fontSize: 12,
                                            color: Colors.grey
                                          ),
                                          border:  OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4),
                                            borderSide: BorderSide(color: Colors.grey),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                          isDense: true,
                                        ),

                                        onChanged: (value) {
                                          detailstext = value;
                                        },
                                      ),
                                    ),

                                  ],
                                ),*/
                                SizedBox(height: 10),
                                _buildTitle("Priority", required: true),
                                if (data.priorityList!.dATA != null) ...[
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      _showPriority(
                                        context,
                                        data.priorityList!.dATA!.lIST!,
                                            (newAssignedTo) {
                                          setState(() {
                                            strDefaultprioroty = newAssignedTo;
                                          });
                                        },
                                            (newAssignedToId) {
                                          setState(() {
                                            selectedPriority = newAssignedToId;
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.APPCOLOR.withOpacity(.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.priority_high_rounded,
                                              color: AppColors.APPCOLOR,
                                              size: 20,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Text(
                                              strDefaultprioroty ?? "Select Priority",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: strDefaultprioroty == null
                                                    ? Colors.grey
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),

                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.grey.shade700,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                             /*   Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [ Text(
                                        'Priority',
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                        Text(
                                          '*', // Red star
                                          style: GoogleFonts.lato(color: Colors.red, fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    if(data.priorityList!.dATA != null)...[


                                      InkWell(
                                          onTap: () {

                                            _showPriority(
                                                context,
                                                data.priorityList!.dATA!.lIST!,
                                                    (newAssignedTo) {
                                                  setState(() {
                                                    strDefaultprioroty = newAssignedTo;
                                                  });
                                                },
                                                    (newAssignedToId) {
                                                  setState(() {
                                                    selectedPriority = newAssignedToId;
                                                  });
                                                }
                                            );
                                          },
                                          child: Container(
                                            width: Platform.isAndroid
                                                ? double.infinity                 // full width on Android
                                                : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                            height: Platform.isAndroid
                                                ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                                : MediaQuery.of(context).size.height * 0.055,

                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,  // same as TextFormField
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text(strDefaultprioroty ?? "Select Priority",
                                                  style: GoogleFonts.lato(

                                                     color: Colors.grey),),


                                                Row(
                                                    children: [
                                                      Text("", style: const TextStyle(
                                                          fontFamily: 'Roboto',
                                                          color: AppColors.TEXTCOLOR),),
                                                      Padding(
                                                          padding: EdgeInsets.all(.0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            size: 35.0,)),

                                                    ]),

                                              ],
                                            ),
                                          )),
                                    ],
                                  ],
                                ),*/
                                SizedBox(height: 10),
                                /* Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Remark',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),

                                  TextFormField(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      hintText: 'Enter Remark',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                    ),
                                    onChanged: (value) {
                                      selectRemark = value;
                                    },
                                  ),

                                  Divider(color: Colors.grey),
                                ],
                              ),

                              SizedBox(
                                height: 10,
                              ),*/
                              ],
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
          )); // Mobile UI


  }


  // Validation method
// Method to show the progress dialog
  // Modified buildTextFieldWithLabel to accept onChanged callback
  Widget buildNumericTextFieldWithLabel(String label, String hint,
      Function(String) onChanged) {
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

  Future<List<BussinessPartnersListModel>> getPaginatedData(int pageNumber,
      String? searchText) async {
    // Calculate start and end indices for the current page
    final int startIndex = pageNumber * 25;
    final int endIndex = startIndex + 25;

    List<BussinessPartnersListModel> businessPartnersListModel;
    if (searchText != null && searchText.length > 2) {
      businessPartnersListModel =
      await DatabaseService().getBusinessPartnersSearchList1(
          'CUSTOMER', searchText);
    } else {
      businessPartnersListModel =
      await DatabaseService().getBusinessPartnersPaginateList1(
          'CUSTOMER', pageNumber);
    }

    // If the start index is beyond the list length, return an empty list
    // if (startIndex >= businessPartnersListModel.length) {
    //   return [];
    // }

    // Return the slice of the list for the requested page
    return businessPartnersListModel;
  }


  Future<Future<ConfirmAction?>> _asyncStatusDialog(BuildContext context,
      List<LISTSTATUS> lossreasonlist) async {
    statusList = lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: (300.0 * statusList!.length),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  height: (80.0 * statusList!.length),
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  child: Scaffold(
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            }

                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: Text('Status', style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Avenir'),),

                      bottom: PreferredSize(
                        preferredSize: Size(0, 40),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 0, 0, 0),
                                  child: TextField(
                                    autofocus: false,
                                    textAlign: TextAlign.left,

                                    onChanged: (value) async {
                                      setState(() {
                                        statusListOnSearch = statusList
                                            .where((element) =>
                                            element.name!
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                        Navigator.of(context).pop(
                                            ConfirmAction.Cancel);
                                        (_asyncStatusDialog(
                                            context,
                                            statusList));
                                      });
                                    },
                                    controller: _textEditingStatusController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 1.0),
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
                                      color: Color(0xff848484)),
                                ),
                              ),
                            )
                          ],
                        )
                            : ListView.builder(
                          itemCount: _textEditingStatusController.text
                              .isNotEmpty
                              ? statusListOnSearch.length
                              : statusList.length,

                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    strDefaultStatus =
                                    _textEditingStatusController.text.isNotEmpty
                                        ? statusListOnSearch[index].name
                                        : statusList[index].name;
                                    selectedStatus =
                                    _textEditingStatusController.text.isNotEmpty
                                        ? statusListOnSearch[index].statusid
                                        : statusList[index].statusid;
                                  });


                                  Navigator.of(context).pop();
                                },

                                child: Column(
                                  children: [ Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 0, 0, 0),
                                    child: Container(
                                        height: 30,
                                        // Set your desired height here
                                        child:
                                        ListTile(
                                          tileColor: Constant.isSelected
                                              ? Colors.black
                                              : Colors.black,

                                          title: Text(

                                            _textEditingStatusController.text
                                                .isNotEmpty
                                                ? statusListOnSearch[index]
                                                .name!
                                                : statusList[index].name!,
                                            style: TextStyle(
                                              color: Constant.isSelected
                                                  ? Colors.black
                                                  : Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),)),

                                  ),
                                    SizedBox(

                                        height: 10),
                                    Divider(), // Add Divider here


                                  ],
                                )
                            );
                          },
                        )),
                  )),

              actions: <Widget>[
              ],
            ));
      },
    );
  }

  Future<Future<ConfirmAction?>> _asyncBusinessPartnersDialog(
      BuildContext context,
      List<LISTSLEDEGER> lossreasonlist) async {
    businessprtnersList = lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                  width: SizeConfig.screenWidth! * 80,
                  height: (300.0 * businessprtnersList!.length),
                  child: AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius
                          .zero, // Set to zero for sharp corners
                    ),
                    content: new Container(
                        height: (80.0 * businessprtnersList!.length),
                        width: SizeConfig.screenWidth! * 95,
                        child: Scaffold(
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
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }

                              ),
                            ],
                            backgroundColor: Colors.white,
                            title: Text('Business Partners', style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Avenir'),),

                            bottom: PreferredSize(
                              preferredSize: Size(0, 40),
                              child: Column(
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 0, 0, 0),
                                    child:
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter),
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 0),
                                        child: TextField(
                                          autofocus: false,
                                          textAlign: TextAlign.left,

                                          onChanged: (value) async {
                                            setState(() {
                                              businessprtnersListOnSearch =
                                                  businessprtnersList
                                                      .where((element) =>
                                                      element.cUSTOMERNAME!
                                                          .toLowerCase()
                                                          .contains(
                                                          value.toLowerCase()))
                                                      .toList();
                                              // Navigator.of(context).pop(ConfirmAction.Cancel);
                                              // ( _asyncBusinessPartnersDialog(
                                              //     context,
                                              //     businessprtnersList ));
                                            });
                                          },
                                          controller: _textEditingbusinessprtnersController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: 1.0),
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
                              child: _textEditingbusinessprtnersController.text
                                  .isNotEmpty &&
                                  businessprtnersListOnSearch.isEmpty
                                  ? Column(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 0),
                                      child: Text(
                                        'No results',
                                        style: TextStyle(
                                            fontFamily: 'Avenir',
                                            fontSize: 12,
                                            color: Color(0xff848484)),
                                      ),
                                    ),
                                  )
                                ],
                              )
                                  : ListView.builder(
                                itemCount: _textEditingbusinessprtnersController
                                    .text.isNotEmpty
                                    ? businessprtnersListOnSearch.length
                                    : businessprtnersList.length,

                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          strDefaultbusinessprtners =
                                          _textEditingbusinessprtnersController
                                              .text.isNotEmpty
                                              ? businessprtnersListOnSearch[index]
                                              .cUSTOMERNAME
                                              : businessprtnersList[index]
                                              .cUSTOMERNAME;
                                          selectedBusinessPartners =
                                          _textEditingbusinessprtnersController
                                              .text.isNotEmpty
                                              ? businessprtnersListOnSearch[index]
                                              .sLID
                                              : businessprtnersList[index].sLID;
                                        });


                                        Navigator.of(context).pop();
                                      },

                                      child: Column(
                                        children: [ Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 0),
                                          child: Container(
                                              height: 30,
                                              // Set your desired height here
                                              child:
                                              ListTile(
                                                tileColor: Constant.isSelected
                                                    ? Colors.black
                                                    : Colors.black,

                                                title: Text(

                                                  _textEditingbusinessprtnersController
                                                      .text.isNotEmpty
                                                      ? businessprtnersListOnSearch[index]
                                                      .cUSTOMERNAME!
                                                      : businessprtnersList[index]
                                                      .cUSTOMERNAME!,
                                                  style: TextStyle(
                                                    color: Constant.isSelected
                                                        ? Colors.black
                                                        : Colors.black,
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
                  ));
            }
        );
      },
    );
  }

  Future<Future<ConfirmAction?>> _asyncPriorityDialog(BuildContext context,
      List<LISTSTATUS> lossreasonlist) async {
    priorotyList = lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: (300.0 * priorotyList!.length),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  height: (80.0 * priorotyList!.length),
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  child: Scaffold(
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            }

                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: Text('Priority', style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Avenir'),),

                      bottom: PreferredSize(
                        preferredSize: Size(0, 40),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 0, 0, 0),
                                  child: TextField(
                                    autofocus: false,
                                    textAlign: TextAlign.left,

                                    onChanged: (value) async {
                                      setState(() {
                                        priorotyListOnSearch = priorotyList
                                            .where((element) =>
                                            element.name!
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                        Navigator.of(context).pop(
                                            ConfirmAction.Cancel);
                                        (_asyncPriorityDialog(
                                            context,
                                            priorotyList));
                                      });
                                    },
                                    controller: _textEditingpriorotyController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 1.0),
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
                                      color: Color(0xff848484)),
                                ),
                              ),
                            )
                          ],
                        )
                            : ListView.builder(
                          itemCount: _textEditingpriorotyController.text
                              .isNotEmpty
                              ? priorotyListOnSearch.length
                              : priorotyList.length,

                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    strDefaultprioroty =
                                    _textEditingpriorotyController.text
                                        .isNotEmpty
                                        ? priorotyListOnSearch[index].name
                                        : priorotyList[index].name;
                                    selectedPriority =
                                    _textEditingpriorotyController.text
                                        .isNotEmpty
                                        ? priorotyListOnSearch[index].statusid
                                        : priorotyList[index].statusid;
                                  });


                                  Navigator.of(context).pop();
                                },

                                child: Column(
                                  children: [ Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 0, 0, 0),
                                    child: Container(
                                        height: 30,
                                        // Set your desired height here
                                        child:
                                        ListTile(
                                          tileColor: Constant.isSelected
                                              ? Colors.black
                                              : Colors.black,

                                          title: Text(

                                            _textEditingpriorotyController.text
                                                .isNotEmpty
                                                ? priorotyListOnSearch[index]
                                                .name!
                                                : priorotyList[index].name!,
                                            style: TextStyle(
                                              color: Constant.isSelected
                                                  ? Colors.black
                                                  : Colors.black,
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
            ));
      },
    );
  }

  Future<Future<ConfirmAction?>> _asyncAssignedToDialog(BuildContext context,
      List<LISTUSER> lossreasonlist) async {
    glossarList = lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  child: Scaffold(
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            }

                        ),
                      ],
                      backgroundColor: Colors.white,
                      title: Text('Assigned To', style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Avenir'),),

                      bottom: PreferredSize(
                        preferredSize: Size(0, 40),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 0, 0, 0),
                                  child: TextField(
                                    focusNode: _focusNode,
                                    autofocus: false,
                                    textAlign: TextAlign.left,

                                    onChanged: (value) async {
                                      setState(() {
                                        FocusScope.of(context).requestFocus(
                                            _focusNode);
                                        glossarListOnSearch = glossarList
                                            .where((element) =>
                                            element.uSERNAME!
                                                .toLowerCase()
                                                .contains(value.toLowerCase()))
                                            .toList();
                                        Navigator.of(context).pop(
                                            ConfirmAction.Cancel);
                                        FocusScope.of(context).requestFocus(
                                            _focusNode);

                                        (_asyncAssignedToDialog(
                                            context,
                                            glossarList));
                                      });
                                    },
                                    controller: _textEditingController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 1.0),
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
                                    strDefaultAssignedTo =
                                    _textEditingController.text.isNotEmpty
                                        ? glossarListOnSearch[index].uSERNAME
                                        : glossarList[index].uSERNAME;
                                    selectedAssignedTo =
                                    _textEditingController.text.isNotEmpty
                                        ? glossarListOnSearch[index].uSERID
                                        : glossarList[index].uSERID;
                                  });


                                  Navigator.of(context).pop();
                                },

                                child: Column(
                                  children: [ Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 0, 0, 0),
                                    child: Container(
                                        height: 30,
                                        // Set your desired height here
                                        child:
                                        ListTile(
                                          tileColor: Constant.isSelected
                                              ? Colors.black
                                              : Colors.black,

                                          title: Text(

                                            _textEditingController.text
                                                .isNotEmpty
                                                ? glossarListOnSearch[index]
                                                .uSERNAME!
                                                : glossarList[index].uSERNAME!,
                                            style: TextStyle(
                                              color: Constant.isSelected
                                                  ? Colors.black
                                                  : Colors.black,
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
            ));
      },
    );
  }


    /*void _showOptionDialog(BuildContext context, List<LISTUSER> lossreasonlist, Function(String) onAssignedToSelected , Function(String) onAssignedToSelectedId) {
      // Create the TextEditingController for the search field
      TextEditingController _searchController = TextEditingController();

      // Initialize the list and the search list
      List<LISTUSER> glossarList = lossreasonlist;
      List<LISTUSER> glossarListOnSearch = List.from(glossarList); // Copy the list for search

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('Assigned To'),
                content: Container(
                  width:  Platform.isAndroid
                      ? double.infinity                       // FULL width on Android
                      : (MediaQuery.of(context).size.width * 0.30),
                  height: Platform.isAndroid
                      ? double.infinity                       // FULL width on Android
                      : (MediaQuery.of(context).size.width * 0.30),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search ',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.search),
                            ),
                            // Listen to changes in the search field
                            onChanged: (query) {
                              setState(() {
                                if (query.isEmpty) {
                                  glossarListOnSearch = List.from(glossarList);
                                } else {
                                  glossarListOnSearch = glossarList
                                      .where((element) =>
                                      element.uSERNAME!
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                      .toList();
                                }
                              });
                            },
                          ),
                        ),
                        // List of items (Users)
                        Container(
                          height: 70 * glossarListOnSearch.length.toDouble(),
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: glossarListOnSearch.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(177, 232, 255, 100),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Pass the selected username to the parent widget
                                    onAssignedToSelected(glossarListOnSearch[index].uSERNAME!);
                                    onAssignedToSelectedId(glossarListOnSearch[index].uSERID!);
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: ListTile(
                                    title: Text(
                                      glossarListOnSearch[index].uSERNAME!,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }
*/
  void _showOptionDialog(
      BuildContext context,
      List<LISTUSER> lossreasonlist,
      Function(String) onAssignedToSelected,
      Function(String) onAssignedToSelectedId,
      )
  {
    TextEditingController _searchController = TextEditingController();

    List<LISTUSER> glossarList = lossreasonlist;
    List<LISTUSER> glossarListOnSearch = List.from(glossarList);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Container(
                width: Platform.isAndroid
                    ? double.infinity
                    : MediaQuery.of(context).size.width * .35,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .75,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_search_rounded,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Assigned To",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          splashRadius: 22,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// Search Field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search employee",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          if (query.isEmpty) {
                            glossarListOnSearch = List.from(glossarList);
                          } else {
                            glossarListOnSearch = glossarList
                                .where(
                                  (element) => element.uSERNAME!
                                  .toLowerCase()
                                  .contains(query.toLowerCase()),
                            )
                                .toList();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    /// User List
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: glossarListOnSearch.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = glossarListOnSearch[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              onAssignedToSelected(user.uSERNAME!);
                              onAssignedToSelectedId(user.uSERID!);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      user.uSERNAME!
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      user.uSERNAME!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
 /* void _showBusinessPartners(BuildContext context, List<LISTSLEDEGER> lossreasonlist, Function(String) onBusinessPartnersSelected, Function(String) onBusinessPartnersId) {
    // Show loader before opening the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Simulate a delay (e.g., data fetching or any other operation)
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pop(); // Dismiss the loader

      // Create the TextEditingController for the search field
      TextEditingController _searchController = TextEditingController();

      // Initialize the list and the search list
      List<LISTSLEDEGER> businessprtnersList = lossreasonlist;
      List<LISTSLEDEGER> glossarListOnSearch = List.from(businessprtnersList); // Copy the list for search

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('Business Partners'),
                content: Container(
                  width:  Platform.isAndroid
                      ? double.infinity                       // FULL width on Android
                      : (MediaQuery.of(context).size.width * 0.30),
                  height: Platform.isAndroid
                      ? double.infinity                       // FULL width on Android
                      : (MediaQuery.of(context).size.width * 0.30),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search ',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.search),
                            ),
                            // Listen to changes in the search field
                            onChanged: (query) {
                              setState(() {
                                if (query.isEmpty) {
                                  glossarListOnSearch = List.from(businessprtnersList);
                                } else {
                                  glossarListOnSearch = businessprtnersList
                                      .where((element) =>
                                      element.cUSTOMERNAME!
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                      .toList();
                                }
                              });
                            },
                          ),
                        ),
                        // List of items (Users)
                        Container(
                          height: 70 * glossarListOnSearch.length.toDouble(),
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: glossarListOnSearch.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(177, 232, 255, 100),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Pass the selected username to the parent widget
                                    onBusinessPartnersSelected(glossarListOnSearch[index].cUSTOMERNAME!);
                                    onBusinessPartnersId(glossarListOnSearch[index].sLID!);
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: ListTile(
                                    title: Text(
                                      glossarListOnSearch[index].cUSTOMERNAME!,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }
*/
  void _showBusinessPartners(
      BuildContext context,
      List<LISTSLEDEGER> lossreasonlist,
      Function(String) onBusinessPartnersSelected,
      Function(String) onBusinessPartnersId,
      )
  {
    /// Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pop();

      TextEditingController searchController = TextEditingController();

      List<LISTSLEDEGER> businessPartnersList = lossreasonlist;
      List<LISTSLEDEGER> searchList = List.from(businessPartnersList);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Container(
                  width: Platform.isAndroid
                      ? double.infinity
                      : MediaQuery.of(context).size.width * .35,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * .75,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.business_rounded,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Business Partners",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            splashRadius: 22,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// Search
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search Business Partner",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (query) {
                          setState(() {
                            if (query.isEmpty) {
                              searchList = List.from(businessPartnersList);
                            } else {
                              searchList = businessPartnersList
                                  .where((element) => element.cUSTOMERNAME!
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                                  .toList();
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      /// Business Partner List
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: searchList.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final partner = searchList[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                onBusinessPartnersSelected(
                                    partner.cUSTOMERNAME!);
                                onBusinessPartnersId(partner.sLID!);

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                      Colors.blue.shade100,
                                      child: Text(
                                        partner.cUSTOMERNAME!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        partner.cUSTOMERNAME!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// Close Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Close",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
/*
  void _showStatus(BuildContext context, List<LISTSTATUS> lossreasonlist, Function(String) onStatusSelected , Function(String) onStatusId) {
    // Create the TextEditingController for the search field
    TextEditingController _searchController = TextEditingController();

    // Initialize the list and the search list
    List<LISTSTATUS> statusList = lossreasonlist;
    List<LISTSTATUS> glossarListOnSearch = List.from(statusList); // Copy the list for search

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Status'),
              content: Container(
                width:  Platform.isAndroid
                    ? double.infinity                       // FULL width on Android
                    : (MediaQuery.of(context).size.width * 0.30),
                height: Platform.isAndroid
                    ? double.infinity                       // FULL width on Android
                    : (MediaQuery.of(context).size.width * 0.30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search ',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.search),
                          ),
                          // Listen to changes in the search field
                          onChanged: (query) {
                            setState(() {
                              if (query.isEmpty) {
                                glossarListOnSearch = List.from(statusList);
                              } else {
                                glossarListOnSearch = statusList
                                    .where((element) =>
                                    element.name!
                                        .toLowerCase()
                                        .contains(query.toLowerCase()))
                                    .toList();
                              }
                            });
                          },
                        ),
                      ),
                      // List of items (Users)
                      Container(
                        height: 70 * glossarListOnSearch.length.toDouble(),
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: glossarListOnSearch.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromRGBO(177, 232, 255, 100),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Pass the selected username to the parent widget
                                  onStatusSelected(glossarListOnSearch[index].name!);
                                  onStatusId(glossarListOnSearch[index].statusid!);
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: ListTile(
                                  title: Text(
                                    glossarListOnSearch[index].name!,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
*/
  void _showStatus(
      BuildContext context,
      List<LISTSTATUS> lossreasonlist,
      Function(String) onStatusSelected,
      Function(String) onStatusId,
      )
  {
    TextEditingController searchController = TextEditingController();

    List<LISTSTATUS> statusList = lossreasonlist;
    List<LISTSTATUS> searchList = List.from(statusList);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Container(
                width: Platform.isAndroid
                    ? double.infinity
                    : MediaQuery.of(context).size.width * .35,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .75,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.flag_circle_rounded,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Status",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          splashRadius: 22,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// Search
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search Status",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          if (query.isEmpty) {
                            searchList = List.from(statusList);
                          } else {
                            searchList = statusList
                                .where((element) => element.name!
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    /// Status List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: searchList.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final status = searchList[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              onStatusSelected(status.name!);
                              onStatusId(status.statusid!);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                    Colors.blue.shade100,
                                    child: Text(
                                      status.name!
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      status.name!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  /*void _showPriority(BuildContext context, List<LISTSTATUS> lossreasonlist, Function(String) onPrioritySelected , Function(String) onPriorityId) {
    // Create the TextEditingController for the search field
    TextEditingController _searchController = TextEditingController();

    // Initialize the list and the search list
    List<LISTSTATUS> priorotyList = lossreasonlist;
    List<LISTSTATUS> glossarListOnSearch = List.from(priorotyList); // Copy the list for search

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Priority'),
              content: Container(
                width:  Platform.isAndroid
                    ? double.infinity                       // FULL width on Android
                    : (MediaQuery.of(context).size.width * 0.30),
                height: Platform.isAndroid
                    ? double.infinity                       // FULL width on Android
                    : (MediaQuery.of(context).size.width * 0.30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search ',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.search),
                          ),
                          // Listen to changes in the search field
                          onChanged: (query) {
                            setState(() {
                              if (query.isEmpty) {
                                glossarListOnSearch = List.from(priorotyList);
                              } else {
                                glossarListOnSearch = priorotyList
                                    .where((element) =>
                                    element.name!
                                        .toLowerCase()
                                        .contains(query.toLowerCase()))
                                    .toList();
                              }
                            });
                          },
                        ),
                      ),
                      // List of items (Users)
                      Container(
                        height: 70 * glossarListOnSearch.length.toDouble(),
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: glossarListOnSearch.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromRGBO(177, 232, 255, 100),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Pass the selected username to the parent widget
                                  onPrioritySelected(glossarListOnSearch[index].name!);
                                  onPriorityId(glossarListOnSearch[index].statusid!);
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: ListTile(
                                  title: Text(
                                    glossarListOnSearch[index].name!,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
*/
  void _showPriority(
      BuildContext context,
      List<LISTSTATUS> lossreasonlist,
      Function(String) onPrioritySelected,
      Function(String) onPriorityId,
      )
  {
    TextEditingController searchController = TextEditingController();

    List<LISTSTATUS> priorityList = lossreasonlist;
    List<LISTSTATUS> searchList = List.from(priorityList);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Container(
                width: Platform.isAndroid
                    ? double.infinity
                    : MediaQuery.of(context).size.width * .35,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .75,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.priority_high_rounded,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Priority",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          splashRadius: 22,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// Search
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search Priority",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          if (query.isEmpty) {
                            searchList = List.from(priorityList);
                          } else {
                            searchList = priorityList
                                .where(
                                  (element) => element.name!
                                  .toLowerCase()
                                  .contains(query.toLowerCase()),
                            )
                                .toList();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    /// Priority List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: searchList.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final priority = searchList[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              onPrioritySelected(priority.name!);
                              onPriorityId(priority.statusid!);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      priority.name!
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      priority.name!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DueDateWidget extends StatefulWidget {
  const DueDateWidget({super.key, this.title, this.onDateSelected});

  final String? title;
  final Function(DateTime)? onDateSelected;

  @override
  State<DueDateWidget> createState() => _DueDateWidget();
}

class _DueDateWidget extends State<DueDateWidget> {
  DateTime? selectedDate;
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

 /* Future<void> _selectDate(BuildContext context) async {
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
*/
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(
      children: [
      Text(
            widget.title.toString(),
            style: GoogleFonts.lato(
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
        Text(
          '*', // Red star
          style: GoogleFonts.lato(color: Colors.red, fontSize: 20),
        ),
      ],
      ),
          GestureDetector(
            onTap: () => _selectDateTime(context),
            child: Container(
              width: Platform.isAndroid
                  ? double.infinity                 // full width on Android
                  : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

              height: Platform.isAndroid
                  ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                  : MediaQuery.of(context).size.height * 0.055,

              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
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
                        : "Select Date",
                    style: GoogleFonts.lato(fontSize: 16,color: Colors.grey),
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
