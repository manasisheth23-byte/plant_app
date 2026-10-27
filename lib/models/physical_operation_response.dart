class PhysicalBarcodeOperation {
  final String mid;
  final String docId;
  final String oprnId;
  final String oprnCode;
  final String oprnDesc;
  final String seq;
  final String isFinal;
  final String currentOpQty;
  final String QTY;
  final String PRDTQTY;
  final String WOQTY;

  PhysicalBarcodeOperation({
    required this.mid,
    required this.docId,
    required this.oprnId,
    required this.oprnCode,
    required this.oprnDesc,
    required this.seq,
    required this.isFinal,
    required this.currentOpQty,
    required this.QTY,
    required this.PRDTQTY,
    required this.WOQTY,
  });

  factory PhysicalBarcodeOperation.fromJson(Map<String, dynamic> json) {
    return PhysicalBarcodeOperation(
      mid: json['MID'] ?? '',
      docId: json['DOCID'] ?? '',
      oprnId: json['OPRNID'] ?? '',
      oprnCode: json['OPRNCODE'] ?? '',
      oprnDesc: json['OPRNDESC'] ?? '',
      seq: json['SEQ'] ?? '',
      isFinal: json['ISFINAL'] ?? '',
      currentOpQty: json['CURRENTOPQTY'] ?? '',
      QTY: json['QTY'] ?? '',
      PRDTQTY: json['PRDTQTY'] ?? '',
      WOQTY: json['WOQTY'] ?? '',
    );
  }
}
