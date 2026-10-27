class SyncILedgerModel {
  DATA? dATA;

  SyncILedgerModel({this.dATA});

  SyncILedgerModel.fromJson(Map<String, dynamic> json) {
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
  String? iTEMID;
  String? iTEMCODE;
  String? iTEMDESC;
  String? bASEUOMID;
  String? bASEUOMCODE;
  String? uOMCODE;
  String? subGroup;
  String? mainGroup;
  String? plant;
  String? itemType;
  String? currency;
  String? inStockQty;
  String? unitprice;

  LIST(
      {this.iTEMID,
        this.iTEMCODE,
        this.iTEMDESC,
        this.bASEUOMID,
        this.bASEUOMCODE,
        this.uOMCODE,
        this.subGroup,
        this.mainGroup,
        this.plant,
        this.itemType,
        this.currency,
        this.inStockQty,
        this.unitprice});

  LIST.fromJson(Map<String, dynamic> json) {
    iTEMID = json['ITEMID'];
    iTEMCODE = json['ITEMCODE'];
    iTEMDESC = json['ITEMDESC'];
    bASEUOMID = json['BASEUOMID'];
    bASEUOMCODE = json['BASEUOMCODE'];
    uOMCODE = json['UOMCODE'];
    subGroup = json['SubGroup'];
    mainGroup = json['MainGroup'];
    plant = json['Plant'];
    itemType = json['ItemType'];
    currency = json['Currency'];
    inStockQty = json['InStockQty'];
    unitprice = json['Unitprice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ITEMID'] = this.iTEMID;
    data['ITEMCODE'] = this.iTEMCODE;
    data['ITEMDESC'] = this.iTEMDESC;
    data['BASEUOMID'] = this.bASEUOMID;
    data['BASEUOMCODE'] = this.bASEUOMCODE;
    data['UOMCODE'] = this.uOMCODE;
    data['SubGroup'] = this.subGroup;
    data['MainGroup'] = this.mainGroup;
    data['Plant'] = this.plant;
    data['ItemType'] = this.itemType;
    data['Currency'] = this.currency;
    data['InStockQty'] = this.inStockQty;
    data['Unitprice'] = this.unitprice;
    return data;
  }
}
