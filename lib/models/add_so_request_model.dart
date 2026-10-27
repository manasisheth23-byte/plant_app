class AddSORequestModel {
  XMLFILE? xMLFILE;

  AddSORequestModel({this.xMLFILE});

  AddSORequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILE.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILE {
  String? sOID;
  String? sLID;
  String? pOREFNO;
  String? pOREFDATE;
  String? mID;
  String? dOCID;
  String? cREATEDBY;
  String? sODATE;
  String? cREATEDON;
  String? dUEDATE;
  String? fLAG;
  String? lASTUPDATEDDATE;
  String? tOKEN;
  String? uSERID;
  String? oRGSTRUCTID;
  String? pOSID;
  List<SOTRANS>? sOTRANS;

  XMLFILE(
      {this.sOID,
        this.sLID,
        this.pOREFNO,
        this.pOREFDATE,
        this.mID,
        this.dOCID,
        this.cREATEDBY,
        this.sODATE,
        this.cREATEDON,
        this.dUEDATE,
        this.fLAG,
        this.lASTUPDATEDDATE,
        this.tOKEN,
        this.uSERID,
        this.oRGSTRUCTID,
        this.pOSID,
        this.sOTRANS});

  XMLFILE.fromJson(Map<String, dynamic> json) {
    sOID = json['SOID'];
    sLID = json['SLID'];
    pOREFNO = json['POREFNO'];
    pOREFDATE = json['POREFDATE'];
    mID = json['MID'];
    dOCID = json['DOCID'];
    cREATEDBY = json['CREATEDBY'];
    sODATE = json['SODATE'];
    cREATEDON = json['CREATEDON'];
    dUEDATE = json['DUEDATE'];
    fLAG = json['FLAG'];
    lASTUPDATEDDATE = json['LASTUPDATEDDATE'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    oRGSTRUCTID = json['ORGSTRUCTID'];
    pOSID = json['POSID'];
    if (json['SOTRANS'] != null) {
      sOTRANS = <SOTRANS>[];
      json['SOTRANS'].forEach((v) {
        sOTRANS!.add(new SOTRANS.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SOID'] = this.sOID;
    data['SLID'] = this.sLID;
    data['POREFNO'] = this.pOREFNO;
    data['POREFDATE'] = this.pOREFDATE;
    data['MID'] = this.mID;
    data['DOCID'] = this.dOCID;
    data['CREATEDBY'] = this.cREATEDBY;
    data['SODATE'] = this.sODATE;
    data['CREATEDON'] = this.cREATEDON;
    data['DUEDATE'] = this.dUEDATE;
    data['FLAG'] = this.fLAG;
    data['LASTUPDATEDDATE'] = this.lASTUPDATEDDATE;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['ORGSTRUCTID'] = this.oRGSTRUCTID;
    data['POSID'] = this.pOSID;
    if (this.sOTRANS != null) {
      data['SOTRANS'] = this.sOTRANS!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SOTRANS {
  String? tID;
  String? iTEMID;
  String? uNITRATE;
  String? qTY;
  String? mRP;
  String? dELDATE;
  String? fLAG;
  String? lASTUPDATEDDATE;

  SOTRANS(
      {this.tID,
        this.iTEMID,
        this.uNITRATE,
        this.qTY,
        this.mRP,
        this.dELDATE,
        this.fLAG,
        this.lASTUPDATEDDATE});

  SOTRANS.fromJson(Map<String, dynamic> json) {
    tID = json['TID'];
    iTEMID = json['ITEMID'];
    uNITRATE = json['UNITRATE'];
    qTY = json['QTY'];
    mRP = json['MRP'];
    dELDATE = json['DELDATE'];
    fLAG = json['FLAG'];
    lASTUPDATEDDATE = json['LASTUPDATEDDATE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TID'] = this.tID;
    data['ITEMID'] = this.iTEMID;
    data['UNITRATE'] = this.uNITRATE;
    data['QTY'] = this.qTY;
    data['MRP'] = this.mRP;
    data['DELDATE'] = this.dELDATE;
    data['FLAG'] = this.fLAG;
    data['LASTUPDATEDDATE'] = this.lASTUPDATEDDATE;
    return data;
  }
}
