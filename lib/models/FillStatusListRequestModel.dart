class FillStatusListRequestModel {
  XMLFILEFILLSTATUS? xMLFILE;

  FillStatusListRequestModel({this.xMLFILE});

  FillStatusListRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEFILLSTATUS.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEFILLSTATUS {
  String? dESC;
  String? fLAG;
  String? sTATUSID;
  String? tYPEID;
  String? tOKEN;
  int? uSERID;
  String? orgstd;
  String? controlno;

  XMLFILEFILLSTATUS(
      {this.dESC,
        this.fLAG,
        this.sTATUSID,
        this.tYPEID,
        this.tOKEN,
        this.uSERID,
      this.orgstd,
      this.controlno});

  XMLFILEFILLSTATUS.fromJson(Map<String, dynamic> json) {
    dESC = json['DESC'];
    fLAG = json['FLAG'];
    sTATUSID = json['STATUSID'];
    tYPEID = json['TYPEID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    orgstd = json['ORGSTRUCTID'];
    controlno = json['CONTROLNO '];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DESC'] = this.dESC;
    data['FLAG'] = this.fLAG;
    data['STATUSID'] = this.sTATUSID;
    data['TYPEID'] = this.tYPEID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['ORGSTRUCTID'] = this.orgstd;
    data['CONTROLNO '] = this.controlno;
    return data;
  }
}
