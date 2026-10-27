class ASNScanningReaponse {
  TRANSACTIONDETAILS? tRANSACTIONDETAILS;

  ASNScanningReaponse({this.tRANSACTIONDETAILS});

  ASNScanningReaponse.fromJson(Map<String, dynamic> json) {
    tRANSACTIONDETAILS = json['TRANSACTIONDETAILS'] != null
        ? new TRANSACTIONDETAILS.fromJson(json['TRANSACTIONDETAILS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tRANSACTIONDETAILS != null) {
      data['TRANSACTIONDETAILS'] = this.tRANSACTIONDETAILS!.toJson();
    }
    return data;
  }
}

class TRANSACTIONDETAILS {
  List<TRANSACTIONSASN>? tRANSACTIONS;

  TRANSACTIONDETAILS({this.tRANSACTIONS});

  TRANSACTIONDETAILS.fromJson(Map<String, dynamic> json) {
    if (json['TRANSACTIONS'] != null) {
      tRANSACTIONS = <TRANSACTIONSASN>[];
      json['TRANSACTIONS'].forEach((v) {
        tRANSACTIONS!.add(new TRANSACTIONSASN.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tRANSACTIONS != null) {
      data['TRANSACTIONS'] = this.tRANSACTIONS!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TRANSACTIONSASN {
  String? mID;
  String? dOCID;
  String? tID;
  String? iTEMID;

  String? documentType;
  String? documentNo;
  String? documentDate;
  String? suppler;

  String? productCode;
  String? productDescription;
  String? uOM;
  String? quantity;
  String? scanned;
  String? scanStatus;

  TRANSACTIONSASN({
    this.mID,
    this.dOCID,
    this.tID,
    this.iTEMID,
    this.documentType,
    this.documentNo,
    this.documentDate,
    this.suppler,
    this.productCode,
    this.productDescription,
    this.uOM,
    this.quantity,
    this.scanned,
    this.scanStatus,
  });

  TRANSACTIONSASN.fromJson(Map<String, dynamic> json) {
    mID = json['MID']?.toString();
    dOCID = json['DOCID']?.toString();
    tID = json['TID']?.toString();
    iTEMID = json['ITEMID']?.toString();

    documentType = json['Document Type']?.toString();
    documentNo = json['Document No.']?.toString();
    documentDate = json['Document Date']?.toString();
    suppler = json['Suppler']?.toString();

    productCode = json['Product Code']?.toString();
    productDescription = json['Product Description']?.toString();
    uOM = json['UOM']?.toString();
    quantity = json['Quantity']?.toString();
    scanned = json['Scanned']?.toString();
    scanStatus = json['Scan Status']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'MID': mID,
      'DOCID': dOCID,
      'TID': tID,
      'ITEMID': iTEMID,
      'Document Type': documentType,
      'Document No.': documentNo,
      'Document Date': documentDate,
      'Suppler': suppler,
      'Product Code': productCode,
      'Product Description': productDescription,
      'UOM': uOM,
      'Quantity': quantity,
      'Scanned': scanned,
      'Scan Status': scanStatus,
    };
  }
}
