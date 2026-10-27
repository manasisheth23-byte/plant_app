class SyncSLedgerModel {
  DATA? dATA;

  SyncSLedgerModel({this.dATA});

  SyncSLedgerModel.fromJson(Map<String, dynamic> json) {
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
  String? status;
  String? message;
  String? sYNCDATETIME;
  List<LISTSLEDEGER>? lIST;

  DATA({this.status, this.message, this.sYNCDATETIME, this.lIST});

  DATA.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
    sYNCDATETIME = json['SYNCDATETIME'];
    if (json['LIST'] != null) {
      lIST = <LISTSLEDEGER>[];
      json['LIST'].forEach((v) {
        lIST!.add(new LISTSLEDEGER.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Message'] = this.message;
    data['SYNCDATETIME'] = this.sYNCDATETIME;
    if (this.lIST != null) {
      data['LIST'] = this.lIST!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LISTSLEDEGER {
  String? sLID;
  String? sLCODE;
  String? cUSTOMERNAME;
  String? sLTYPE;
  String? aDDRESS;
  String? eMAIL;
  String? pHONE;
  String? mOBILE;
  String? vENDORCODE;
  String? cITY;
  String? cONTACTPERSON;
  String? cURRENCY;
  String? cREDITACCOUNTDETAIL;
  String? fAX;
  String? sALESPERSON;
  CONTACTPERSONDETAILS? cONTACTPERSONDETAILS;

  LISTSLEDEGER(
      {this.sLID,
        this.sLCODE,
        this.cUSTOMERNAME,
        this.sLTYPE,
        this.aDDRESS,
        this.eMAIL,
        this.pHONE,
        this.mOBILE,
        this.vENDORCODE,
        this.cITY,
        this.cONTACTPERSON,
        this.cURRENCY,
        this.cREDITACCOUNTDETAIL,
        this.fAX,
        this.sALESPERSON,
        this.cONTACTPERSONDETAILS});

  LISTSLEDEGER.fromJson(Map<String, dynamic> json) {
    sLID = json['SLID'];
    sLCODE = json['SLCODE'];
    cUSTOMERNAME = json['CUSTOMERNAME'];
    sLTYPE = json['SLTYPE'];
    aDDRESS = json['ADDRESS'];
    eMAIL = json['EMAIL'];
    pHONE = json['PHONE'];
    mOBILE = json['MOBILE'];
    vENDORCODE = json['VENDORCODE'];
    cITY = json['CITY'];
    cONTACTPERSON = json['CONTACTPERSON'];
    cURRENCY = json['CURRENCY'];
    cREDITACCOUNTDETAIL = json['CREDITACCOUNTDETAIL'];
    fAX = json['FAX'];
    sALESPERSON = json['SALESPERSON'];
    cONTACTPERSONDETAILS = json['CONTACTPERSONDETAILS'] != null
        ? new CONTACTPERSONDETAILS.fromJson(json['CONTACTPERSONDETAILS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SLID'] = this.sLID;
    data['SLCODE'] = this.sLCODE;
    data['CUSTOMERNAME'] = this.cUSTOMERNAME;
    data['SLTYPE'] = this.sLTYPE;
    data['ADDRESS'] = this.aDDRESS;
    data['EMAIL'] = this.eMAIL;
    data['PHONE'] = this.pHONE;
    data['MOBILE'] = this.mOBILE;
    data['VENDORCODE'] = this.vENDORCODE;
    data['CITY'] = this.cITY;
    data['CONTACTPERSON'] = this.cONTACTPERSON;
    data['CURRENCY'] = this.cURRENCY;
    data['CREDITACCOUNTDETAIL'] = this.cREDITACCOUNTDETAIL;
    data['FAX'] = this.fAX;
    data['SALESPERSON'] = this.sALESPERSON;
    if (this.cONTACTPERSONDETAILS != null) {
      data['CONTACTPERSONDETAILS'] = this.cONTACTPERSONDETAILS!.toJson();
    }
    return data;
  }
}

class CONTACTPERSONDETAILS {
  String? nAME;
  String? dESIGNATION;
  String? mOBILE;
  String? fAX;
  String? eMAIL;
  String? iSDEFAULT;

  CONTACTPERSONDETAILS(
      {this.nAME,
        this.dESIGNATION,
        this.mOBILE,
        this.fAX,
        this.eMAIL,
        this.iSDEFAULT});

  CONTACTPERSONDETAILS.fromJson(Map<String, dynamic> json) {
    nAME = json['NAME'];
    dESIGNATION = json['DESIGNATION'];
    mOBILE = json['MOBILE'];
    fAX = json['FAX'];
    eMAIL = json['EMAIL'];
    iSDEFAULT = json['ISDEFAULT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NAME'] = this.nAME;
    data['DESIGNATION'] = this.dESIGNATION;
    data['MOBILE'] = this.mOBILE;
    data['FAX'] = this.fAX;
    data['EMAIL'] = this.eMAIL;
    data['ISDEFAULT'] = this.iSDEFAULT;
    return data;
  }
}
