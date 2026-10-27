class TransactionModel_FinancialYear {
  final TransactionDetails? transactionDetails;

  TransactionModel_FinancialYear({this.transactionDetails});
  // ✅ ADD THIS GETTER (VERY IMPORTANT)
  List<FinancialYearTransaction> get transactions =>
      transactionDetails?.transactions ?? [];
  factory TransactionModel_FinancialYear.fromJson(
      Map<String, dynamic> json) {
    return TransactionModel_FinancialYear(
      transactionDetails: json['TRANSACTIONDETAILS'] != null
          ? TransactionDetails.fromJson(json['TRANSACTIONDETAILS'])
          : null,
    );
  }
}

// ------------------------------------------------------------

class TransactionDetails {
  final List<FinancialYearTransaction> transactions;

  TransactionDetails({required this.transactions});

  factory TransactionDetails.fromJson(
      Map<String, dynamic> json) {
    return TransactionDetails(
      transactions: json['TRANSACTIONS'] != null
          ? List<FinancialYearTransaction>.from(
          json['TRANSACTIONS']
              .map((e) => FinancialYearTransaction.fromJson(e)))
          : [],
    );
  }
}

// ------------------------------------------------------------

class FinancialYearTransaction {
  final String? controlNo;
  final String? sDate;
  final String? eDate;
  final String? tStrDate;
  final String? yrCls;
  final String? invYrCls;
  final String? chkURate;
  final String? asstYrCls;
  final String? defaultYr;
  final String? isActive;
  final String? isAuth;
  final String? description;

  FinancialYearTransaction({
    this.controlNo,
    this.sDate,
    this.eDate,
    this.tStrDate,
    this.yrCls,
    this.invYrCls,
    this.chkURate,
    this.asstYrCls,
    this.defaultYr,
    this.isActive,
    this.isAuth,
    this.description,
  });

  factory FinancialYearTransaction.fromJson(
      Map<String, dynamic> json) {
    return FinancialYearTransaction(
      controlNo: json['CONTROLNO'],
      sDate: json['SDATE'],
      eDate: json['EDATE'],
      tStrDate: json['TSTRDATE'],
      yrCls: json['YRCLS'],
      invYrCls: json['INVYRCLS'],
      chkURate: json['CHKURATE'],
      asstYrCls: json['ASSTYRCLS'],
      defaultYr: json['DEFAULTYR'],
      isActive: json['ISACTIVE'],
      isAuth: json['ISAUTH'],
      description: json['DESCRIPTION'],
    );
  }
}
