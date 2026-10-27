class CheckDeviceRequestModel {
  XMLFILEc? xMLFILE;

  CheckDeviceRequestModel({this.xMLFILE});

  CheckDeviceRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEc.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEc {
  String? dEVICEID;
  String? fLAG;
  String? iPADDRESS;
  String? mAC;
  String? pORT;
  int? vERSION;
  int? uSERID;

  XMLFILEc(
      {this.dEVICEID,
        this.fLAG,
        this.iPADDRESS,
        this.mAC,
        this.pORT,
        this.vERSION,
        this.uSERID});

  XMLFILEc.fromJson(Map<String, dynamic> json) {
    dEVICEID = json['DEVICEID'];
    fLAG = json['FLAG'];
    iPADDRESS = json['IPADDRESS'];
    mAC = json['MAC'];
    pORT = json['PORT'];
    vERSION = json['VERSION'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DEVICEID'] = this.dEVICEID;
    data['FLAG'] = this.fLAG;
    data['IPADDRESS'] = this.iPADDRESS;
    data['MAC'] = this.mAC;
    data['PORT'] = this.pORT;
    data['VERSION'] = this.vERSION;
    data['USERID'] = this.uSERID;
    return data;
  }
}

