class AddActivityRequestModel {
  XMLFILEACTIVITY? xMLFILE;

  AddActivityRequestModel({this.xMLFILE});

  AddActivityRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEACTIVITY.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEACTIVITY {
  String? aCTIVITYID;
  int? aSSIGNEDTO;
  int? cALLPLANTYPEID;
  int? cALLTYPEID;
  int? cONTACTPERSONID;
  String? cONTENT;
  String? fLAG;
  String? oRGSTRUCTID;
  String? pOSID;
  String? sUBJECT;
  int? tYPEID;
  String? tOKEN;
  String? uSERID;
  String? controlno;


  XMLFILEACTIVITY(
      {this.aCTIVITYID,
        this.aSSIGNEDTO,
        this.cALLPLANTYPEID,
        this.cALLTYPEID,
        this.cONTACTPERSONID,
        this.cONTENT,
        this.fLAG,
        this.oRGSTRUCTID,
        this.pOSID,
        this.sUBJECT,
        this.tYPEID,
        this.tOKEN,
        this.uSERID,
      this.controlno});

  XMLFILEACTIVITY.fromJson(Map<String, dynamic> json) {
    aCTIVITYID = json['ACTIVITYID'];
    aSSIGNEDTO = json['ASSIGNEDTO'];
    cALLPLANTYPEID = json['CALLPLANTYPEID'];
    cALLTYPEID = json['CALLTYPEID'];
    cONTACTPERSONID = json['CONTACTPERSONID'];
    cONTENT = json['CONTENT'];
    fLAG = json['FLAG'];
    oRGSTRUCTID = json['ORGSTRUCTID'];
    pOSID = json['POSID'];
    sUBJECT = json['SUBJECT'];
    tYPEID = json['TYPEID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    controlno = json['CONTROLNO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ACTIVITYID'] = this.aCTIVITYID;
    data['ASSIGNEDTO'] = this.aSSIGNEDTO;
    data['CALLPLANTYPEID'] = this.cALLPLANTYPEID;
    data['CALLTYPEID'] = this.cALLTYPEID;
    data['CONTACTPERSONID'] = this.cONTACTPERSONID;
    data['CONTENT'] = this.cONTENT;
    data['FLAG'] = this.fLAG;
    data['ORGSTRUCTID'] = this.oRGSTRUCTID;
    data['POSID'] = this.pOSID;
    data['SUBJECT'] = this.sUBJECT;
    data['TYPEID'] = this.tYPEID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['CONTROLNO'] = this.controlno;
    return data;
  }
}
