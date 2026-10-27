import 'dart:convert';

class ProjectDetailSalesOrder {
  String soNo;
  String soDate;
  String customer;
  String productCode;
  String productDesc;
  String poNo;
  String poDate;
  int lineNo;
  List<Item> items;

  ProjectDetailSalesOrder({
    required this.soNo,
    required this.soDate,
    required this.customer,
    required this.productCode,
    required this.productDesc,
    required this.poNo,
    required this.poDate,
    required this.lineNo,
    required this.items,
  });

  factory ProjectDetailSalesOrder.fromJson(Map<String, dynamic> json) {
    var list = json['Items'] as List;
    List<Item> itemsList = list.map((i) => Item.fromJson(i)).toList();

    return ProjectDetailSalesOrder(
      soNo: json['SoNo'],
      soDate: json['SoDate'],
      customer: json['Customer'],
      productCode: json['ProductCode'],
      productDesc: json['ProductDesc'],
      poNo: json['PoNo'],
      poDate: json['PoDate'],
      lineNo: json['LineNo'],
      items: itemsList,
    );
  }
}


class Item {
  String itemCode;
  String BuyerName;
  String itemType;
  String Dimension;
  String MTA_MTO;
  String Availability;
  String StockAvailable;
  String OpenPO_WOQty;
  String QuantityRequired;
  String PendingQuantity;
  String leadTime;
  String FKNeedByDate;
  String LastDateForRaisingPO_WO;
  String ExpectedDate;
  String ProductionType;
  String BOMDefined;
  String ProductFlowDefined;


  Item({
    required this.itemCode,
    required this.BuyerName,
    required this.itemType,
    required this.Dimension,
    required this.MTA_MTO,
    required this.Availability,
    required this.StockAvailable,
    required this.OpenPO_WOQty,
    required this.QuantityRequired,
    required this.PendingQuantity,
    required this.leadTime,
    required this.FKNeedByDate,
    required this.LastDateForRaisingPO_WO,
    required this.ExpectedDate,
    required this.ProductionType,
    required this.BOMDefined,
    required this.ProductFlowDefined,



  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemCode: json['ItemCode'],
      BuyerName: json['BuyerName'],
      itemType: json['ItemType'],
      Dimension: json['Dimension'],
      MTA_MTO: json['MTA_MTO'],
      Availability: json['Availability'],
      StockAvailable: json['StockAvailable'],
      OpenPO_WOQty: json['OpenPO_WOQty'],
      QuantityRequired: json['QuantityRequired'],
      PendingQuantity: json['PendingQuantity'],
      leadTime: json['leadTime'],
      FKNeedByDate: json['FKNeedByDate'],
      LastDateForRaisingPO_WO: json['LastDateForRaisingPO_WO'],
      ExpectedDate: json['ExpectedDate'],
      ProductionType: json['ProductionType'],
      BOMDefined: json['BOMDefined'],
      ProductFlowDefined: json['ProductFlowDefined'],
    );
  }
}