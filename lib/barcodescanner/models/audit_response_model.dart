class AuditResponseModel {
  final TransactionDetails? transactionDetails;

  AuditResponseModel({this.transactionDetails});

  factory AuditResponseModel.fromJson(Map<String, dynamic> json) {
    return AuditResponseModel(
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
  final List<Transaction>? transactions;
  final List<LotDetail>? lotDetails;
  final dynamic fileDetail;

  TransactionDetails({this.transactions, this.lotDetails, this.fileDetail});

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactions: json['TRANSACTIONS'] != null
          ? List<Transaction>.from(
          json['TRANSACTIONS'].map((x) => Transaction.fromJson(x)))
          : null,
      lotDetails: json['LOTDETAILS'] != null
          ? List<LotDetail>.from(
          json['LOTDETAILS'].map((x) => LotDetail.fromJson(x)))
          : null,
      fileDetail: json['FILEDETAIL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TRANSACTIONS': transactions?.map((x) => x.toJson()).toList(),
      'LOTDETAILS': lotDetails?.map((x) => x.toJson()).toList(),
      'FILEDETAIL': fileDetail,
    };
  }
}

class Transaction {
  final String? invcType;
  final String? invcNumb;
  final String? invcDate;
  final String? nou;
  final String? dimn;
  final String? qty;
  final String? barcode;
  final String? lotDesc;
  final String? issuedQty;
  final String? balanceQty;
  final String? itemCode;
  final String? itemDesc;
  final String? jobNo;
  final String? locDesc;
  final String? totalStock;
  final String? itemGroup;
  final String? verifiedStock;
  final String? rackDescription;
  final String? itemType;

  Transaction({
    this.invcType,
    this.invcNumb,
    this.invcDate,
    this.nou,
    this.dimn,
    this.qty,
    this.barcode,
    this.lotDesc,
    this.issuedQty,
    this.balanceQty,
    this.itemCode,
    this.itemDesc,
    this.jobNo,
    this.locDesc,
    this.totalStock,
    this.itemGroup,
    this.verifiedStock,
    this.rackDescription,
    this.itemType,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      invcType: json['INVCTYPE'],
      invcNumb: json['INVCNUMB'],
      invcDate: json['INVCDATE'],
      nou: json['NOU'],
      dimn: json['DIMN'],
      qty: json['QTY'],
      barcode: json['BARCODE'],
      lotDesc: json['LOTDESC'],
      issuedQty: json['ISSUEDQTY'],
      balanceQty: json['BALANCEQTY'],
      itemCode: json['itemcode'],
      itemDesc: json['itemdesc'],
      jobNo: json['JOBNO'],
      locDesc: json['LOCDESC'],
      totalStock: json['TOTALSTOCK'],
      itemGroup: json['ItemGroup'],
      verifiedStock: json['verifiedstock'],
      rackDescription: json['RACKDESCRIPTION'],
      itemType: json['ITEMTYPE'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'INVCTYPE': invcType,
      'INVCNUMB': invcNumb,
      'INVCDATE': invcDate,
      'NOU': nou,
      'DIMN': dimn,
      'QTY': qty,
      'BARCODE': barcode,
      'LOTDESC': lotDesc,
      'ISSUEDQTY': issuedQty,
      'BALANCEQTY': balanceQty,
      'itemcode': itemCode,
      'itemdesc': itemDesc,
      'JOBNO': jobNo,
      'LOCDESC': locDesc,
      'TOTALSTOCK': totalStock,
      'ItemGroup': itemGroup,
      'verifiedstock': verifiedStock,
      'RACKDESCRIPTION': rackDescription,
      'ITEMTYPE': itemType,
    };
  }
}

class LotDetail {
  final String? grnNo;
  final String? grnDate;
  final String? soNo;
  final String? poNo;
  final String? supplier;
  final String? customer;

  LotDetail({this.grnNo, this.grnDate, this.soNo, this.poNo, this.supplier, this.customer});

  factory LotDetail.fromJson(Map<String, dynamic> json) {
    return LotDetail(
      grnNo: json['GRNNO'],
      grnDate: json['GRNDATE'],
      soNo: json['SONO'],
      poNo: json['PONO'],
      supplier: json['SUPPLIER'],
      customer: json['CUSTOMER'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GRNNO': grnNo,
      'GRNDATE': grnDate,
      'SONO': soNo,
      'PONO': poNo,
      'SUPPLIER': supplier,
      'CUSTOMER': customer,
    };
  }
}
