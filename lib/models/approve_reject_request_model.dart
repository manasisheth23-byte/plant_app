class ApproveRejectRequestModel {
  XMLFILE? xMLFILE;

  ApproveRejectRequestModel({this.xMLFILE});

  ApproveRejectRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILE.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILE {
  String? dOCID;
  String? fLAG;
  String? iD;
  String? iSNEXTLVLUSER;
  String? mENUID;
  String? mID;
  String? nEXTLVLREMARK;
  String? oRGSTRUCID;
  String? pOSID;
  String? rEMARK;
  String? sTATUSID;
  String? tOKEN;
  String? uSERID;
  String? controlno;

  XMLFILE(
      {this.dOCID,
        this.fLAG,
        this.iD,
        this.iSNEXTLVLUSER,
        this.mENUID,
        this.mID,
        this.nEXTLVLREMARK,
        this.oRGSTRUCID,
        this.pOSID,
        this.rEMARK,
        this.sTATUSID,
        this.tOKEN,
        this.uSERID,
      this.controlno});

  XMLFILE.fromJson(Map<String, dynamic> json) {
    dOCID = json['DOCID'];
    fLAG = json['FLAG'];
    iD = json['ID'];
    iSNEXTLVLUSER = json['ISNEXTLVLUSER'];
    mENUID = json['MENUID'];
    mID = json['MID'];
    nEXTLVLREMARK = json['NEXTLVLREMARK'];
    oRGSTRUCID = json['ORGSTRUCID'];
    pOSID = json['POSID'];
    rEMARK = json['REMARK'];
    sTATUSID = json['STATUSID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    controlno = json['CONTROLNO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DOCID'] = this.dOCID;
    data['FLAG'] = this.fLAG;
    data['ID'] = this.iD;
    data['ISNEXTLVLUSER'] = this.iSNEXTLVLUSER;
    data['MENUID'] = this.mENUID;
    data['MID'] = this.mID;
    data['NEXTLVLREMARK'] = this.nEXTLVLREMARK;
    data['ORGSTRUCID'] = this.oRGSTRUCID;
    data['POSID'] = this.pOSID;
    data['REMARK'] = this.rEMARK;
    data['STATUSID'] = this.sTATUSID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['CONTROLNO'] = this.controlno;
    return data;
  }
}
