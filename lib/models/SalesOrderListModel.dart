class SoListModel {
  DATA? dATA;

  SoListModel({this.dATA});

  SoListModel.fromJson(Map<String, dynamic> json) {
    dATA = json['DATA'] != null ? new DATA.fromJson(json['DATA']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dATA != null) {
      data['DATA'] = this.dATA!.toJson();
    }
    return data;
  }
}

class DATA {
  String? sYNCDATETIME;
  List<LIST>? lIST;

  DATA({this.sYNCDATETIME, this.lIST});

  DATA.fromJson(Map<String, dynamic> json) {
    sYNCDATETIME = json['SYNCDATETIME'];
    if (json['LIST'] != null) {
      lIST = <LIST>[];
      json['LIST'].forEach((v) {
        lIST!.add(new LIST.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SYNCDATETIME'] = this.sYNCDATETIME;
    if (this.lIST != null) {
      data['LIST'] = this.lIST!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LIST {
  String? rPTID;
  String? mID;
  String? dOCID;
  String? dOCTYPE;
  String? iNVCNUMB;
  String? iNVCDATE;
  String? cONTROLNO;
  String? fCAMOUNT;
  String? aMOUNT;
  String? sLID;
  String? sLDESC;
  String? pORDERNO;
  String? pORDERDATE;
  String? iSAUTH;
  String? iSRELEASE;
  String? dOCSTATUS;
  String? iSCOMPLETE;
  String? cREATEDON;
  String? cREATEDBY;
  String? cREATEDBYNAME;
  String? sALESPERSON;
  String? dUEDATE;
  String? sTATUS;
  TRANSLIST? tRANSLIST;

  LIST(
      {this.rPTID,
        this.mID,
        this.dOCID,
        this.dOCTYPE,
        this.iNVCNUMB,
        this.iNVCDATE,
        this.cONTROLNO,
        this.fCAMOUNT,
        this.aMOUNT,
        this.sLID,
        this.sLDESC,
        this.pORDERNO,
        this.pORDERDATE,
        this.iSAUTH,
        this.iSRELEASE,
        this.dOCSTATUS,
        this.iSCOMPLETE,
        this.cREATEDON,
        this.cREATEDBY,
        this.cREATEDBYNAME,
        this.sALESPERSON,
        this.dUEDATE,
        this.sTATUS,
        this.tRANSLIST});

  LIST.fromJson(Map<String, dynamic> json) {
    rPTID = json['RPTID'];
    mID = json['MID'];
    dOCID = json['DOCID'];
    dOCTYPE = json['DOCTYPE'];
    iNVCNUMB = json['INVCNUMB'];
    iNVCDATE = json['INVCDATE'];
    cONTROLNO = json['CONTROLNO'];
    fCAMOUNT = json['FCAMOUNT'];
    aMOUNT = json['AMOUNT'];
    sLID = json['SLID'];
    sLDESC = json['SLDESC'];
    pORDERNO = json['PORDERNO'];
    pORDERDATE = json['PORDERDATE'];
    iSAUTH = json['ISAUTH'];
    iSRELEASE = json['ISRELEASE'];
    dOCSTATUS = json['DOCSTATUS'];
    iSCOMPLETE = json['ISCOMPLETE'];
    cREATEDON = json['CREATEDON'];
    cREATEDBY = json['CREATEDBY'];
    cREATEDBYNAME = json['CREATEDBYNAME'];
    sALESPERSON = json['SALESPERSON'];
    dUEDATE = json['DUEDATE'];
    sTATUS = json['STATUS'];
    tRANSLIST = json['TRANSLIST'] != null
        ? new TRANSLIST.fromJson(json['TRANSLIST'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RPTID'] = this.rPTID;
    data['MID'] = this.mID;
    data['DOCID'] = this.dOCID;
    data['DOCTYPE'] = this.dOCTYPE;
    data['INVCNUMB'] = this.iNVCNUMB;
    data['INVCDATE'] = this.iNVCDATE;
    data['CONTROLNO'] = this.cONTROLNO;
    data['FCAMOUNT'] = this.fCAMOUNT;
    data['AMOUNT'] = this.aMOUNT;
    data['SLID'] = this.sLID;
    data['SLDESC'] = this.sLDESC;
    data['PORDERNO'] = this.pORDERNO;
    data['PORDERDATE'] = this.pORDERDATE;
    data['ISAUTH'] = this.iSAUTH;
    data['ISRELEASE'] = this.iSRELEASE;
    data['DOCSTATUS'] = this.dOCSTATUS;
    data['ISCOMPLETE'] = this.iSCOMPLETE;
    data['CREATEDON'] = this.cREATEDON;
    data['CREATEDBY'] = this.cREATEDBY;
    data['CREATEDBYNAME'] = this.cREATEDBYNAME;
    data['SALESPERSON'] = this.sALESPERSON;
    data['DUEDATE'] = this.dUEDATE;
    data['STATUS'] = this.sTATUS;
    if (this.tRANSLIST != null) {
      data['TRANSLIST'] = this.tRANSLIST!.toJson();
    }
    return data;
  }
}

class TRANSLIST {
  List<TRANS>? tRANS;

  TRANSLIST({this.tRANS});

  TRANSLIST.fromJson(Map<String, dynamic> json) {
    if (json['TRANS'] != null) {
      tRANS = <TRANS>[];
      json['TRANS'].forEach((v) {
        tRANS!.add(new TRANS.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tRANS != null) {
      data['TRANS'] = this.tRANS!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TRANS {
  String? tID;
  String? iTEMID;
  String? productCode;
  String? productDescription;
  String? nOU;
  String? qTY;
  String? iNVCAMOUNT;
  String? uNITRATE;
  String? uOMID;
  String? uOMCODE;
  String? lASTSALERATE;
  String? dELIVERYDATE;

  TRANS(
      {this.tID,
        this.iTEMID,
        this.productCode,
        this.productDescription,
        this.nOU,
        this.qTY,
        this.iNVCAMOUNT,
        this.uNITRATE,
        this.uOMID,
        this.uOMCODE,
        this.lASTSALERATE,
        this.dELIVERYDATE});

  TRANS.fromJson(Map<String, dynamic> json) {
    tID = json['TID'];
    iTEMID = json['ITEMID'];
    productCode = json['Product_Code'];
    productDescription = json['Product_Description'];
    nOU = json['NOU'];
    qTY = json['QTY'];
    iNVCAMOUNT = json['INVCAMOUNT'];
    uNITRATE = json['UNITRATE'];
    uOMID = json['UOMID'];
    uOMCODE = json['UOMCODE'];
    lASTSALERATE = json['LASTSALERATE'];
    dELIVERYDATE = json['DELIVERYDATE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TID'] = this.tID;
    data['ITEMID'] = this.iTEMID;
    data['Product_Code'] = this.productCode;
    data['Product_Description'] = this.productDescription;
    data['NOU'] = this.nOU;
    data['QTY'] = this.qTY;
    data['INVCAMOUNT'] = this.iNVCAMOUNT;
    data['UNITRATE'] = this.uNITRATE;
    data['UOMID'] = this.uOMID;
    data['UOMCODE'] = this.uOMCODE;
    data['LASTSALERATE'] = this.lASTSALERATE;
    data['DELIVERYDATE'] = this.dELIVERYDATE;
    return data;
  }
}
