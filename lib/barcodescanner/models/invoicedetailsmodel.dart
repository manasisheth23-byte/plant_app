class InvoiceDetailsModelAns {
  TransactionDetails? transactionDetails;

  InvoiceDetailsModelAns({this.transactionDetails});

  InvoiceDetailsModelAns.fromJson(Map<String, dynamic> json) {
    transactionDetails = json["TRANSACTIONDETAILS"] != null
        ? TransactionDetails.fromJson(json["TRANSACTIONDETAILS"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (transactionDetails != null) {
      data["TRANSACTIONDETAILS"] = transactionDetails!.toJson();
    }

    return data;
  }
}

class TransactionDetails {
  String? status;
  String? message;
  Mast? mast;
  List<TransactionItem>? transactions;

  TransactionDetails({
    this.status,
    this.message,
    this.mast,
    this.transactions,
  });

  TransactionDetails.fromJson(Map<String, dynamic> json) {
    status = json["Status"];
    message = json["Message"];

    mast = json["MAST"] != null
        ? Mast.fromJson(json["MAST"])
        : null;

    if (json["TRANSACTIONS"] != null) {
      transactions = (json["TRANSACTIONS"] as List)
          .map((e) => TransactionItem.fromJson(e))
          .toList();
    } else {
      transactions = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "Status": status,
      "Message": message,
      "MAST": mast?.toJson(),
      "TRANSACTIONS":
      transactions?.map((e) => e.toJson()).toList(),
    };
  }
}

class Mast {
  String? documentType;
  String? documentNo;
  String? documentDate;
  String? supplier;
  String? billNo;
  String? billDate;

  String? mid;
  String? docId;
  String? tid;
  String? gateEntry;

  Mast({
    this.documentType,
    this.documentNo,
    this.documentDate,
    this.supplier,
    this.billNo,
    this.billDate,
    this.mid,
    this.docId,
    this.tid,
    this.gateEntry,
  });

  Mast.fromJson(Map<String, dynamic> json) {
    documentType = json["Document Type"];
    documentNo = json["Document No."];
    documentDate = json["Document Date"];
    supplier = json["Suppler"];
    billNo = json["BILLNO"];
    billDate = json["BILLDATE"];
    mid = json["MID"];
    docId = json["DOCID"];
    tid = json["TID"];
    gateEntry = json["GATEENTRY"];
  }

  Map<String, dynamic> toJson() {
    return {
      "Document Type": documentType,
      "Document No.": documentNo,
      "Document Date": documentDate,
      "Suppler": supplier,
      "BILLNO": billNo,
      "BILLDATE": billDate,
      "MID": mid,
      "DOCID": docId,
      "TID": tid,
      "GATEENTRY": gateEntry,
    };
  }
}

class TransactionItem {
  String? productCode;
  String? productDescription;
  String? uom;
  String? quantity;
  String? scanned;
  String? mid;
  String? docId;
  String? tid;
  String? itemId;
  String? scanStatus;

  TransactionItem({
    this.productCode,
    this.productDescription,
    this.uom,
    this.quantity,
    this.scanned,
    this.mid,
    this.docId,
    this.tid,
    this.itemId,
    this.scanStatus,
  });

  TransactionItem.fromJson(Map<String, dynamic> json) {
    productCode = json["Product Code"];
    productDescription = json["Product Description"];
    uom = json["UOM"];
    quantity = json["Quantity"];
    scanned = json["Scanned"];
    mid = json["MID"];
    docId = json["DOCID"];
    tid = json["TID"];
    itemId = json["ITEMID"];
    scanStatus = json["Scan Status"];
  }

  Map<String, dynamic> toJson() {
    return {
      "Product Code": productCode,
      "Product Description": productDescription,
      "UOM": uom,
      "Quantity": quantity,
      "Scanned": scanned,
      "MID": mid,
      "DOCID": docId,
      "TID": tid,
      "ITEMID": itemId,
      "Scan Status": scanStatus,
    };
  }
}