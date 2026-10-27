class TransactionResponse {
  final List<TransactionModel> transactions;

  TransactionResponse({required this.transactions});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactions: json['TRANSACTIONDETAILS'] != null &&
          json['TRANSACTIONDETAILS']['TRANSACTIONS'] != null
          ? (json['TRANSACTIONDETAILS']['TRANSACTIONS'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList()
          : [],
    );
  }
}

class TransactionModel {
  final String orgStrucId;
  final String companyName;

  TransactionModel({
    required this.orgStrucId,
    required this.companyName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      orgStrucId: json['ORGSTRUCID'] ?? '',
      companyName: json['Company Name'] ?? '',
    );
  }
}
