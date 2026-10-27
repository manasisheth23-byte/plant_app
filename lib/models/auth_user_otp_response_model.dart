class UserAuthOTPResponseModel {
  ERRORMSG? eRRORMSG;

  UserAuthOTPResponseModel({this.eRRORMSG});

  UserAuthOTPResponseModel.fromJson(Map<String, dynamic> json) {
    eRRORMSG = json['ERRORMSG'] != null
        ? new ERRORMSG.fromJson(json['ERRORMSG'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eRRORMSG != null) {
      data['ERRORMSG'] = this.eRRORMSG!.toJson();
    }
    return data;
  }
}

class ERRORMSG {
  String? iD;
  String? mSG;
  String? lOGINID;
  String? OTP;
  String? cODE;

  ERRORMSG({this.iD, this.mSG, this.lOGINID,this.OTP, this.cODE});

  ERRORMSG.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    mSG = json['MSG'];
    lOGINID = json['LOGINID'];
    OTP = json['OTP'];
    cODE = json['CODE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['MSG'] = this.mSG;
    data['LOGINID'] = this.lOGINID;
    data['OTP'] = this.OTP;
    data['CODE'] = this.cODE;
    return data;
  }
}
