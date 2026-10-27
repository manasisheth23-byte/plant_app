class FillLocationsRequestModel {
  XMLFILEFILLLOCATION? xMLFILE;

  FillLocationsRequestModel({this.xMLFILE});

  FillLocationsRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEFILLLOCATION.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEFILLLOCATION {
  String? dOCID;
  String? fLAG;
  String? lOCMAPTYPE;
  String? oRGSTRUCID;
  String? pFMID;
  String? pRODLINEID;
  String? sEARCHTXT;
  String? tOKEN;
  String? uSERID;

  XMLFILEFILLLOCATION(
      {this.dOCID,
        this.fLAG,
        this.lOCMAPTYPE,
        this.oRGSTRUCID,
        this.pFMID,
        this.pRODLINEID,
        this.sEARCHTXT,
        this.tOKEN,
        this.uSERID});

  XMLFILEFILLLOCATION.fromJson(Map<String, dynamic> json) {
    dOCID = json['DOCID'];
    fLAG = json['FLAG'];
    lOCMAPTYPE = json['LOCMAPTYPE'];
    oRGSTRUCID = json['ORGSTRUCID'];
    pFMID = json['PFMID'];
    pRODLINEID = json['PRODLINEID'];
    sEARCHTXT = json['SEARCHTXT'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DOCID'] = this.dOCID;
    data['FLAG'] = this.fLAG;
    data['LOCMAPTYPE'] = this.lOCMAPTYPE;
    data['ORGSTRUCID'] = this.oRGSTRUCID;
    data['PFMID'] = this.pFMID;
    data['PRODLINEID'] = this.pRODLINEID;
    data['SEARCHTXT'] = this.sEARCHTXT;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
