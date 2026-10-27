class SyncPriceMasterModel {
  DATA? dATA;

  SyncPriceMasterModel({this.dATA});

  SyncPriceMasterModel.fromJson(Map<String, dynamic> json) {
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
  List<LIST>? lIST;

  DATA({this.status, this.message, this.sYNCDATETIME, this.lIST});

  DATA.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
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
    data['Status'] = this.status;
    data['Message'] = this.message;
    data['SYNCDATETIME'] = this.sYNCDATETIME;
    if (this.lIST != null) {
      data['LIST'] = this.lIST!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LIST {
  String? pID;
  String? iTEMID;
  String? iTEMCODE;
  String? iTEMDESC;
  String? iTEMRATE;
  String? effectiveDate;

  LIST(
      {this.pID,
        this.iTEMID,
        this.iTEMCODE,
        this.iTEMDESC,
        this.iTEMRATE,
        this.effectiveDate});

  LIST.fromJson(Map<String, dynamic> json) {
    pID = json['PID'];
    iTEMID = json['ITEMID'];
    iTEMCODE = json['ITEMCODE'];
    iTEMDESC = json['ITEMDESC'];
    iTEMRATE = json['ITEMRATE'];
    effectiveDate = json['EffectiveDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PID'] = this.pID;
    data['ITEMID'] = this.iTEMID;
    data['ITEMCODE'] = this.iTEMCODE;
    data['ITEMDESC'] = this.iTEMDESC;
    data['ITEMRATE'] = this.iTEMRATE;
    data['EffectiveDate'] = this.effectiveDate;
    return data;
  }
}
