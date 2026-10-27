class CheckDeviceResponseModel {
  DATA? dATA;
  String? error;
  CheckDeviceResponseModel({this.dATA});

  CheckDeviceResponseModel.fromJson(Map<String, dynamic> json) {
    dATA = json['DATA'] != null ? new DATA.fromJson(json['DATA']) : null;
  }
  CheckDeviceResponseModel.withError(String errorValue)
      : dATA = DATA(),
        error = errorValue;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dATA != null) {
      data['DATA'] = this.dATA!.toJson();
    }
    return data;
  }
}

class DATA {
  String? dEVICEID;
  String? mACID;
  String? iPADDRESS;
  String? pORT;
  String? cURRENTVERSION;
  String? lATESTVERSION;
  String? cREATEDON;
  String? mODIFIEDON;
  String? sERVERDATE;
  String? sERVERDATETIME;

  DATA(
      {this.dEVICEID,
        this.mACID,
        this.iPADDRESS,
        this.pORT,
        this.cURRENTVERSION,
        this.lATESTVERSION,
        this.cREATEDON,
        this.mODIFIEDON,
        this.sERVERDATE,
        this.sERVERDATETIME});

  DATA.fromJson(Map<String, dynamic> json) {
    dEVICEID = json['DEVICEID'];
    mACID = json['MACID'];
    iPADDRESS = json['IPADDRESS'];
    pORT = json['PORT'];
    cURRENTVERSION = json['CURRENTVERSION'];
    lATESTVERSION = json['LATESTVERSION'];
    cREATEDON = json['CREATEDON'];
    mODIFIEDON = json['MODIFIEDON'];
    sERVERDATE = json['SERVERDATE'];
    sERVERDATETIME = json['SERVERDATETIME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DEVICEID'] = this.dEVICEID;
    data['MACID'] = this.mACID;
    data['IPADDRESS'] = this.iPADDRESS;
    data['PORT'] = this.pORT;
    data['CURRENTVERSION'] = this.cURRENTVERSION;
    data['LATESTVERSION'] = this.lATESTVERSION;
    data['CREATEDON'] = this.cREATEDON;
    data['MODIFIEDON'] = this.mODIFIEDON;
    data['SERVERDATE'] = this.sERVERDATE;
    data['SERVERDATETIME'] = this.sERVERDATETIME;
    return data;
  }
}