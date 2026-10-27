class ChangePasswordRequestModel {
  XMLFILECHANGEPASSWORD? xMLFILE;

  ChangePasswordRequestModel({this.xMLFILE});

  ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILECHANGEPASSWORD.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILECHANGEPASSWORD {
  String? cONFIRMPASSWORD;
  String? nEWPASSWORD;
  String? oLDPASSWORD;
  String? tOKEN;
  String? uSERID;
  String? FLAG;

  XMLFILECHANGEPASSWORD(
      {this.cONFIRMPASSWORD,
        this.nEWPASSWORD,
        this.oLDPASSWORD,
        this.tOKEN,
        this.uSERID,
        this.FLAG

      });

  XMLFILECHANGEPASSWORD.fromJson(Map<String, dynamic> json) {
    cONFIRMPASSWORD = json['CONFIRMPASSWORD'];
    nEWPASSWORD = json['NEWPASSWORD'];
    oLDPASSWORD = json['OLDPASSWORD'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    FLAG = json['FLAG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CONFIRMPASSWORD'] = this.cONFIRMPASSWORD;
    data['NEWPASSWORD'] = this.nEWPASSWORD;
    data['OLDPASSWORD'] = this.oLDPASSWORD;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['FLAG'] = this.FLAG;
    return data;
  }
}
