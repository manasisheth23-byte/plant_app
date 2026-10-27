class GetTransDetailsForQCRequestModel {
  XMLFILEFGDETAILS? xMLFILE;

  GetTransDetailsForQCRequestModel({this.xMLFILE});

  GetTransDetailsForQCRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEFGDETAILS.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEFGDETAILS {
  String? fLAG;
  String? mENUID;
  String? mID;
  String? tOKEN;
  String? uSERID;

  XMLFILEFGDETAILS({this.fLAG, this.mENUID, this.mID, this.tOKEN, this.uSERID});

  XMLFILEFGDETAILS.fromJson(Map<String, dynamic> json) {
    fLAG = json['FLAG'];
    mENUID = json['MENUID'];
    mID = json['MID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FLAG'] = this.fLAG;
    data['MENUID'] = this.mENUID;
    data['MID'] = this.mID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
