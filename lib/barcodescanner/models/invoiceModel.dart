class InvoiceModel {
  TRANSACTIONDETAILS? tRANSACTIONDETAILS;

  InvoiceModel({this.tRANSACTIONDETAILS});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
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
  String? status;
  String? message;

  TRANSACTIONDETAILS({this.tRANSACTIONS, this.status, this.message});

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
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tRANSACTIONS != null) {
      data['TRANSACTIONS'] = this.tRANSACTIONS!.map((v) => v.toJson()).toList();
    }
    data['Status'] = this.status;
    data['Message'] = this.message;
    return data;
  }
}

// class TRANSACTIONS {
//   String? mID;
//   String? dOCID;
//   String? documentType;
//   String? documentNo;
//   String? documentDate;
//   String? customer;
//   String? tID;
//   String? pROJID;
//   String? sLID;

//   TRANSACTIONS({
//     this.mID,
//     this.dOCID,
//     this.documentType,
//     this.documentNo,
//     this.documentDate,
//     this.customer,
//     this.tID,
//     this.pROJID,
//     this.sLID,
//   });

//   TRANSACTIONS.fromJson(Map<String, dynamic> json) {
//     mID = json['MID'];
//     dOCID = json['DOCID'];
//     documentType = json['Document Type'];
//     documentNo = json['Document No.'];
//     documentDate = formatApiDate(json['Document Date']);
//     customer = json['Customer'];
//     tID = json['TID'];
//     pROJID = json['PROJID'];
//     sLID = json['SLID'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['MID'] = this.mID;
//     data['DOCID'] = this.dOCID;
//     data['Document Type'] = this.documentType;
//     data['Document No.'] = this.documentNo;
//     data['Document Date'] = this.documentDate;
//     data['Customer'] = this.customer;
//     return data;
//   }
// }
// **************************************************************************
// class TRANSACTIONS {
//   String? documentType;
//   String? documentNo;
//   String? documentDate;
//   String? productCode;
//   String? productDescription;
//   String? uOM;
//   String? quantity;
//   String? slid;
//   String? customer;
//   String? projid;
//   String? scanned;
//   String? mID;
//   String? dOCID;
//   String? tID;
//   String? iTEMID;

//   TRANSACTIONS(
//       {this.documentType,
//       this.documentNo,
//       this.documentDate,
//       this.productCode,
//       this.productDescription,
//       this.uOM,
//       this.quantity,
//       this.slid,
//       this.customer,
//       this.projid,
//       this.scanned,
//       this.mID,
//       this.dOCID,
//       this.tID,
//       this.iTEMID});

//   TRANSACTIONS.fromJson(Map<String, dynamic> json) {
//     documentType = json['Document Type'];
//     documentNo = json['Document No.'];
//     documentDate = formatApiDate(json['Document Date']);
//     productCode = json['Product Code'];
//     productDescription = json['Product Description'];
//     uOM = json['UOM'];
//     quantity = json['Quantity'];
//     slid = json.containsKey("SLID") ? json['SLID'] : '';
//     customer = json['Customer'];
//     projid = json.containsKey("PROJID") ? json['PROJID'] : "";
//     scanned = json['Scanned'];
//     mID = json['MID'];
//     dOCID = json['DOCID'];
//     tID = json['TID'];
//     iTEMID = json['ITEMID'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['Document Type'] = this.documentType;
//     data['Document No.'] = this.documentNo;
//     data['Document Date'] = this.documentDate;
//     data['Product Code'] = this.productCode;
//     data['Product Description'] = this.productDescription;
//     data['UOM'] = this.uOM;
//     data['Quantity'] = this.quantity;
//     data['Scanned'] = this.scanned;
//     data['MID'] = this.mID;
//     data['DOCID'] = this.dOCID;
//     data['TID'] = this.tID;
//     data['ITEMID'] = this.iTEMID;
//     return data;
//   }
// }

class TRANSACTIONS {
  String? mID;
  String? dOCID;
  String? tID;
  String? pROJID;
  String? sLID;
  String? documentType;
  String? documentNo;
  String? documentDate;
  String? customer;

  TRANSACTIONS(
      {this.mID,
      this.dOCID,
      this.tID,
      this.pROJID,
      this.sLID,
      this.documentType,
      this.documentNo,
      this.documentDate,
      this.customer});

  TRANSACTIONS.fromJson(Map<String, dynamic> json) {
    mID = json['MID'];
    dOCID = json['DOCID'];
    tID = json['TID'];
    pROJID = json['PROJID'];
    sLID = json['SLID'];
    documentType = json['Document Type'];
    documentNo = json['Document No.'];
    documentDate = json['Document Date'];
    customer = json['Customer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MID'] = this.mID;
    data['DOCID'] = this.dOCID;
    data['TID'] = this.tID;
    data['PROJID'] = this.pROJID;
    data['SLID'] = this.sLID;
    data['Document Type'] = this.documentType;
    data['Document No.'] = this.documentNo;
    data['Document Date'] = this.documentDate;
    data['Customer'] = this.customer;
    return data;
  }
}

String formatApiDate(String? apiDate) {
  if (apiDate == null || apiDate.isEmpty) {
    return '';
  }

  // Assuming the API date format is yyyy/dd/mm
  List<String> parts = apiDate.split('-');
  if (parts.length == 3) {
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  } else {
    return apiDate; // Return original date if the format is unexpected
  }
}
