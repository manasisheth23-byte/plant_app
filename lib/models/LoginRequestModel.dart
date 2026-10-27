class LoginRequestModel {
  XMLFILElogin? xMLFILE;

  LoginRequestModel({this.xMLFILE});

  LoginRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILElogin.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILElogin {
  String? lOGINID;
  String? pASSWORD;
  String? rFID;
  int? uSERID;
  String? DEVICENAME;
  String? DEVICEIP;
  String? FCMKEY;
  String? OLDFCMKEY;

  XMLFILElogin({this.lOGINID, this.pASSWORD, this.rFID, this.uSERID, this.DEVICENAME, this.DEVICEIP,this.FCMKEY,this.OLDFCMKEY});

  XMLFILElogin.fromJson(Map<String, dynamic> json) {
    lOGINID = json['LOGINID'];
    pASSWORD = json['PASSWORD'];
    rFID = json['RFID'];
    uSERID = json['USERID'];
    DEVICENAME = json['DEVICENAME'];
    DEVICEIP = json['DEVICEIP'];
    FCMKEY = json['FCMKEY'];
    OLDFCMKEY = json['OLDFCMKEY'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LOGINID'] = this.lOGINID;
    data['PASSWORD'] = this.pASSWORD;
    data['RFID'] = this.rFID;
    data['USERID'] = this.uSERID;
    data['DEVICENAME'] = this.DEVICENAME;
    data['DEVICEIP'] = this.DEVICEIP;
    data['FCMKEY'] = this.FCMKEY;
    data['OLDFCMKEY'] = this.OLDFCMKEY;
    return data;
  }
}
