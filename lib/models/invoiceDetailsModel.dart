class InvoiceDetailsModel {
  TRANSACTIONDETAILS? tRANSACTIONDETAILS;

  InvoiceDetailsModel({this.tRANSACTIONDETAILS});

  InvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
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
  List<TRANSACTIONS>? tRANSACTIONS;
  String? status;
  String? message;

  TRANSACTIONDETAILS({this.tRANSACTIONS, this.status, this.message});

  TRANSACTIONDETAILS.fromJson(Map<String, dynamic> json) {
    if (json['Status'] != null && json['Status'] == "false") {
      // Handle the case where no records are found
      status = json['Status'];
      message = json['Message'];
    } else {
      if (json['TRANSACTIONS'] != null) {
        tRANSACTIONS = <TRANSACTIONS>[];
        json['TRANSACTIONS'].forEach((v) {
          tRANSACTIONS!.add(new TRANSACTIONS.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tRANSACTIONS != null) {
      data['TRANSACTIONS'] = this.tRANSACTIONS!.map((v) => v.toJson()).toList();
    }
    data['Status'] = this.status;
    data['Message'] = this.message;
    return data;
  }
}

class TRANSACTIONS {
  String? tID;
  String? mID;
  String? dOCID;
  String? iTEMID;
  String? serialNo;
  String? productCode;
  String? productDescription;
  String? uOM;
  String? quantity;
  String? dispatched;
  String? balance;
  String? scanned;
  String? scanStatus;

  TRANSACTIONS(
      {this.tID,
      this.mID,
      this.dOCID,
      this.iTEMID,
      this.serialNo,
      this.productCode,
      this.productDescription,
      this.uOM,
      this.quantity,
      this.dispatched,
      this.balance,
      this.scanned,
      this.scanStatus});

  TRANSACTIONS.fromJson(Map<String, dynamic> json) {
    tID = json['TID'];
    mID = json['MID'];
    dOCID = json['DOCID'];
    iTEMID = json['ITEMID'];
    serialNo = json['Serial No.'];
    productCode = json['Product Code'];
    productDescription = json['Product Description'];
    uOM = json['UOM'];
    quantity = json['Quantity'];
    dispatched = json['Dispatched'];
    balance = json['Balance'];
    scanned = json['Scanned'];
    scanStatus = json['Scan Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TID'] = this.tID;
    data['MID'] = this.mID;
    data['DOCID'] = this.dOCID;
    data['ITEMID'] = this.iTEMID;
    data['Serial No.'] = this.serialNo;
    data['Product Code'] = this.productCode;
    data['Product Description'] = this.productDescription;
    data['UOM'] = this.uOM;
    data['Quantity'] = this.quantity;
    data['Dispatched'] = this.dispatched;
    data['Balance'] = this.balance;
    data['Scanned'] = this.scanned;
    data['Scan Status'] = this.scanStatus;
    return data;
  }
}
