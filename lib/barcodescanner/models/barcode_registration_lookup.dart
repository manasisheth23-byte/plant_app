class BarcodeRegistrationLookup {
  final String? invcType;
  final String? invcNumb;
  final String? itemCode;
  final String? itemDesc;
  final String? qty;
  final String? lotId;
  final String? tid;
  final String? mid;
  final String? docid;
  final String? barcode;
  List<PostRegisterBarcode> postBarcodes;


  BarcodeRegistrationLookup({
    this.invcType,
    this.invcNumb,
    this.itemCode,
    this.itemDesc,
    this.qty,
    this.lotId,
    this.tid,
    this.mid,
    this.docid,
    this.barcode,
    List<PostRegisterBarcode>? postBarcodes,

  }) : postBarcodes = postBarcodes ?? [];
  factory BarcodeRegistrationLookup.fromMap(Map<String, dynamic> map) {
    return BarcodeRegistrationLookup(
      invcType: map['INVCTYPE'] as String?,
      invcNumb: map['INVCNUMB'] as String?,
      itemCode: map['ITEMCODE'] as String?,
      itemDesc: map['ITEMDESC'] as String?,
      qty: map['QTY'] as String?,
      lotId: map['LOTID'] as String?,
      tid: map['TID'] as String?,
      mid: map['MID'] as String?,
      docid: map['DOCID'] as String?,
      barcode: map['BARCODE'] as String?,

      postBarcodes: [],
    );
  }
}

class PostRegisterBarcode {
  final String lotId;
  final String barcodeVerify;
  final String tid;
  final String mid;
  final String docid;
  final String qty;
  final String barcode;


  PostRegisterBarcode({
    required this.lotId,
    required this.barcodeVerify,
    required this.tid,
    required this.mid,
    required this.docid,
    required this.qty,
    required this.barcode,
  });

  // Convert single object to JSON
  Map<String, dynamic> toJson() {
    return {
      'LOTID': lotId,
      'barcode_verify': barcodeVerify,
      'TID': tid,
      'MID': mid,
      'DOCID': docid,
      'QTY': qty,
      'BARCODE': barcode,

    };
  }

  // Convert a list of objects to JSON list
  static List<Map<String, dynamic>> toJsonList(List<PostRegisterBarcode> list) {
    return list.map((item) => item.toJson()).toList();
  }
}
