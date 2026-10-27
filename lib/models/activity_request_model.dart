class ActivityRequestModel {
  XMLFILEACTIVITY? xMLFILE;

  ActivityRequestModel({this.xMLFILE});

  ActivityRequestModel.fromJson(Map<String, dynamic> json) {
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
  String? dESC;
  String? fLAG;
  String? oRGSTRUCTID;
  String? pOSID;
  String? tOKEN;
  String? uSERID;

  XMLFILEACTIVITY(
      {this.aCTIVITYID,
        this.dESC,
        this.fLAG,
        this.oRGSTRUCTID,
        this.pOSID,
        this.tOKEN,
        this.uSERID});

  XMLFILEACTIVITY.fromJson(Map<String, dynamic> json) {
    aCTIVITYID = json['ACTIVITYID'];
    dESC = json['DESC'];
    fLAG = json['FLAG'];
    oRGSTRUCTID = json['ORGSTRUCTID'];
    pOSID = json['POSID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ACTIVITYID'] = this.aCTIVITYID;
    data['DESC'] = this.dESC;
    data['FLAG'] = this.fLAG;
    data['ORGSTRUCTID'] = this.oRGSTRUCTID;
    data['POSID'] = this.pOSID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
