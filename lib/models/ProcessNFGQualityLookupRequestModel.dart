class ProcessNFGQualityLookupRequestModel {
  XMLFILEFGQUALITY? xMLFILE;

  ProcessNFGQualityLookupRequestModel({this.xMLFILE});

  ProcessNFGQualityLookupRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEFGQUALITY.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEFGQUALITY {
  String? cONTROLNO;
  String? dOCID;
  String? mENUID;
  String? oRGSTRUCID;
  String? pAGENO;
  String? sTATUSID;
  String? tYPEID;
  String? tOKEN;
  String? uSERID;

  XMLFILEFGQUALITY(
      {this.cONTROLNO,
        this.dOCID,
        this.mENUID,
        this.oRGSTRUCID,
        this.pAGENO,
        this.sTATUSID,
        this.tYPEID,
        this.tOKEN,
        this.uSERID});

  XMLFILEFGQUALITY.fromJson(Map<String, dynamic> json) {
    cONTROLNO = json['CONTROLNO'];
    dOCID = json['DOCID'];
    mENUID = json['MENUID'];
    oRGSTRUCID = json['ORGSTRUCID'];
    pAGENO = json['PAGENO'];
    sTATUSID = json['STATUSID'];
    tYPEID = json['TYPEID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CONTROLNO'] = this.cONTROLNO;
    data['DOCID'] = this.dOCID;
    data['MENUID'] = this.mENUID;
    data['ORGSTRUCID'] = this.oRGSTRUCID;
    data['PAGENO'] = this.pAGENO;
    data['STATUSID'] = this.sTATUSID;
    data['TYPEID'] = this.tYPEID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
