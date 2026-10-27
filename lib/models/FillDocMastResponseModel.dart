class FillDocMastResponseModel {
  FillDocMastResponseModel({
    required this.data,
  });

   Data? data;
  FillDocMastResponseModel.withError(String errorValue) {
    var error = errorValue;
  }
  factory FillDocMastResponseModel.fromJson(Map<String, dynamic> json){
    return FillDocMastResponseModel(
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

  final List<ListElementDocMast> list;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      list: json["LIST"] == null ? [] : List<ListElementDocMast>.from(json["LIST"]!.map((x) => ListElementDocMast.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "LIST": list.map((x) => x?.toJson()).toList(),
  };

}

class ListElementDocMast {
  ListElementDocMast({
    required this.docid,
    required this.invctype,
    required this.docmastdesc,
  });

  final String? docid;
  final String? invctype;
  final String? docmastdesc;

  factory ListElementDocMast.fromJson(Map<String, dynamic> json){
    return ListElementDocMast(
      docid: json["DOCID"],
      invctype: json["INVCTYPE"],
      docmastdesc: json["DOCMASTDESC"],
    );
  }

  Map<String, dynamic> toJson() => {
    "DOCID": docid,
    "INVCTYPE": invctype,
    "DOCMASTDESC": docmastdesc,
  };

}
