class ClientEngagementReqestModel {
  XMLFILECLIENTENG? xMLFILE;

  ClientEngagementReqestModel({this.xMLFILE});

  ClientEngagementReqestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILECLIENTENG.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILECLIENTENG {
  String? mID;
  String? tOKEN;
  String? uSERID;

  XMLFILECLIENTENG({this.mID, this.tOKEN, this.uSERID});

  XMLFILECLIENTENG.fromJson(Map<String, dynamic> json) {
    mID = json['MID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MID'] = this.mID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
