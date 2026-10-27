class GetItemBalanceModel {
  DATA? dATA;

  GetItemBalanceModel({this.dATA});

  GetItemBalanceModel.fromJson(Map<String, dynamic> json) {
    dATA = json['DATA'] != null ? DATA.fromJson(json['DATA']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dATA != null) {
      data['DATA'] = dATA!.toJson();
    }
    return data;
  }
}

class DATA {
  String? status;
  String? message;
  String? sYNCDATETIME;
  List<LIST>? lIST;

  DATA({this.status, this.message, this.sYNCDATETIME, this.lIST});

  DATA.fromJson(Map<String, dynamic> json) {
    status = json['Status'] as String?;
    message = json['Message'] as String?;
    sYNCDATETIME = json['SYNCDATETIME'] as String?;
    if (json['LIST'] != null) {
      lIST = <LIST>[];
      json['LIST'].forEach((v) {
        lIST!.add(LIST.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    data['Message'] = message;
    data['SYNCDATETIME'] = sYNCDATETIME;
    if (lIST != null) {
      data['LIST'] = lIST!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LIST {
  String? iTEMID;
  String? lOCID;
  String? lOCDESC;
  String? lOCCODE;
  String? iTEMCODE;
  String? cLOSEBAL;
  String? oRGSTRUCID;

  LIST(
      {this.iTEMID,
        this.lOCID,
        this.lOCDESC,
        this.lOCCODE,
        this.iTEMCODE,
        this.cLOSEBAL,
        this.oRGSTRUCID});

  LIST.fromJson(Map<String, dynamic> json) {
    iTEMID = json['ITEMID'] as String?;
    lOCID = json['LOCID'] as String?;
    lOCDESC = json['LOCDESC'] as String?;
    lOCCODE = json['LOCCODE'] as String?;
    iTEMCODE = json['ITEMCODE'] as String?;
    cLOSEBAL = json['CLOSEBAL'] as String?;
    oRGSTRUCID = json['ORGSTRUCID'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ITEMID'] = iTEMID;
    data['LOCID'] = lOCID;
    data['LOCDESC'] = lOCDESC;
    data['LOCCODE'] = lOCCODE;
    data['ITEMCODE'] = iTEMCODE;
    data['CLOSEBAL'] = cLOSEBAL;
    data['ORGSTRUCID'] = oRGSTRUCID;
    return data;
  }
}
