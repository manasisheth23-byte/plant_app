class FillStatusListResponseModel {
  FillStatusListResponseModel({
    required this.data,
  });

   Data? data;
  FillStatusListResponseModel.withError(String errorValue) {
    var error = errorValue;
  }
  factory FillStatusListResponseModel.fromJson(Map<String, dynamic> json){
    return FillStatusListResponseModel(
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

  final List<ListElementStatus> list;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      list: json["LIST"] == null ? [] : List<ListElementStatus>.from(json["LIST"]!.map((x) => ListElementStatus.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "LIST": list.map((x) => x?.toJson()).toList(),
  };

}

class ListElementStatus {
  ListElementStatus({
    required this.statusid,
    required this.name,
    required this.typeid,
    required this.extra,
    required this.seq,
  });

  final String? statusid;
  final String? name;
  final String? typeid;
  final String? extra;
  final String? seq;

  factory ListElementStatus.fromJson(Map<String, dynamic> json){
    return ListElementStatus(
      statusid: json["statusid"],
      name: json["name"],
      typeid: json["TYPEID"],
      extra: json["EXTRA"],
      seq: json["SEQ"],
    );
  }

  Map<String, dynamic> toJson() => {
    "statusid": statusid,
    "name": name,
    "TYPEID": typeid,
    "EXTRA": extra,
    "SEQ": seq,
  };

}
