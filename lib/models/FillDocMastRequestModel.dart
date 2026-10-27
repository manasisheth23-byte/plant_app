class FillDocMastRequestModel {
  XMLFILEFILLDOCMAST? xMLFILE;

  FillDocMastRequestModel({this.xMLFILE});

  FillDocMastRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEFILLDOCMAST.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEFILLDOCMAST {
  String? dESC;
  String? dOCID;
  String? fLAG;
  String? mENUID;
  String? oRGSTRUCID;
  String? pOSID;
  String? rEFDOCID;
  String? sYSDOCID;
  String? tOKEN;
  String? uSERID;

  XMLFILEFILLDOCMAST(
      {this.dESC,
        this.dOCID,
        this.fLAG,
        this.mENUID,
        this.oRGSTRUCID,
        this.pOSID,
        this.rEFDOCID,
        this.sYSDOCID,
        this.tOKEN,
        this.uSERID});

  XMLFILEFILLDOCMAST.fromJson(Map<String, dynamic> json) {
    dESC = json['DESC'];
    dOCID = json['DOCID'];
    fLAG = json['FLAG'];
    mENUID = json['MENUID'];
    oRGSTRUCID = json['ORGSTRUCID'];
    pOSID = json['POSID'];
    rEFDOCID = json['REFDOCID'];
    sYSDOCID = json['SYSDOCID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DESC'] = this.dESC;
    data['DOCID'] = this.dOCID;
    data['FLAG'] = this.fLAG;
    data['MENUID'] = this.mENUID;
    data['ORGSTRUCID'] = this.oRGSTRUCID;
    data['POSID'] = this.pOSID;
    data['REFDOCID'] = this.rEFDOCID;
    data['SYSDOCID'] = this.sYSDOCID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
