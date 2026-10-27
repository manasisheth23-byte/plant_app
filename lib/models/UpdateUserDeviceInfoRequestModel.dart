class UpdateUserDeviceInfoRequestModel {
  XMLFILEDEVICEINFO? xMLFILE;

  UpdateUserDeviceInfoRequestModel({this.xMLFILE});

  UpdateUserDeviceInfoRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEDEVICEINFO.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEDEVICEINFO {
  String? dEVICEID;
  String? dEVICETYPE;
  String? fLAG;
  String? tOKEN;
  String? uSERID;

  XMLFILEDEVICEINFO({this.dEVICEID, this.dEVICETYPE, this.fLAG, this.tOKEN, this.uSERID});

  XMLFILEDEVICEINFO.fromJson(Map<String, dynamic> json) {
    dEVICEID = json['DEVICEID'];
    dEVICETYPE = json['DEVICETYPE'];
    fLAG = json['FLAG'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DEVICEID'] = this.dEVICEID;
    data['DEVICETYPE'] = this.dEVICETYPE;
    data['FLAG'] = this.fLAG;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
