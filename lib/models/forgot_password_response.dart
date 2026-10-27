class ForgotPasswordResponse {
  SYSMSGS? sYSMSGS;

  ForgotPasswordResponse({this.sYSMSGS});

  ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    sYSMSGS =
    json['SYSMSGS'] != null ? new SYSMSGS.fromJson(json['SYSMSGS']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sYSMSGS != null) {
      data['SYSMSGS'] = this.sYSMSGS!.toJson();
    }
    return data;
  }
}

class SYSMSGS {
  String? iD;
  String? eRRORMSGS;
  String? tYPE;
  String? tITLE;
  String? mOBILENO;

  SYSMSGS({this.iD, this.eRRORMSGS, this.tYPE, this.tITLE, this.mOBILENO});

  SYSMSGS.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    eRRORMSGS = json['ERRORMSGS'];
    tYPE = json['TYPE'];
    tITLE = json['TITLE'];
    mOBILENO = json['MOBILENO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['ERRORMSGS'] = this.eRRORMSGS;
    data['TYPE'] = this.tYPE;
    data['TITLE'] = this.tITLE;
    data['MOBILENO'] = this.mOBILENO;
    return data;
  }
}
