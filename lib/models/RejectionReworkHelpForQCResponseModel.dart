class RejectionReworkHelpForQcResponseModel {
  RejectionReworkHelpForQcResponseModel({
    required this.data,
  });

   Data? data;
  RejectionReworkHelpForQcResponseModel.withError(String errorValue) {
    var error = errorValue;
  }
  factory RejectionReworkHelpForQcResponseModel.fromJson(Map<String, dynamic> json){
    return RejectionReworkHelpForQcResponseModel(
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

  final ListClass? list;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      list: json["LIST"] == null ? null : ListClass.fromJson(json["LIST"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "LIST": list?.toJson(),
  };

}

class ListClass {
  ListClass({
    required this.defaultdata,
    required this.reasonlist,
  });

  final Defaultdata? defaultdata;
  final Reasonlist? reasonlist;

  factory ListClass.fromJson(Map<String, dynamic> json){
    return ListClass(
      defaultdata: json["DEFAULTDATA"] == null ? null : Defaultdata.fromJson(json["DEFAULTDATA"]),
      reasonlist: json["REASONLIST"] == null ? null : Reasonlist.fromJson(json["REASONLIST"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "DEFAULTDATA": defaultdata?.toJson(),
    "REASONLIST": reasonlist?.toJson(),
  };

}

class Defaultdata {
  Defaultdata({
    required this.info,
  });

  final Info? info;

  factory Defaultdata.fromJson(Map<String, dynamic> json){
    return Defaultdata(
      info: json["INFO"] == null ? null : Info.fromJson(json["INFO"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "INFO": info?.toJson(),
  };

}

class Info {
  Info({
    required this.rejlocid,
    required this.loccode,
    required this.locdesc,
    required this.reasontype,
  });

  final String? rejlocid;
  final String? loccode;
  final String? locdesc;
  final String? reasontype;

  factory Info.fromJson(Map<String, dynamic> json){
    return Info(
      rejlocid: json["REJLOCID"],
      loccode: json["LOCCODE"],
      locdesc: json["LOCDESC"],
      reasontype: json["REASONTYPE"],
    );
  }

  Map<String, dynamic> toJson() => {
    "REJLOCID": rejlocid,
    "LOCCODE": loccode,
    "LOCDESC": locdesc,
    "REASONTYPE": reasontype,
  };

}

class Reasonlist {
  Reasonlist({
    required this.reason,
  });

  final List<Reason> reason;

  factory Reasonlist.fromJson(Map<String, dynamic> json){
    return Reasonlist(
      reason: json["REASON"] == null ? [] : List<Reason>.from(json["REASON"]!.map((x) => Reason.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "REASON": reason.map((x) => x?.toJson()).toList(),
  };

}

class Reason {
  Reason({
    required this.qcrid,
    required this.rejectionid,
    required this.rejectioncode,
    required this.rejectiondesc,
    required this.qty,
  });

  final String? qcrid;
  final String? rejectionid;
  final String? rejectioncode;
  final String? rejectiondesc;
  final String? qty;

  factory Reason.fromJson(Map<String, dynamic> json){
    return Reason(
      qcrid: json["QCRID"],
      rejectionid: json["REJECTIONID"],
      rejectioncode: json["REJECTIONCODE"],
      rejectiondesc: json["REJECTIONDESC"],
      qty: json["QTY"],
    );
  }

  Map<String, dynamic> toJson() => {
    "QCRID": qcrid,
    "REJECTIONID": rejectionid,
    "REJECTIONCODE": rejectioncode,
    "REJECTIONDESC": rejectiondesc,
    "QTY": qty,
  };

}
