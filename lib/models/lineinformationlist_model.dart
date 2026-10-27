class LineInformationList {
  final String itemId;
  final String itemDesc;
  final DateTime delDate;
  final String qty;
  final String mrp;
  final String sotId;
  final String unitRate;

  LineInformationList({
    required this.itemId,
    required this.itemDesc,
    required this.delDate,
    required this.qty,
    required this.mrp,
    required this.sotId,
    required this.unitRate,
  });

  // Convert a LineInformationList object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemDesc': itemDesc,
      'delDate': delDate,
      'qty': qty,
      'mrp': mrp,
      'sotId': sotId,
      'unitRate': unitRate,
    };
  }

  // Create a LineInformationList object from a JSON map
  factory LineInformationList.fromJson(Map<String, dynamic> json) {
    return LineInformationList(
      itemId: json['itemId'] ?? '',
      itemDesc: json['itemDesc'] ?? '',
      delDate: json['delDate'] ?? '',
      qty: json['qty'] ?? '',
      mrp: json['mrp'] ?? '',
      sotId: json['sotId'] ?? '',
      unitRate: json['unitRate'] ?? '',
    );
  }
}
