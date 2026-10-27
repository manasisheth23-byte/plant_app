import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Constants.dart';
import '../../app_colors.dart';
import '../login/login_controller.dart';
import '../../models/FillLocationsRequestModel.dart';
import '../../models/FillLocationsResponseModel.dart';
import '../../models/GetTransDetailsForQCRequestModel.dart';
import '../../models/GetTransDetailsForQCResponseModel.dart';
import '../../models/ProcessNFGQualityLookupResponseModel.dart';
import '../../models/RejectionReworkHelpForQCRequestModel.dart';
import '../../models/RejectionReworkHelpForQCResponseModel.dart';
import '../../repository/LoginApiRepository.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';

class FGQualityDetails extends StatefulWidget {


  FGQualityDetails();
    // TODO: implement LoginUI

  @override
  _FGQualityDetails createState() => _FGQualityDetails();
}

class _FGQualityDetails extends State<FGQualityDetails> {
  static  bool? isFGQualityeFillter=false;
  List<ListElementLocation> _locationListOnSearch = [];
  List<ListElementLocation> _locationList = [];
  GetTransDetailsForQcResponseModel  _getTransfgdetails=new GetTransDetailsForQcResponseModel();
  MediaQueryData? _mediaQueryData;
  TextEditingController _textEditingControllerLoc= TextEditingController();

  double? screenWidth;
  double? screenHeight;
  String? strDefaultQcdate;
  double? blockSizeHorizontal;
  DateTime date = DateTime.now();
  late var formattedDate;
  String? strLocation="Select Location",_strSelectedLocId;
  // TODO: implement LoginUI

  _FGQualityDetails();

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {

      formattedDate = DateFormat('d-MMM-yy').format(date);
      strDefaultQcdate=formattedDate;
    });
  }
  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);


    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = (screenWidth! / 100);
    var blockSizeVertical = (screenHeight! / 100);
    return Consumer<LoginController>(

        builder: (context, data, _) {




          return PopScope(
            canPop: true,
            onPopInvoked: (didPop) {


            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: AppColors.APPCOLOR,
                foregroundColor: Colors.white,
                title: Center(
                  child: Text(
                    'FG Quality Details', style: TextStyle(fontFamily: 'Roboto'),),
                ),
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {


                  },
                ),
              ),

              resizeToAvoidBottomInset: false,
              body: Container(

                  child: FutureBuilder<GetTransDetailsForQcResponseModel>(
                      future: GetTransDetailsForQcapicall(context,"250",data.loginResponseModel!.data!.token!,
                      data.mid,data.loginResponseModel!.data!.userid!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          GetTransDetailsForQcResponseModel?
                          fgquantityResponseModel = snapshot.data;
                          if (fgquantityResponseModel != null) {

                            if (fgquantityResponseModel.data != null) {
                              return    SingleChildScrollView(
                                  child:  Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(color: Colors.blueGrey, width: .0),
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            child:Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text("Document No", style: const TextStyle(
                                                      fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                                  Text(fgquantityResponseModel!.data!.list!.defaultdata!.info!.refinvcnumb!??"", style: const TextStyle(
                                                      fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),

                                                ]

                                            ),
                                            SizedBox(
                                                width: 80,
                                                height: 0),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text("Document Date", style: const TextStyle(
                                                    fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),

                                                Text(fgquantityResponseModel!.data!.list!.defaultdata!.info!.refinvcdate!??"", style: const TextStyle(
                                                    fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),


                                              ],
                                            ),
                                            SizedBox(
                                                width: 80,
                                                height: 0),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text("Document Type", style: const TextStyle(
                                                    fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),

                                                Text(fgquantityResponseModel!.data!.list!.defaultdata!.info!.refinvctype! ??"", style: const TextStyle(
                                                    fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),


                                              ],
                                            ),
                                            SizedBox(
                                                width: 80,
                                                height: 0),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text("QC Date", style: const TextStyle(
                                                    fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),

                                                InkWell(
                                                  onTap: ()async{
                                                    // Add what you want to do on tap
                                                    await showDatePicker(
                                                    context: context,
                                                    initialDate:  date,
                                                    firstDate: DateTime(2022),
                                                    lastDate: DateTime(2030),
                                                    ).then((selectedDate) {
                                                      if (selectedDate != null) {
                                                        setState(() {
                                                          date = selectedDate;
                                                          formattedDate = DateFormat('d-MMM-yy').format(selectedDate);
                                                          strDefaultQcdate=formattedDate;
                                                        });
                                                      }
                                                    }
                                                    );


                                                  },
                                                  child:
                                                  Row(
                                                      children: [
                                                        Text(strDefaultQcdate ?? "", style: const TextStyle(
                                                            fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                        Padding(
                                                            padding: EdgeInsets.all(.0),
                                                            child: Icon(Icons.date_range,size: 30.0,)),

                                                      ]),),

                                              ],
                                            ),


                                          ],
                                        )),
                                      ),

                                      Row1(notifyParent: refresh,strProjectNo:fgquantityResponseModel.data!.list!.qcdetails!.qc!.projno!,
                        strItemCode:fgquantityResponseModel.data!.list!.qcdetails!.qc!.itemcode,strItemDesc:fgquantityResponseModel.data!.list!.qcdetails!.qc!.itemdesc,),
                                      Row2(notifyParent: refresh,strFlocdesc:"",
                                          strProductionQty:"",strAcceptQty:""),
                                      Row(
                                        children: <Widget>[
                        if(_FGQualityDetails.isFGQualityeFillter! ==
                        true)...[

                                          Expanded(
                                              child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text("Accept Location", style: const TextStyle(
                                                            fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                                        InkWell(
                                                          onTap: (){
                                                            // Add what you want to do on tap
                                                            print("*********");
                                                            FillLocationapicall(fgquantityResponseModel.data!.list!.qcdetails!.qc!.qcdocid!,  data!.loginResponseModel!.data!.token!,fgquantityResponseModel.data!.list!.qcdetails!.qc!.docorgstruid!,   data!.loginResponseModel!.data!.userid!,fgquantityResponseModel.data!.list!.qcdetails!.qc!.pfmid!, fgquantityResponseModel.data!.list!.qcdetails!.qc!.prodnlineid!);
                                                          },
                                                          child:
                                                          Row(
                                                              children: [
                                                                Text(strLocation!, style: const TextStyle(
                                                                    fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                                Padding(
                                                                    padding: EdgeInsets.all(.0),
                                                                    child: Icon(Icons.keyboard_arrow_down_rounded,size: 30.0,)),

                                                              ]),),
                                                      ]

                                                  ),)),

                        ]else...[
                          AbsorbPointer(
                              absorbing: true,
                              // <-- Ignore only when selecting something.
                              child: Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Accept Location", style: const TextStyle(
                                              fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                          InkWell(
                                            onTap: (){
                                              // Add what you want to do on tap

                                            },
                                            child:
                                            Row(
                                                children: [
                                                  Text(strLocation!, style: const TextStyle(
                                                      fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                  Padding(
                                                      padding: EdgeInsets.all(.0),
                                                      child: Icon(Icons.keyboard_arrow_down_rounded,size: 30.0,)),

                                                ]),),
                                        ]

                                    ),))),
                        ],

                        if(_FGQualityDetails.isFGQualityeFillter! ==
                        true)...[   Expanded(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text("Rejected Qty", style: const TextStyle(
                                                          fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                                      InkWell(
                                                        onTap: (){
                                                          // Add what you want to do on tap
                                                          print("*********");

                                                        },
                                                        child:
                                                        Row(
                                                            children: [
                                                              Text("", style: const TextStyle(
                                                                  fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                              Padding(
                                                                  padding: EdgeInsets.all(.0),
                                                                  child: Icon(Icons.keyboard_arrow_down_rounded,size: 30.0,)),

                                                            ]),),
                                                    ]

                                                ),)),

                                          ]else...[
                          Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Rejected Qty", style: const TextStyle(
                                          fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                      InkWell(
                                        onTap: (){
                                          // Add what you want to do on tap
                                          print("*********");

                                        },
                                        child:
                                        Row(
                                            children: [
                                              Text("", style: const TextStyle(
                                                  fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                              Padding(
                                                  padding: EdgeInsets.all(.0),
                                                  child: Icon(Icons.keyboard_arrow_down_rounded,size: 30.0,)),

                                            ]),),
                                    ]

                                ),)),
                        ],
                        if(_FGQualityDetails.isFGQualityeFillter! ==
                        true)...[    Expanded(
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text("Rework Qty", style: const TextStyle(
                                                          fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                                      InkWell(
                                                        onTap: (){
                                                          // Add what you want to do on tap
                                                      print("*********");

                                                        },
                                                        child:
                                                        Row(
                                                            children: [
                                                              Text("", style: const TextStyle(
                                                                  fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                              Padding(
                                                                  padding: EdgeInsets.all(.0),
                                                                  child: Icon(Icons.keyboard_arrow_down_rounded,size: 30.0,)),

                                                            ]),),
                                                    ]

                                                ),)),]else
                                                  ...[
                                                    Expanded(
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: <Widget>[
                                                                Text("Rework Qty", style: const TextStyle(
                                                                    fontFamily: 'Roboto',   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                                                InkWell(
                                                                  onTap: (){
                                                                    // Add what you want to do on tap
                                                                    print("*********");

                                                                  },
                                                                  child:
                                                                  Row(
                                                                      children: [
                                                                        Text("", style: const TextStyle(
                                                                            fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                                        Padding(
                                                                            padding: EdgeInsets.all(.0),
                                                                            child: Icon(Icons.keyboard_arrow_down_rounded,size: 30.0,)),

                                                                      ]),),
                                                              ]

                                                          ),))
                                                  ]
                                        ],
                                      )

                                    ],
                                  ));
                            } else {
                              return Center(
                                child: Text("No Records to display"),
                              );
                            }
                          }
                        }
                        return CircularProgressIndicator();
                      })),
            ),
          );
        });
  }
  Future<GetTransDetailsForQcResponseModel> GetTransDetailsForQcapicall(BuildContext context,String? strMenuId,
      String? strToken,String? strMid,String? strUserId) async {
    try {

      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {

        GetTransDetailsForQCRequestModel fgqualityrequestmodel =
        GetTransDetailsForQCRequestModel();
        fgqualityrequestmodel.xMLFILE = XMLFILEFGDETAILS();
        fgqualityrequestmodel.xMLFILE!.uSERID =strUserId ;
        fgqualityrequestmodel.xMLFILE!.mENUID = strMenuId;

        fgqualityrequestmodel.xMLFILE!.tOKEN =strToken ;
        fgqualityrequestmodel.xMLFILE!.fLAG ="0" ;

        fgqualityrequestmodel.xMLFILE!.mID = strMid;

        GetTransDetailsForQcResponseModel?  getTransfgdetails =
        await _repository.GetTransDetailsForQCData(fgqualityrequestmodel);
        if (getTransfgdetails != null) {
          _getTransfgdetails=getTransfgdetails;
          strDefaultQcdate=_getTransfgdetails!.data!.list!.defaultdata!.info!.minqcdate!??"";

        } else {

        }
      } else {
        return _getTransfgdetails;
      }
    } catch (error, stacktrace) {

      // print("Exception occured: $error stackTrace: $stacktrace");
    }
    return _getTransfgdetails;
  }

 FillLocationapicall(String strDocid, String strToken,String strOrgstuctid,String strUserId,
    String strPfMid,String strProdLineId ) async {
    try {

      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {

        FillLocationsRequestModel filllocationrequestmodel =
        FillLocationsRequestModel();
        filllocationrequestmodel.xMLFILE = XMLFILEFILLLOCATION();
        filllocationrequestmodel.xMLFILE!.dOCID=strDocid ;
        filllocationrequestmodel.xMLFILE!.oRGSTRUCID=strOrgstuctid;
        filllocationrequestmodel.xMLFILE!.lOCMAPTYPE = "2";
        filllocationrequestmodel.xMLFILE!.tOKEN =strToken ;
        filllocationrequestmodel.xMLFILE!.pFMID =strPfMid;
        filllocationrequestmodel.xMLFILE!.fLAG = "12";
        filllocationrequestmodel.xMLFILE!.dOCID =strDocid ;
        filllocationrequestmodel.xMLFILE!.pRODLINEID = strProdLineId;
        filllocationrequestmodel.xMLFILE!.sEARCHTXT = "";
        filllocationrequestmodel.xMLFILE!.uSERID=strUserId;


      FillLocationsResponseModel  filllocationresponsemodel =
        await _repository.FillLocationsData(filllocationrequestmodel);
        if (filllocationresponsemodel != null) {
          _asyncLocationDialog(context,filllocationresponsemodel!.data!.list!);
        } else {

        }
      } else {

      }
    } catch (error, stacktrace) {

      // print("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  RejectionReworkHelpForQCapicall(String strDocid, String strToken,String strOrgstuctid,String strUserId,
      String strQcMid,String strProdLineId,String strQcTid ,String strFlag) async {
    try {

      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {

        RejectionReworkHelpForQCRequestModel rejectionreworkQcrequestmodel =
        RejectionReworkHelpForQCRequestModel();
        rejectionreworkQcrequestmodel.xMLFILE = XMLFILEREJECTIONQC();
        rejectionreworkQcrequestmodel.xMLFILE!.dOCID=strDocid ;
        rejectionreworkQcrequestmodel.xMLFILE!.oRGSTRUCID=strOrgstuctid;
        rejectionreworkQcrequestmodel.xMLFILE!.qCMID = strQcMid;
        rejectionreworkQcrequestmodel.xMLFILE!.tOKEN =strToken;
        rejectionreworkQcrequestmodel.xMLFILE!.qCTID =strQcTid;
        rejectionreworkQcrequestmodel.xMLFILE!.fLAG = strFlag;
        rejectionreworkQcrequestmodel.xMLFILE!.dOCID =strDocid ;
        rejectionreworkQcrequestmodel.xMLFILE!.pRODLINEID = strProdLineId;

        rejectionreworkQcrequestmodel.xMLFILE!.uSERID=strUserId;


        RejectionReworkHelpForQcResponseModel  rejectionreworkQcresponsemodel =
        await _repository.RejectionReworkHelpForQCData(rejectionreworkQcrequestmodel);
        if (rejectionreworkQcresponsemodel != null) {

        } else {

        }
      } else {

      }
    } catch (error, stacktrace) {

      // print("Exception occured: $error stackTrace: $stacktrace");
    }
  }
  Future<Future<ConfirmAction?>> _asyncLocationDialog(BuildContext context,
      List<ListElementLocation> locationlist ) async {

    _locationList=locationlist;

    return showDialog<ConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return  AlertDialog(
          backgroundColor: Colors.white,

          content: new   Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: ()
                  {

                    Navigator.of(context).pop();
                  }

              ),
              backgroundColor: Colors.white,
              title: Text('',style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Avenir'),),
              /* flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                ),
              ),*/
              bottom: PreferredSize(
                preferredSize: Size(0, 40),
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.fromLTRB(1,1, 1, 0),
                      child:
                      Container(
                        //height: 50,
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
                                _locationListOnSearch = _locationList
                                    .where((element) => element.locdesc!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                    .toList();
                                Navigator.of(context).pop(ConfirmAction.Cancel);
                                ( _asyncLocationDialog(
                                    context,
                                    _locationList));
                              });
                            },
                            controller: _textEditingControllerLoc,
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
                child: _textEditingControllerLoc.text.isNotEmpty &&
                    _locationListOnSearch.isEmpty
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
                  itemCount: _textEditingControllerLoc.text.isNotEmpty
                      ? _locationListOnSearch.length
                      : _locationList.length,

                  itemBuilder: (context, index) {

                    return GestureDetector(
                      onTap: () {

                        setState(() {

                          strLocation =
                          _textEditingControllerLoc.text.isNotEmpty
                              ? _locationListOnSearch[index].locdesc
                              : _locationList[index].locdesc;

                          _strSelectedLocId = _textEditingControllerLoc.text.isNotEmpty
                              ? _locationListOnSearch[index].locid
                              : _locationList[index].locid;

                          Constant.isSelected=true;
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected Value: "+_strSelectedDesc!??""),    ));
                          /* ProcessNFGQualityLookupapicall(context,strControlNo,_strSelectedDocid!,strMenuId,
                                strToken,strOrgstuctid,"1",_strSelectedStatusId!,_strSelectedTypeId!,strUserId);*/
                        });
                        Navigator.of(context).pop();
                      },

                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child:
                        ListTile(
                          tileColor:Constant.isSelected? Colors.black : Colors.black,

                          title: Text(

                            _textEditingControllerLoc.text.isNotEmpty
                                ?_locationListOnSearch[index].locdesc!
                                : _locationList[index].locdesc! ,
                            style: TextStyle(
                                color: Constant.isSelected? Colors.black : Colors.black,

                                fontFamily: 'Avenir'),
                          ),),

                      ),
                    );
                  },
                )),
          ),

          actions: <Widget>[




          ],
        );




      },
    );
  }
}
enum ConfirmAction { Cancel, Accept }

class Row1 extends StatefulWidget {
  final Function()? notifyParent;
  String? strProjectNo;
  String? strItemCode;
  String? strItemDesc;

  Row1( {Key? key,  this.notifyParent, this.strProjectNo, this.strItemCode,this.strItemDesc}) : super(key: key);



  @override
  State<Row1> createState() => _Row1(notifyParent: notifyParent,strProjectNo:strProjectNo,
      strItemCode:strItemCode,strItemDesc:strItemDesc);
}
class _Row1 extends State<Row1> {
  String? strProjectNo;
  String? strItemCode;
  String? strItemDesc;
  bool check1=false;
  final Function()? notifyParent;
  _Row1( {this.notifyParent,this.strProjectNo, this.strItemCode,this.strItemDesc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.COMPLETECOLOR,
      height: 60,
      child: Row(
        children: <Widget>[
          Expanded(
              child:Checkbox(
                  value: _FGQualityDetails. isFGQualityeFillter,
                focusColor: Colors.white,
                  onChanged: (value) {

                    setState(() {
                      check1 = !check1  ;
                      _FGQualityDetails. isFGQualityeFillter=check1;
                    });

                  }
              ) ),
          Expanded(
              child: RichText(
                text: TextSpan(
                  text: strItemCode! +" ("+strItemDesc!+")",
                  style: TextStyle(
                      fontFamily: 'Roboto', fontWeight: FontWeight.bold,color: Colors.white),
                  children: const <TextSpan>[
                    TextSpan(
                        text: '',
                        style: TextStyle(
                            fontFamily: 'Roboto', fontWeight: FontWeight.bold,color: Colors.white)),
                  ],
                ),
              )),
          Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: strProjectNo,
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,color: Colors.white)),
                    ],
                  ),
                )),
          ),

        ],
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
class Row2 extends StatefulWidget {
  final Function()? notifyParent;
  String? strFlocdesc;
  String? strProductionQty;
  String? strAcceptQty;

  Row2( {Key? key,this.notifyParent, this.strFlocdesc, this.strProductionQty,this.strAcceptQty}) : super(key: key);



  @override
  State<Row2> createState() => _Row2(notifyParent: notifyParent,strFlocdesc:strFlocdesc,
      strProductionQty:strProductionQty,strAcceptQty:strAcceptQty);
}
class _Row2 extends State<Row2> {
  String? strFlocdesc;
  String? strProductionQty;
  String? strAcceptQty;
  bool check1=false;
  final Function()? notifyParent;
  _Row2( {this.notifyParent,this.strFlocdesc, this.strProductionQty,this.strAcceptQty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue[200],
      height: 48,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: strFlocdesc,
                      style: TextStyle(
                          fontFamily: 'Roboto', fontWeight: FontWeight.bold,color: Colors.white),
                      children: const <TextSpan>[
                        TextSpan(
                            text: '',
                            style: TextStyle(
                                fontFamily: 'Roboto', fontWeight: FontWeight.bold,color: Colors.white)),
                      ],
                    ),
                  ))),
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: "Production Qty: "+strProductionQty!,
                      style: TextStyle(
                          fontFamily: 'Roboto', fontWeight: FontWeight.bold,color: Colors.white),
                      children: const <TextSpan>[
                        TextSpan(
                            text: '',
                            style: TextStyle(
                                fontFamily: 'Roboto', fontWeight: FontWeight.bold,color: Colors.white)),
                      ],
                    ),
                  ))),

          Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Accept Qty: "+strAcceptQty!,
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,color: Colors.white)),
                    ],
                  ),
                )),
          ),

        ],
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
