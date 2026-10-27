import 'dart:convert';


class SalesOrderList {

   String? SLID;
   String? strCustomerNAme;
   String? strDueDate;
   String? strPORefDate;
   String? strSoID;
   String? strPORefNo;
   String? strMID;
   String? strDOCID;
   String? strDOCDESC;
   String? strSOID;
   String? strISRELEASE;
   String? strSoDate;
   String? strAmount;
   String? strDocType;
   String? strINVCNUMB;
   String?  srtCreatedByName;
   String? strSalesPerson;
   String? strStatus;
   String? strSlDesc;
   SalesOrderList({
      this.SLID,
      this.strCustomerNAme,
      this.strDueDate,
      this.strPORefDate,
      this.strSoID,
      this.strPORefNo,
      this.strMID,
      this.strDOCID,
      this.strDOCDESC,
      this.strSOID,
      this.strISRELEASE,
      this.strSoDate,
      this.strAmount,
      this.strDocType,
      this.strINVCNUMB,
      this.srtCreatedByName,
      this.strSalesPerson,
      this.strStatus,
      this.strSlDesc});


   Map<String, dynamic> toMap() {
     return {
       'SLID': SLID,
       'strCustomerNAme': strCustomerNAme,
       'strDueDate': strDueDate,
       'strPORefDate': strPORefDate,
       'strSoID': strSoID,

       'strPORefNo': strPORefNo,
       'strMID': strMID,
       'strDOCID': strDOCID,
       'strDOCDESC': strDOCDESC,
       'strSOID': strSOID,
       'strISRELEASE': strISRELEASE,
       'strSoDate': strSoDate,
       'strAmount': strAmount,
       'strDocType': strDocType,
       'strINVCNUMB': strINVCNUMB,
       'srtCreatedByName': srtCreatedByName,
       'strSalesPerson': strSalesPerson,
       'strStatus': strStatus,
       'strSlDesc': strSlDesc,
     };
   }

   factory SalesOrderList.fromMap(Map<String, dynamic> map) {
     return SalesOrderList(
       SLID: map['SLID'] ?? '',
       strCustomerNAme: map['strCustomerNAme'] ?? '',
       strDueDate: map['strDueDate'] ?? '',
       strPORefDate: map['strPORefDate'] ?? '',
       strSoID: map['strSoID'] ?? '',
       strPORefNo: map['strPORefNo'] ?? '',
       strMID: map['strMID'] ?? '',
       strDOCID: map['strDOCID'] ?? '',
       strDOCDESC: map['strDOCDESC'] ?? '',
       strSOID: map['strSOID'] ?? '',
       strISRELEASE: map['strISRELEASE'] ?? '',
       strSoDate: map['strSoDate'] ?? '',
       strAmount: map['strAmount'] ?? '',
       strDocType: map['strDocType'] ?? '',
       strINVCNUMB: map['strINVCNUMB'] ?? '',
       srtCreatedByName: map['srtCreatedByName'] ?? '',
       strSalesPerson: map['strSalesPerson'] ?? '',
       strStatus: map['strStatus'] ?? '',
       strSlDesc: map['strSlDesc'] ?? '',
     );
   }






}