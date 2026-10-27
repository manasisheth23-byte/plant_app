class TransactionDetailsResponse {
  final TransactionDetails? transactionDetails;

  TransactionDetailsResponse({this.transactionDetails});

  factory TransactionDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionDetailsResponse(
      transactionDetails: json['TRANSACTIONDETAILS'] != null
          ? TransactionDetails.fromJson(json['TRANSACTIONDETAILS'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TRANSACTIONDETAILS': transactionDetails?.toJson(),
    };
  }
}

class TransactionDetails {
  final List<Transactionl>? transactions;
  final List<LotDetail>? lotDetails;

  TransactionDetails({this.transactions, this.lotDetails});

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactions: (json['TRANSACTIONS'] as List?)
          ?.map((e) => Transactionl.fromJson(e))
          .toList(),
      lotDetails: (json['LOTDETAILS'] as List?)
          ?.map((e) => LotDetail.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TRANSACTIONS': transactions?.map((e) => e.toJson()).toList(),
      'LOTDETAILS': lotDetails?.map((e) => e.toJson()).toList(),
    };
  }
}

 class Transactionl {
  final String? orgStrucId;
  final String? userId;
  final String? transactions;
  final String? mid;
  final String? docId;
  final String? tid;
  final String? invcNumb;
  final String? invcDate;
  final String? invcType;
  final String? itemId;
  final String? itemCode;
  final String? itemDesc;
  final String? uomId;
  final String? uom;
  final String? locId;
  final String? location;
  final String? projId;
  final String? projNo;
  final String? nou;
  final String? qty;
  final String? lineNumb;
  final String? barcodeQty;
  final String? dimension;

  Transactionl({
    this.orgStrucId,
    this.userId,
    this.transactions,
    this.mid,
    this.docId,
    this.tid,
    this.invcNumb,
    this.invcDate,
    this.invcType,
    this.itemId,
    this.itemCode,
    this.itemDesc,
    this.uomId,
    this.uom,
    this.locId,
    this.location,
    this.projId,
    this.projNo,
    this.nou,
    this.qty,
    this.lineNumb,
    this.barcodeQty,
    this.dimension,
  });

  factory Transactionl.fromJson(Map<String, dynamic> json) {
    return Transactionl(
      orgStrucId: json['ORGSTRUCID'],
      userId: json['USERID'],
      transactions: json['TRANSACTIONS'],
      mid: json['MID'],
      docId: json['DOCID'],
      tid: json['TID'],
      invcNumb: json['INVCNUMB'],
      invcDate: json['INVCDATE'],
      invcType: json['INVCTYPE'],
      itemId: json['ITEMID'],
      itemCode: json['ITEMCODE'],
      itemDesc: json['ITEMDESC'],
      uomId: json['UOMID'],
      uom: json['UOM'],
      locId: json['LOCID'],
      location: json['LOCATION'],
      projId: json['PROJID'],
      projNo: json['PROJNO'],
      nou: json['NOU'],
      qty: json['QTY'],
      lineNumb: json['LINENUMB'],
      barcodeQty: json['BARCODEQTY'],
      dimension: json['DIMENSION'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'ORGSTRUCID': orgStrucId,
      'USERID': userId,
      'TRANSACTIONS': transactions,
      'MID': mid,
      'DOCID': docId,
      'TID': tid,
      'INVCNUMB': invcNumb,
      'INVCDATE': invcDate,
      'INVCTYPE': invcType,
      'ITEMID': itemId,
      'ITEMCODE': itemCode,
      'ITEMDESC': itemDesc,
      'UOMID': uomId,
      'UOM': uom,
      'LOCID': locId,
      'LOCATION': location,
      'PROJID': projId,
      'PROJNO': projNo,
      'NOU': nou,
      'QTY': qty,
      'LINENUMB': lineNumb,
      'BARCODEQTY': barcodeQty,
      'DIMENSION': dimension,
    };
  }
  /// Convert Map<String, dynamic> to Transactionl object
  factory Transactionl.fromMap(Map<String, dynamic> map) {
    return Transactionl(
      orgStrucId: map['ORGSTRUCID']?.toString(),
      userId: map['USERID']?.toString(),
      transactions: map['TRANSACTIONS']?.toString(),
      mid: map['MID']?.toString(),
      docId: map['DOCID']?.toString(),
      tid: map['TID']?.toString(),
      invcNumb: map['INVCNUMB']?.toString(),
      invcDate: map['INVCDATE']?.toString(),
      invcType: map['INVCTYPE']?.toString(),
      itemId: map['ITEMID']?.toString(),
      itemCode: map['ITEMCODE']?.toString(),
      itemDesc: map['ITEMDESC']?.toString(),
      uomId: map['UOMID']?.toString(),
      uom: map['UOM']?.toString(),
      locId: map['LOCID']?.toString(),
      location: map['LOCATION']?.toString(),
      projId: map['PROJID']?.toString(),
      projNo: map['PROJNO']?.toString(),
      nou: map['NOU']?.toString(),
      qty: map['QTY']?.toString(),
      lineNumb: map['LINENUMB']?.toString(),
      barcodeQty: map['BARCODEQTY']?.toString(),
      dimension: map['DIMENSION']?.toString(),
    );
  }

  // Convert list of Transaction to list of maps
  static List<Map<String, dynamic>> listToMap(List<Transactionl>? transactions) {
    if (transactions == null) return [];
    return transactions.map((txn) => txn.toMap()).toList();
  }
  Map<String, dynamic> toJson() {
    return {
      'ORGSTRUCID': orgStrucId,
      'USERID': userId,
      'TRANSACTIONS': transactions,
      'MID': mid,
      'DOCID': docId,
      'TID': tid,
      'INVCNUMB': invcNumb,
      'INVCDATE': invcDate,
      'INVCTYPE': invcType,
      'ITEMID': itemId,
      'ITEMCODE': itemCode,
      'ITEMDESC': itemDesc,
      'UOMID': uomId,
      'UOM': uom,
      'LOCID': locId,
      'LOCATION': location,
      'PROJID': projId,
      'PROJNO': projNo,
      'NOU': nou,
      'QTY': qty,
      'LINENUMB': lineNumb,
      'BARCODEQTY': barcodeQty,
    };
  }
}

class LotDetail {
  final String? lotId;
  final String? mid;
  final String? docId;
  final String? invcType;
  final String? invcNumb;
  final String? invcDate;
  final String? tid;
  final String? nou;
  final String? dimn;
  final String? qty;
  final String? barcode;
  final String? lotDesc;
  final String? varifiedFlag;
  final String? issuedQty;
  final String? balanceQty;
  final String? orgStructId;
  final String? itemCode;
  final String? itemDesc;
  final String? jobId;
  final String? jobNo;
  final String? locId;
  final String? locDesc;
  final String? barcodeQty;
  LotDetail({
    this.lotId,
    this.mid,
    this.docId,
    this.invcType,
    this.invcNumb,
    this.invcDate,
    this.tid,
    this.nou,
    this.dimn,
    this.qty,
    this.barcode,
    this.lotDesc,
    this.varifiedFlag,
    this.issuedQty,
    this.balanceQty,
    this.orgStructId,
    this.itemCode,
    this.itemDesc,
    this.jobId,
    this.jobNo,
    this.locId,
    this.locDesc,
    this.barcodeQty,
  });

  factory LotDetail.fromJson(Map<String, dynamic> json) {
    return LotDetail(
      lotId: json['LOTID'],
      mid: json['MID'],
      docId: json['DOCID'],
      invcType: json['INVCTYPE'],
      invcNumb: json['INVCNUMB'],
      invcDate: json['INVCDATE'],
      tid: json['TID'],
      nou: json['NOU'],
      dimn: json['DIMN'],
      qty: json['QTY'],
      barcode: json['BARCODE'],
      lotDesc: json['LOTDESC'],
      varifiedFlag: json['VARIFIEDFLAG'],
      issuedQty: json['ISSUEDQTY'],
      balanceQty: json['BALANCEQTY'],
      orgStructId: json['ORGSTRUCTID'],
      itemCode: json['itemcode'],
      itemDesc: json['itemdesc'],
      jobId: json['JOBID'],
      jobNo: json['JOBNO'],
      locId: json['LOCID'],
      locDesc: json['LOCDESC'],
      barcodeQty: json['BARCODEQTY'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LOTID': lotId,
      'MID': mid,
      'DOCID': docId,
      'INVCTYPE': invcType,
      'INVCNUMB': invcNumb,
      'INVCDATE': invcDate,
      'TID': tid,
      'NOU': nou,
      'DIMN': dimn,
      'QTY': qty,
      'BARCODE': barcode,
      'LOTDESC': lotDesc,
      'VARIFIEDFLAG': varifiedFlag,
      'ISSUEDQTY': issuedQty,
      'BALANCEQTY': balanceQty,
      'ORGSTRUCTID': orgStructId,
      'itemcode': itemCode,
      'itemdesc': itemDesc,
      'JOBID': jobId,
      'JOBNO': jobNo,
      'LOCID': locId,
      'LOCDESC': locDesc,
      'BARCODEQTY' : barcodeQty,
    };
  }
  Map<String, dynamic> toMap() {

    return {
      'LOTID': lotId,
      'MID': mid,
      'DOCID': docId,
      'INVCTYPE': invcType,
      'INVCNUMB': invcNumb,
      'INVCDATE': invcDate,
      'TID': tid,
      'NOU': nou,
      'DIMN': dimn,
      'QTY': qty,
      'LOTDESC': lotDesc,
      'VARIFIEDFLAG': varifiedFlag,
      'ISSUEDQTY': issuedQty,
      'BARCODEQTY': barcodeQty,
      'ORGSTRUCTID': orgStructId,
      'BARCODE': barcode,
      'BARCODE_VERIFY': '0',
      'itemcode': itemCode,
      'itemdesc': itemDesc,
      'CHK_VERIFY_BARCODE': '0',
    };
  }
  factory LotDetail.fromMap(Map<String, dynamic> map) {
    return LotDetail(
      lotId: map['LOTID']?.toString(),
      mid: map['MID']?.toString(),
      docId: map['DOCID']?.toString(),
      invcType: map['INVCTYPE']?.toString(),
      invcNumb: map['INVCNUMB']?.toString(),
      invcDate: map['INVCDATE']?.toString(),
      tid: map['TID']?.toString(),
      nou: map['NOU']?.toString(),
      dimn: map['DIMN']?.toString(),
      qty: map['QTY']?.toString(),
      barcode: map['BARCODE']?.toString(),
      lotDesc: map['LOTDESC']?.toString(),
      varifiedFlag: map['VARIFIEDFLAG']?.toString(),
      issuedQty: map['ISSUEDQTY']?.toString(),
      balanceQty: map['BALANCEQTY']?.toString(),
      orgStructId: map['ORGSTRUCTID']?.toString(),
      itemCode: map['itemcode']?.toString(),
      itemDesc: map['itemdesc']?.toString(),
      jobId: map['JOBID']?.toString(),
      jobNo: map['JOBNO']?.toString(),
      locId: map['LOCID']?.toString(),
      locDesc: map['LOCDESC']?.toString(),
      barcodeQty: map['BARCODEQTY']?.toString(),
    );
  }

  static List<Map<String, dynamic>> listToMap(List<LotDetail>? lotDetails) {
    if (lotDetails == null) return [];
    return lotDetails.map((lot) => lot.toMap()).toList();
  }
}
