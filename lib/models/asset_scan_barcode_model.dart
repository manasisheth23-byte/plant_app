class AssetBarcodeModel {
  TRANSACTIONDETAILS? tRANSACTIONDETAILS;

  AssetBarcodeModel({this.tRANSACTIONDETAILS});

  AssetBarcodeModel.fromJson(Map<String, dynamic> json) {
    tRANSACTIONDETAILS = json['TRANSACTIONDETAILS'] != null
        ? new TRANSACTIONDETAILS.fromJson(json['TRANSACTIONDETAILS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tRANSACTIONDETAILS != null) {
      data['TRANSACTIONDETAILS'] = this.tRANSACTIONDETAILS!.toJson();
    }
    return data;
  }
}

class TRANSACTIONDETAILS {
  List<TRANSACTIONS>? tRANSACTIONS;
  Null? fILEDETAIL;
  String? status;
  String? message;

  TRANSACTIONDETAILS(
      {this.tRANSACTIONS, this.fILEDETAIL, this.status, this.message});

  TRANSACTIONDETAILS.fromJson(Map<String, dynamic> json) {
    if (json['Status'] != null && json['Status'] == "false") {
      // Handle the case where no records are found
      status = json['Status'];
      message = json['Message'];
    } else {
      if (json['TRANSACTIONS'] != null) {
        tRANSACTIONS = <TRANSACTIONS>[];
        json['TRANSACTIONS'].forEach((v) {
          tRANSACTIONS!.add(new TRANSACTIONS.fromJson(v));
        });
      }
      fILEDETAIL = json['FILEDETAIL'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tRANSACTIONS != null) {
      data['TRANSACTIONS'] = this.tRANSACTIONS!.map((v) => v.toJson()).toList();
    }
    data['FILEDETAIL'] = this.fILEDETAIL;
    data['Status'] = this.status;
    data['Message'] = this.message;
    return data;
  }
}

class TRANSACTIONS {
  String? aSSETCODE;
  String? mACHINENO;
  String? mACHINENAME;
  String? mAKE;
  String? dIVISION;
  String? lOCATION;
  String? mFGYEAR;
  String? cAPIYEAR;

  TRANSACTIONS(
      {this.aSSETCODE,
      this.mACHINENO,
      this.mACHINENAME,
      this.mAKE,
      this.dIVISION,
      this.lOCATION,
      this.mFGYEAR,
      this.cAPIYEAR});

  TRANSACTIONS.fromJson(Map<String, dynamic> json) {
    aSSETCODE = json['ASSETCODE'];
    mACHINENO = json['MACHINENO'];
    mACHINENAME = json['MACHINENAME'];
    mAKE = json['MAKE'];
    dIVISION = json['DIVISION'];
    lOCATION = json['LOCATION'];
    mFGYEAR = json['MFGYEAR'];
    cAPIYEAR = json['CAPIYEAR'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ASSETCODE'] = this.aSSETCODE;
    data['MACHINENO'] = this.mACHINENO;
    data['MACHINENAME'] = this.mACHINENAME;
    data['MAKE'] = this.mAKE;
    data['DIVISION'] = this.dIVISION;
    data['LOCATION'] = this.lOCATION;
    data['MFGYEAR'] = this.mFGYEAR;
    data['CAPIYEAR'] = this.cAPIYEAR;
    return data;
  }
}
