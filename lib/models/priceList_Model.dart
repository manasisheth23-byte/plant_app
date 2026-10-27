class PriseListModel {
  final int pid;
  final int itemId;
  final String itemCode;
  final String itemDesc;
  final String wef;
  final double unitRate;

  PriseListModel(this.pid, this.itemId, this.itemCode, this.itemDesc, this.wef, this.unitRate);

  factory PriseListModel.fromMap(Map<String, dynamic> map) {
    return PriseListModel(
      map['PID'],
      map['ITEMID'],
      map['ITEMCODE'],
      map['ITEMDESC'],
      map['FROMDATE'],
      map['UNITRATE'] is int
          ? (map['UNITRATE'] as int).toDouble() // Convert int to double
          : map['UNITRATE'] as double, // Use the value directly if it's already a double
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'PID': pid,
      'ITEMID': itemId,
      'ITEMCODE': itemCode,
      'ITEMDESC': itemDesc,
      'FROMDATE': wef,
      'UNITRATE': unitRate,
    };
  }
}
