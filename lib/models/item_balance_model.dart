import 'dart:convert';

class ItemBalanceModel {

  String? iTEMID;
  String? lOCID;
  String? lOCCODE;

  String? lOCDESC;
  String? iTEMCODE;
  String? CLOSEBAL;
  String? ORGSTRUCID;




  ItemBalanceModel({


    this.iTEMID,
    this.lOCID,
    this.lOCCODE,
    // this.mRP = MRP;
    this.lOCDESC ,
    this.iTEMCODE ,
    this.CLOSEBAL,
    this.ORGSTRUCID,

  });

  // Convert a Breed into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'iTEMID': iTEMID,
      'lOCID': lOCID,
      'lOCCODE': lOCCODE,
      'lOCDESC': lOCDESC,
      'iTEMCODE': iTEMCODE,

      'CLOSEBAL': CLOSEBAL,
      'ORGSTRUCID': ORGSTRUCID,


    };
  }

  factory ItemBalanceModel.fromMap(Map<String, dynamic> map) {
    return ItemBalanceModel(
      iTEMID: map['iTEMID'] ?? '',
      lOCID: map['lOCID'] ?? '',
      lOCCODE: map['lOCCODE'] ?? '',
      lOCDESC: map['lOCDESC'] ?? '',
      iTEMCODE: map['iTEMCODE'] ?? '',
      CLOSEBAL: map['CLOSEBAL'] ?? '',
      ORGSTRUCID: map['ORGSTRUCID'] ?? '',


    );
  }

  String? toJson() => json.encode(toMap());

  factory ItemBalanceModel.fromJson(String source) =>
      ItemBalanceModel.fromMap(json.decode(source));


}