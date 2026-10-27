import 'dart:convert';


class CustomerNameModel {
  int? sLID;
  String? sLCODE;
  String? sLDESC;

  CustomerNameModel({
    this.sLID,
    this.sLCODE,
    this.sLDESC,
  });

  // Convert a SalesExecutiveSpinnerModel into a Map.
  Map<String, dynamic> toMap() {
    return {
      'sLID': sLID,
      'sLCODE': sLCODE,
      'sLDESC': sLDESC,
    };
  }

  // Create a SalesExecutiveSpinnerModel from a Map.
  factory CustomerNameModel.fromMap(Map<String, dynamic> map) {
    return CustomerNameModel(
      sLID: map['sLID'] ?? '',
      sLCODE: map['sLCODE'] ?? '',
      sLDESC: map['sLDESC'] ?? '',
    );
  }

  // Convert the model to JSON.
  String? toJson() => json.encode(toMap());

  // Create a SalesExecutiveSpinnerModel from JSON.
  factory CustomerNameModel.fromJson(String source) =>
      CustomerNameModel.fromMap(json.decode(source));
}
