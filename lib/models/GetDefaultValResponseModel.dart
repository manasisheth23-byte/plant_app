class GetDefaultValResponseModel {
  GetDefaultValResponseModel({
     this.data,
  });

   Data? data;
  GetDefaultValResponseModel.withError(String errorValue) {
    var error = errorValue;
  }
  factory GetDefaultValResponseModel.fromJson(Map<String, dynamic> json){
    return GetDefaultValResponseModel(
      data: json["DATA"] == null ? null : Data.fromJson(json["DATA"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "DATA": data?.toJson(),
  };

  @override
  String toString(){
    return "$data, ";
  }
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

  @override
  String toString(){
    return "$list, ";
  }
}

class ListElement {
  ListElement({
    required this.defstatusid,
    required this.defstatusdesc,
    required this.deftypeid,
    required this.deftypedesc,
    required this.defdocid,
    required this.defdoctype,
    required this.defdocdesc,
  });

  final String? defstatusid;
  final String? defstatusdesc;
  final String? deftypeid;
  final String? deftypedesc;
  final String? defdocid;
  final String? defdoctype;
  final String? defdocdesc;

  factory ListElement.fromJson(Map<String, dynamic> json){
    return ListElement(
      defstatusid: json["DEFSTATUSID"],
      defstatusdesc: json["DEFSTATUSDESC"],
      deftypeid: json["DEFTYPEID"],
      deftypedesc: json["DEFTYPEDESC"],
      defdocid: json["DEFDOCID"],
      defdoctype: json["DEFDOCTYPE"],
      defdocdesc: json["DEFDOCDESC"],
    );
  }

  Map<String, dynamic> toJson() => {
    "DEFSTATUSID": defstatusid,
    "DEFSTATUSDESC": defstatusdesc,
    "DEFTYPEID": deftypeid,
    "DEFTYPEDESC": deftypedesc,
    "DEFDOCID": defdocid,
    "DEFDOCTYPE": defdoctype,
    "DEFDOCDESC": defdocdesc,
  };

  @override
  String toString(){
    return "$defstatusid, $defstatusdesc, $deftypeid, $deftypedesc, $defdocid, $defdoctype, $defdocdesc, ";
  }
}
