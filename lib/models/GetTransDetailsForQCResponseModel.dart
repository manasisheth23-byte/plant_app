class GetTransDetailsForQcResponseModel {
  GetTransDetailsForQcResponseModel({
     this.data,
  });

   Data? data;
  GetTransDetailsForQcResponseModel.withError(String errorValue) {
    var error = errorValue;
  }
  factory GetTransDetailsForQcResponseModel.fromJson(Map<String, dynamic> json){
    return GetTransDetailsForQcResponseModel(
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
    required this.qcdetails,
  });

  final Defaultdata? defaultdata;
  final Qcdetails? qcdetails;

  factory ListClass.fromJson(Map<String, dynamic> json){
    return ListClass(
      defaultdata: json["DEFAULTDATA"] == null ? null : Defaultdata.fromJson(json["DEFAULTDATA"]),
      qcdetails: json["QCDETAILS"] == null ? null : Qcdetails.fromJson(json["QCDETAILS"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "DEFAULTDATA": defaultdata?.toJson(),
    "QCDETAILS": qcdetails?.toJson(),
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
    required this.refinvcnumb,
    required this.refinvcdate,
    required this.refinvctype,
    required this.minqcdate,
  });

  final String? refinvcnumb;
  final String? refinvcdate;
  final String? refinvctype;
  final String? minqcdate;

  factory Info.fromJson(Map<String, dynamic> json){
    return Info(
      refinvcnumb: json["REFINVCNUMB"],
      refinvcdate: json["REFINVCDATE"],
      refinvctype: json["REFINVCTYPE"],
      minqcdate: json["MINQCDATE"],
    );
  }

  Map<String, dynamic> toJson() => {
    "REFINVCNUMB": refinvcnumb,
    "REFINVCDATE": refinvcdate,
    "REFINVCTYPE": refinvctype,
    "MINQCDATE": minqcdate,
  };

}

class Qcdetails {
  Qcdetails({
    required this.qc,
  });

  final Qc? qc;

  factory Qcdetails.fromJson(Map<String, dynamic> json){
    return Qcdetails(
      qc: json["QC"] == null ? null : Qc.fromJson(json["QC"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "QC": qc?.toJson(),
  };

}

class Qc {
  Qc({
    required this.qctid,
    required this.qcmid,
    required this.qcdocid,
    required this.wono,
    required this.parentwono,
    required this.flocid,
    required this.flocdesc,
    required this.qcdate,
    required this.omid,
    required this.odocid,
    required this.otid,
    required this.rtid,
    required this.itemid,
    required this.itemcode,
    required this.itemdesc,
    required this.uomid,
    required this.oprnid,
    required this.transqty,
    required this.transnou,
    required this.transdimn,
    required this.transedimn,
    required this.transdate,
    required this.accnou,
    required this.accqty,
    required this.acclocid,
    required this.acclocdesc,
    required this.rejnou,
    required this.rejqty,
    required this.rejlocid,
    required this.rejlocdesc,
    required this.reworknou,
    required this.reworkqty,
    required this.reworklocid,
    required this.reworklocdesc,
    required this.qcstatus,
    required this.projid,
    required this.projno,
    required this.prodnlineid,
    required this.pfmid,
    required this.docorgstruid,
    required this.qcmenuid,
  });

  final String? qctid;
  final String? qcmid;
  final String? qcdocid;
  final String? wono;
  final String? parentwono;
  final String? flocid;
  final String? flocdesc;
  final String? qcdate;
  final String? omid;
  final String? odocid;
  final String? otid;
  final String? rtid;
  final String? itemid;
  final String? itemcode;
  final String? itemdesc;
  final String? uomid;
  final String? oprnid;
  final String? transqty;
  final String? transnou;
  final String? transdimn;
  final String? transedimn;
  final String? transdate;
  final String? accnou;
  final String? accqty;
  final String? acclocid;
  final String? acclocdesc;
  final String? rejnou;
  final String? rejqty;
  final String? rejlocid;
  final String? rejlocdesc;
  final String? reworknou;
  final String? reworkqty;
  final String? reworklocid;
  final String? reworklocdesc;
  final String? qcstatus;
  final String? projid;
  final String? projno;
  final String? prodnlineid;
  final String? pfmid;
  final String? docorgstruid;
  final String? qcmenuid;

  factory Qc.fromJson(Map<String, dynamic> json){
    return Qc(
      qctid: json["QCTID"],
      qcmid: json["QCMID"],
      qcdocid: json["QCDOCID"],
      wono: json["WONO"],
      parentwono: json["PARENTWONO"],
      flocid: json["FLOCID"],
      flocdesc: json["FLOCDESC"],
      qcdate: json["QCDATE"],
      omid: json["OMID"],
      odocid: json["ODOCID"],
      otid: json["OTID"],
      rtid: json["TID"],
      itemid: json["ITEMID"],
      itemcode: json["ITEMCODE"],
      itemdesc: json["ITEMDESC"],
      uomid: json["UOMID"],
      oprnid: json["OPRNID"],
      transqty: json["TRANSQTY"],
      transnou: json["TRANSNOU"],
      transdimn: json["TRANSDIMN"],
      transedimn: json["TRANSEDIMN"],
      transdate: json["TRANSDATE"],
      accnou: json["ACCNOU"],
      accqty: json["ACCQTY"],
      acclocid: json["ACCLOCID"],
      acclocdesc: json["ACCLOCDESC"],
      rejnou: json["REJNOU"],
      rejqty: json["REJQTY"],
      rejlocid: json["REJLOCID"],
      rejlocdesc: json["REJLOCDESC"],
      reworknou: json["REWORKNOU"],
      reworkqty: json["REWORKQTY"],
      reworklocid: json["REWORKLOCID"],
      reworklocdesc: json["REWORKLOCDESC"],
      qcstatus: json["QCSTATUS"],
      projid: json["PROJID"],
      projno: json["PROJNO"],
      prodnlineid: json["PRODNLINEID"],
      pfmid: json["PFMID"],
      docorgstruid: json["DOCORGSTRUID"],
      qcmenuid: json["QCMENUID"],
    );
  }

  Map<String, dynamic> toJson() => {
    "QCTID": qctid,
    "QCMID": qcmid,
    "QCDOCID": qcdocid,
    "WONO": wono,
    "PARENTWONO": parentwono,
    "FLOCID": flocid,
    "FLOCDESC": flocdesc,
    "QCDATE": qcdate,
    "OMID": omid,
    "ODOCID": odocid,
    "OTID": otid,
    "RTID": rtid,
    "ITEMID": itemid,
    "ITEMCODE": itemcode,
    "ITEMDESC": itemdesc,
    "UOMID": uomid,
    "OPRNID": oprnid,
    "TRANSQTY": transqty,
    "TRANSNOU": transnou,
    "TRANSDIMN": transdimn,
    "TRANSEDIMN": transedimn,
    "TRANSDATE": transdate,
    "ACCNOU": accnou,
    "ACCQTY": accqty,
    "ACCLOCID": acclocid,
    "ACCLOCDESC": acclocdesc,
    "REJNOU": rejnou,
    "REJQTY": rejqty,
    "REJLOCID": rejlocid,
    "REJLOCDESC": rejlocdesc,
    "REWORKNOU": reworknou,
    "REWORKQTY": reworkqty,
    "REWORKLOCID": reworklocid,
    "REWORKLOCDESC": reworklocdesc,
    "QCSTATUS": qcstatus,
    "PROJID": projid,
    "PROJNO": projno,
    "PRODNLINEID": prodnlineid,
    "PFMID": pfmid,
    "DOCORGSTRUID": docorgstruid,
    "QCMENUID": qcmenuid,
  };

}
