import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui';
import 'dart:ui';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../Constants.dart';
import '../../Dashboard.dart';
import '../../app_colors.dart';
import '../../database/database_service.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/activity_response_model.dart';
import '../../models/activity_task_request_model.dart';
import '../../models/add_event_request_model.dart';
import '../../models/add_event_response_model.dart';
import '../../models/business_partners_list_model.dart';
import '../../models/fill_status_list_model.dart';
import '../../models/fill_user_list_model.dart';
import '../../models/sync_s_ledger_model.dart';
import '../../repository/LoginApiRepository.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../alerts/alerts_list.dart';
import 'activity_controller.dart';
import 'activity_list_screen.dart';
import 'package:http/http.dart' as http;

class EditEventScreen extends StatefulWidget {
  LoginResponseModel? loginResponseModel;
  String? strActivityId;
  String? strActivityName;

  EditEventScreen({required this.loginResponseModel,required this.strActivityId,required this.strActivityName});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState(loginResponseModel,strActivityId,strActivityName);
}

class _EditEventScreenState extends State<EditEventScreen> {
  // Define separate variables for the selected values
  LoginResponseModel? loginResponseModel;
  String? selectSubject;
  String? taskowner;
  String? selectRemark;
  DateTime? selectedDueDate;
  String? strActivityName;
  BussinessPartnersListModel? selectedContactTo;
  String? strActivityId;
  String? selectedAssignedTo;
  String? selectedStatus;
  String? selectedPriority;
  TextEditingController _subjectController = TextEditingController();

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
  String? durationStartString;
  String? durationEndString;
  String? starttimeString;
  String? strDefaultAssignedTo="Select Assigned To";
  String? strDefaultStatus="Select Status";
  String? strDefaultprioroty="Select Priority";
  String? strDefaultbusinessprtners="Select Business Partner";
  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');
  TextStyle titleStyle = GoogleFonts.lato(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.normal);
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  LISTUSER? chosenuserValue;
  Map<String, dynamic>? line;
  List<LISTUSER> adduserlist = [];
  List<ATTENDEES> attendessList = [];
  ActivityResponseModel getactivityresponsemodel1 = new ActivityResponseModel();
  final _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  bool _isSearching = true;
  bool _isLoading = false;
  String _selectedLocation = '';
  double lat=0.0;
  double lng=0.0;
  String _placeId = '';
   String PLACES_API_KEY = "AIzaSyDEgk5Wh6lWkCsOif_KSMJ_i7sw6ON1c2E";
  final FocusNode _searchFocus = FocusNode();
  _EditEventScreenState(this.loginResponseModel,this.strActivityId,this.strActivityName);

  final FocusNode _focusNode = FocusNode(); // Create a FocusNode
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
  Future<void> getPlaceDetails(String placeId, String apiKey) async {
    String detailsBaseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String detailsRequest = '$detailsBaseURL?place_id=$placeId&key=$apiKey';
    var response = await http.get(Uri.parse(detailsRequest));
    var data = json.decode(response.body);

    if (response.statusCode == 200) {
      lat = data['result']['geometry']['location']['lat'];
      lng = data['result']['geometry']['location']['lng'];

      print('Latitude: $lat, Longitude: $lng');
      // You can now use the latitude and longitude as needed
    } else {
      throw Exception('Failed to load place details');
    }
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
  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        // Format the time with AM/PM
        final hour = picked.hourOfPeriod == 0
            ? 12
            : picked.hourOfPeriod; // Convert 0 to 12 for AM/PM formatting
        final period = picked.period == DayPeriod.am
            ? 'AM'
            : 'PM'; // Check if it's AM or PM

        // Update the duration string
        durationEndString =
        '$hour:${picked.minute.toString().padLeft(2, '0')} $period'; // Add leading 0 for minute
      });
    } else {
      setState(() {
        durationEndString = 'Select Duration'; // Default text if not set
      });
    }
  }
  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        // Format the time with AM/PM
        final hour = picked.hourOfPeriod == 0
            ? 12
            : picked.hourOfPeriod; // Convert 0 to 12 for AM/PM formatting
        final period = picked.period == DayPeriod.am
            ? 'AM'
            : 'PM'; // Check if it's AM or PM

        // Update the duration string
        durationStartString =
        '$hour:${picked.minute.toString().padLeft(2, '0')} $period'; // Add leading 0 for minute
      });
    } else {
      setState(() {
        durationStartString = 'Select Duration'; // Default text if not set
      });
    }
  }
  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_controller.text == _controller.text) {
        getSuggestion(_controller.text);
      }
    });
  }

  Future<void> launchMapForLocation(String location) async {
    try {
      final encodedLocation = Uri.encodeComponent(location);
      final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch map';
      }
    } catch (e) {
      print('Error launching map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open map')),
      );
    }
  }
  void launchGoogleMaps(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps?q=$latitude,$longitude';

    // Check if the URL can be launched
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch Google Maps with the provided location.';
    }
  }

  void getSuggestion(String input) async {
    if (input.isEmpty) {
      setState(() {
        _placeList = [];
      });
      return;
    }


    setState(() {
      _isLoading = true;
    });

    try {
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (kDebugMode) {
        print('Response data:');
        print(data);
      }

      if (response.statusCode == 200) {
        setState(() {
          _placeList = data['predictions'];

        });

        if (_placeList.isNotEmpty) {
          String placeId = _placeList[0]['place_id'];
          _placeId=_placeList[0]['place_id'];
          print('_placeId: $_placeId');
          await getPlaceDetails(placeId, PLACES_API_KEY);
        }
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  final TextEditingController searchController = TextEditingController();
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if(strActivityName != null && strActivityName == "EditEventActivity") {
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
           /* Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
                  ActivityListFragment(
                    loginResponseModel: loginResponseModel,)),
            );*/
          }else if(strActivityName != null && strActivityName == "EditEventNotification") {

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
          }
        },
        child:Center(
          child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: AppBar(
                              elevation: 0,
                              centerTitle: Platform.isWindows ? true : false,
                              backgroundColor: const Color(0xFF12426E),
                              foregroundColor: Colors.white,
                              title: const Text(
                                "Edit Event",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              actions: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline),
                                  onPressed: () async {

                                    try {

                                      DateFormat inputFormat1 = DateFormat('dd-MMM-yyyy h:mm a');
                                      DateTime parsedDate1 = inputFormat1.parse(startDateController.text+ " "+durationStartString!);

                                      // Step 2: Format the DateTime object to the desired output string
                                      DateFormat outputFormat1 = DateFormat('yyyy-MM-dd HH:mm:ss');
                                      String outputDate1 = outputFormat1.format(parsedDate1);

                                      print(outputDate1); // Output: 2024-10-03 05:24:00
                                      DateFormat inputFormat2 = DateFormat('dd-MMM-yyyy h:mm a');
                                      DateTime parsedDate2 = inputFormat2.parse(endDateController.text+ " "+durationEndString!);

                                      // Step 2: Format the DateTime object to the desired output string
                                      DateFormat outputFormat2 = DateFormat('yyyy-MM-dd HH:mm:ss');
                                      String outputDate2 = outputFormat2.format(parsedDate2);

                                      print(outputDate2);

                                      DateTime dt1 = DateTime.parse( outputDate1);
                                      DateTime dt2 = DateTime.parse(outputDate2);



                                      if (selectSubject == null || selectSubject!.isEmpty) {
                  _showSnackBar("Please enter Subject");
                  return;
                                      }else if (adduserlist == null || adduserlist.length ==0) {
                  _showSnackBar("Please select Attendess");
                  return;
                                      }else if (startDateController.text == null || startDateController.text.isEmpty || durationStartString == null || durationStartString!.isEmpty) {
                  _showSnackBar("Please enter Start Date-Time");
                  return;
                                      }else if (endDateController.text == null || endDateController.text.isEmpty || durationEndString == null || durationEndString!.isEmpty) {
                  _showSnackBar("Please enter End Date-Time");
                  return;
                                      } else if(dt1.compareTo(dt2) == 0){
                  _showSnackBar("Please enter End Date-Time greater than Start Date-Time");
                                      } else if(dt1.compareTo(dt2) > 0){
                  _showSnackBar("Please enter End Date-Time greater than Start Date-Time");
                                      } else
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
                    attendessList.clear();
                    for(int k=0;k<adduserlist.length;k++) {
                      ATTENDEES attendess = new ATTENDEES();
                      attendess.aTTENDEESUSERID=adduserlist[k].uSERID;

                      attendessList.add(attendess);
                    }

                    AddEventRequestModel activityRequestModel = new AddEventRequestModel();
                    activityRequestModel.xMLFILE = new XMLFILEEVENT();
                    activityRequestModel.xMLFILE!.aCTIVITYID = strActivityId;
                    activityRequestModel.xMLFILE!.aSSIGNEDTO = "0";
                    activityRequestModel.xMLFILE!.bUSINESSPARTNERID = selectedBusinessPartners;

                    activityRequestModel.xMLFILE!.cONTACT = "";
                    activityRequestModel.xMLFILE!.rEFDOCID = "0";
                    activityRequestModel.xMLFILE!.rEFMID = "0";
                    activityRequestModel.xMLFILE!.rEMARKS = "";
                    activityRequestModel.xMLFILE!.fLAG = "E";
                    activityRequestModel.xMLFILE!.oRGSTRUCTID =loginResponseModel!.data!.orgstrucid!;
                    activityRequestModel.xMLFILE!.pOSID = loginResponseModel!.data!.posid!;
                    activityRequestModel.xMLFILE!.sUBJECT = selectSubject;
                    activityRequestModel.xMLFILE!.tYPEID = 4;
                    activityRequestModel.xMLFILE!.tOKEN = loginResponseModel!.data!.token!;
                    activityRequestModel.xMLFILE!.sTARTTIME = durationStartString! ?? "";
                    activityRequestModel.xMLFILE!.sTARTDATE = startDateController.text;
                    activityRequestModel.xMLFILE!.eNDTIME = durationEndString! ?? "";

                    activityRequestModel.xMLFILE!.eNDDATE = endDateController.text;
                    activityRequestModel.xMLFILE!.dUEDATE ="";
                    activityRequestModel.xMLFILE!.lATITUDE =lat.toString() ?? "0.0";
                    activityRequestModel.xMLFILE!.lONGITUDE =lng.toString() ??"0.0";
                    activityRequestModel.xMLFILE!.sTATUSID = "0";
                    activityRequestModel.xMLFILE!.uSERID = loginResponseModel!.data!.userid!;
                    activityRequestModel.xMLFILE!.aTTENDEES =attendessList;


                    AddEventResponseModel? response;  response = await Provider.of<ActivityController>(context, listen: false)
                        .AddActivityEventDetails(activityRequestModel,context);

                    if (response != null) {
                      Navigator.pop(context); //for dissmiss progres dialog


                      _showAddedSnackbar(response!.sYSMSGS!.eRRORMSGS!.toString());
                     if(strActivityName != null && strActivityName == "EditEventActivity") {
                     /*  Navigator.pushReplacement(
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
                     }else if(strActivityName != null && strActivityName == "EditEventNotification") {
                     /*  Navigator.of(context).pushReplacement(MaterialPageRoute(
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
                     }

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
                                    } catch (e) {
                                      print("Error parsing date: $e");
                                      if (selectSubject == null || selectSubject!.isEmpty) {
                  _showSnackBar("Please enter Subject");
                  return;
                                      }else if (adduserlist == null || adduserlist.length ==0) {
                  _showSnackBar("Please select Attendess");
                  return;
                                      }else if (startDateController.text == null || startDateController.text.isEmpty || durationStartString == null || durationStartString!.isEmpty) {
                  _showSnackBar("Please enter Start Date-Time");
                  return;
                                      }else if (endDateController.text == null || endDateController.text.isEmpty || durationEndString == null || durationEndString!.isEmpty) {
                  _showSnackBar("Please enter End Date-Time");
                  return;
                                      }
                                    }
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
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


                            CommonUtils commonUtils = new CommonUtils();
                            bool isConnectivity = await commonUtils.check();
                            if (isConnectivity) {
                              attendessList.clear();
                              for(int k=0;k<adduserlist.length;k++) {
                                ATTENDEES attendess = new ATTENDEES();
                                attendess.aTTENDEESUSERID=adduserlist[k].uSERID;

                                attendessList.add(attendess);
                              }

                              AddEventRequestModel activityRequestModel = new AddEventRequestModel();
                              activityRequestModel.xMLFILE = new XMLFILEEVENT();
                              activityRequestModel.xMLFILE!.aCTIVITYID = strActivityId;
                              activityRequestModel.xMLFILE!.aSSIGNEDTO = "0";
                              activityRequestModel.xMLFILE!.bUSINESSPARTNERID = "";

                              activityRequestModel.xMLFILE!.cONTACT = "";
                              activityRequestModel.xMLFILE!.rEFDOCID = "0";
                              activityRequestModel.xMLFILE!.rEFMID = "0";
                              activityRequestModel.xMLFILE!.rEMARKS = "";
                              activityRequestModel.xMLFILE!.fLAG = "D";
                              activityRequestModel.xMLFILE!.oRGSTRUCTID =loginResponseModel!.data!.orgstrucid!;
                              activityRequestModel.xMLFILE!.pOSID = loginResponseModel!.data!.posid!;
                              activityRequestModel.xMLFILE!.sUBJECT = selectSubject;
                              activityRequestModel.xMLFILE!.tYPEID = 4;
                              activityRequestModel.xMLFILE!.tOKEN = loginResponseModel!.data!.token!;
                              activityRequestModel.xMLFILE!.sTARTTIME =  "";
                              activityRequestModel.xMLFILE!.sTARTDATE = "";
                              activityRequestModel.xMLFILE!.eNDTIME =  "";

                              activityRequestModel.xMLFILE!.eNDDATE = "";
                              activityRequestModel.xMLFILE!.dUEDATE ="";
                              activityRequestModel.xMLFILE!.lATITUDE ="";
                              activityRequestModel.xMLFILE!.lONGITUDE ="";
                              activityRequestModel.xMLFILE!.sTATUSID = "0";
                              activityRequestModel.xMLFILE!.uSERID = loginResponseModel!.data!.userid!;
                              activityRequestModel.xMLFILE!.aTTENDEES =attendessList;


                              AddEventResponseModel? response;  response = await Provider.of<ActivityController>(context, listen: false)
                                  .AddActivityEventDetails(activityRequestModel,context);

                              if (response != null) {

                                _showAddedSnackbar(response!.sYSMSGS!.eRRORMSGS!.toString());
                                if(strActivityName != null && strActivityName == "EditEventActivity") {
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
                                }else if(strActivityName != null && strActivityName == "EditEventNotification") {
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
                                }
                              } else {



                              }
                            } else {

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
                                  if(strActivityName != null && strActivityName == "EditEventActivity") {
                              //Navigator.pop(context);
                                /*    Navigator.pushReplacement(
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

                                  }else if(strActivityName != null && strActivityName == "EditEventNotification") {
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
                                  /* Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
                                    ));*/
                                  }
                                },
                              ),
                                    ))),
              bottomNavigationBar: Builder(
                  builder: (context) {
                    return NavigationBarTheme(
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
                    );
                  }
              ),
                  body: Consumer<ActivityController>(
                builder: (context, data, _) {
                if (data.fillUserListModel == null) {
                return const Center(
                child: CircularProgressIndicator(),
                );
                }

                return SafeArea(
                child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,

                child: Center(
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


                child: Container(
                  padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:  Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color:
                                            Colors.purple.withOpacity(.12),
                                            borderRadius:
                                            BorderRadius.circular(
                                                12),
                                          ),
                                          child: Icon(
                                            Icons.event,
                                            color: Colors.purple,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _subjectController.text,
                                                style: const TextStyle(

                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                taskowner ?? "",
                                                style:
                                                const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                  FontWeight.w700,
                                                   color: Colors.blue
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 20),

                              /*  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
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
                                          style: GoogleFonts.lato(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: _subjectController,
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

                                  ],
                                ),*/
                                const SizedBox(height: 20),
                                /*_buildTitle("Subject", required: true),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _subjectController,
                                  decoration: InputDecoration(
                                    hintText: "Enter Subject",
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    selectSubject = value;
                                  },
                                ),*/
                                _buildTitle("Subject", required: true),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _subjectController,
                                  decoration: InputDecoration(
                                    hintText: "Enter Subject",
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    selectSubject = value;
                                  },
                                ),
                                SizedBox(height: 10),
                                _buildTitle("Attendees", required: true),

                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<LISTUSER>(
                                      isExpanded: true,
                                      hint: const Row(
                                        children: [
                                          Icon(Icons.person_add),
                                          SizedBox(width: 8),
                                          Text("Add Attendee"),
                                        ],
                                      ),
                                      items: data.fillUserListModel!.dATA!.lIST!
                                          .map(
                                            (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.uSERNAME ?? ""),
                                        ),
                                      )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value == null) return;

                                        final alreadyExists = adduserlist.any(
                                              (user) => user.uSERID == value.uSERID,
                                        );

                                        if (!alreadyExists) {
                                          setState(() {
                                            chosenuserValue = value;
                                            adduserlist.add(value);
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Attendee already added'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                /*if (adduserlist != null && adduserlist.length > 0) ...[
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: adduserlist.length,
                                    //  itemBuilder: (context, index) => _stringsAddTravelers[index],
                                    itemBuilder: (BuildContext context, int index) {
                                      final item = chosenuserValue;
                                      return MyTile(
                                        key: ObjectKey(item),
                                        item: adduserlist[index], onDeleteClicked: () { setState(() {
                                        adduserlist.remove(index);
                                      });  }, adduserlist: adduserlist, index: index,

                                      );
                                    },
                                  ),
                                ],*/
                                if (adduserlist.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: adduserlist.map((user) {
                                      return Chip(
                                        label: Text(user.uSERNAME ?? "",style: TextStyle(color: Colors.blue),),
                                        deleteIcon: const Icon(Icons.close),
                                        onDeleted: () {
                                          setState(() {
                                            adduserlist.remove(user);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                SizedBox(
                                  height: 10,

                                ),

                              /*  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Business Partners',
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      *//*  SearchableDropdown<BussinessPartnersListModel>.paginated(

                                      // controller: searchableDropdownController,

                                      hintText: const Text('Select Business Partners'),
                                      initialValue: SearchableDropdownMenuItem<BussinessPartnersListModel>(value: selectedContactTo, label: selectedContactTo != null ? selectedContactTo!.sLDESC! : 'Select Business Partners', child: Text(selectedContactTo != null ? selectedContactTo!.sLDESC! : 'Select Business Partners')),
                                      // margin: const EdgeInsets.all(15),
                                      paginatedRequest: (int page, String? searchKey) async {
                                        return await Future.delayed(
                                            const Duration(milliseconds: 500), () async{
                                          List<BussinessPartnersListModel> data = await getPaginatedData(page, searchKey);
                                          return data.map((e) => SearchableDropdownMenuItem<BussinessPartnersListModel>(value: e, label: e.sLDESC ?? '', child: Text(e.sLDESC ?? ''))).toList();
                                        });
                                      },
                                      requestItemCount: 25,
                                      onChanged: (BussinessPartnersListModel? value) {
                                        selectedBusinessPartners = value!.sLID!;
                                      },
                                    ),*//*

                                      InkWell(
                                          onTap: (){
                                            // Add what you want to do on tap
                                          *//*  setState(() {
                                              _asyncBusinessPartnersDialog(context, data.syncSLedgerModel!.dATA!.lIST!);
                                            });*//*
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
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Text(strDefaultbusinessprtners ?? "Select Business Partners", style:  GoogleFonts.lato(
                                                       fontWeight: FontWeight.normal),),


                                                Row(
                                                    children: [
                                                      Text("", style:  GoogleFonts.lato(
                                                          color: AppColors.TEXTCOLOR),),
                                                      Padding(
                                                          padding: EdgeInsets.all(.0),
                                                          child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                    ]),

                                              ],
                                            ),
                                          )),
                                    ]
                                ),*/
                                _buildTitle("Business Partner"),

                                const SizedBox(height: 8),

                                InkWell(
                                  onTap: () {
                                    // Existing Dialog
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
                                            strDefaultbusinessprtners ??
                                                "Select Business Partner",
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                               /* Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Start Date-Time ',
                                        style: titleStyle,
                                        children:  <TextSpan>[
                                          TextSpan(text: '*', style: GoogleFonts.lato(color: Colors.red)),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),*/
                                _buildTitle("Start Date & Time", required: true),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _dateCard(
                                        startDateController.text.isEmpty
                                            ? "Select Date"
                                            : startDateController.text,
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
                                        durationStartString ??
                                            "Select Time",
                                        Icons.access_time,
                                            () => selectStartTime(context),
                                      ),
                                    ),
                                  ],
                                ),
                               /* Row(
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
                                                  style: GoogleFonts.lato(
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
                                        onTap: () => selectStartTime(context),
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
                                                  durationStartString ?? 'Select Time',
                                                  // Display the selected time or default
                                                  style: GoogleFonts.lato(
                                                    color: durationStartString == null
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

                                SizedBox(height: 10),

                                _buildTitle("End Date & Time ", required: true),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _dateCard(
                                        endDateController.text.isEmpty
                                            ? "Select Date"
                                            : endDateController.text,
                                        Icons.calendar_month,
                                            () => _selectDate(
                                          context,
                                              endDateController,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _dateCard(
                                        durationEndString ??
                                            "Select Time",
                                        Icons.access_time,
                                            () => selectStartTime(context),
                                      ),
                                    ),
                                  ],
                                ),
                              /*  Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'End Date-Time ',
                                        style: titleStyle,
                                        children:  <TextSpan>[
                                          TextSpan(text: '*', style: GoogleFonts.lato(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectDate(context, endDateController),
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
                                                  endDateController.text.trim().isEmpty
                                                      ? 'Select Date'
                                                      : endDateController.text.trim(),
                                                  style: GoogleFonts.lato(
                                                    color: endDateController.text.trim().isEmpty
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
                                        onTap: () => selectEndTime(context),
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
                                                  durationEndString ?? 'Select Time',
                                                  // Display the selected time or default
                                                  style: GoogleFonts.lato(
                                                    color: durationEndString == null
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

                                SizedBox(height: 10),


                       /*         Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [

                                        Text(
                                          'Location',
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          '*', // Red star
                                          style: GoogleFonts.lato(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        TextField(
                                          controller: _controller,
                                          decoration: InputDecoration(
                                            hintText: "Search your location here",
                                            focusColor: Colors.white,
                                            floatingLabelBehavior: FloatingLabelBehavior.never,
                                            prefixIcon: const Icon(Icons.map),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (_isLoading)
                                                  const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  ),
                                                IconButton(
                                                  icon: const Icon(Icons.cancel),
                                                  onPressed: () {
                                                    setState(() {
                                                      _controller.clear();
                                                      _selectedLocation = '';
                                                      _placeList = [];
                                                      if(_controller.text.isEmpty) {
                                                        _placeId = '';
                                                      }
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.location_on,size: 40,color: Colors.blue,),
                                                  onPressed: () async{

                                                    if(_controller.text.isNotEmpty) {
                                                      print(_controller.text);
                                      String strEnterText=_controller.text;
                                      String baseURL1 = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
                                      String request1 = '$baseURL1?input=($strEnterText)&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
                                      var response1 = await http.get(Uri.parse(request1));
                                      var data1 = json.decode(response1.body);

                                      if (kDebugMode) {
                                      print('Response data:');
                                      print(data1);
                                      }

                                      if (response1.statusCode == 200) {
                                      setState(() {
                                      _placeList = data1['predictions'];

                                      });

                                      if (_placeList.isNotEmpty) {

                                      _placeId=_placeList[0]['place_id'];
                                      print('_placeId: $_placeId');

                                      }
                                      } else {

                                      }}

                                                    //https://www.google.com/maps/search/?api=1&query=$latitude,$longitude
                                                    final Uri url = Uri.parse('https://www.google.com/maps?q=1600+Amphitheatre+Pkwy,+Mountain+View,+CA+94043,+USA');
                                                    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
                                                    //_placeId ='ChIJN9KX5JG7wjsRXxQz0cVVw5A';
                                                    String request = '$baseURL?placeid=$_placeId&key=$PLACES_API_KEY';
                                                    var response = await http.get(Uri.parse(request));
                                                    //await launchUrl(Uri.parse(request));
                                                    if (response.statusCode == 200) {
                                                      var data = json.decode(response.body);
                                                      print('Response Data: $data'); // Print the full response for debugging

                                                      // Extract the relevant details from the response
                                                      if (data['status'] == 'OK') {
                                                        var result = data['result'];
                                                        var name = result['name'];
                                                        var address = result['formatted_address'];
                                                        var latitude = result['geometry']['location']['lat'];
                                                        var longitude = result['geometry']['location']['lng'];
                                                        launchGoogleMaps(latitude, longitude);
                                                        // You can use this data as needed, for example:
                                                        print('Place Name: $name');
                                                        print('Address: $address');
                                                        print('Latitude: $latitude');
                                                        print('Longitude: $longitude');
                                                      } else {
                                                        print('Error: ${data['status']}');
                                                      }
                                                    } else {
                                                      print('Failed to load place details. Status code: ${response.statusCode}');
                                                    }
                                                    setState(() {
                                                      _placeList.clear();
                                                    });

                                                    if(_controller.text.isEmpty) {

                                                      _placeId = '';
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        if (_placeList.isNotEmpty)
                                          Container(
                                            constraints: BoxConstraints(maxHeight: 200),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: _placeList.length,
                                              itemBuilder: (context, index) {
                                                return Material(
                                                  child: ListTile(
                                                    leading: Icon(Icons.location_on, color: Colors.grey[600]),
                                                    title: Text(_placeList[index]["description"]),
                                                    onTap: () {
                                                      _placeId=_placeList[index]['place_id'];
                                                      setState(() {
                                                        print(_placeList[index]["description"]);
                                                        _isSearching = false;
                                                        _controller.text = _placeList[index]["description"];
                                                        _selectedLocation = _placeList[index]["description"];
                                                        _placeList = [];
                                                        _isSearching = true;
                                                      });
                                                      FocusScope.of(context).unfocus();
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),*/
                                _buildTitle("Location", required: true),

                                const SizedBox(height: 8),

                             /*   TextField(
                                  controller: _controller,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: "Search your location",
                                    prefixIcon: const Icon(Icons.location_on),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),*/
                                TextField(
                                  focusNode: _searchFocus,
                                  controller: _controller,
                                  minLines: 1,
                                  maxLines: 3,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintText: "Search your location",
                                    prefixIcon: const Icon(Icons.location_on),
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
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_isLoading)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),

                                        IconButton(
                                          icon: const Icon(Icons.cancel),
                                          onPressed: () {
                                            setState(() {
                                              _controller.clear();
                                              _selectedLocation = '';
                                              _placeList = [];
                                              if (_controller.text.isEmpty) {
                                                _placeId = '';
                                              }
                                            });
                                          },
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.map,
                                            color: AppColors.APPCOLOR,
                                          ),
                                          onPressed: () async {
                                            _searchFocus.unfocus();
                                            if (_placeId.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Please select a location first')),
                                              );
                                              return;
                                            }   else  if(_placeId.isNotEmpty) {
                                              print(_controller.text);
                                              String strEnterText=_controller.text;
                                              String baseURL1 = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
                                              String request1 = '$baseURL1?input=($strEnterText)&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
                                              var response1 = await http.get(Uri.parse(request1));
                                              var data1 = json.decode(response1.body);

                                              if (kDebugMode) {
                                                print('Response data:');
                                                print(data1);
                                              }

                                              if (response1.statusCode == 200) {
                                                setState(() {
                                                  _placeList = data1['predictions'];

                                                });

                                                if (_placeList.isNotEmpty) {

                                                  _placeId=_placeList[0]['place_id'];
                                                  print('_placeId: $_placeId');

                                                }
                                              } else {

                                              }}

                                            //https://www.google.com/maps/search/?api=1&query=$latitude,$longitude
                                            final Uri url = Uri.parse('https://www.google.com/maps?q=1600+Amphitheatre+Pkwy,+Mountain+View,+CA+94043,+USA');
                                            String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
                                            //_placeId ='ChIJN9KX5JG7wjsRXxQz0cVVw5A';
                                            String request = '$baseURL?placeid=$_placeId&key=$PLACES_API_KEY';
                                            var response = await http.get(Uri.parse(request));
                                            //await launchUrl(Uri.parse(request));
                                            if (response.statusCode == 200) {
                                              var data = json.decode(response.body);
                                              print('Response Data: $data'); // Print the full response for debugging

                                              // Extract the relevant details from the response
                                              if (data['status'] == 'OK') {
                                                var result = data['result'];
                                                var name = result['name'];
                                                var address = result['formatted_address'];
                                                var latitude = result['geometry']['location']['lat'];
                                                var longitude = result['geometry']['location']['lng'];
                                                launchGoogleMaps(latitude, longitude);
                                                // You can use this data as needed, for example:
                                                print('Place Name: $name');
                                                print('Address: $address');
                                                print('Latitude: $latitude');
                                                print('Longitude: $longitude');
                                              } else {
                                                print('Error: ${data['status']}');
                                              }
                                            } else {
                                              print('Failed to load place details. Status code: ${response.statusCode}');
                                            }
                                            setState(() {
                                              _placeList.clear();
                                            });

                                            if(_controller.text.isEmpty) {

                                              _placeId = '';
                                            }



                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_placeList.isNotEmpty)
                                  Container(
                                    constraints: BoxConstraints(maxHeight: 200),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _placeList.length,
                                      itemBuilder: (context, index) {
                                        return Material(
                                          child: ListTile(
                                            leading: Icon(Icons.location_on, color: Colors.grey[600]),
                                            title: Text(_placeList[index]["description"]),
                                            onTap: () {
                                              _placeId=_placeList[index]['place_id'];
                                              setState(() {
                                                _isSearching = false;
                                                _controller.text = _placeList[index]["description"];
                                                _selectedLocation = _placeList[index]["description"];
                                                _placeList = [];
                                                _isSearching = true;
                                              });
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                ),
                    ),
                  ),
                ),);
              }
                  ),
                ),
          ),
        ));
  }
/*  Widget _buildTitle(
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
  }*/
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
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getUserResponse();
    _controller.addListener(() {
      if (_isSearching && _controller.text.length > 1) {
        _onChanged();
      }
    });
  }

  Future<String> getAddressFromLatLngWindows(double? lat, double? lng) async {

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$PLACES_API_KEY');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          _isSearching = false;
          _controller.text=data['results'][0]['formatted_address'];
          _placeList = [];
          _isSearching = true;

          FocusScope.of(context).unfocus();

          return data['results'][0]['formatted_address'];
        } else {
          return 'No address found';
        }
      } else {
        return 'Failed to fetch address';
      }
    } catch (e) {
      print(e);
      return 'Error fetching address';
    }
  }
  Future<String> getAddressFromLatLng(double? latitude, double? longitude) async {
    try {
      // Get placemarks (address components)
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude!, longitude!);

      // Get the first placemark and return the full address
      Placemark place = placemarks[0];
      String address = '${place.name}, ${place.subLocality},${place.locality}, ${place.administrativeArea}, ${place.country}';




      _isSearching = false;
      _controller.text=address;
      _placeList = [];
      _isSearching = true;

      FocusScope.of(context).unfocus();
      return address;
    } catch (e) {
      print(e);
      return 'Unable to get address';
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    _textEditingController.dispose();
    _textEditingStatusController.dispose();
    _textEditingpriorotyController.dispose();
    _textEditingbusinessprtnersController.dispose();
    super.dispose();
  }
  Future<ActivityResponseModel> GetActivityListapicall(
      String strToken,
      String strUserId,
      String strOrgstructId,
      String strPostId,
      String strSearchText,String strActivityId) async {
    try {

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
        if (getactivityresponsemodel1 != null) {
setState(() {
  _subjectController.text=getactivityresponsemodel1.data!.list![0].subject ??"";
  selectSubject =getactivityresponsemodel1.data!.list![0].subject ??"";
  taskowner =getactivityresponsemodel1.data!.list![0].assignedbyname ??"";
  selectedBusinessPartners=getactivityresponsemodel1.data!.list![0].businesspartnerid ??"";
  strDefaultbusinessprtners=getactivityresponsemodel1.data!.list![0].businesspartner ??"";
startDateController.text=getactivityresponsemodel1.data!.list![0].starttime!.split(' ')[0].toString();
  endDateController.text=getactivityresponsemodel1.data!.list![0].endtime!.split(' ')[0].toString();
  durationStartString=getactivityresponsemodel1.data!.list![0].starttime!.split(' ')[1].toString()+" "+getactivityresponsemodel1.data!.list![0].starttime!.split(' ')[2].toString();
  durationEndString=getactivityresponsemodel1.data!.list![0].endtime!.split(' ')[1].toString()+" "+getactivityresponsemodel1.data!.list![0].endtime!.split(' ')[2].toString();
  attendessList.clear;
  adduserlist.clear();
lat=double.tryParse(getactivityresponsemodel1.data!.list![0].latitude.toString())?? 0.0;
lng=double.tryParse(getactivityresponsemodel1.data!.list![0].longitude.toString()) ?? 0.0;

if(!Platform.isWindows) {
  getAddressFromLatLng(
      double.tryParse(getactivityresponsemodel1.data!.list![0].latitude.toString()),
      double.tryParse(getactivityresponsemodel1.data!.list![0].longitude.toString()));
}else
  {
    getAddressFromLatLngWindows(
        double.tryParse(getactivityresponsemodel1.data!.list![0].latitude.toString()),
        double.tryParse(getactivityresponsemodel1.data!.list![0].longitude.toString()));
  }
  for(int k=0;k<getactivityresponsemodel1.data!.list![0].attendees.length;k++) {
    ATTENDEES attendess = new ATTENDEES();
    attendess.aTTENDEESUSERID=getactivityresponsemodel1.data!.list![0].attendees[k].userid;

    attendessList.add(attendess);

    chosenuserValue=new LISTUSER();
    chosenuserValue?.uSERNAME =getactivityresponsemodel1.data!.list![0].attendees[k].attendeesname;
    chosenuserValue?.uSERID =getactivityresponsemodel1.data!.list![0].attendees[k].userid;
    adduserlist.add(chosenuserValue!);

  }
});


        } else {
          if(strActivityName != null && strActivityName == "EditEventNotification") {
             AlertDialog(
              title: Text(""),
              content: Text("This records is not availabe"),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
                    ));// Return false if No is pressed
                  },
                ),

              ],
            );
          }
        }
      } else {
        return getactivityresponsemodel1;
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
    }
    return getactivityresponsemodel1;
  }

  void getUserResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs = await SharedPreferences.getInstance();
    setState(() {
      loginResponseModel = LoginResponseModel.fromJson(
          jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;

    });
    adduserlist.clear();
   /* chosenuserValue=new LISTUSER();
    chosenuserValue?.uSERNAME =loginResponseModel!.data!.username!;
    chosenuserValue?.uSERID =loginResponseModel!.data!.userid!;
    adduserlist.add(chosenuserValue!);
   */ WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityController>(context, listen: false).fetchData();
     GetActivityListapicall(
          loginResponseModel!.data!.token,
          loginResponseModel!.data!.userid,
          loginResponseModel!.data!.orgstrucid.toString(),
          loginResponseModel!.data!.posid.toString(),
          "",strActivityId!);



    });

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
          style: GoogleFonts.lato(
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
  Future<Future<ConfirmAction?>> _asyncAssignedToDialog(BuildContext context,
      List<LISTUSER> lossreasonlist  ) async {

    glossarList=lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Container(
            width: SizeConfig.blockSizeHorizontal!*100,
            child:AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Set to zero for sharp corners
              ),
              content: new Container(
                  width: SizeConfig.blockSizeHorizontal!*100,
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
                      title: Text('Assigned To',style: GoogleFonts.lato(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
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
                                  style: GoogleFonts.lato(

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
                                            style: GoogleFonts.lato(
                                              color: Constant.isSelected? Colors.black : Colors.black,
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
  void _openKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode); // Request focus to open the keyboard
  }

  Future<Future<ConfirmAction?>> _asyncBusinessPartnersDialog(BuildContext context,
      List<LISTSLEDEGER> lossreasonlist  ) async {

    businessprtnersList=lossreasonlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  Container(
            width: SizeConfig.screenWidth!*80,
            height: (300.0 * businessprtnersList!.length),
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
                      title: Text('Business Partners',style: GoogleFonts.lato(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
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
                                  style: GoogleFonts.lato(

                                      fontSize: 12,
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
                                            style: GoogleFonts.lato(
                                              color: Constant.isSelected? Colors.black : Colors.black,
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
  void _showBusinessPartners(BuildContext context, List<LISTSLEDEGER> lossreasonlist, Function(String) onBusinessPartnersSelected, Function(String) onBusinessPartnersId) {
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
      Navigator.of(context).pop();
     // Dismiss the loader

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
                content: SingleChildScrollView(
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
                                    style: GoogleFonts.lato(
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

}

// Modify SelectProductCode widget to accept a callback for selected value

class DueDateWidget extends StatefulWidget {
  const DueDateWidget({super.key, this.title, this.onDateSelected});

  final String? title;
  final Function(DateTime)? onDateSelected;

  @override
  State<DueDateWidget> createState() => _DueDateWidget();
}

class _DueDateWidget extends State<DueDateWidget> {
  DateTime? selectedDate;

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
                style: GoogleFonts.lato(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? DateFormat('dd-MMM-yyyy hh:mm a').format(selectedDate!)
                        : "Select Date",
                    style: GoogleFonts.lato(fontSize: 16),
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

class MyTile extends StatefulWidget {
  final LISTUSER item;
  final VoidCallback onDeleteClicked;
  List<LISTUSER> adduserlist = [];
  final int index;
  MyTile(
      {required Key key, required this.onDeleteClicked, required this.item,required this.adduserlist,required this.index})
      : super(key: key);

  @override
  _MyTileState createState() {
    return TileStateType1();
  }
}

class TileStateType1 extends _MyTileState {
  @override
  Widget _buildDifferently() {
    return Row(
      children: <Widget>[
        Text(
          widget.item!.uSERNAME!,
          style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  void _doDifferently() {
    /*  Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("I am type 1"),
    ));*/
  }
}

abstract class _MyTileState extends State<MyTile> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 3.0,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: _doDifferently,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:Row(
                    children: <Widget>[
                      Text(
                        widget.item!.uSERNAME!,
                        style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete,color: Colors.red,),
              onPressed: () {
                setState(() {
                  widget.adduserlist.removeAt(widget.index);
                  widget.onDeleteClicked();

                  //Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifferently();

  void _doDifferently();
}

class Item {
  final String title;
  final String description;

  Item({required this.title, required this.description});
}