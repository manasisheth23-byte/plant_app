class NotificationDetailResponse {
  final List<Detail> details;

  NotificationDetailResponse({required this.details});

  factory NotificationDetailResponse.fromJson(Map<String, dynamic> json) {
    // Navigate safely through nested JSON
    final spXml = json["SPXML"];
    if (spXml == null || spXml["NOTIFICATIONDETAILS"] == null) {
      return NotificationDetailResponse(details: []);
    }

    final detailsJson = spXml["NOTIFICATIONDETAILS"];
    if (detailsJson is List && detailsJson.isNotEmpty) {
      final list = detailsJson[0]["DETAILS"] as List? ?? [];
      return NotificationDetailResponse(
        details: list.map((e) => Detail.fromJson(e)).toList(),
      );
    }

    return NotificationDetailResponse(details: []);
  }
}

class Detail {
  final String mid;
  final List<DataField> data;

  Detail({required this.mid, required this.data});

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      mid: json["MID"]?.toString() ?? "", // ✅ safe parsing
      data: (json["DATA"] as List? ?? [])
          .map((e) => DataField.fromJson(e))
          .toList(),
    );
  }
}

class DataField {
  final String columnName;
  final String values;

  DataField({required this.columnName, required this.values});

  factory DataField.fromJson(Map<String, dynamic> json) {
    return DataField(
      columnName: json["COLUMNNAME"]?.toString() ?? "",
      values: json["VALUES"]?.toString() ?? "",
    );
  }
}
