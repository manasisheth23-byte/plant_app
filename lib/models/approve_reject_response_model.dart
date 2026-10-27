class ApproveRejectResponseModel {
  ApproveRejectResponseModel({
    required this.data,
  });

  final Data? data;

  factory ApproveRejectResponseModel.fromJson(Map<String, dynamic> json){
    return ApproveRejectResponseModel(
      data: json["DATA"] == null ? null : Data.fromJson(json["DATA"]),
    );
  }

}

class Data {
  Data({
    required this.id,
    required this.status,
    required this.errormsgs,
    required this.type,
    required this.title,
  });

  final String? id;
  final String? status;
  final String? errormsgs;
  final String? type;
  final String? title;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      id: json["ID"],
      status: json["Status"],
      errormsgs: json["ERRORMSGS"],
      type: json["TYPE"],
      title: json["TITLE"],
    );
  }

}
