class SoTableModel {
  String? sTATUS;
  List<Data>? data;

  SoTableModel({this.sTATUS, this.data});

  SoTableModel.fromJson(Map<String, dynamic> json) {
    sTATUS = json['STATUS'];
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['STATUS'] = this.sTATUS;
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? sRNO;
  String? sONO;
  String? sODATE;
  int? sOLineNo;
  String? customer;
  String? itemCode;
  int? eRPITEMID;
  String? itemDescription;
  int? pRODNQTY;
  int? bINISSUEQTY;
  double? qTY; // Changed from int? to double?
  double? dISPATCHQTY; // Changed from int? to double?
  double? fkQty1; // Changed from int? to double?
  double? fkQty; // Changed from int? to double?
  double? avlQty; // Changed from int? to double?
  String? cDD;
  String? iNTPLANDT;
  String? eXWORKDATE;
  String? plannedFKdate;
  String? expectedFKDate;
  String? expectedDeliveryDate;
  int? noOfDelayDays;
  String? cOLORNAME;
  String? cOLORDESC;
  String? aLERTS;
  int? iSSPIKE;
  int? aSSIGNPRIORITY;
  int? uSOID;
  bool? sTANDARDPRODUCT;
  int? fKQtyWithoutMatReserv;
  int? fKQtywithMatReserv;
  int? sHOWMATSTATUS;
  int? totalRows;
  double? totalPages; // Changed from int? to double?
  int? pageSize;
  int? pageNo;
  String? criticalResourceName;
  String? pRODUCTIONTYPE;
  String? gROUP;
  String? cUSTOMERTYPE;
  String? lOCCODE;
  int? eRPPROJID;
  String? pROJNO;
  int? bOMMID;
  String? dISPITEMCODE;
  int? oRGSTRUCID;
  String? oRGDESC;
  String? pONO;
  String? pODATE;
  String? customerPartNO;
  String? customerPOLineNo;
  String? revNo;
  int? podiffdays;
  String? drgNoRevNo;
  int? mID;
  int? tID;
  int? dOCID;
  String? salescompnaycode;
  double? pENDINGQTY; // Changed from int? to double?
  int? currencyId;
  String? cURRENCYDESC;
  double? mTMQTY; // Changed from int? to double?
  String? oRIGINALCONTRADATE;
  double? pERUNITNETORDERBOOKING; // Changed from int? to double?
  double? vALUE; // Changed from int? to double?

  Data({
    this.sRNO,
    this.sONO,
    this.sODATE,
    this.sOLineNo,
    this.customer,
    this.itemCode,
    this.eRPITEMID,
    this.itemDescription,
    this.pRODNQTY,
    this.bINISSUEQTY,
    this.qTY,
    this.dISPATCHQTY,
    this.fkQty1,
    this.fkQty,
    this.avlQty,
    this.cDD,
    this.iNTPLANDT,
    this.eXWORKDATE,
    this.plannedFKdate,
    this.expectedFKDate,
    this.expectedDeliveryDate,
    this.noOfDelayDays,
    this.cOLORNAME,
    this.cOLORDESC,
    this.aLERTS,
    this.iSSPIKE,
    this.aSSIGNPRIORITY,
    this.uSOID,
    this.sTANDARDPRODUCT,
    this.fKQtyWithoutMatReserv,
    this.fKQtywithMatReserv,
    this.sHOWMATSTATUS,
    this.totalRows,
    this.totalPages,
    this.pageSize,
    this.pageNo,
    this.criticalResourceName,
    this.pRODUCTIONTYPE,
    this.gROUP,
    this.cUSTOMERTYPE,
    this.lOCCODE,
    this.eRPPROJID,
    this.pROJNO,
    this.bOMMID,
    this.dISPITEMCODE,
    this.oRGSTRUCID,
    this.oRGDESC,
    this.pONO,
    this.pODATE,
    this.customerPartNO,
    this.customerPOLineNo,
    this.revNo,
    this.podiffdays,
    this.drgNoRevNo,
    this.mID,
    this.tID,
    this.dOCID,
    this.salescompnaycode,
    this.pENDINGQTY,
    this.currencyId,
    this.cURRENCYDESC,
    this.mTMQTY,
    this.oRIGINALCONTRADATE,
    this.pERUNITNETORDERBOOKING,
    this.vALUE,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sRNO = json['SRNO'];
    sONO = json['SONO'];
    sODATE = json['SODATE'];
    sOLineNo = json['SOLineNo'];
    customer = json['Customer'];
    itemCode = json['ItemCode'];
    eRPITEMID = json['ERPITEMID'];
    itemDescription = json['ItemDescription'];
    pRODNQTY = json['PRODNQTY'];
    bINISSUEQTY = json['BINISSUEQTY'];
    qTY = json['QTY'];
    dISPATCHQTY = json['DISPATCHQTY'];
    fkQty1 = json['FkQty1'];
    fkQty = json['FkQty'];
    avlQty = json['AvlQty'];
    cDD = json['CDD'];
    iNTPLANDT = json['INTPLANDT'];
    eXWORKDATE = json['EXWORKDATE'];
    plannedFKdate = json['PlannedFKdate'];
    expectedFKDate = json['ExpectedFKDate'];
    expectedDeliveryDate = json['ExpectedDeliveryDate'];
    noOfDelayDays = json['NoOfDelayDays'];
    cOLORNAME = json['COLORNAME'];
    cOLORDESC = json['COLORDESC'];
    aLERTS = json['ALERTS'];
    iSSPIKE = json['ISSPIKE'];
    aSSIGNPRIORITY = json['ASSIGNPRIORITY'];
    uSOID = json['USOID'];
    sTANDARDPRODUCT = json['STANDARDPRODUCT'];
    fKQtyWithoutMatReserv = json['FKQtyWithoutMatReserv'];
    fKQtywithMatReserv = json['FKQtywithMatReserv'];
    sHOWMATSTATUS = json['SHOWMATSTATUS'];
    totalRows = json['TotalRows'];
    totalPages = json['TotalPages'];
    pageSize = json['PageSize'];
    pageNo = json['PageNo'];
    criticalResourceName = json['CriticalResourceName'];
    pRODUCTIONTYPE = json['PRODUCTIONTYPE'];
    gROUP = json['GROUP'];
    cUSTOMERTYPE = json['CUSTOMERTYPE'];
    lOCCODE = json['LOCCODE'];
    eRPPROJID = json['ERPPROJID'];
    pROJNO = json['PROJNO'];
    bOMMID = json['BOMMID'];
    dISPITEMCODE = json['DISPITEMCODE'];
    oRGSTRUCID = json['ORGSTRUCID'];
    oRGDESC = json['ORGDESC'];
    pONO = json['PONO'];
    pODATE = json['PODATE'];
    customerPartNO = json['CustomerPartNO'];
    customerPOLineNo = json['CustomerPOLineNo'];
    revNo = json['RevNo'];
    podiffdays = json['podiffdays'];
    drgNoRevNo = json['DrgNoRevNo'];
    mID = json['MID'];
    tID = json['TID'];
    dOCID = json['DOCID'];
    salescompnaycode = json['salescompnaycode'];
    pENDINGQTY = json['PENDINGQTY'];
    currencyId = json['CurrencyId'];
    cURRENCYDESC = json['CURRENCYDESC'];
    mTMQTY = json['MTMQTY'];
    oRIGINALCONTRADATE = json['ORIGINAL_CONTRADATE'];
    pERUNITNETORDERBOOKING = json['PERUNITNETORDERBOOKING'];
    vALUE = json['VALUE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SRNO'] = this.sRNO;
    data['SONO'] = this.sONO;
    data['SODATE'] = this.sODATE;
    data['SOLineNo'] = this.sOLineNo;
    data['Customer'] = this.customer;
    data['ItemCode'] = this.itemCode;
    data['ERPITEMID'] = this.eRPITEMID;
    data['ItemDescription'] = this.itemDescription;
    data['PRODNQTY'] = this.pRODNQTY;
    data['BINISSUEQTY'] = this.bINISSUEQTY;
    data['QTY'] = this.qTY;
    data['DISPATCHQTY'] = this.dISPATCHQTY;
    data['FkQty1'] = this.fkQty1;
    data['FkQty'] = this.fkQty;
    data['AvlQty'] = this.avlQty;
    data['CDD'] = this.cDD;
    data['INTPLANDT'] = this.iNTPLANDT;
    data['EXWORKDATE'] = this.eXWORKDATE;
    data['PlannedFKdate'] = this.plannedFKdate;
    data['ExpectedFKDate'] = this.expectedFKDate;
    data['ExpectedDeliveryDate'] = this.expectedDeliveryDate;
    data['NoOfDelayDays'] = this.noOfDelayDays;
    data['COLORNAME'] = this.cOLORNAME;
    data['COLORDESC'] = this.cOLORDESC;
    data['ALERTS'] = this.aLERTS;
    data['ISSPIKE'] = this.iSSPIKE;
    data['ASSIGNPRIORITY'] = this.aSSIGNPRIORITY;
    data['USOID'] = this.uSOID;
    data['STANDARDPRODUCT'] = this.sTANDARDPRODUCT;
    data['FKQtyWithoutMatReserv'] = this.fKQtyWithoutMatReserv;
    data['FKQtywithMatReserv'] = this.fKQtywithMatReserv;
    data['SHOWMATSTATUS'] = this.sHOWMATSTATUS;
    data['TotalRows'] = this.totalRows;
    data['TotalPages'] = this.totalPages;
    data['PageSize'] = this.pageSize;
    data['PageNo'] = this.pageNo;
    data['CriticalResourceName'] = this.criticalResourceName;
    data['PRODUCTIONTYPE'] = this.pRODUCTIONTYPE;
    data['GROUP'] = this.gROUP;
    data['CUSTOMERTYPE'] = this.cUSTOMERTYPE;
    data['LOCCODE'] = this.lOCCODE;
    data['ERPPROJID'] = this.eRPPROJID;
    data['PROJNO'] = this.pROJNO;
    data['BOMMID'] = this.bOMMID;
    data['DISPITEMCODE'] = this.dISPITEMCODE;
    data['ORGSTRUCID'] = this.oRGSTRUCID;
    data['ORGDESC'] = this.oRGDESC;
    data['PONO'] = this.pONO;
    data['PODATE'] = this.pODATE;
    data['CustomerPartNO'] = this.customerPartNO;
    data['CustomerPOLineNo'] = this.customerPOLineNo;
    data['RevNo'] = this.revNo;
    data['podiffdays'] = this.podiffdays;
    data['DrgNoRevNo'] = this.drgNoRevNo;
    data['MID'] = this.mID;
    data['TID'] = this.tID;
    data['DOCID'] = this.dOCID;
    data['salescompnaycode'] = this.salescompnaycode;
    data['PENDINGQTY'] = this.pENDINGQTY;
    data['CurrencyId'] = this.currencyId;
    data['CURRENCYDESC'] = this.cURRENCYDESC;
    data['MTMQTY'] = this.mTMQTY;
    data['ORIGINAL_CONTRADATE'] = this.oRIGINALCONTRADATE;
    data['PERUNITNETORDERBOOKING'] = this.pERUNITNETORDERBOOKING;
    data['VALUE'] = this.vALUE;
    return data;
  }
}
