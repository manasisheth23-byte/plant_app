class GetBiPageSheetResponseModel {
  GetBiPageSheetResponseModel({
     this.data,
  });

   Data? data;
  GetBiPageSheetResponseModel.withError(String errorValue)
  {
    var error = errorValue;

  }
  factory GetBiPageSheetResponseModel.fromJson(Map<String, dynamic> json){
    return GetBiPageSheetResponseModel(
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
    required this.pagesheetid,
    required this.description,
    required this.entrydate,
  });

  final String? pagesheetid;
  final String? description;
  final String? entrydate;

  factory ListElement.fromJson(Map<String, dynamic> json){
    return ListElement(
      pagesheetid: json["PAGESHEETID"],
      description: json["DESCRIPTION"],
      entrydate: json["ENTRYDATE"],
    );
  }

  Map<String, dynamic> toJson() => {
    "PAGESHEETID": pagesheetid,
    "DESCRIPTION": description,
    "ENTRYDATE": entrydate,
  };

}
