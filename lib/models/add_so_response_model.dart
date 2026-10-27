class AddSoResponseModel {
  AddSoResponseModel({
    required this.sysmsgs,
  });

  final Sysmsgs? sysmsgs;

  factory AddSoResponseModel.fromJson(Map<String, dynamic> json){
    return AddSoResponseModel(
      sysmsgs: json["SYSMSGS"] == null ? null : Sysmsgs.fromJson(json["SYSMSGS"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "SYSMSGS": sysmsgs?.toJson(),
  };

}

class Sysmsgs {
  Sysmsgs({
    required this.id,
    required this.soid,
    required this.isdelete,
    required this.lastupdateddate,
    required this.translist,
    required this.errormsgs,
    required this.type,
    required this.title,
  });

  final String? id;
  final String? soid;
  final String? isdelete;
  final String? lastupdateddate;
  final Translist? translist;
  final String? errormsgs;
  final String? type;
  final String? title;

  factory Sysmsgs.fromJson(Map<String, dynamic> json){
    return Sysmsgs(
      id: json["ID"],
      soid: json["SOID"],
      isdelete: json["ISDELETE"],
      lastupdateddate: json["LASTUPDATEDDATE"],
      translist: json["TRANSLIST"] == null ? null : Translist.fromJson(json["TRANSLIST"]),
      errormsgs: json["ERRORMSGS"],
      type: json["TYPE"],
      title: json["TITLE"],
    );
  }

  Map<String, dynamic> toJson() => {
    "ID": id,
    "SOID": soid,
    "ISDELETE": isdelete,
    "LASTUPDATEDDATE": lastupdateddate,
    "TRANSLIST": translist?.toJson(),
    "ERRORMSGS": errormsgs,
    "TYPE": type,
    "TITLE": title,
  };

}

class Translist {
  Translist({required this.json});
  final Map<String,dynamic> json;

  factory Translist.fromJson(Map<String, dynamic> json){
    return Translist(
        json: json
    );
  }

  Map<String, dynamic> toJson() => {
  };

}
