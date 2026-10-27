class APPROVALSLIST {
  String? iD;
  String? rPTID;
  String? mID;
  String? dOCID;
  String? dOCWFTYPE;
  String? dOCDESC;
  String? mENUID;
  String? mENUNAME;
  String? iNVCTYPE;
  String? rEMARKS;
  String? aPPROVEDBY;
  String? aPPROVERNAME;
  String? aPPROVERPOSITION;
  String? oRGSTRUCTDESC;
  String? dOCWFTID;
  String? lVL;
  String? iNVCNUMB;
  String? iNVCDATE;
  String? sTATUSID;
  String? aPPROVERSTATUS;
  String? rELEASEDATE;
  String? cREATEDBY;
  String? cREATEDBYNAME;
  String? sLID;
  String? sLDESC;
  String? gLDESC;
  String? dOCAMT;
  String? cOLOR;
  String? cOLORCODE;
  String? rELEASECOUNT;
  String? lastAppDate;
  String? dUEDATE;
  String? cREATEDDATE;
  String? cONTROLNAME;
  String? cONTROLNAMEFORVIEW;
  String? totalRows;
  String? totalPages;
  String? pageSize;
  ATTCHMNTINFO? aTTCHMNTINFO;

  APPROVALSLIST(
      {this.iD,
        this.rPTID,
        this.mID,
        this.dOCID,
        this.dOCWFTYPE,
        this.dOCDESC,
        this.mENUID,
        this.mENUNAME,
        this.iNVCTYPE,
        this.rEMARKS,
        this.aPPROVEDBY,
        this.aPPROVERNAME,
        this.aPPROVERPOSITION,
        this.oRGSTRUCTDESC,
        this.dOCWFTID,
        this.lVL,
        this.iNVCNUMB,
        this.iNVCDATE,
        this.sTATUSID,
        this.aPPROVERSTATUS,
        this.rELEASEDATE,
        this.cREATEDBY,
        this.cREATEDBYNAME,
        this.sLID,
        this.sLDESC,
        this.gLDESC,
        this.dOCAMT,
        this.cOLOR,
        this.cOLORCODE,
        this.rELEASECOUNT,
        this.lastAppDate,
        this.dUEDATE,
        this.cREATEDDATE,
        this.cONTROLNAME,
        this.cONTROLNAMEFORVIEW,
        this.totalRows,
        this.totalPages,
        this.pageSize,
        this.aTTCHMNTINFO});

  APPROVALSLIST.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    rPTID = json['RPTID'];
    mID = json['MID'];
    dOCID = json['DOCID'];
    dOCWFTYPE = json['DOCWFTYPE'];
    dOCDESC = json['DOCDESC'];
    mENUID = json['MENUID'];
    mENUNAME = json['MENUNAME'];
    iNVCTYPE = json['INVCTYPE'];
    rEMARKS = json['REMARKS'];
    aPPROVEDBY = json['APPROVEDBY'];
    aPPROVERNAME = json['APPROVERNAME'];
    aPPROVERPOSITION = json['APPROVERPOSITION'];
    oRGSTRUCTDESC = json['ORGSTRUCTDESC'];
    dOCWFTID = json['DOCWFTID'];
    lVL = json['LVL'];
    iNVCNUMB = json['INVCNUMB'];
    iNVCDATE = json['INVCDATE'];
    sTATUSID = json['STATUSID'];
    aPPROVERSTATUS = json['APPROVERSTATUS'];
    rELEASEDATE = json['RELEASEDATE'];
    cREATEDBY = json['CREATEDBY'];
    cREATEDBYNAME = json['CREATEDBYNAME'];
    sLID = json['SLID'];
    sLDESC = json['SLDESC'];
    gLDESC = json['GLDESC'];
    dOCAMT = json['DOCAMT'];
    cOLOR = json['COLOR'];
    cOLORCODE = json['COLORCODE'];
    rELEASECOUNT = json['RELEASECOUNT'];
    lastAppDate = json['LastAppDate'];
    dUEDATE = json['DUEDATE'];
    cREATEDDATE = json['CREATEDDATE'];
    cONTROLNAME = json['CONTROLNAME'];
    cONTROLNAMEFORVIEW = json['CONTROLNAMEFORVIEW'];
    totalRows = json['TotalRows'];
    totalPages = json['TotalPages'];
    pageSize = json['PageSize'];
    aTTCHMNTINFO = json['ATTCHMNTINFO'] != null
        ? new ATTCHMNTINFO.fromJson(json['ATTCHMNTINFO'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['RPTID'] = this.rPTID;
    data['MID'] = this.mID;
    data['DOCID'] = this.dOCID;
    data['DOCWFTYPE'] = this.dOCWFTYPE;
    data['DOCDESC'] = this.dOCDESC;
    data['MENUID'] = this.mENUID;
    data['MENUNAME'] = this.mENUNAME;
    data['INVCTYPE'] = this.iNVCTYPE;
    data['REMARKS'] = this.rEMARKS;
    data['APPROVEDBY'] = this.aPPROVEDBY;
    data['APPROVERNAME'] = this.aPPROVERNAME;
    data['APPROVERPOSITION'] = this.aPPROVERPOSITION;
    data['ORGSTRUCTDESC'] = this.oRGSTRUCTDESC;
    data['DOCWFTID'] = this.dOCWFTID;
    data['LVL'] = this.lVL;
    data['INVCNUMB'] = this.iNVCNUMB;
    data['INVCDATE'] = this.iNVCDATE;
    data['STATUSID'] = this.sTATUSID;
    data['APPROVERSTATUS'] = this.aPPROVERSTATUS;
    data['RELEASEDATE'] = this.rELEASEDATE;
    data['CREATEDBY'] = this.cREATEDBY;
    data['CREATEDBYNAME'] = this.cREATEDBYNAME;
    data['SLID'] = this.sLID;
    data['SLDESC'] = this.sLDESC;
    data['GLDESC'] = this.gLDESC;
    data['DOCAMT'] = this.dOCAMT;
    data['COLOR'] = this.cOLOR;
    data['COLORCODE'] = this.cOLORCODE;
    data['RELEASECOUNT'] = this.rELEASECOUNT;
    data['LastAppDate'] = this.lastAppDate;
    data['DUEDATE'] = this.dUEDATE;
    data['CREATEDDATE'] = this.cREATEDDATE;
    data['CONTROLNAME'] = this.cONTROLNAME;
    data['CONTROLNAMEFORVIEW'] = this.cONTROLNAMEFORVIEW;
    data['TotalRows'] = this.totalRows;
    data['TotalPages'] = this.totalPages;
    data['PageSize'] = this.pageSize;
    if (this.aTTCHMNTINFO != null) {
      data['ATTCHMNTINFO'] = this.aTTCHMNTINFO!.toJson();
    }
    return data;
  }
}

class ATTCHMNTINFO {
  ATTACHMENTS? aTTACHMENTS;

  ATTCHMNTINFO({this.aTTACHMENTS});

  ATTCHMNTINFO.fromJson(Map<String, dynamic> json) {
    aTTACHMENTS = json['ATTACHMENTS'] != null
        ? new ATTACHMENTS.fromJson(json['ATTACHMENTS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.aTTACHMENTS != null) {
      data['ATTACHMENTS'] = this.aTTACHMENTS!.toJson();
    }
    return data;
  }
}

class ATTACHMENTS {
  List<INFO>? iNFO;

  ATTACHMENTS({this.iNFO});

  ATTACHMENTS.fromJson(Map<String, dynamic> json) {
    if (json['INFO'] != null) {
      iNFO = <INFO>[];
      json['INFO'].forEach((v) {
        iNFO!.add(new INFO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.iNFO != null) {
      data['INFO'] = this.iNFO!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class INFO {
  String? aTCHFILEID;
  String? oRIGINALFILENAME;
  String? nEWFILENAME;
  String? eXTENSION;
  String? fOLDERNAME;
  String? iSDELETE;
  String? dOWNLOADURL;

  INFO(
      {this.aTCHFILEID,
        this.oRIGINALFILENAME,
        this.nEWFILENAME,
        this.eXTENSION,
        this.fOLDERNAME,
        this.iSDELETE,
        this.dOWNLOADURL});

  INFO.fromJson(Map<String, dynamic> json) {
    aTCHFILEID = json['ATCHFILEID'];
    oRIGINALFILENAME = json['ORIGINALFILENAME'];
    nEWFILENAME = json['NEWFILENAME'];
    eXTENSION = json['EXTENSION'];
    fOLDERNAME = json['FOLDERNAME'];
    iSDELETE = json['ISDELETE'];
    dOWNLOADURL = json['DOWNLOADURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ATCHFILEID'] = this.aTCHFILEID;
    data['ORIGINALFILENAME'] = this.oRIGINALFILENAME;
    data['NEWFILENAME'] = this.nEWFILENAME;
    data['EXTENSION'] = this.eXTENSION;
    data['FOLDERNAME'] = this.fOLDERNAME;
    data['ISDELETE'] = this.iSDELETE;
    data['DOWNLOADURL'] = this.dOWNLOADURL;
    return data;
  }
}
