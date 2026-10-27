class GetApproveHistoryResponseModel {
  GetApproveHistoryResponseModel({
     this.data,
  });

   Data? data;

  factory GetApproveHistoryResponseModel.fromJson(Map<String, dynamic> json){
    return GetApproveHistoryResponseModel(
      data: json["DATA"] == null ? null : Data.fromJson(json["DATA"]),
    );
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

}

class ListElement {
  ListElement({
    required this.releasecount,
    required this.sublist,
  });

  final String? releasecount;
  final List<Sublist> sublist;

  factory ListElement.fromJson(Map<String, dynamic> json){
    return ListElement(
      releasecount: json["RELEASECOUNT"],
      sublist: json["SUBLIST"] == null ? [] : List<Sublist>.from(json["SUBLIST"]!.map((x) => Sublist.fromJson(x))),
    );
  }

}

class Sublist {
  Sublist({
    required this.id,
    required this.mid,
    required this.docid,
    required this.docdesc,
    required this.menuid,
    required this.menuname,
    required this.remarks,
    required this.approvedby,
    required this.approvername,
    required this.approvedon,
    required this.approvedposid,
    required this.approverposition,
    required this.approvedorgstrucid,
    required this.orgstructdesc,
    required this.docwftid,
    required this.lvl,
    required this.invcnumb,
    required this.invcdate,
    required this.statusid,
    required this.approverstatus,
    required this.profileimg,
    required this.releasedBy,
    required this.releasedbyname,
    required this.releasedate,
    required this.releasecount,
    required this.name,
    required this.date,
  });

  final String? id;
  final String? mid;
  final String? docid;
  final String? docdesc;
  final String? menuid;
  final String? menuname;
  final String? remarks;
  final String? approvedby;
  final String? approvername;
  final DateTime? approvedon;
  final String? approvedposid;
  final String? approverposition;
  final String? approvedorgstrucid;
  final String? orgstructdesc;
  final String? docwftid;
  final String? lvl;
  final String? invcnumb;
  final DateTime? invcdate;
  final String? statusid;
  final String? approverstatus;
  final String? profileimg;
  final String? releasedBy;
  final String? releasedbyname;
  final DateTime? releasedate;
  final String? releasecount;
  final String? name;
  final String? date;

  factory Sublist.fromJson(Map<String, dynamic> json){
    return Sublist(
      id: json["ID"],
      mid: json["MID"],
      docid: json["DOCID"],
      docdesc: json["DOCDESC"],
      menuid: json["MENUID"],
      menuname: json["MENUNAME"],
      remarks: json["REMARKS"],
      approvedby: json["APPROVEDBY"],
      approvername: json["APPROVERNAME"],
      approvedon: DateTime.tryParse(json["APPROVEDON"] ?? ""),
      approvedposid: json["APPROVEDPOSID"],
      approverposition: json["APPROVERPOSITION"],
      approvedorgstrucid: json["APPROVEDORGSTRUCID"],
      orgstructdesc: json["ORGSTRUCTDESC"],
      docwftid: json["DOCWFTID"],
      lvl: json["LVL"],
      invcnumb: json["INVCNUMB"],
      invcdate: DateTime.tryParse(json["INVCDATE"] ?? ""),
      statusid: json["STATUSID"],
      approverstatus: json["APPROVERSTATUS"],
      profileimg: json["PROFILEIMG"],
      releasedBy: json["ReleasedBy"],
      releasedbyname: json["RELEASEDBYNAME"],
      releasedate: DateTime.tryParse(json["RELEASEDATE"] ?? ""),
      releasecount: json["RELEASECOUNT"],
      name: json["NAME"],
      date: json["DATE"],
    );
  }

}
