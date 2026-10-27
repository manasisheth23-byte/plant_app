class AddEventResponseModel {
  SYSMSGS? sYSMSGS;

  AddEventResponseModel({this.sYSMSGS});

  AddEventResponseModel.fromJson(Map<String, dynamic> json) {
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

  SYSMSGS({this.iD, this.eRRORMSGS, this.tYPE, this.tITLE});

  SYSMSGS.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    eRRORMSGS = json['ERRORMSGS'];
    tYPE = json['TYPE'];
    tITLE = json['TITLE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['ERRORMSGS'] = this.eRRORMSGS;
    data['TYPE'] = this.tYPE;
    data['TITLE'] = this.tITLE;
    return data;
  }
}
