class AddActivityResponseModel {
  AddActivityResponseModel({
    required this.sysmsgs,
  });

  final Sysmsgs? sysmsgs;

  factory AddActivityResponseModel.fromJson(Map<String, dynamic> json){
    return AddActivityResponseModel(
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
    required this.errormsgs,
    required this.type,
    required this.title,
  });

  final String? id;
  final String? errormsgs;
  final String? type;
  final String? title;

  factory Sysmsgs.fromJson(Map<String, dynamic> json){
    return Sysmsgs(
      id: json["ID"],
      errormsgs: json["ERRORMSGS"],
      type: json["TYPE"],
      title: json["TITLE"],
    );
  }

  Map<String, dynamic> toJson() => {
    "ID": id,
    "ERRORMSGS": errormsgs,
    "TYPE": type,
    "TITLE": title,
  };

}
