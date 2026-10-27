class AuditItemModel {
  final String itemType;
  final String itemGroup;
  final String itemCode;
  final String itemDesc;
  final String quantity;
  final String rackBin;
  final String grnNo;
  final String projNo;
  final String soNo;
  final String poNo;
  final String supplier;
  final String customer;
  final String closingBalance;

  AuditItemModel({
    required this.itemType,
    required this.itemGroup,
    required this.itemCode,
    required this.itemDesc,
    required this.quantity,
    required this.rackBin,
    required this.grnNo,
    required this.projNo,
    required this.soNo,
    required this.poNo,
    required this.supplier,
    required this.customer,
    required this.closingBalance,
  });

  factory AuditItemModel.fromJson(Map<String, dynamic> json) {
    return AuditItemModel(
      itemType: json['itemType'] ?? '',
      itemGroup: json['itemGroup'] ?? '',
      itemCode: json['itemCode'] ?? '',
      itemDesc: json['itemDesc'] ?? '',
      quantity: json['quantity'] ?? '',
      rackBin: json['rackBin'] ?? '',
      grnNo: json['grnNo'] ?? '',
      projNo: json['projNo'] ?? '',
      soNo: json['soNo'] ?? '',
      poNo: json['poNo'] ?? '',
      supplier: json['supplier'] ?? '',
      customer: json['customer'] ?? '',
      closingBalance: json['closingBalance'] ?? '',
    );
  }
}
