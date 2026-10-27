import 'dart:convert';


class InventoryListModel {

  int? iTEMID;
   String? iTEMCODE;
   String? iTEMDESC;

   String? uOMCODE;
   String? uOMDESC;
   String? sUBGROUP;
   String? mAINGROUP;
   String? pLANT;
   String? iTEMTYPE;
   String? cURRENCY;
   String?  iNSTOCKQTY;
   String? uNITPRICE;




  InventoryListModel({


    this.iTEMID,
    this.iTEMCODE,
    this.iTEMDESC,
    // this.mRP = MRP;
    this.uOMCODE ,
    this.uOMDESC ,
    this.sUBGROUP,
    this.mAINGROUP,
    this.pLANT,
    this.iTEMTYPE,
    this.cURRENCY,
    this.iNSTOCKQTY ,
    this.uNITPRICE ,

  });

  // Convert a Breed into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'iTEMID': iTEMID,
      'iTEMCODE': iTEMCODE,
      'iTEMDESC': iTEMDESC,
      'sUBGROUP': sUBGROUP,
      'mAINGROUP': mAINGROUP,

      'pLANT': pLANT,
      'iTEMTYPE': iTEMTYPE,
      'cURRENCY': cURRENCY,
      'iNSTOCKQTY': iNSTOCKQTY,
      'uNITPRICE': uNITPRICE,


    };
  }

  factory InventoryListModel.fromMap(Map<String, dynamic> map) {
    return InventoryListModel(
      iTEMID: map['iTEMID'] ?? '',
      iTEMCODE: map['iTEMCODE'] ?? '',
      iTEMDESC: map['iTEMDESC'] ?? '',
      sUBGROUP: map['sUBGROUP'] ?? '',
      mAINGROUP: map['mAINGROUP'] ?? '',
      pLANT: map['pLANT'] ?? '',
      iTEMTYPE: map['iTEMTYPE'] ?? '',
      cURRENCY: map['cURRENCY'] ?? '',
      iNSTOCKQTY: map['iNSTOCKQTY'] ?? '',
      uNITPRICE: map['uNITPRICE'] ?? '',


    );
  }

  String? toJson() => json.encode(toMap());

  factory InventoryListModel.fromJson(String source) =>
      InventoryListModel.fromMap(json.decode(source));


}