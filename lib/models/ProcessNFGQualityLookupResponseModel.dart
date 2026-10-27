class ProcessNfgQualityLookupResponseModel {
  ProcessNfgQualityLookupResponseModel({
     this.data,
  });

   Data? data;
  ProcessNfgQualityLookupResponseModel.withError(String errorValue) {
    var error = errorValue;
  }
  factory ProcessNfgQualityLookupResponseModel.fromJson(Map<String, dynamic> json){
    return ProcessNfgQualityLookupResponseModel(
      data: json["DATA"] == null ? null : Data.fromJson(json["DATA"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "DATA": data?.toJson(),
  };

}

class Data {
  Data({
    required this.list,
  });

  final List<ListElement> list;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      list: json["LIST"] == null ? [] : List<ListElement>.from(json["LIST"]!.map((x) => ListElement.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "LIST": list.map((x) => x?.toJson()).toList(),
  };

}

class ListElement {
  ListElement({
    required this.invcnumb,
    required this.qcmid,
    required this.qcdocid,
    required this.invctype,
    required this.invcdate,
    required this.qcusername,
    required this.qcdate,
    required this.prodqty,
    required this.prodcode,
    required this.proddesc,
    required this.wono,
    required this.itemtype,
    required this.wodate,
    required this.operation,
    required this.qcstatusdesc,
    required this.totalRows,
    required this.totalPages,
    required this.pageSize,
  });

  final String? invcnumb;
  final String? qcmid;
  final String? qcdocid;
  final String? invctype;
  final String? invcdate;
  final String? qcusername;
  final String? qcdate;
  final String? prodqty;
  final String? prodcode;
  final String? proddesc;
  final String? wono;
  final String? itemtype;
  final String? wodate;
  final String? operation;
  final String? qcstatusdesc;
  final String? totalRows;
  final String? totalPages;
  final String? pageSize;

  factory ListElement.fromJson(Map<String, dynamic> json){
    return ListElement(
      invcnumb: json["INVCNUMB"],
      qcmid: json["QCMID"],
      qcdocid: json["QCDOCID"],
      invctype: json["INVCTYPE"],
      invcdate: json["INVCDATE"],
      qcusername: json["QCUSERNAME"],
      qcdate: json["QCDATE"],
      prodqty: json["PRODQTY"],
      prodcode: json["PRODCODE"],
      proddesc: json["PRODDESC"],
      wono: json["WONO"],
      itemtype: json["ITEMTYPE"],
      wodate: json["WODATE"],
      operation: json["OPERATION"],
      qcstatusdesc: json["QCSTATUSDESC"],
      totalRows: json["TotalRows"],
      totalPages: json["TotalPages"],
      pageSize: json["PageSize"],
    );
  }

  Map<String, dynamic> toJson() => {
    "INVCNUMB": invcnumb,
    "QCMID": qcmid,
    "QCDOCID": qcdocid,
    "INVCTYPE": invctype,
    "INVCDATE": invcdate,
    "QCUSERNAME": qcusername,
    "QCDATE": qcdate,
    "PRODQTY": prodqty,
    "PRODCODE": prodcode,
    "PRODDESC": proddesc,
    "WONO": wono,
    "ITEMTYPE": itemtype,
    "WODATE": wodate,
    "OPERATION": operation,
    "QCSTATUSDESC": qcstatusdesc,
    "TotalRows": totalRows,
    "TotalPages": totalPages,
    "PageSize": pageSize,
  };

}
