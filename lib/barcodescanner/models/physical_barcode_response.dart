class PhysicalbarcodeResponseModel {
  TransactionDetails? transactionDetails;

  PhysicalbarcodeResponseModel({this.transactionDetails});

  factory PhysicalbarcodeResponseModel.fromJson(Map<String, dynamic> json) {
    return PhysicalbarcodeResponseModel(
      transactionDetails: json['TRANSACTIONDETAILS'] != null
          ? TransactionDetails.fromJson(json['TRANSACTIONDETAILS'])
          : null,
    );
  }
}

class TransactionDetails {
  List<Transaction>? transactions;

  TransactionDetails({this.transactions});

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactions: json['TRANSACTIONS'] != null
          ? List<Transaction>.from(
          json['TRANSACTIONS'].map((x) => Transaction.fromJson(x)))
          : [],
    );
  }
}

class Transaction {
  String? mid;
  String? workorderNo;
  String? itemCode;
  String? itemDesc;
  String? quantity;

  Transaction({
    this.mid,
    this.workorderNo,
    this.itemCode,
    this.itemDesc,
    this.quantity,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      mid: json['MID'],
      workorderNo: json['WORKORDERNO'],
      itemCode: json['ITEMCODE'],
      itemDesc: json['ITEMDESC'],
      quantity: json['QUANTITY'],
    );
  }
}
