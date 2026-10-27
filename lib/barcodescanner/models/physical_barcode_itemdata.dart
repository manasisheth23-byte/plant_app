class PhysicalBarcodeItemResponse {
  final List<TransactionDetail> transactions;

  PhysicalBarcodeItemResponse({required this.transactions});

  factory PhysicalBarcodeItemResponse.fromJson(Map<String, dynamic> json) {
    final transactionSection = json['TRANSACTIONDETAILS'] ?? {};

    final transList = transactionSection['TRANSACTIONS'];

    // If null or not a list → return empty list safely
    if (transList == null || transList is! List) {
      return PhysicalBarcodeItemResponse(transactions: []);
    }

    return PhysicalBarcodeItemResponse(
      transactions: transList
          .map((t) => TransactionDetail.fromJson(t))
          .toList(),
    );
  }
}


class TransactionDetail {
  final String mid;
  final String docid;
  final String itemid;
  final String itemCode;
  final String item;
  final String operation;
  final String bulkIssueApplicable;
  final String totalRequiredItemQuantity;
  final String pendingIssueAdvQuantity;
  final String availableItemQuantity;
  final String stockInStore;
  final String totalShortfallQuantity;
  final String uomCode;
  final String uomId;
  final String qtyDeciplaces;
  final String nouDeciplaces;
  final String mtamto;
  final String balanceIssueAdviceQuantity;
  final String totalIssueAdvQuantity;
  final String fullKitQuantity;
  final String isProcessItem;
  final String itemTypeDesc;
  final String itemLocId;
  final String itemLocDesc;
  final String alternateItemExists;
  final String pfbdim;
  final String issAdvNumb;
  final String SCANNEDQTY;

  TransactionDetail({
    required this.mid,
    required this.docid,
    required this.itemid,
    required this.itemCode,
    required this.item,
    required this.operation,
    required this.bulkIssueApplicable,
    required this.totalRequiredItemQuantity,
    required this.pendingIssueAdvQuantity,
    required this.availableItemQuantity,
    required this.stockInStore,
    required this.totalShortfallQuantity,
    required this.uomCode,
    required this.uomId,
    required this.qtyDeciplaces,
    required this.nouDeciplaces,
    required this.mtamto,
    required this.balanceIssueAdviceQuantity,
    required this.totalIssueAdvQuantity,
    required this.fullKitQuantity,
    required this.isProcessItem,
    required this.itemTypeDesc,
    required this.itemLocId,
    required this.itemLocDesc,
    required this.alternateItemExists,
    required this.pfbdim,
    required this.issAdvNumb,
    required this.SCANNEDQTY,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      mid: json['MID'] ?? '',
      docid: json['DOCID'] ?? '',
      itemid: json['ITEMID'] ?? '',
      itemCode: json['ItemCode'] ?? '',
      item: json['Item'] ?? '',
      operation: json['Operation'] ?? '',
      bulkIssueApplicable: json['BulkIssueApplicable'] ?? '',
      totalRequiredItemQuantity: json['TotalRequiredItemQuantity'] ?? '',
      pendingIssueAdvQuantity: json['PendingIssueAdvQuantity'] ?? '',
      availableItemQuantity: json['AvailableItemQuantity'] ?? '',
      stockInStore: json['StockInStore'] ?? '',
      totalShortfallQuantity: json['TotalShortfallQuantity'] ?? '',
      uomCode: json['UOMCODE'] ?? '',
      uomId: json['UOMID'] ?? '',
      qtyDeciplaces: json['QTYDECIPLACES'] ?? '',
      nouDeciplaces: json['NOUDECIPLACES'] ?? '',
      mtamto: json['MTAMTO'] ?? '',
      balanceIssueAdviceQuantity: json['BalanceIssueAdviceQuantity'] ?? '',
      totalIssueAdvQuantity: json['TotalIssueAdvQuantity'] ?? '',
      fullKitQuantity: json['FullKitQuantity'] ?? '',
      isProcessItem: json['ISPROCESSITEM'] ?? '',
      itemTypeDesc: json['ITEMTYPEDESC'] ?? '',
      itemLocId: json['ITEMLOCID'] ?? '',
      itemLocDesc: json['ITEMLOCDESC'] ?? '',
      alternateItemExists: json['ALTERNATEITEMEXISTS'] ?? '',
      pfbdim: json['PFBDIM'] ?? '',
      issAdvNumb: json['ISSADVNUMB'] ?? '',
      SCANNEDQTY: json['SCANNEDQTY'] ?? '',
    );
  }
}
