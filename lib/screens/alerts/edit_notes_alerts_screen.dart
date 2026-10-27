import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/provider/edit_note_provider.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/LoginResponseModel.dart';
import '../../models/activity_request_model.dart';
import '../../models/activity_response_model.dart';
import '../../models/activity_task_request_model.dart';
import '../../repository/LoginApiRepository.dart';
import '../../utils/CommonUtils.dart';
import '../activity/activity_controller.dart';
import 'alerts_list.dart';

class EditNotesAlertsActivity extends StatefulWidget {

  EditNotesAlertsActivity({required this.activityid, required this.loginResponseModel});

  final LoginResponseModel? loginResponseModel;
  final String? activityid;

  @override
  State<EditNotesAlertsActivity> createState() => _EditNotesAlertsActivityState(loginResponseModel,activityid);
}

class _EditNotesAlertsActivityState extends State<EditNotesAlertsActivity> {
   TextEditingController _subjectController= TextEditingController();
   TextEditingController _contentController= TextEditingController();
  ActivityResponseModel getactivityresponsemodel1 = new ActivityResponseModel();
  LoginResponseModel? loginResponseModel;
   String? activityid;
  _EditNotesAlertsActivityState(this.loginResponseModel,this.activityid);
  @override
  void initState() {
    super.initState();
    // Initialize controllers with the initial values
   // _subjectController = TextEditingController(text: widget.subject);
   // _contentController = TextEditingController(text: widget.content);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetActivityListapicall(
          loginResponseModel!.data!.token,
          loginResponseModel!.data!.userid,
          loginResponseModel!.data!.orgstrucid.toString(),
          loginResponseModel!.data!.posid.toString(),
          "",activityid!);
      Provider.of<ActivityController>(context, listen: false).fetchData();


    });

  }

  @override
  void dispose() {
    // Dispose the controllers
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        title: Text("Edit Notes",style: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_rounded),
            onPressed: () {
              // Call the EditNote method with values from the TextEditingController
              Provider.of<EditNoteProvider>(context, listen: false).EditNote(
                  _contentController.text,
                  _subjectController.text,
                  widget.activityid!,
                  "E"
              );

              // Show a success SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Note edited successfully!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
              ));
              // Optionally, navigate back after showing the SnackBar
             // Navigator.of(context).pop(true);
            },
          ),


          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              // Show confirmation dialog
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
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true if Yes is pressed
                        },
                      ),
                    ],
                  );
                },
              );

              // If the user confirms deletion
              if (confirmDelete == true) {
                // Call the EditNote method with the delete operation
                Provider.of<EditNoteProvider>(context, listen: false).EditNote(
                  _contentController.text,
                  _subjectController.text,
                  widget.activityid!,
                  "D",
                );

                // Show a success SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Note deleted successfully!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
                ));
                // Optionally, navigate back after showing the SnackBar
               // Navigator.of(context).pop(true); // Pop the screen after deletion
              }
            },
          )


        ],

        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
            ));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextFormField(
                  controller: _subjectController, // Use the controller
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Enter subject',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  onChanged: (value) {},
                ),
                Divider(color: Colors.grey),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextFormField(
                  controller: _contentController, // Use the controller
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Enter content',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  onChanged: (value) {},
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
              height: 0,
            ),
          ],
        ),
      ),
    );
  }

  Future<ActivityResponseModel> GetActivityListapicall(
      String strToken,
      String strUserId,
      String strOrgstructId,
      String strPostId,
      String strSearchText,String strActivityId) async {
    try {
     /* AlertDialog alert = AlertDialog(
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
      );*/
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

          _subjectController.text=getactivityresponsemodel1!.data!.list![0].subject!;
          _contentController.text=getactivityresponsemodel1!.data!.list![0].content!;
          setState(() {});
        } else {

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
