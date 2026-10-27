class GetDefaultValRequestModel {
  XMLFILEDEFAULTVAL? xMLFILE;

  GetDefaultValRequestModel({this.xMLFILE});

  GetDefaultValRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEDEFAULTVAL.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEDEFAULTVAL {
  String? mENUID;
  String? oRGSTRUCID;
  String? pOSID;
  String? tOKEN;
  String? uSERID;

  XMLFILEDEFAULTVAL({this.mENUID, this.oRGSTRUCID, this.pOSID, this.tOKEN, this.uSERID});

  XMLFILEDEFAULTVAL.fromJson(Map<String, dynamic> json) {
    mENUID = json['MENUID'];
    oRGSTRUCID = json['ORGSTRUCID'];
    pOSID = json['POSID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MENUID'] = this.mENUID;
    data['ORGSTRUCID'] = this.oRGSTRUCID;
    data['POSID'] = this.pOSID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
