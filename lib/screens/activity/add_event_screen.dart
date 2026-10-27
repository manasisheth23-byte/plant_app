import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../Constants.dart';
import '../../Dashboard.dart';
import '../../app_colors.dart';
import '../../database/database_service.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/add_event_request_model.dart';
import '../../models/add_event_response_model.dart';
import '../../models/business_partners_list_model.dart';
import '../../models/fill_status_list_model.dart';
import '../../models/fill_user_list_model.dart';
import '../../models/sync_s_ledger_model.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import 'activity_controller.dart';
import 'activity_list_screen.dart';
import 'googlemap.dart';

class AddEventScreen extends StatefulWidget {
  LoginResponseModel? loginResponseModel;

  AddEventScreen({required this.loginResponseModel});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState(loginResponseModel);
}

class _AddEventScreenState extends State<AddEventScreen> {
  // Define separate variables for the selected values
  LoginResponseModel? loginResponseModel;
  String? selectSubject;
  String? selectRemark;
  DateTime? selectedDueDate;
  BussinessPartnersListModel? selectedContactTo;
  String _placeId = '';
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
  final _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  bool _isSearching = true;
  bool _isLoading = false;
  String _selectedLocation = '';
  double lat=0.0;
  double lng=0.0;
   String PLACES_API_KEY = "AIzaSyDEgk5Wh6lWkCsOif_KSMJ_i7sw6ON1c2E";

  _AddEventScreenState(this.loginResponseModel);

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
  /*void _showAddedSnackbar(String message) {
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
  }*/
  void _showAddedSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating, // looks better on desktop
          margin: const EdgeInsets.all(16),
        ),
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
  void navigateToMap(double latitude, double longitude, String locationName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
        ),
      ),
    );
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
          String placeId = _placeList[0]['place_id']; // Get place ID
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
  final TextEditingController searchController = TextEditingController();
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
  Widget _dateCard(
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
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
            Icon(
              icon,
              color: AppColors.APPCOLOR,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: title.contains("Select")
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  int _idx = 0;
  final FocusNode _searchFocus = FocusNode();
  final subjectFocus = FocusNode();
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
                  resizeToAvoidBottomInset: true,
                  appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: SizedBox(
                      width: isDesktop ? 700 : double.infinity,
                      child:AppBar(
            elevation: 0,
            centerTitle: Platform.isWindows ? true : false,
            backgroundColor: const Color(0xFF12426E),
            foregroundColor: Colors.white,
            title: Text('Add Event',style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),),
            actions: [
              IconButton(
                icon: Icon(Icons.check_circle_outline,color: Colors.white,),
                onPressed: () async {

                  try {

                      DateFormat inputFormat1 = DateFormat('dd-MMM-yyyy h:mm a');
                      DateTime parsedDate1 = inputFormat1.parse(
                          startDateController.text + " " + durationStartString!);

                      // Step 2: Format the DateTime object to the desired output string
                      DateFormat outputFormat1 = DateFormat('yyyy-MM-dd HH:mm:ss');
                      String outputDate1 = outputFormat1.format(parsedDate1);

                      print(outputDate1);
                      DateTime dt1 = DateTime.parse( outputDate1);
                    // Output: 2024-10-03 05:24:00
                    DateFormat inputFormat2 = DateFormat('dd-MMM-yyyy h:mm a');
                    DateTime parsedDate2 = inputFormat2.parse(endDateController.text+ " "+durationEndString!);

                    // Step 2: Format the DateTime object to the desired output string
                    DateFormat outputFormat2 = DateFormat('yyyy-MM-dd HH:mm:ss');
                    String outputDate2 = outputFormat2.format(parsedDate2);

                    print(outputDate2);


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
                  }
                    else
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
                      activityRequestModel.xMLFILE!.aCTIVITYID = "0";
                      activityRequestModel.xMLFILE!.aSSIGNEDTO = "0";
                      activityRequestModel.xMLFILE!.bUSINESSPARTNERID = selectedBusinessPartners ?? "";
                      activityRequestModel.xMLFILE!.cONTACT = "";
                      activityRequestModel.xMLFILE!.rEFDOCID = "0";
                      activityRequestModel.xMLFILE!.rEFMID = "0";
                      activityRequestModel.xMLFILE!.rEMARKS = "";
                      activityRequestModel.xMLFILE!.fLAG = "I";
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
                        _showAddedSnackbar(context,response!.sYSMSGS!.eRRORMSGS!.toString());

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
                  body:Consumer<ActivityController>(
              builder: (context, data, _) {
                return data.fillUserListModel == null ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Center(
                      child: Container(

                       /* width: Platform.isAndroid
                            ? double.infinity
                            : MediaQuery.of(context).size.width * 0.40,*/
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F9FC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Center(
                child:SingleChildScrollView(
                  child: Container(

                color:const Color(0xFFF5F7FB),
                width: isDesktop ? 700 : double.infinity,
                padding: const EdgeInsets.all(10),
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
                                        style: GoogleFonts.lato(color: Colors.red),
                                      ),
                                    ],
                                  ),*/
                                  _buildTitle("Subject", required: true),
                                  TextFormField(
                                    focusNode: subjectFocus,
                                    autofocus: false,
                                    minLines: 1,      // initial height = 2 lines
                                    maxLines: null,   // expands automatically
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
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    onChanged: (value) {
                                      selectSubject = value;
                                    },
                                  ),


                                ],
                              ),
                             SizedBox(height: 10,),
                             /* Container(

                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(

                                        padding: EdgeInsets.symmetric(horizontal: 0),
                                        child: Text(
                                          "Add Attendees",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.lato(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.normal,fontSize: 16),
                                        ),
                                      ),
                                    ),
                        Center(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<LISTUSER>(
                              isExpanded: true,

                              hint: Row(
                                children: [
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.add, color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),

                              items: data.fillUserListModel!.dATA!.lIST!
                                  .map((LISTUSER user) => DropdownMenuItem(
                                value: user,
                                child: Text(
                                  user.uSERNAME!,
                                  style:  GoogleFonts.lato(

                                      color: AppColors.TEXTCOLOR),
                                ),
                              ))
                                  .toList(),

                              onChanged: (LISTUSER? value) {
                                setState(() {
                                  chosenuserValue = value;
                                  adduserlist.add(value!); // Add to your list
                                });
                              },

                              // ----------🔍 Search Feature Here ----------
                              dropdownSearchData: DropdownSearchData(
                                searchController: searchController,
                                searchInnerWidgetHeight: 50,

                                searchInnerWidget: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Search user...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),

                                searchMatchFn: (item, searchValue) {
                                  return item.value!.uSERNAME!
                                      .toLowerCase()
                                      .contains(searchValue.toLowerCase());
                                },
                              ),
                              // -------------------------------------------

                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  searchController.clear(); // clear search when closed
                                }
                              },

                              buttonStyleData: ButtonStyleData(
                                width: 35,
                                height: 35,
                                padding: EdgeInsets.all(3),
                              ),

                              iconStyleData: IconStyleData(
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 0,
                              ),

                              dropdownStyleData: DropdownStyleData(
                                width: Platform.isWindows
                                    ? SizeConfig.screenWidth! * 0.40       // 👉 40% width for Windows
                                    : SizeConfig.screenWidth! * 0.85,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                elevation: 8,
                                offset: Offset(-20, 0),
                              ),

                              menuItemStyleData: const MenuItemStyleData(
                                height: 35,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ),


                                  ],
                                ),
                              ),
                              if (adduserlist != null && adduserlist.length > 0) ...[
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
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.APPCOLOR.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.group_outlined,
                                            color: AppColors.APPCOLOR,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            "Attendees",
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.APPCOLOR,
                                            ),
                                          ),
                                        ),

                                        DropdownButtonHideUnderline(
                                          child: DropdownButton2<LISTUSER>(
                                            isExpanded: true,

                                            hint: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.APPCOLOR,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.person_add_alt_1,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),

                                            items: data.fillUserListModel!.dATA!.lIST!
                                                .map((LISTUSER user) => DropdownMenuItem(
                                              value: user,
                                              child: Text(
                                                user.uSERNAME!,
                                                style: GoogleFonts.lato(
                                                  color: AppColors.TEXTCOLOR,
                                                ),
                                              ),
                                            ))
                                                .toList(),

                                          /*  onChanged: (LISTUSER? value) {
                                              setState(() {
                                                chosenuserValue = value;
                                                adduserlist.add(value!);
                                              });
                                            },*/
                                            onChanged: (LISTUSER? value) {
                                              if (value == null) return;

                                              if (!adduserlist.any((e) => e.uSERID == value.uSERID)) {
                                                setState(() {
                                                  chosenuserValue = value;
                                                  adduserlist.add(value);
                                                });
                                              }
                                            },
                                            dropdownSearchData: DropdownSearchData(
                                              searchController: searchController,
                                              searchInnerWidgetHeight: 50,
                                              searchInnerWidget: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: TextFormField(
                                                  controller: searchController,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Search user...',
                                                    prefixIcon: const Icon(Icons.search),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              searchMatchFn: (item, searchValue) {
                                                return item.value!.uSERNAME!
                                                    .toLowerCase()
                                                    .contains(searchValue.toLowerCase());
                                              },
                                            ),

                                            onMenuStateChange: (isOpen) {
                                              if (!isOpen) {
                                                searchController.clear();
                                              }
                                            },

                                            buttonStyleData: const ButtonStyleData(
                                              height: 40,
                                              width: 40,
                                            ),

                                            iconStyleData: const IconStyleData(
                                              iconSize: 0,
                                            ),

                                            dropdownStyleData: DropdownStyleData(
                                              width: Platform.isWindows
                                                  ? 450
                                                  : MediaQuery.of(context).size.width * 0.90,
                                              maxHeight: 400,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.white,
                                              ),
                                              elevation: 8,
                                            ),

                                            menuItemStyleData: const MenuItemStyleData(
                                              height: 42,
                                              padding: EdgeInsets.symmetric(horizontal: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (adduserlist.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: adduserlist.map((user) {
                                            return Chip(
                                              label: Text(
                                                user.uSERNAME ?? "",
                                                style: const TextStyle(
                                                  color: AppColors.APPCOLOR,
                                                ),
                                              ),
                                              backgroundColor: Colors.blue.shade50,
                                              deleteIcon: const Icon(Icons.close, size: 18),
                                              onDeleted: () {
                                                setState(() {
                                                  adduserlist.remove(user);
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              /*      if (adduserlist.isNotEmpty) ...[
                                      const SizedBox(height: 12),

                                      ListView.separated(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: adduserlist.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                                        itemBuilder: (context, index) {
                                          final item = chosenuserValue;

                                          return MyTile(
                                            key: ObjectKey(item),
                                            item: adduserlist[index],
                                            onDeleteClicked: () {
                                              setState(() {
                                                adduserlist.remove(index);
                                              });
                                            },
                                            adduserlist: adduserlist,
                                            index: index,
                                          );
                                        },
                                      ),
                                    ],*/
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTitle("Business Partners", required: false),
                                    /*Text(
                                      'Business Partners',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),*/


                                   /* InkWell(
                                        onTap: (){

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
                                              Text(strDefaultbusinessprtners ?? "Select Business Partners", style: GoogleFonts.lato(
                                                     fontWeight: FontWeight.normal),),


                                              Row(
                                                  children: [
                                                    Text("", style: GoogleFonts.lato(
                                                        color: AppColors.TEXTCOLOR),),
                                                    Padding(
                                                        padding: EdgeInsets.all(.0),
                                                        child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                  ]),

                                            ],
                                          ),
                                        )),*/
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
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
                                                Icons.business,
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
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                              ),
                              SizedBox(height: 10),
                            /*  Row(
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
                           /*   Row(
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
                                      durationStartString ?? "Select Time",
                                      Icons.access_time,
                                          () => selectStartTime(context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),


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
                              ),*/
                              _buildTitle("End Date & Time", required: true),
                           /*   Row(
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
                                      durationEndString ?? "Select Time",
                                      Icons.access_time,
                                          () => selectEndTime(context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                               /*   Row(
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
                                  ),*/
                                  _buildTitle("Location", required: true),
                                  /*Column(
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
                                                icon: const Icon(Icons.location_on, size: 40, color: Colors.blue),
                                                onPressed: () async {
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
                                    SingleChildScrollView(
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


                            ],
                          ),
                        ),),
                      ),
                    ),
                  ),
                ));
              }
                  ),
                ),
          ),
        ));
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
  void getUserResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs = await SharedPreferences.getInstance();
    setState(() {
      loginResponseModel = LoginResponseModel.fromJson(
          jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;

    });
    adduserlist.clear();
    chosenuserValue=new LISTUSER();
    chosenuserValue?.uSERNAME =loginResponseModel!.data!.username!;
    chosenuserValue?.uSERID =loginResponseModel!.data!.userid!;
    adduserlist.add(chosenuserValue!);
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
                      elevation: 0,
                      centerTitle: false,
                      backgroundColor: const Color(0xFF12426E),
                      foregroundColor: Colors.white,
                      title: Text('Assigned To',style:  GoogleFonts.lato(

                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
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
                                    // Add Divider here


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
                          fontSize: 16,
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
  /*void _showBusinessPartners(BuildContext context, List<LISTSLEDEGER> lossreasonlist, Function(String) onBusinessPartnersSelected, Function(String) onBusinessPartnersId) {
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
  }*/
  void _showBusinessPartners(
      BuildContext context,
      List<LISTSLEDEGER> lossreasonlist,
      Function(String) onBusinessPartnersSelected,
      Function(String) onBusinessPartnersId,
      ) {
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
                              color: Colors.blue.shade50,
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
                              searchList = List.from(businessPartnersList);
                            } else {
                              searchList = businessPartnersList
                                  .where(
                                    (element) => element.cUSTOMERNAME!
                                    .toLowerCase()
                                    .contains(query.toLowerCase()),
                              )
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
                                      Colors.indigo.shade100,
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
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
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
                          child: Text(
                            "Close",
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
  @override
  void dispose() {
    _controller.dispose();
    _textEditingController.dispose();
    _textEditingStatusController.dispose();
    _textEditingpriorotyController.dispose();
    _textEditingbusinessprtnersController.dispose();
    super.dispose();
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