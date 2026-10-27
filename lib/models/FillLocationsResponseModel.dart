class FillLocationsResponseModel {
  FillLocationsResponseModel({
     this.data,
  });

   Data? data;
  FillLocationsResponseModel.withError(String errorValue) {
    var error = errorValue;
  }
  factory FillLocationsResponseModel.fromJson(Map<String, dynamic> json){
    return FillLocationsResponseModel(
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

  final List<ListElementLocation> list;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      list: json["LIST"] == null ? [] : List<ListElementLocation>.from(json["LIST"]!.map((x) => ListElementLocation.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "LIST": list.map((x) => x?.toJson()).toList(),
  };

}

class ListElementLocation {
  ListElementLocation({
    required this.locid,
    required this.loccode,
    required this.locdesc,
  });

  final String? locid;
  final String? loccode;
  final String? locdesc;

  factory ListElementLocation.fromJson(Map<String, dynamic> json){
    return ListElementLocation(
      locid: json["LOCID"],
      loccode: json["LOCCODE"],
      locdesc: json["LOCDESC"],
    );
  }

  Map<String, dynamic> toJson() => {
    "LOCID": locid,
    "LOCCODE": loccode,
    "LOCDESC": locdesc,
  };

}
