class AddEventRequestModel {
  XMLFILEEVENT? xMLFILE;

  AddEventRequestModel({this.xMLFILE});

  AddEventRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEEVENT.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEEVENT {
  String? fLAG;
  String? aCTIVITYID;
  String? bUSINESSPARTNERID;
  String? cONTACT;
  String? sUBJECT;
  int? tYPEID;
  String? rEFDOCID;
  String? rEFMID;
  String? rEMARKS;
  String? aSSIGNEDTO;
  String? sTARTDATE;
  String? sTARTTIME;
  String? eNDDATE;
  String? eNDTIME;
  String? dUEDATE;
  String? sTATUSID;
  String? lATITUDE;
  String? lONGITUDE;
  String? oRGSTRUCTID;
  String? pOSID;
  String? tOKEN;
  String? uSERID;
  List<ATTENDEES>? aTTENDEES;

  XMLFILEEVENT(
      {this.fLAG,
        this.aCTIVITYID,
        this.bUSINESSPARTNERID,
        this.cONTACT,
        this.sUBJECT,
        this.tYPEID,
        this.rEFDOCID,
        this.rEFMID,
        this.rEMARKS,
        this.aSSIGNEDTO,
        this.sTARTDATE,
        this.sTARTTIME,
        this.eNDDATE,
        this.eNDTIME,
        this.dUEDATE,
        this.sTATUSID,
        this.lATITUDE,
        this.lONGITUDE,
        this.oRGSTRUCTID,
        this.pOSID,
        this.tOKEN,
        this.uSERID,
        this.aTTENDEES});

  XMLFILEEVENT.fromJson(Map<String, dynamic> json) {
    fLAG = json['FLAG'];
    aCTIVITYID = json['ACTIVITYID'];
    bUSINESSPARTNERID = json['BUSINESSPARTNERID'];
    cONTACT = json['CONTACT'];
    sUBJECT = json['SUBJECT'];
    tYPEID = json['TYPEID'];
    rEFDOCID = json['REFDOCID'];
    rEFMID = json['REFMID'];
    rEMARKS = json['REMARKS'];
    aSSIGNEDTO = json['ASSIGNEDTO'];
    sTARTDATE = json['STARTDATE'];
    sTARTTIME = json['STARTTIME'];
    eNDDATE = json['ENDDATE'];
    eNDTIME = json['ENDTIME'];
    dUEDATE = json['DUEDATE'];
    sTATUSID = json['STATUSID'];
    lATITUDE = json['LATITUDE'];
    lONGITUDE = json['LONGITUDE'];
    oRGSTRUCTID = json['ORGSTRUCTID'];
    pOSID = json['POSID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    if (json['ATTENDEES'] != null) {
      aTTENDEES = <ATTENDEES>[];
      json['ATTENDEES'].forEach((v) {
        aTTENDEES!.add(new ATTENDEES.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FLAG'] = this.fLAG;
    data['ACTIVITYID'] = this.aCTIVITYID;
    data['BUSINESSPARTNERID'] = this.bUSINESSPARTNERID;
    data['CONTACT'] = this.cONTACT;
    data['SUBJECT'] = this.sUBJECT;
    data['TYPEID'] = this.tYPEID;
    data['REFDOCID'] = this.rEFDOCID;
    data['REFMID'] = this.rEFMID;
    data['REMARKS'] = this.rEMARKS;
    data['ASSIGNEDTO'] = this.aSSIGNEDTO;
    data['STARTDATE'] = this.sTARTDATE;
    data['STARTTIME'] = this.sTARTTIME;
    data['ENDDATE'] = this.eNDDATE;
    data['ENDTIME'] = this.eNDTIME;
    data['DUEDATE'] = this.dUEDATE;
    data['STATUSID'] = this.sTATUSID;
    data['LATITUDE'] = this.lATITUDE;
    data['LONGITUDE'] = this.lONGITUDE;
    data['ORGSTRUCTID'] = this.oRGSTRUCTID;
    data['POSID'] = this.pOSID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    if (this.aTTENDEES != null) {
      data['ATTENDEES'] = this.aTTENDEES!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ATTENDEES {
  String? aTTENDEESUSERID;

  ATTENDEES({this.aTTENDEESUSERID});

  ATTENDEES.fromJson(Map<String, dynamic> json) {
    aTTENDEESUSERID = json['ATTENDEESUSERID'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ATTENDEESUSERID'] = this.aTTENDEESUSERID;

    return data;
  }
}
