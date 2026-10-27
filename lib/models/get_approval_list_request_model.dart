class GetApprovalListRequestModel {
  XMLFILEAPPROVALS? xMLFILE;

  GetApprovalListRequestModel({this.xMLFILE});

  GetApprovalListRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEAPPROVALS.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEAPPROVALS {
  String? dOCID;
  String? dUEDATE;
  String? fLAG;
  String? fROMDATE;
  String? mENUID;
  String? mID;
  String? oRGSTRUCTID;
  int? pAGENO;
  String? pOSID;
  String? tODATE;
  String? tOKEN;
  String? uSERID;
  String? dESC;
  String? controlno;

  XMLFILEAPPROVALS(
      {this.dOCID,
        this.dUEDATE,
        this.fLAG,
        this.fROMDATE,
        this.mENUID,
        this.mID,
        this.oRGSTRUCTID,
        this.pAGENO,
        this.pOSID,
        this.tODATE,
        this.tOKEN,
        this.uSERID,
        this.dESC,
        this.controlno
      });

  XMLFILEAPPROVALS.fromJson(Map<String, dynamic> json) {
    dOCID = json['DOCID'];
    dUEDATE = json['DUEDATE'];
    fLAG = json['FLAG'];
    fROMDATE = json['FROMDATE'];
    mENUID = json['MENUID'];
    mID = json['MID'];
    oRGSTRUCTID = json['ORGSTRUCTID'];
    pAGENO = json['PAGENO'];
    pOSID = json['POSID'];
    tODATE = json['TODATE'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    dESC = json['DESC'];
    controlno = json['CONTROLNO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DOCID'] = this.dOCID;
    data['DUEDATE'] = this.dUEDATE;
    data['FLAG'] = this.fLAG;
    data['FROMDATE'] = this.fROMDATE;
    data['MENUID'] = this.mENUID;
    data['MID'] = this.mID;
    data['ORGSTRUCTID'] = this.oRGSTRUCTID;
    data['PAGENO'] = this.pAGENO;
    data['POSID'] = this.pOSID;
    data['TODATE'] = this.tODATE;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['DESC'] = this.dESC;
    data['CONTROLNO'] = this.controlno;
    return data;
  }
}
