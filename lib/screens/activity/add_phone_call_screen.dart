import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/database/database_service.dart';
import 'package:erpflutter/helpers/api_helpers.dart';
import 'package:erpflutter/helpers/api_request.dart';
import 'package:erpflutter/models/activity_response_model.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/activity/activity_controller.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/business_partners_list_model.dart';
import '../../models/fill_status_list_model.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/global_variables.dart';
import 'activity_list_screen.dart';

class AddPhoneCallScreen extends StatefulWidget {
  ListElement? editPhoneCallInfo;
  LoginResponseModel? loginResponseModel;
  AddPhoneCallScreen({this.editPhoneCallInfo, required this.loginResponseModel, super.key});

  @override
  State<AddPhoneCallScreen> createState() => _AddPhoneCallScreenState(editPhoneCallInfo,loginResponseModel);
}

class _AddPhoneCallScreenState extends State<AddPhoneCallScreen> {
  ListElement? editPhoneCallInfo;
  LoginResponseModel? loginResponseModel;
  _AddPhoneCallScreenState(this.editPhoneCallInfo,this.loginResponseModel);

  TextStyle titleStyle = GoogleFonts.lato(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold);

  String? selectedType;
  BussinessPartnersListModel? selectedContactTo;
  String? selectedCallPurpose;
  String? selectedCallType;

  TextEditingController contactPersonController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController callResultController = TextEditingController();
  TextEditingController startDateController = TextEditingController();

  String? timeString;
  String? durationString;

  List<BussinessPartnersListModel>? syncSLedgerModel = [];
  List<BussinessPartnersListModel>? syncSLedgerModelOnSearch = [];
  TextEditingController contactToSearchController = TextEditingController();
  TextEditingController contactToController = TextEditingController();

  void getData() async {
    syncSLedgerModel = await DatabaseService().getBusinessPartnersList();
    setState(() {});

    if (editPhoneCallInfo != null) {
      // Set selected contact
      for (int i = 0; i < syncSLedgerModel!.length; i++) {
        if (editPhoneCallInfo!.contactpersonid == syncSLedgerModel![i].sLID) {
          setState(() {
            selectedContactTo = syncSLedgerModel![i];
            contactToController.text = selectedContactTo!.sLDESC ?? '';
          });
          break;
        }
      }

      // Set selected type, call purpose, and call type
      FillStatusListModel? typeList = Provider.of<ActivityController>(context, listen: false).typeList;
      FillStatusListModel? callPurposeList = Provider.of<ActivityController>(context, listen: false).callPurposeList;
      FillStatusListModel? callTypeList = Provider.of<ActivityController>(context, listen: false).callTypeList;

      for (int j = 0; j < typeList!.dATA!.lIST!.length; j++) {
        if (editPhoneCallInfo!.callplantypeid == typeList.dATA!.lIST![j].statusid) {
          selectedType = editPhoneCallInfo!.callplantypeid;
          break;
        }
      }

      for (int j = 0; j < callPurposeList!.dATA!.lIST!.length; j++) {
        if (editPhoneCallInfo!.callpurposedid == callPurposeList.dATA!.lIST![j].statusid) {
          selectedCallPurpose = editPhoneCallInfo!.callpurposedid;
          break;
        }
      }

      for (int j = 0; j < callTypeList!.dATA!.lIST!.length; j++) {
        if (editPhoneCallInfo!.calltypeid == callTypeList.dATA!.lIST![j].statusid) {
          selectedCallType = editPhoneCallInfo!.calltypeid;
          break;
        }
      }

      // Set other fields
      contentController.text = editPhoneCallInfo!.content ?? '';
      callResultController.text = editPhoneCallInfo!.callresult ?? '';
      contactPersonController.text = editPhoneCallInfo!.contactperson ?? '';
      contactNumberController.text = editPhoneCallInfo!.contactpersonnumber ?? '';
      subjectController.text = editPhoneCallInfo!.subject ?? '';
      startDateController.text = editPhoneCallInfo!.starttime != null ? getDateString(editPhoneCallInfo!.starttime!) : '';
      timeString = editPhoneCallInfo!.starttime != null ? getTimeString(editPhoneCallInfo!.starttime!) : '';
      durationString = editPhoneCallInfo!.callduration;
    }

    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
    super.initState();
  }

  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

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

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        timeString = '$hour:${picked.minute.toString().padLeft(2, '0')} $period';
      });
    } else {
      setState(() {
        timeString = 'Select Time';
      });
    }
  }

  String getDateString(String inputDate) {
    DateFormat inputFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    DateTime parsedDate = inputFormat.parse(inputDate);
    return DateFormat('dd-MMM-yyyy').format(parsedDate);
  }

  String getTimeString(String inputDate) {
    DateFormat inputFormat = DateFormat('dd-MMM-yyyy hh:mm a');
    DateTime parsedDate = inputFormat.parse(inputDate);
    return DateFormat('hh:mm a').format(parsedDate);
  }
  @override
  void dispose() {
    contactPersonController.dispose();
    contactNumberController.dispose();
    subjectController.dispose();
    contentController.dispose();
    callResultController.dispose();
    startDateController.dispose();
    super.dispose();
  }
  Widget _dateCard(
      String text,
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildTitle(
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
  final subjectFocus = FocusNode();
  final contentFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          //Navigator.pop(context);
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
                  appBar: AppBar(
            elevation: 0,
            centerTitle: Platform.isWindows ? true : false,
            backgroundColor: const Color(0xFF12426E),
            foregroundColor: Colors.white,
            title: Text(
              editPhoneCallInfo == null
                  ? "Add Phone Call"
                  : "Edit Phone Call",
              style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              )
            ),

            actions: [
              IconButton(
                onPressed: () async {
                  String flag = 'I';

                  if (editPhoneCallInfo != null) {
                    flag = 'E';
                  }

                  if (selectedContactTo == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please select Contact To field!"),
                    ));
                    return;
                  }

                  if (contactPersonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please enter Contact Person!"),
                    ));
                    return;
                  }

                  if (contactNumberController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please enter Contact Number!"),
                    ));
                    return;
                  }

                  if (subjectController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please enter subject!"),
                    ));
                    return;
                  }

                  if (startDateController.text.trim().isEmpty || timeString == null || (timeString != null && timeString!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please select start Date-Time!"),
                    ));
                    return;
                  }

                  String dateString = "${startDateController.text.trim()} $timeString";
                  final DateFormat format = DateFormat('dd-MMM-yyyy hh:mm a');
                  DateTime dateTime = format.parse(dateString);

                  AlertDialog alert = AlertDialog(
                    content: Row(children: [
                      CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                      Container(margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
                    ]),
                  );

                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );

                  var response = await ApiRequest.post(
                    url: AppConfig.BASE_URL + AddActivity,
                    body: json.encode({
                      "XMLFILE": {
                        "ACTIVITYID": editPhoneCallInfo != null ? editPhoneCallInfo!.activityid : "0",
                        "CALLDURATION": durationString ?? '',
                        "CALLPLANTYPEID": selectedType,
                        "CALLPURPOSE": "",
                        "CALLPURPOSEID": selectedCallPurpose,
                        "CALLRESULT": callResultController.text.trim(),
                        "CALLTYPE": "",
                        "CALLTYPEID": selectedCallType,
                        "CONTACT": contactPersonController.text.trim(),
                        "CONTACTNO": contactNumberController.text.trim(),
                        "CONTACTPERSONID": selectedContactTo!.sLID,
                        "CONTENT": contentController.text.trim(),
                        "FLAG": flag,
                        "ORGSTRUCTID": orgStructId,
                        "POSID": posId,
                        "STARTTIME": format.format(dateTime), // Use the correct format here
                        "SUBJECT": subjectController.text.trim(),
                        "TYPEID": 1,
                        "TOKEN": token,
                        "USERID": userId,
                        "STATUSID": 1
                      }
                    }),
                  );

                  print('response---> ${response.body}');
                  final responseData = jsonDecode(response.body);
                  if (response.statusCode == 200) {
                    Navigator.pop(context); // Dismiss progress dialog
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(editPhoneCallInfo != null ? "Phone Call Edited Successfully!" : "Phone Call Added Successfully!"),
                    ));
                    Navigator.of(context).pop(true);
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
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ActivityListFragment(loginResponseModel: loginResponseModel,)),
                    );*/
                  }else{
                    Navigator.pop(context); // Dismiss progress dialog
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(responseData['Data']['Message']),
                    ));
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
              ),
              if (editPhoneCallInfo != null)
                IconButton(
                  onPressed: () async {
                    AlertDialog alert = AlertDialog(
                      content: Row(children: [
                        CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                        Container(margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
                      ]),
                    );

                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );

                    var response = await ApiRequest.post(
                      url: AppConfig.BASE_URL + AddActivity,
                      body: json.encode({
                        "XMLFILE": {
                          "ACTIVITYID": editPhoneCallInfo != null ? editPhoneCallInfo!.activityid : "0",
                          "CALLDURATION": "",
                          "CALLPLANTYPEID": "",
                          "CALLPURPOSE": "",
                          "CALLPURPOSEID": 0,
                          "CALLRESULT": "",
                          "CALLTYPE": "",
                          "CALLTYPEID": 0,
                          "CONTACT": "",
                          "CONTACTNO": "",
                          "CONTACTPERSONID": 0,
                          "CONTENT": "",
                          "FLAG": "D",
                          "ORGSTRUCTID": 0,
                          "POSID": 0,
                          "STARTTIME": "",
                          "SUBJECT": "",
                          "TYPEID": 1,
                          "TOKEN": token,
                          "USERID": userId,
                          "STATUSID": 1
                        }
                      }),
                    );

                    print('response---> ${response.body}');

                    if (response.statusCode == 200) {
                      Navigator.pop(context); // Dismiss progress dialog
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Phone Call Deleted Successfully!"),
                      ));
                      Navigator.of(context).pop(true);
                    }
                  },
                  icon:const Icon(Icons.delete_outline),
                ),
              SizedBox(width: 8)
            ],
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
               // Navigator.pop(context);
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
               /* Navigator.pushReplacement(
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
                    /*Navigator.pushReplacement(
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
                return data.dataLoaded == false || (editPhoneCallInfo != null && selectedContactTo == null)
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                       /* width:Platform.isAndroid
                            ? double.infinity                       // FULL width on Android
                            : (MediaQuery.of(context).size.width * 0.40),*/
                        decoration:BoxDecoration(
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
                              if (editPhoneCallInfo != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.call,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subjectController.text.isEmpty
                                                ? "Phone Call"
                                                : subjectController.text,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            contactToController.text,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                             /* RichText(
                                text: TextSpan(
                                  text: 'Type ',
                                  style: titleStyle,
                                  children:  <TextSpan>[
                                    TextSpan(text: '*', style: GoogleFonts.lato(color: Colors.red)),
                                  ],
                                ),
                              ),
                              Container(
                                width: Platform.isAndroid
                                    ? double.infinity                 // full width on Android
                                    : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                height: Platform.isAndroid
                                    ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                    : MediaQuery.of(context).size.height * 0.055,

                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    items: data.typeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option.statusid,
                                        child: Text(option.name!),
                                      );
                                    }).toList(),
                                    value: selectedType,
                                    hint: const Text('Select Type'),
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedType = value;
                                      });
                                    },
                                  ),
                                ),
                              ),*/
                              if (editPhoneCallInfo != null)
                              SizedBox(height: 10),
                              buildTitle("Type", required: true),
                             /* Container(
                                padding: const EdgeInsets.only(
                                  left: 0,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                      isExpanded: true,
                                      value: selectedType,
                                      hint: const Text("Select Type"),
                                      items: data.typeList!.dATA!.lIST!.map((option) {
                                        return DropdownMenuItem<String>(
                                          value: option.statusid,
                                          child: Text(option.name!),
                                        );
                                      }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedType = value;
                                      });
                                    },
                                  ),
                                ),
                              ),*/
                              /*Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    value: selectedType,

                                    hint: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.category_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Select Type",
                                          style: GoogleFonts.lato(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),

                                    items: data.typeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option.statusid,
                                        child: Text(
                                          option.name!,
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedType = value;
                                      });
                                    },

                                    iconStyleData: IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    buttonStyleData: const ButtonStyleData(
                                      height: 50,
                                    ),

                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                             /* Container(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  right: 12,
                                  top: 4,
                                  bottom: 4
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    value: selectedType,

                                    hint: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.category_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Select Type",
                                          style: GoogleFonts.lato(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),

                                    items: data.typeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option.statusid,
                                        child: Text(
                                          option.name!,
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedType = value;
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      height: 50,
                                      padding: EdgeInsets.zero,
                                    ),

                                    iconStyleData: IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),

                                    menuItemStyleData: const MenuItemStyleData(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                              DropdownButton2<String>(
                                isExpanded: true,
                                value: selectedType,

                                hint: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.APPCOLOR.withOpacity(.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.category_outlined,
                                        color: AppColors.APPCOLOR,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Select Type",
                                      style: GoogleFonts.lato(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                items: data.typeList!.dATA!.lIST!.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option.statusid,
                                    child: Text(
                                      option.name!,
                                      style: GoogleFonts.lato(fontSize: 14),
                                    ),
                                  );
                                }).toList(),

                                /// Keeps the icon visible after selection
                                selectedItemBuilder: (context) {
                                  return data.typeList!.dATA!.lIST!.map((option) {
                                    return Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.category_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            option.name!,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },

                                onChanged: (String? value) {
                                  setState(() {
                                    selectedType = value;
                                  });
                                },

                                buttonStyleData: const ButtonStyleData(
                                  height: 50,
                                  padding: EdgeInsets.zero,
                                ),

                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey.shade700,
                                  ),
                                ),

                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                ),

                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                              SizedBox(height: 10),
                              buildTitle("Contact To ", required: true),
                             /* RichText(
                                text: TextSpan(
                                  text: 'Contact To ',
                                  style: titleStyle,
                                  children:  <TextSpan>[
                                    TextSpan(text: '*', style: GoogleFonts.lato(color: Colors.red)),
                                  ],
                                ),
                              ),*/

                            /*  InkWell(
                                  onTap: (){
                                    contactToDialog(context);
                                  },
                                  child: Container(
                                    width: Platform.isAndroid
                                        ? double.infinity                 // full width on Android
                                        : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                    height: Platform.isAndroid
                                        ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                        : MediaQuery.of(context).size.height * 0.055,

                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(contactToController.text.isEmpty ? "Select Contact To" : contactToController.text, style: const TextStyle(
                                            fontFamily: 'Roboto',   fontWeight: FontWeight.normal),),


                                        Row(
                                            children: [
                                              Text("", style: const TextStyle(
                                                  fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                              Padding(
                                                  padding: EdgeInsets.all(.0),
                                                  child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                            ]),

                                      ],
                                    ),
                                  )),*/
                              /*InkWell(
                                onTap: () {
                                  contactToDialog(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          contactToController.text.isEmpty
                                              ? "Select Contact To"
                                              : contactToController.text,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                ),
                              ),*/
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  contactToDialog(context);
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
                                          Icons.contact_phone_outlined,
                                          color: AppColors.APPCOLOR,
                                          size: 20,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Text(
                                          contactToController.text.isEmpty
                                              ? "Select Contact To"
                                              : contactToController.text,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: contactToController.text.isEmpty
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
                              buildTitle("Contact Person ", required: true),
                           /*   RichText(
                                text: TextSpan(
                                  text: 'Contact Person ',
                                  style: titleStyle,
                                  children:  <TextSpan>[
                                    TextSpan(text: '*', style: GoogleFonts.lato(color: Colors.red)),
                                  ],
                                ),
                              ),*/
                            /*  Container(
                                width: Platform.isAndroid
                                    ? double.infinity                 // full width on Android
                                    : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                height: Platform.isAndroid
                                    ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                    : MediaQuery.of(context).size.height * 0.055,

                                child: TextField(
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Contact Person',
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



                                  controller: contactPersonController,
                                ),
                              ),*/
                            /*  TextFormField(
                                controller: contactPersonController,
                                decoration: InputDecoration(
                                  hintText: "Enter Contact Person",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),*/
                              TextFormField(
                                controller: contactPersonController,
                                decoration: InputDecoration(
                                  hintText: "Enter Contact Person",
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
                                      Icons.person_outline,
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
                              ),
                              SizedBox(height: 10),
                              buildTitle("Contact Number ", required: true),
                             /* RichText(
                                text: TextSpan(
                                  text: 'Contact Number ',
                                  style: titleStyle,
                                  children: const <TextSpan>[
                                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),*/
                             /* TextField(
                                autofocus: false,
                                decoration: InputDecoration(
                                  hintText: 'Enter Contact Number',
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
                                keyboardType: TextInputType.phone,
                                controller: contactNumberController,
                                maxLength: 10,
                              ),*/
                             /* TextFormField(
                                controller: contactNumberController,
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: "Enter Contact Person",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),*/
                              TextFormField(
                                controller: contactNumberController,
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: "Enter Contact Number",
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
                                      Icons.phone_outlined,
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

                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.APPCOLOR,
                                      width: 1.2,
                                    ),
                                  ),

                                  counterText: "",

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              buildTitle("Subject ", required: true),
                             /* RichText(
                                text: TextSpan(
                                  text: 'Subject ',
                                  style: titleStyle,
                                  children: const <TextSpan>[
                                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),*/
            /*
                              TextFormField(
                                controller: subjectController,
                                decoration: InputDecoration(
                                  hintText: "Enter Subject",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),*/
                              TextFormField(
                                  focusNode: subjectFocus,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                maxLines: 2,
                                minLines: 1,
                                controller: subjectController,
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
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
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
                              ),
                              SizedBox(height: 10),
                              buildTitle("Call Purpose ", required: true),
                             /* RichText(
                                text: TextSpan(
                                  text: 'Call Purpose ',
                                  style: titleStyle,
                                  children: const <TextSpan>[
                                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),*/
                            /*  Container(
                                width: Platform.isAndroid
                                    ? double.infinity                 // full width on Android
                                    : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                height: Platform.isAndroid
                                    ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                    : MediaQuery.of(context).size.height * 0.055,

                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: Text('Please Select'),
                                    items: data.callPurposeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                          value: option.statusid,
                                          child: Text(option.name!));
                                    }).toList(),
                                    value: selectedCallPurpose,
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedCallPurpose = value ?? selectedCallPurpose;
                                      });
                                    },
                                  ),
                                ),
                              ),*/
                              const SizedBox(height: 0),
                              Container(
                                height: 58,
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    value: selectedCallPurpose,

                                    /// Hint
                                    hint: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.call_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "Select Call Purpose",
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              color: Colors.grey.shade600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    /// Items
                                    items: data.callPurposeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option.statusid,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.call_outlined,
                                              size: 18,
                                              color: AppColors.APPCOLOR,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                option.name ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                    /// Selected Item
                                    selectedItemBuilder: (context) {
                                      return data.callPurposeList!.dATA!.lIST!.map((option) {
                                        return Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: AppColors.APPCOLOR.withOpacity(.08),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.call_outlined,
                                                color: AppColors.APPCOLOR,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                option.name ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },

                                    onChanged: (value) {
                                      setState(() {
                                        selectedCallPurpose = value;
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      height: 56,
                                      padding: EdgeInsets.zero,
                                    ),

                                    iconStyleData: IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey.shade700,
                                        size: 24,
                                      ),
                                    ),

                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 320,
                                      elevation: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      offset: const Offset(0, 8),
                                    ),

                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 48,
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                              ),
                       /*       Container(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  right: 12,
                                  top: 4,
                                  bottom: 4
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    value: selectedCallPurpose,

                                    hint: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.call_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Select Call Purpose",
                                          style: GoogleFonts.lato(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),

                                    items: data.callPurposeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option.statusid,
                                        child: Text(
                                          option.name ?? "",
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    selectedItemBuilder: (context) {
                                      return data.callPurposeList!.dATA!.lIST!.map((option) {
                                        return Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.APPCOLOR.withOpacity(.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.call_outlined,
                                                color: AppColors.APPCOLOR,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                option.name ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },

                                    onChanged: (value) {
                                      setState(() {
                                        selectedCallPurpose = value;
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      height: 50,
                                      padding: EdgeInsets.zero,
                                    ),

                                    iconStyleData: IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),

                                    menuItemStyleData: const MenuItemStyleData(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                              SizedBox(height: 10),

                           /*   RichText(
                                text: TextSpan(
                                  text: 'Call Type ',
                                  style: titleStyle,
                                  children: const <TextSpan>[
                                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),*/
                             /* Container(
                                width: Platform.isAndroid
                                    ? double.infinity                 // full width on Android
                                    : MediaQuery.of(context).size.width * 0.40,   // 40% width on Desktop

                                height: Platform.isAndroid
                                    ? MediaQuery.of(context).size.height * 0.055             // Mobile height
                                    : MediaQuery.of(context).size.height * 0.055,

                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: Text('None'),
                                    items: data.callTypeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                          value: option.statusid,
                                          child: Text(option.name!));
                                    }).toList(),
                                    value: selectedCallType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedCallType = value ?? selectedCallType;
                                      });
                                    },
                                  ),
                                ),
                              ),*/
                              buildTitle("Call Type",required: true),

                              const SizedBox(height: 0),

                             /* Container(
                                padding: const EdgeInsets.only(
                                  left: 0,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    value: selectedCallType,

                                    hint: const Text(
                                      "None",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    items: data.callTypeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option.statusid,
                                        child: Text(
                                          option.name ?? "",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),

                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedCallType = value;
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                      padding: EdgeInsets.zero, // removes extra left space
                                    ),

                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                      ),
                                    ),

                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),*/
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  right: 12,
                                  top: 4,
                                  bottom: 4
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    value: selectedCallType,

                                    hint: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.phone_in_talk_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Select Call Type",
                                          style: GoogleFonts.lato(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),

                                    items: data.callTypeList!.dATA!.lIST!.map((option) {
                                      return DropdownMenuItem<String>(
                                        value: option.statusid,
                                        child: Text(
                                          option.name ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    selectedItemBuilder: (context) {
                                      return data.callTypeList!.dATA!.lIST!.map((option) {
                                        return Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.APPCOLOR.withOpacity(.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.phone_in_talk_outlined,
                                                color: AppColors.APPCOLOR,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                option.name ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },

                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedCallType = value;
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      height: 50,
                                      padding: EdgeInsets.zero,
                                    ),

                                    iconStyleData: IconStyleData(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),

                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 42,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              buildTitle("Content",required: false),
                             /* Text('Content',
                                  style: titleStyle
                              ),*/
                             /* TextField(
                                autofocus: false,
                                decoration: InputDecoration(
                                  hintText: 'Enter Content',
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
                                controller: contentController,
                              ),*/
                          /*    TextFormField(
                                controller: contentController,
                                decoration: InputDecoration(
                                  hintText: "Enter Content",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),*/
                              TextFormField(
                                controller: contentController,
                                focusNode: contentFocus,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                minLines: 1,
                                maxLines: null,
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
                                      Icons.notes_outlined,
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
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
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
                              ),
                              SizedBox(height: 10),

                          /*    RichText(
                                text: TextSpan(
                                  text: 'Start Date-Time ',
                                  style: titleStyle,
                                  children: const <TextSpan>[
                                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectDate(context, startDateController),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12.0),
                                        decoration: BoxDecoration(
                                          // borderRadius: BorderRadius.circular(8.0),
                                            border: Border(
                                                bottom: BorderSide(color: Colors.grey))),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 125,
                                              child: Text(
                                                startDateController.text.trim().isEmpty
                                                    ? 'Select Date'
                                                    : startDateController.text.trim(),
                                                style: TextStyle(
                                                  color: startDateController.text.trim().isEmpty
                                                      ? Colors.grey
                                                      : Colors.black,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(Icons.calendar_month)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => selectTime(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 12.0),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent, // Background color
                                            // borderRadius: BorderRadius.circular(8.0),
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey)) // Rounded corners
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 125,
                                              child: Text(
                                                timeString ?? 'Select Time',
                                                // Display the selected time or default
                                                style: TextStyle(
                                                  color: timeString == null
                                                      ? Colors.grey
                                                      : Colors.black, // Text color
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(Icons.access_time_outlined)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),*/
                              buildTitle(
                                "Start Date & Time",
                                required: true,
                              ),

                              const SizedBox(height: 8),

                          /*    Row(
                                children: [
                                  Expanded(
                                    child: _dateCard(
                                      startDateController.text.trim().isEmpty
                                          ? "Select Date"
                                          : startDateController.text.trim(),
                                      Icons.calendar_month,
                                          () => _selectDate(
                                        context,
                                        startDateController,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: _dateCard(
                                      timeString ?? "Select Time",
                                      Icons.access_time,
                                          () => selectTime(context),
                                    ),
                                  ),
                                ],
                              ),*/
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => _selectDate(
                                        context,
                                        startDateController,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.calendar_month_rounded,
                                                color: Colors.blue.shade700,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                startDateController.text.trim().isEmpty
                                                    ? "Select Date"
                                                    : startDateController.text.trim(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: startDateController.text.trim().isEmpty
                                                      ? Colors.grey
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => selectTime(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.access_time_rounded,
                                                color: Colors.orange.shade700,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                timeString ?? "Select Time",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: timeString == null
                                                      ? Colors.grey
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              /*if (editPhoneCallInfo != null)...[
                                Text('Duration', style: titleStyle),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DurationSelectDialog();
                                      },
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          durationString = value;
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent, // Background color
                                        // borderRadius: BorderRadius.circular(8.0),
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey)) // Rounded corners
                                    ),
                                    child: Text(
                                      ((durationString == null) || (durationString != null && durationString!.isEmpty)) ? 'Select Duration' : durationString!,
                                      // Display the selected time or default
                                      style: TextStyle(
                                        color: durationString == null
                                            ? Colors.grey
                                            : Colors.black, // Text color
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],*/
                              if (editPhoneCallInfo != null) ...[
                                buildTitle("Duration"),

                                const SizedBox(height: 8),

                                /*_dateCard(
                                  ((durationString == null) || durationString!.isEmpty)
                                      ? "Select Duration"
                                      : durationString!,
                                  Icons.timer_outlined,
                                      () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DurationSelectDialog();
                                      },
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          durationString = value;
                                        });
                                      }
                                    });
                                  },
                                ),*/
                                InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DurationSelectDialog();
                                      },
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          durationString = value;
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.timer_outlined,
                                            color: Colors.green.shade700,
                                            size: 20,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Duration",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (durationString == null || durationString!.isEmpty)
                                                    ? "Select Duration"
                                                    : durationString!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: (durationString == null ||
                                                      durationString!.isEmpty)
                                                      ? Colors.grey
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

            /*
                              Text('Call Result', style: titleStyle),*/
                              buildTitle(
                                "Call Result",
                                required: false,
                              ),
                          /*    TextFormField(
                                controller: callResultController,
                                decoration: InputDecoration(
                                  hintText: "Enter Call Result",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),*/
                              TextFormField(
                                controller: callResultController,
                                minLines: 2,
                                maxLines: null,
                                decoration: InputDecoration(
                                  labelText: "Call Result",
                                  hintText: "Enter call outcome or remarks",
                                  prefixIcon: const Icon(
                                    Icons.call_outlined,
                                    color: Color(0xFF12426E),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF12426E),
                                      width: 1.5,
                                    ),
                                  ),

                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              /*TextField(
                                autofocus: false,
                                decoration: InputDecoration(
                                  hintText: 'Enter Call Result',
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
                                controller: callResultController,
                              ),*/
                              SizedBox(height: 10),


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
        ));
  }
  Widget fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2744),
            ),
          ),
          if (required)
            const Text(
              " *",
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(
      String hint,
      IconData icon,
      ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: AppColors.APPCOLOR,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
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
          width: 1.5,
        ),
      ),
    );
  }

  Widget pickerCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.APPCOLOR),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<List<BussinessPartnersListModel>> getPaginatedData(int pageNumber, String? searchText) async{
    // Calculate start and end indices for the current page
    final int startIndex = pageNumber * 25;
    final int endIndex = startIndex + 25;

    List<BussinessPartnersListModel> businessPartnersListModel;
    if(searchText != null && searchText.length > 2){
      businessPartnersListModel = await DatabaseService().getBusinessPartnersSearchList1('CUSTOMER', searchText);
    } else {
      businessPartnersListModel = await DatabaseService().getBusinessPartnersPaginateList1('CUSTOMER', pageNumber);
    }

    // If the start index is beyond the list length, return an empty list
    // if (startIndex >= businessPartnersListModel.length) {
    //   return [];
    // }

    // Return the slice of the list for the requested page
    return businessPartnersListModel;
  }

  /*void contactToDialog(BuildContext context) {
    // businessprtnersList=lossreasonlist;
    showDialog(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  StatefulBuilder(
            builder: (context, setState) {
              return Container(
                  width:  Platform.isAndroid
                      ? double.infinity                       // FULL width on Android
                      : (MediaQuery.of(context).size.width * 0.30),
                  height: Platform.isAndroid
                      ? double.infinity                       // FULL width on Android
                      : (MediaQuery.of(context).size.width * 0.30),
                  child:AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Set to zero for sharp corners
                    ),
                    content: new Container(
                        width:  Platform.isAndroid
                            ? double.infinity                       // FULL width on Android
                            : (MediaQuery.of(context).size.width * 0.30),
                        height: Platform.isAndroid
                            ? double.infinity                       // FULL width on Android
                            : (MediaQuery.of(context).size.width * 0.30),
                        child:  Scaffold(
                          appBar: AppBar(


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
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
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
                                              syncSLedgerModelOnSearch = syncSLedgerModel!
                                                  .where((element) => element.sLDESC!
                                                  .toLowerCase()
                                                  .contains(value.toLowerCase()))
                                                  .toList();
                                              // Navigator.of(context).pop(ConfirmAction.Cancel);
                                              // ( _asyncBusinessPartnersDialog(
                                              //     context,
                                              //     businessprtnersList ));
                                            });
                                          },
                                          controller: contactToSearchController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blue, width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blue, width: 1.0),
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
                              child: contactToSearchController.text.isNotEmpty &&
                                  syncSLedgerModelOnSearch!.isEmpty
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
                                itemCount: contactToSearchController.text.isNotEmpty
                                    ? syncSLedgerModelOnSearch!.length
                                    : syncSLedgerModel!.length,

                                itemBuilder: (context, index) {

                                  return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedContactTo  = contactToSearchController.text.isNotEmpty
                                              ? syncSLedgerModelOnSearch![index]
                                              : syncSLedgerModel![index];
                                          contactToController.text = contactToSearchController.text.isNotEmpty
                                              ? syncSLedgerModelOnSearch![index].sLDESC ?? ''
                                              : syncSLedgerModel![index].sLDESC ?? '';

                                          contactToSearchController.clear();
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
                                                tileColor: Colors.black,

                                                title: Text(
                                                  contactToSearchController.text.isNotEmpty
                                                      ?syncSLedgerModelOnSearch![index].sLDESC!
                                                      : syncSLedgerModel![index].sLDESC! ,
                                                  // syncSLedgerModel![index].sLDESC ?? '',
                                                  style: TextStyle(
                                                    color: Colors.black,
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
    ).then((value) {
      setState(() {});
    },);
  }*/
  void contactToDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  maxHeight: MediaQuery.of(context).size.height * .80,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
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
                            Icons.business_rounded,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
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
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// Search
                    TextField(
                      controller: contactToSearchController,
                      decoration: InputDecoration(
                        hintText: "Search Business Partner",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          syncSLedgerModelOnSearch = syncSLedgerModel!
                              .where((element) => element.sLDESC!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    /// List
                    Expanded(
                      child: contactToSearchController.text.isNotEmpty &&
                          syncSLedgerModelOnSearch!.isEmpty
                          ? const Center(
                        child: Text(
                          "No Results Found",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      )
                          : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: contactToSearchController.text.isNotEmpty
                            ? syncSLedgerModelOnSearch!.length
                            : syncSLedgerModel!.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = contactToSearchController
                              .text.isNotEmpty
                              ? syncSLedgerModelOnSearch![index]
                              : syncSLedgerModel![index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                selectedContactTo = item;

                                contactToController.text =
                                    item.sLDESC ?? "";

                                contactToSearchController.clear();
                              });

                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius:
                                BorderRadius.circular(16),
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
                                      item.sLDESC!
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color:
                                        Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.sLDESC ?? "",
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
    ).then((value) {
      setState(() {});
    });
  }
}

class DurationSelectDialog extends StatefulWidget {
  @override
  _DurationSelectDialogState createState() => _DurationSelectDialogState();
}

class _DurationSelectDialogState extends State<DurationSelectDialog> {
  int selectedHours = 0;
  int selectedMinutes = 0;

  void incrementHours() {
    setState(() {
      if (selectedHours < 23) selectedHours++;
    });
  }

  void decrementHours() {
    setState(() {
      if (selectedHours > 0) selectedHours--;
    });
  }

  void incrementMinutes() {
    setState(() {
      if (selectedMinutes < 59) selectedMinutes++;
    });
  }

  void decrementMinutes() {
    setState(() {
      if (selectedMinutes > 0) selectedMinutes--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Duration',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours Selector
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_drop_up),
                      onPressed: incrementHours,
                    ),
                    Text(
                      selectedHours.toString().padLeft(2, '0'),
                      style: TextStyle(fontSize: 24.0),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: decrementHours,
                    ),
                  ],
                ),
                SizedBox(width: 10.0),
                Text(
                  ':',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(width: 10.0),
                // Minutes Selector
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_drop_up),
                      onPressed: incrementMinutes,
                    ),
                    Text(
                      selectedMinutes.toString().padLeft(2, '0'),
                      style: TextStyle(fontSize: 24.0),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      onPressed: decrementMinutes,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(
                    '${selectedHours.toString().padLeft(2, '0')}:${selectedMinutes.toString().padLeft(2, '0')}');
              },
              child: Text(
                'Confirm',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
