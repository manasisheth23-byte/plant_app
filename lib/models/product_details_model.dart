/*
class ProductsDetailsModel {
  SOLDETAILS? sOLDETAILS;

  ProductsDetailsModel({this.sOLDETAILS});

  ProductsDetailsModel.fromJson(Map<String, dynamic> json) {
    sOLDETAILS = json['SOLDETAILS'] != null
        ? new SOLDETAILS.fromJson(json['SOLDETAILS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sOLDETAILS != null) {
      data['SOLDETAILS'] = this.sOLDETAILS!.toJson();
    }
    return data;
  }
}

class SOLDETAILS {
  List<SOLUTIONS>? sOLUTIONS;

  SOLDETAILS({this.sOLUTIONS});

  SOLDETAILS.fromJson(Map<String, dynamic> json) {
    if (json['SOLUTIONS'] != null) {
      sOLUTIONS = <SOLUTIONS>[];
      json['SOLUTIONS'].forEach((v) {
        sOLUTIONS!.add(new SOLUTIONS.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sOLUTIONS != null) {
      data['SOLUTIONS'] = this.sOLUTIONS!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SOLUTIONS {
  String? sOLFOLID;
  String? sOLID;
  String? tITLE;
  String? sOLUTIONTYPEDESC;
  String? sOLUTIONSTATUSDESC;
  String? dATE;
  String? dESCRIPTION;
  String? lIKES;
  String? dISLIKES;

  SOLUTIONS(
      {this.sOLFOLID,
        this.sOLID,
        this.tITLE,
        this.sOLUTIONTYPEDESC,
        this.sOLUTIONSTATUSDESC,
        this.dATE,
        this.dESCRIPTION,
        this.lIKES,
        this.dISLIKES});

  SOLUTIONS.fromJson(Map<String, dynamic> json) {
    sOLFOLID = json['SOLFOLID'];
    sOLID = json['SOLID'];
    tITLE = json['TITLE'];
    sOLUTIONTYPEDESC = json['SOLUTIONTYPEDESC'];
    sOLUTIONSTATUSDESC = json['SOLUTIONSTATUSDESC'];
    dATE = json['DATE'];
    dESCRIPTION = json['DESCRIPTION'];
    lIKES = json['LIKES'];
    dISLIKES = json['DISLIKES'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SOLFOLID'] = this.sOLFOLID;
    data['SOLID'] = this.sOLID;
    data['TITLE'] = this.tITLE;
    data['SOLUTIONTYPEDESC'] = this.sOLUTIONTYPEDESC;
    data['SOLUTIONSTATUSDESC'] = this.sOLUTIONSTATUSDESC;
    data['DATE'] = this.dATE;
    data['DESCRIPTION'] = this.dESCRIPTION;
    data['LIKES'] = this.lIKES;
    data['DISLIKES'] = this.dISLIKES;
    return data;
  }
}
*/
class ProductsDetailsModel {
  SOLDETAILS? sOLDETAILS;

  ProductsDetailsModel({this.sOLDETAILS});

  ProductsDetailsModel.fromJson(Map<String, dynamic> json) {
    sOLDETAILS = json['SOLDETAILS'] != null
        ? SOLDETAILS.fromJson(json['SOLDETAILS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sOLDETAILS != null) {
      data['SOLDETAILS'] = sOLDETAILS!.toJson();
    }
    return data;
  }
}

class SOLDETAILS {
  List<SOLUTIONS>? sOLUTIONS;

  SOLDETAILS({this.sOLUTIONS});

  SOLDETAILS.fromJson(Map<String, dynamic> json) {
    if (json['SOLUTIONS'] != null) {
      sOLUTIONS = <SOLUTIONS>[];
      json['SOLUTIONS'].forEach((v) {
        sOLUTIONS!.add(SOLUTIONS.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sOLUTIONS != null) {
      data['SOLUTIONS'] = sOLUTIONS!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SOLUTIONS {
  String? sOLFOLID;
  String? sOLID;
  String? tITLE;
  String? sOLUTIONTYPEDESC;
  String? sOLUTIONSTATUSDESC;
  String? dATE;
  String? dESCRIPTION;
  String? lIKES;
  String? dISLIKES;
  ATTCHMNTINFO? aTTCHMNTINFO;

  SOLUTIONS(
      {this.sOLFOLID,
        this.sOLID,
        this.tITLE,
        this.sOLUTIONTYPEDESC,
        this.sOLUTIONSTATUSDESC,
        this.dATE,
        this.dESCRIPTION,
        this.lIKES,
        this.dISLIKES,
        this.aTTCHMNTINFO});

  SOLUTIONS.fromJson(Map<String, dynamic> json) {
    sOLFOLID = json['SOLFOLID'];
    sOLID = json['SOLID'];
    tITLE = json['TITLE'];
    sOLUTIONTYPEDESC = json['SOLUTIONTYPEDESC'];
    sOLUTIONSTATUSDESC = json['SOLUTIONSTATUSDESC'];
    dATE = json['DATE'];
    dESCRIPTION = json['DESCRIPTION'];
    lIKES = json['LIKES'];
    dISLIKES = json['DISLIKES'];
    aTTCHMNTINFO = json['ATTCHMNTINFO'] != null
        ? ATTCHMNTINFO.fromJson(json['ATTCHMNTINFO'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['SOLFOLID'] = sOLFOLID;
    data['SOLID'] = sOLID;
    data['TITLE'] = tITLE;
    data['SOLUTIONTYPEDESC'] = sOLUTIONTYPEDESC;
    data['SOLUTIONSTATUSDESC'] = sOLUTIONSTATUSDESC;
    data['DATE'] = dATE;
    data['DESCRIPTION'] = dESCRIPTION;
    data['LIKES'] = lIKES;
    data['DISLIKES'] = dISLIKES;
    if (aTTCHMNTINFO != null) {
      data['ATTCHMNTINFO'] = aTTCHMNTINFO!.toJson();
    }
    return data;
  }
}

class ATTCHMNTINFO {
  ATTACHMENTS? aTTACHMENTS;

  ATTCHMNTINFO({this.aTTACHMENTS});

  ATTCHMNTINFO.fromJson(Map<String, dynamic> json) {
    aTTACHMENTS = json['ATTACHMENTS'] != null
        ? ATTACHMENTS.fromJson(json['ATTACHMENTS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (aTTACHMENTS != null) {
      data['ATTACHMENTS'] = aTTACHMENTS!.toJson();
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
        iNFO!.add(INFO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (iNFO != null) {
      data['INFO'] = iNFO!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = {};
    data['ATCHFILEID'] = aTCHFILEID;
    data['ORIGINALFILENAME'] = oRIGINALFILENAME;
    data['NEWFILENAME'] = nEWFILENAME;
    data['EXTENSION'] = eXTENSION;
    data['FOLDERNAME'] = fOLDERNAME;
    data['ISDELETE'] = iSDELETE;
    data['DOWNLOADURL'] = dOWNLOADURL;
    return data;
  }
}
