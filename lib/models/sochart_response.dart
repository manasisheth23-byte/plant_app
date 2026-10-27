class SoChartData {
  String? sTATUS;
  List<Dashboard>? dashboard;
  List<ErrorList>? errorList;

  SoChartData({this.sTATUS, this.dashboard, this.errorList});

  SoChartData.fromJson(Map<String, dynamic> json) {
    sTATUS = json['STATUS'];
    if (json['Dashboard'] != null) {
      dashboard = <Dashboard>[];
      json['Dashboard'].forEach((v) {
        dashboard!.add(new Dashboard.fromJson(v));
      });
    }
    if (json['ErrorList'] != null) {
      errorList = <ErrorList>[];
      json['ErrorList'].forEach((v) {
        errorList!.add(new ErrorList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['STATUS'] = this.sTATUS;
    if (this.dashboard != null) {
      data['Dashboard'] = this.dashboard!.map((v) => v.toJson()).toList();
    }
    if (this.errorList != null) {
      data['ErrorList'] = this.errorList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dashboard {
  String? title;
  Totals? totals;
  List<PieChart>? pieChart;

  Dashboard({this.title, this.totals, this.pieChart});

  Dashboard.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    totals =
    json['Totals'] != null ? new Totals.fromJson(json['Totals']) : null;
    if (json['PieChart'] != null) {
      pieChart = <PieChart>[];
      json['PieChart'].forEach((v) {
        pieChart!.add(new PieChart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Title'] = this.title;
    if (this.totals != null) {
      data['Totals'] = this.totals!.toJson();
    }
    if (this.pieChart != null) {
      data['PieChart'] = this.pieChart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Totals {
  int? totalCount;
  double? totalQty;
  double? totalValue;

  Totals({this.totalCount, this.totalQty, this.totalValue});

  Totals.fromJson(Map<String, dynamic> json) {
    totalCount = json['TotalCount'];
    totalQty = json['TotalQty'];
    totalValue = json['TotalValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TotalCount'] = this.totalCount;
    data['TotalQty'] = this.totalQty;
    data['TotalValue'] = this.totalValue;
    return data;
  }
}

class PieChart {
  int? rEPORTON;
  int? rEPORTTYPE;
  int? nOOFSO;
  double? qTY;
  int? nOOFCUSTOMER;
  int? cOLORLVL;
  String? cOLORNAME;
  String? cOLORDESC;
  double? pERC;
  double? tOTAL;
  double? sOVALUE;
  double? tOTALSOVALUE;
  double? qTYTOTAL;
  double? vALUETOTAL;

  PieChart(
      {this.rEPORTON,
        this.rEPORTTYPE,
        this.nOOFSO,
        this.qTY,
        this.nOOFCUSTOMER,
        this.cOLORLVL,
        this.cOLORNAME,
        this.cOLORDESC,
        this.pERC,
        this.tOTAL,
        this.sOVALUE,
        this.tOTALSOVALUE,
        this.qTYTOTAL,
        this.vALUETOTAL});

  PieChart.fromJson(Map<String, dynamic> json) {
    rEPORTON = json['REPORTON'];
    rEPORTTYPE = json['REPORTTYPE'];
    nOOFSO = json['NOOFSO'];
    qTY = json['QTY'];
    nOOFCUSTOMER = json['NOOFCUSTOMER'];
    cOLORLVL = json['COLORLVL'];
    cOLORNAME = json['COLORNAME'];
    cOLORDESC = json['COLORDESC'];
    pERC = json['PERC'];
    tOTAL = json['TOTAL'];
    sOVALUE = json['SOVALUE'];
    tOTALSOVALUE = json['TOTALSOVALUE'];
    qTYTOTAL = json['QTYTOTAL'];
    vALUETOTAL = json['VALUETOTAL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['REPORTON'] = this.rEPORTON;
    data['REPORTTYPE'] = this.rEPORTTYPE;
    data['NOOFSO'] = this.nOOFSO;
    data['QTY'] = this.qTY;
    data['NOOFCUSTOMER'] = this.nOOFCUSTOMER;
    data['COLORLVL'] = this.cOLORLVL;
    data['COLORNAME'] = this.cOLORNAME;
    data['COLORDESC'] = this.cOLORDESC;
    data['PERC'] = this.pERC;
    data['TOTAL'] = this.tOTAL;
    data['SOVALUE'] = this.sOVALUE;
    data['TOTALSOVALUE'] = this.tOTALSOVALUE;
    data['QTYTOTAL'] = this.qTYTOTAL;
    data['VALUETOTAL'] = this.vALUETOTAL;
    return data;
  }
}

class ErrorList {
  int? rNO;
  String? rEASON;
  int? rECORDCNT;
  double? qTY;
  double? vAL;
  String? bGCOLOR;

  ErrorList(
      {this.rNO,
        this.rEASON,
        this.rECORDCNT,
        this.qTY,
        this.vAL,
        this.bGCOLOR});

  ErrorList.fromJson(Map<String, dynamic> json) {
    rNO = json['RNO'];
    rEASON = json['REASON'];
    rECORDCNT = json['RECORDCNT'];
    qTY = json['QTY'];
    vAL = json['VAL'];
    bGCOLOR = json['BGCOLOR'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RNO'] = this.rNO;
    data['REASON'] = this.rEASON;
    data['RECORDCNT'] = this.rECORDCNT;
    data['QTY'] = this.qTY;
    data['VAL'] = this.vAL;
    data['BGCOLOR'] = this.bGCOLOR;
    return data;
  }
}
