class ProductCodeSpinnerModel {
  final int itemId;
  final String itemCode;
  final String itemDesc;
  final int mrp;
  final String uomCode;
  final String uomDesc;

  ProductCodeSpinnerModel({
    required this.itemId,
    required this.itemCode,
    required this.itemDesc,
    required this.mrp,
    required this.uomCode,
    required this.uomDesc,
  });

  // Factory method to create an instance from a JSON object
  factory ProductCodeSpinnerModel.fromJson(Map<String, dynamic> json) {
    return ProductCodeSpinnerModel(
      itemId: json['ITEMID'],
      itemCode: json['ITEMCODE'],
      itemDesc: json['ITEMDESC'],
      mrp: json['MRP'],
      uomCode: json['UOMCODE'],
      uomDesc: json['UOMDESC'],
    );
  }

  // Method to convert an instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'ITEMID': itemId,
      'ITEMCODE': itemCode,
      'ITEMDESC': itemDesc,
      'MRP': mrp,
      'UOMCODE': uomCode,
      'UOMDESC': uomDesc,
    };
  }

  // Method to convert a list of ProductCodeSpinnerModel to JSON
  static List<Map<String, dynamic>> listToJson(List<ProductCodeSpinnerModel> list) {
    return list.map((item) => item.toJson()).toList();
  }

  // Method to create a list of ProductCodeSpinnerModel from JSON
  static List<ProductCodeSpinnerModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ProductCodeSpinnerModel.fromJson(json)).toList();
  }
}
