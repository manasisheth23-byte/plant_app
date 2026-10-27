import 'dart:convert';

class SalesExicutiveUserMast {
  int? USERID;
  String? USERNAME;

  SalesExicutiveUserMast({
    this.USERID,
    this.USERNAME,
  });

  // Convert a CustomerNameSpinnerModel into a Map.
  Map<String, dynamic> toMap() {
    return {
      'USERID': USERID,
      'USERNAME': USERNAME,
    };
  }

  // Create a CustomerNameSpinnerModel from a Map.
  factory SalesExicutiveUserMast.fromMap(Map<String, dynamic> map) {
    return SalesExicutiveUserMast(
      USERID: map['USERID'] ?? '',
      USERNAME: map['USERNAME'] ?? '',
    );
  }

  // Convert the model to JSON.
  String? toJson() => json.encode(toMap());

  // Create a CustomerNameSpinnerModel from JSON.
  factory SalesExicutiveUserMast.fromJson(String source) =>
      SalesExicutiveUserMast.fromMap(json.decode(source));
}
