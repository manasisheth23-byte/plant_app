class AddTaskRequestModel {
  XMLFILETASK? xMLFILE;

  AddTaskRequestModel({this.xMLFILE});

  AddTaskRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILETASK.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILETASK {
  String? fLAG;
  String? aCTIVITYID;
  String? BUSINESSPARTNERID;
  String? cONTACT;
  String? sUBJECT;
  int? tYPEID;
  String? rEFDOCID;
  String? rEFMID;
  String? rEMARKS;
  String? aSSIGNEDTO;
  String? sTARTTIME;
  String? eNDTIME;
  String? dUEDATE;
  String? sTATUSID;
  String? pRIORITYID;
  String? tASKDETAILS;
  String? oRGSTRUCTID;
  String? pOSID;
  String? tOKEN;
  String? uSERID;
  String? controlno;

  XMLFILETASK(
      {this.fLAG,
        this.aCTIVITYID,
        this.BUSINESSPARTNERID,
        this.cONTACT,
        this.sUBJECT,
        this.tYPEID,
        this.rEFDOCID,
        this.rEFMID,
        this.rEMARKS,
        this.aSSIGNEDTO,
        this.sTARTTIME,
        this.eNDTIME,
        this.dUEDATE,
        this.sTATUSID,
        this.pRIORITYID,
        this.tASKDETAILS,
        this.oRGSTRUCTID,
        this.pOSID,
        this.tOKEN,
        this.uSERID,
      this.controlno});

  XMLFILETASK.fromJson(Map<String, dynamic> json) {
    fLAG = json['FLAG'];
    aCTIVITYID = json['ACTIVITYID'];
    BUSINESSPARTNERID = json['BUSINESSPARTNERID'];
    cONTACT = json['CONTACT'];
    sUBJECT = json['SUBJECT'];
    tYPEID = json['TYPEID'];
    rEFDOCID = json['REFDOCID'];
    rEFMID = json['REFMID'];
    rEMARKS = json['REMARKS'];
    aSSIGNEDTO = json['ASSIGNEDTO'];
    sTARTTIME = json['STARTTIME'];
    eNDTIME = json['ENDTIME'];
    dUEDATE = json['DUEDATE'];
    sTATUSID = json['STATUSID'];
    pRIORITYID = json['PRIORITYID'];
    tASKDETAILS = json['TASKDETAILS'];
    oRGSTRUCTID = json['ORGSTRUCTID'];
    pOSID = json['POSID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    controlno = json['CONTROLNO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FLAG'] = this.fLAG;
    data['ACTIVITYID'] = this.aCTIVITYID;
    data['BUSINESSPARTNERID'] = this.BUSINESSPARTNERID;
    data['CONTACT'] = this.cONTACT;
    data['SUBJECT'] = this.sUBJECT;
    data['TYPEID'] = this.tYPEID;
    data['REFDOCID'] = this.rEFDOCID;
    data['REFMID'] = this.rEFMID;
    data['REMARKS'] = this.rEMARKS;
    data['ASSIGNEDTO'] = this.aSSIGNEDTO;
    data['STARTTIME'] = this.sTARTTIME;
    data['ENDTIME'] = this.eNDTIME;
    data['DUEDATE'] = this.dUEDATE;
    data['STATUSID'] = this.sTATUSID;
    data['PRIORITYID'] = this.pRIORITYID;
    data['TASKDETAILS'] = this.tASKDETAILS;
    data['ORGSTRUCTID'] = this.oRGSTRUCTID;
    data['POSID'] = this.pOSID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['CONTROLNO'] = this.controlno;
    return data;
  }
}
