import 'dart:io';

import 'package:erpflutter/screens/login/login_controller.dart';
import 'package:erpflutter/screens/FGQuality/FGQualityDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../Constants.dart';
import '../../Dashboard.dart';
import '../../app_colors.dart';
import '../../models/FillDocMastRequestModel.dart';
import '../../models/FillDocMastResponseModel.dart';
import '../../models/FillStatusListRequestModel.dart';
import '../../models/FillStatusListResponseModel.dart';
import '../../models/GetDefaultValRequestModel.dart';
import '../../models/GetDefaultValResponseModel.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/ProcessNFGQualityLookupRequestModel.dart';
import '../../models/ProcessNFGQualityLookupResponseModel.dart';
import '../../repository/LoginApiRepository.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../../widgetcontrolls/TextControll.dart';

class FGQualityPage extends StatefulWidget {
  String? mENUID;
 /* String? oRGSTRUCID;
  String? pOSID;
  String? tOKEN;
  String? uSERID;
  String tYPEID;*/
  String? strDefaultStatus;
  String? strDefaultType;
  String? strDefaltDocType;
  String? strSelectedTypeId="0";
  String? strSelectedStatusId="0";
  String? strSelectedDocid="0";


  FGQualityPage({required this.strDefaltDocType,required this.strDefaultStatus,
    required this.strDefaultType,required this.strSelectedDocid,required this.strSelectedStatusId,
  required this.strSelectedTypeId}) {
    // TODO: implement LoginUI
  }
  @override
  _FGQualityPage createState() => _FGQualityPage(strDefaltDocType,strDefaultStatus,strDefaultType,strSelectedDocid,strSelectedStatusId,
      strSelectedTypeId);
}

class _FGQualityPage extends State<FGQualityPage> {
  String? mENUID;
  /*String? oRGSTRUCID;
  String? pOSID;
  String? tOKEN;
  String? uSERID;*/
  String? strDefaultStatus;
  String? strDefaultType;
  String? strDefaltDocType;

  GetDefaultValResponseModel getdefaultvalresponsemodel1=new GetDefaultValResponseModel();
  ProcessNfgQualityLookupResponseModel processfgqualityresponsemodel=new ProcessNfgQualityLookupResponseModel();
  FillDocMastResponseModel? filldocmastresponsemodel;
  FillStatusListResponseModel? fillstatusresponsemodel;
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  double? screenWidth;
  double? screenHeight;
  double? blockSizeHorizontal;
  String? tYPEID;
  String? _strSelectedDesc="";
  String? _strSelectedTypeId="0";
  String? _strSelectedStatusId="0";
  TextEditingController _textEditingController = TextEditingController();
  List<ListElementStatus> glossarListOnSearch = [];
  List<ListElementStatus> glossarList = [];
  String? _strSelectedDocid="0";
  List<ListElementStatus> typeListOnSearch = [];
  List<ListElementStatus> typeList = [];
 TextEditingController _textEditingControllerDocmast= TextEditingController();
  TextEditingController _typetextEditingControlle= TextEditingController();
  List<ListElementDocMast> docmastListOnSearch = [];
  List<ListElementDocMast> docmastList = [];
  List<Widget> _strings = [];
  _FGQualityPage(this.strDefaltDocType,this.strDefaultStatus,this.strDefaultType,this._strSelectedDocid,this._strSelectedStatusId,
  this._strSelectedTypeId );
    // TODO: implement LoginUI


  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_){





    });

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
          print(data.strDefaultType);

        /*  _strSelectedTypeId=data.getdefaultvalresponsemodel!.data!.list![0].deftypeid!;
          _strSelectedDocid=data.getdefaultvalresponsemodel!.data!.list![0].defdocid;
          _strSelectedStatusId=data.getdefaultvalresponsemodel!.data!.list![0].defstatusid;
*/

          return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {


      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text(
              'FG Quality', style: TextStyle(fontFamily: 'Roboto'),),
          ),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );


            },
          ),
        ),

        resizeToAvoidBottomInset: false,
        body:Container(

            child: FutureBuilder<ProcessNfgQualityLookupResponseModel>(
                future:  ProcessNFGQualityLookupapicall(context,data.loginResponseModel!.data!.controlno,_strSelectedDocid!,"250",
                    data.loginResponseModel!.data!.token,data.loginResponseModel!.data!.orgstrucid,"1",_strSelectedStatusId!,_strSelectedTypeId!,data.loginResponseModel!.data!.userid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    ProcessNfgQualityLookupResponseModel?
                    fgquantityResponseModel = snapshot.data;
                    if (fgquantityResponseModel != null) {
                      if (fgquantityResponseModel.data != null) {
                          return    SingleChildScrollView(
                            child:  Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text("Document Type", style: const TextStyle(
                                                fontFamily: 'Roboto', fontSize: 20,   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),
                                            InkWell(
                                              onTap: (){
                                                // Add what you want to do on tap
                                                FillDocMastapicall("0",data.loginResponseModel!.data!.token!,data.loginResponseModel!.data!.orgstrucid,
                                                    data.loginResponseModel!.data!.posid!,data.loginResponseModel!.data!.userid!,data.menuid,data.loginResponseModel!.data!.controlno,
                                                "1",_strSelectedStatusId!,_strSelectedTypeId!);

                                              /*  ProcessNFGQualityLookupapicall(context,data.loginResponseModel!.data!.controlno,data!.getdefaultvalresponsemodel!.data!.list![0].defdocid!,mENUID!,
                                                    data.loginResponseModel!.data!.token,data.loginResponseModel!.data!.orgstrucid,"1",data.getdefaultvalresponsemodel!.data!.list![0].defstatusid!,data.getdefaultvalresponsemodel!.data!.list![0].deftypeid!,data.loginResponseModel!.data!.userid);*/
                                              },
                                              child:
                                              Row(
                                                  children: [
                                                    Text(strDefaltDocType ??"", style: const TextStyle(
                                                        fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                    Padding(
                                                        padding: EdgeInsets.all(.0),
                                                        child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                  ]),),
                                          ]

                                      ),
                                      SizedBox(
                                          width: 150,
                                          height: 0),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text("Status", style: const TextStyle(
                                              fontFamily: 'Roboto',  fontSize: 20,   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),

                                          InkWell(
                                            onTap: (){
                                              // Add what you want to do on tap
                                              setState(() {
                                                FillStatusapicall("0","117",data.loginResponseModel!.data!.token!,
                                                    data.loginResponseModel!.data!.userid!,data.loginResponseModel!.data!.orgstrucid,
                                                    data.loginResponseModel!.data!.posid,data.menuid,data.loginResponseModel!.data!.controlno,"1",_strSelectedTypeId! );

                                              });


                                            },
                                            child:
                                            Row(
                                                children: [
                                                  Text(strDefaultStatus ??"", style: const TextStyle(
                                                      fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                  Padding(
                                                      padding: EdgeInsets.all(.0),
                                                      child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                ]),),

                                        ],
                                      ),
                                      SizedBox(
                                          width: 150,
                                          height: 0),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(" Type", style: const TextStyle(
                                              fontFamily: 'Roboto', fontSize: 20,   fontWeight: FontWeight.bold,color: AppColors.COMPLETECOLOR),),

                                          InkWell(
                                            onTap: (){
                                              // Add what you want to do on tap
                                              setState(() {
                                                FillStatusapicall("0","139",data.loginResponseModel!.data!.token!,
                                                    data.loginResponseModel!.data!.userid!,data.loginResponseModel!.data!.orgstrucid,
                                                    data.loginResponseModel!.data!.posid,data.menuid,data.loginResponseModel!.data!.controlno,"1",_strSelectedTypeId!);
                                                // ProcessNFGQualityLookupapicall("20242025","1414","250","79ECD481-C103-446D-BF05-4A10F0D090EC","49","1","2","-1","1837");

                                              });



                                            },
                                            child:   Row(
                                                children: [
                                                  Text(strDefaultType ??"", style: const TextStyle(
                                                      fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),),
                                                  Padding(
                                                      padding: EdgeInsets.all(.0),
                                                      child: Icon(Icons.keyboard_arrow_down_rounded,size: 35.0,)),

                                                ]),),

                                        ],
                                      ),


                                    ],
                                  ),
                                ),


                                for(int k=0;k<fgquantityResponseModel.data!.list!.length;k++)...[
                                  Theme(
                                      data: Theme.of(context).copyWith(dividerColor: Colors.black),
                                      child:  ExpansionTile(
                                    title: Row1(fgquantityResponseModel.data!.list![k].invctype,fgquantityResponseModel.data!.list![k].invcnumb,fgquantityResponseModel.data!.list![k].invcdate!),
                                    subtitle: Row2(fgquantityResponseModel.data!.list![k].prodcode),
                                    children: <Widget>[
                                      ListTile(title:Expanded(
                                          child:Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[


                                             Row(
                                              children: <Widget>[    Expanded(
                                                child: Row3(fgquantityResponseModel.data!.list![k].proddesc,fgquantityResponseModel.data!.list![k].qcusername,fgquantityResponseModel.data!.list![k].qcdate!)),],),
                                            Row(
                                              children: <Widget>[ Expanded(
                  child:  Row4(fgquantityResponseModel.data!.list![k].wono,fgquantityResponseModel.data!.list![k].wodate,"")),],),
                                            Row(
                                              children: <Widget>[    Expanded(
                                                  child: Row5(strDefaultStatus!)),],),


                                          ],
                                        ),
                                      )),

                                      ),
                                    ],
                                  ))
                                ]

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
  FillDocMastapicall(String strDocid, String strToken,String strOrgstuctid,String strPostId,String strUserId,String strMenuId,String strControlNo,
  String strPageno,String strStatusId, String strTypeid) async {
    try {

      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {

        FillDocMastRequestModel filldocmastrequestmodel =
        FillDocMastRequestModel();
        filldocmastrequestmodel.xMLFILE = XMLFILEFILLDOCMAST();
        filldocmastrequestmodel.xMLFILE!.mENUID =strMenuId ;
        filldocmastrequestmodel.xMLFILE!.oRGSTRUCID=strOrgstuctid;
        filldocmastrequestmodel.xMLFILE!.pOSID = strPostId;
        filldocmastrequestmodel.xMLFILE!.tOKEN =strToken ;
        filldocmastrequestmodel.xMLFILE!.dESC = "";
        filldocmastrequestmodel.xMLFILE!.fLAG = "1";
        filldocmastrequestmodel.xMLFILE!.dOCID =strDocid ;
        filldocmastrequestmodel.xMLFILE!.rEFDOCID = "0";
        filldocmastrequestmodel.xMLFILE!.sYSDOCID = "0";
        filldocmastrequestmodel.xMLFILE!.uSERID=strUserId;


        filldocmastresponsemodel =
        await _repository.FillDocMastData(filldocmastrequestmodel);
        if (filldocmastresponsemodel != null) {
          _asyncDocTypeDialog(context,filldocmastresponsemodel!.data!.list!,
               strDocid, strToken,strOrgstuctid,
               strPostId, strUserId, strMenuId, strControlNo,
               strPageno,strStatusId,strTypeid);

        } else {

        }
      } else {

      }
    } catch (error, stacktrace) {

      // print("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Future<ConfirmAction?>> _asyncTYpeDialog(BuildContext context,
      List<ListElementStatus> lossreasonlist ,String strTypeId, String strToken,String strOrgstuctid,String strPostId,String strUserId,String strMenuId,String strControlNo,
      String strPageno,String strStatusId, String strTypeid  ) async {

    typeList=lossreasonlist;

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
                                typeListOnSearch = typeList
                                    .where((element) => element.name!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                    .toList();
                                Navigator.of(context).pop(ConfirmAction.Cancel);
                                ( _asyncTYpeDialog(
                                    context,
                                    typeList,strTypeId,  strToken, strOrgstuctid, strPostId, strUserId, strMenuId, strControlNo,
                                 strPageno, strStatusId, strTypeid));
                              });
                            },
                            controller: _typetextEditingControlle,
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
                child: _typetextEditingControlle.text.isNotEmpty &&
                    typeListOnSearch.isEmpty
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
                  itemCount: _typetextEditingControlle.text.isNotEmpty
                      ? typeListOnSearch.length
                      : typeList.length,

                  itemBuilder: (context, index) {

                    return GestureDetector(
                      onTap: () {

                        setState(() {
                          if(strTypeId == "117")
                          {
                            strDefaultStatus  =
                            _typetextEditingControlle.text.isNotEmpty
                                ? typeListOnSearch[index].name
                                : typeList[index].name;
                          }else if(strTypeId == "139")
                          {
                            strDefaultType  =
                            _typetextEditingControlle.text.isNotEmpty
                                ? typeListOnSearch[index].name
                                : typeList[index].name;
                         //   _strSelectedIdelid=strDefaultType;
                          }else
                          {
                            _strSelectedDesc =
                            _typetextEditingControlle.text.isNotEmpty
                                ? typeListOnSearch[index].name
                                : typeList[index].name;
                           // _strSelectedIdelid=_strSelectedDesc;
                          }
                          _strSelectedTypeId = _typetextEditingControlle.text.isNotEmpty
                              ? typeListOnSearch[index].statusid
                              : typeList[index].statusid;

                          Constant.isSelected=true;
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected Value: "+_strSelectedDesc!??""),    ));

                        });
                        Navigator.of(context).pop();

                      /*  ProcessNFGQualityLookupapicall(context,strControlNo,_strSelectedDocid!,strMenuId,
                            strToken,strOrgstuctid,"1",_strSelectedStatusId!,_strSelectedTypeId!,strUserId);*/
                      },

                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child:
                        ListTile(
                          tileColor:Constant.isSelected? Colors.black : Colors.black,

                          title: Text(

                            _typetextEditingControlle.text.isNotEmpty
                                ?typeListOnSearch[index].name!
                                : typeList[index].name! ,
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
  FillStatusapicall(String strStatusId,String strTypeId,String strToken,String strUserId,String strOrgstuctid,String strPostId,String strMenuId,String strControlNo,
      String strPageno, String strTypeid) async {
    try {

      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {

        FillStatusListRequestModel fillstatusrequestmodel =
        FillStatusListRequestModel();
        fillstatusrequestmodel.xMLFILE = XMLFILEFILLSTATUS();
        fillstatusrequestmodel.xMLFILE!.dESC ="" ;
        fillstatusrequestmodel.xMLFILE!.fLAG = "0";
        fillstatusrequestmodel.xMLFILE!.sTATUSID = strStatusId;
        fillstatusrequestmodel.xMLFILE!.tOKEN =strToken ;
        fillstatusrequestmodel.xMLFILE!.tYPEID =strTypeId ;

        fillstatusrequestmodel.xMLFILE!.uSERID = int.tryParse(strUserId);
        fillstatusresponsemodel =
        await _repository.FillStatusListData(fillstatusrequestmodel);
        if (fillstatusresponsemodel != null) {

        setState(() {
          if(strTypeId == "117") {
            _asyncStatusDialog(
                context, fillstatusresponsemodel!.data!.list!, strTypeId, strToken, strUserId, strOrgstuctid, strPostId, strMenuId,strControlNo,
                 strPageno, strStatusId, strTypeid);
          }else  if(strTypeId == "139")
            {
              _asyncTYpeDialog(
                  context, fillstatusresponsemodel!.data!.list!, strTypeId, strToken, strUserId, strOrgstuctid, strPostId, strMenuId,strControlNo,
                  strPageno, strStatusId, strTypeid);
            }
        });
        } else {
        //for dissmiss progres dialog
        }
      } else {

      }
    } catch (error, stacktrace) {

      // print("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Future<ConfirmAction?>> _asyncStatusDialog(BuildContext context,
      List<ListElementStatus> lossreasonlist ,String strTypeId, String strToken,String strOrgstuctid,String strPostId,String strUserId,String strMenuId,String strControlNo,
      String strPageno,String strStatusId, String strTypeid  ) async {

    glossarList=lossreasonlist;

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
                             glossarListOnSearch = glossarList
                                    .where((element) => element.name!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                    .toList();
                               Navigator.of(context).pop(ConfirmAction.Cancel);
                                ( _asyncStatusDialog(
                                    context,
                                    glossarList,strTypeId, strToken,strOrgstuctid, strPostId, strUserId,strMenuId, strControlNo, strPageno, strStatusId,  strTypeid ));
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
                      if(strTypeId == "117")
                      {
                        strDefaultStatus  =
                        _textEditingController.text.isNotEmpty
                            ? glossarListOnSearch[index].name
                            : glossarList[index].name;
                      }else if(strTypeId == "139")
                      {
                        strDefaultType  =
                        _textEditingController.text.isNotEmpty
                            ? glossarListOnSearch[index].name
                            : glossarList[index].name;
                       // _strSelectedIdelid=strDefaultType;
                      }else
                      {
                        _strSelectedDesc =
                        _textEditingController.text.isNotEmpty
                            ? glossarListOnSearch[index].name
                            : glossarList[index].name;

                      }
                      _strSelectedStatusId = _textEditingController.text.isNotEmpty
                          ? glossarListOnSearch[index].statusid
                          : glossarList[index].statusid;

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

                          _textEditingController.text.isNotEmpty
                              ?glossarListOnSearch[index].name!
                              : glossarList[index].name! ,
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
  Future<Future<ConfirmAction?>> _asyncDocTypeDialog(BuildContext context,
      List<ListElementDocMast> docmastList,String strDocid, String strToken,String strOrgstuctid,String strPostId,String strUserId,String strMenuId,String strControlNo,
      String strPageno,String strStatusId, String strTypeid  ) async {

    docmastList=docmastList;

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
                                docmastListOnSearch = docmastList
                                    .where((element) => element.docmastdesc!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                    .toList();
                                Navigator.of(context).pop(ConfirmAction.Cancel);
                                ( _asyncDocTypeDialog(
                                    context,
                                    docmastList,strDocid, strToken,strOrgstuctid,
                                    strPostId, strUserId, strMenuId, strControlNo,
                                    strPageno,strStatusId,strTypeid));
                              });
                            },
                            controller: _textEditingControllerDocmast,
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
                child: _textEditingControllerDocmast.text.isNotEmpty &&
                    docmastListOnSearch.isEmpty
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
                  itemCount: _textEditingControllerDocmast.text.isNotEmpty
                      ? docmastListOnSearch.length
                      : docmastList.length,

                  itemBuilder: (context, index) {

                    return GestureDetector(
                      onTap: () {

                        setState(() {

                            strDefaltDocType =
                            _textEditingController.text.isNotEmpty
                                ? docmastListOnSearch[index].docmastdesc
                                : docmastList[index].docmastdesc;

                          _strSelectedDocid = _textEditingControllerDocmast.text.isNotEmpty
                              ? docmastListOnSearch[index].docid
                              : docmastList[index].docid;

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

                            _textEditingControllerDocmast.text.isNotEmpty
                                ?docmastListOnSearch[index].docmastdesc!
                                : docmastList[index].docmastdesc! ,
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
  Future<ProcessNfgQualityLookupResponseModel> ProcessNFGQualityLookupapicall(BuildContext context,String strControlNo,String strDocid,String strMenuId,
      String strToken,String strOrgstuctid,String strPageno,String strStatusId,
      String strTypeid,String strUserId) async {
    try {

      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {

        ProcessNFGQualityLookupRequestModel fgqualityrequestmodel =
        ProcessNFGQualityLookupRequestModel();
        fgqualityrequestmodel.xMLFILE = XMLFILEFGQUALITY();
        fgqualityrequestmodel.xMLFILE!.cONTROLNO =strControlNo ;
        fgqualityrequestmodel.xMLFILE!.mENUID = strMenuId;
        fgqualityrequestmodel.xMLFILE!.dOCID = strDocid;
        fgqualityrequestmodel.xMLFILE!.tOKEN =strToken ;
        fgqualityrequestmodel.xMLFILE!.oRGSTRUCID = strOrgstuctid;
        fgqualityrequestmodel.xMLFILE!.pAGENO = strPageno;
        fgqualityrequestmodel.xMLFILE!.sTATUSID = strStatusId;
        fgqualityrequestmodel.xMLFILE!.tYPEID = strTypeid;
        fgqualityrequestmodel.xMLFILE!.uSERID = strUserId;

      ProcessNfgQualityLookupResponseModel  processfgqualityresponsemodel1 =
        await _repository.ProcessNFGQualityLookupData(fgqualityrequestmodel);
        if (processfgqualityresponsemodel1 != null) {
          processfgqualityresponsemodel=processfgqualityresponsemodel1;
          Provider.of<LoginController>(context, listen: false).fgQualityDetailsData(processfgqualityresponsemodel,processfgqualityresponsemodel!.data!.list![0].qcmid!);

        } else {

        }
      } else {
        return processfgqualityresponsemodel;
      }
    } catch (error, stacktrace) {

      // print("Exception occured: $error stackTrace: $stacktrace");
    }
    return processfgqualityresponsemodel;
  }
}
enum ConfirmAction { Cancel, Accept }
class Row1 extends StatelessWidget {
  String? invctype;
  String? invcnumb;
  String invcdate;

  Row1(this.invctype, this.invcnumb, this.invcdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        color: Colors.white,

        child: Row(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                   invctype!,
                  style: const TextStyle(
                      fontFamily: 'Roboto', color: AppColors.COMPLETECOLOR),
                ),
              ),
            ),
            SizedBox(
                width: 5,
                height: 0),
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  invcnumb!,
                  style:
                  TextStyle(fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                ),
              ),
            ),
            SizedBox(
                width: 5,
                height: 0),
            Expanded(
              flex:6 ,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  invcdate,
                  style:
                  TextStyle(fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                ),
              ),
            ),

          ],
        ),
      );
  }
}
class Row2 extends StatelessWidget {
  String? productcode;

  Row2(this.productcode, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        color: Colors.white,

        child: Row(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: /*Text(
                  "Product Code: "+productcode!,
                  style: const TextStyle(
                      fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                ),*/
                RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Product Code:  ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                      TextSpan(
                        text: productcode,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
                width: 9,
                height: 0),
            const Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(''),
              ),
            ),
          ],
        ),
      );
  }
}
class Row3 extends StatelessWidget {
  String? productdesc;
  String? qcname;
  String qcdate;

  Row3(this.productdesc, this.qcname, this.qcdate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        color: Colors.white,

        child: Row(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: /*Text(
                  "Product Desc: "+productdesc!,
                  style: const TextStyle(
                      fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                )*/
                RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Product Desc: ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                      TextSpan(
                        text: productdesc,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
                width: 5,
                height: 0),
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: /*Text(
                  "Qc By: "+qcname!,
                  style:
                  TextStyle(fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                )*/
                RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Qc By: ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                      TextSpan(
                        text: qcname,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
                width: 5,
                height: 0),
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.centerRight,
                child: /*Text(
                  "Qc Date: ",
                  style:
                  TextStyle(fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                ),*/
                RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Qc Date:  ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                      TextSpan(
                        text: qcdate,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
             Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text( ""+qcdate),
              ),
            ),
          ],
        ),
      );
  }
}
class Row4 extends StatelessWidget {
  String? wono;
  String? wonodate;
  String customer;

  Row4(this.wono, this.wonodate, this.customer, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        color: Colors.white,

        child: Row(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: /*Text(
                  "WONO: "+wono!,
                  style: const TextStyle(
                      fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                ),*/
                RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'WONO:  ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                      TextSpan(
                        text: wono,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
                width: 5,
                height: 0),
            Expanded(
              flex: 9,
              child: Align(
                alignment: Alignment.centerLeft,
                child: /*Text(
                  "WONO Date: " +wonodate!,
                  style:
                  TextStyle(fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                ),*/Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        maxLines: 1,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'WONO Date : ',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: AppColors.TEXTCOLOR,
                              ),
                            ),
                            TextSpan(
                              text: wonodate,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.TEXTCOLOR,
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
            SizedBox(
                width: 5,
                height: 0),
            Expanded(

              flex: 6,
              child: Align(
                alignment: Alignment.centerRight,
                child: /*Text(
                  "Customer: ",
                  style:
                  TextStyle(fontFamily: 'Roboto', color: AppColors.TEXTCOLOR),
                ),*/
                RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Customer:  ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                      TextSpan(
                        text:customer,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.TEXTCOLOR,
                        ),
                      ),
                    ],
                  ),
                ),  ),
            ),
          Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text( ""),
              ),
            ),
          ],
        ),
      );
  }
}
class Row5 extends StatelessWidget {
  String? strStatus;
  Row5(String strStatus);


  @override
  Widget build(BuildContext context) {
    return
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        color: Colors.white,

        child: Row(
          children: <Widget>[
if(strStatus != null && strStatus =="Pending")...[
  Expanded(

    child: Align(
      child: TextButton(

        child: const Text(
          '        FG Quality         ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue,
        ), onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FGQualityDetails()),
        );
      },
      ),
    ),
  ),
]else...[
  Expanded(

    child: Align(
      child: TextButton(

        child: const Text(
          '         View Details         ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue,
        ), onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FGQualityDetails()),
        );
      },
      ),
    ),
  ),
]


          ],
        ),
      );
  }
}