import 'dart:convert';


class BussinessPartnersListModel {

  String? sLID;
  String? sLCODE;
  String? sLDESC;
  String? sLTYPE;
  String? aDDRESS;
  String? eMAIL;
  String? pHONE;
  String? mBOILE;
  String? vENDORCODE;
  String? cITY;
  String? sALESPERSON;
  String? cONTACTPERSON;
  String? cURRENCY;
  String? cREDITACCOUNTDETAIL;
  String? fAX;
  String? CONTACTPERSON_MOBILE;
  String? CONTACTPERSON_NAME;
  String? CONTACTPERSON_DESIGNATION;
  String? CONTACTPERSON_FAX;
  String? CONTACTPERSON_EMAIL;
  BussinessPartnersListModel({
    this.sLID,
    this.sLCODE,
    this.sLDESC,
    this.sLTYPE,
    this.aDDRESS,
    this.eMAIL,
    this.pHONE,
    this.mBOILE,
    this.vENDORCODE,
    this.cITY,
    this.sALESPERSON,
    this.cONTACTPERSON,
    this.cURRENCY,
    this.cREDITACCOUNTDETAIL,
    this.fAX,
    this.CONTACTPERSON_MOBILE,
    this.CONTACTPERSON_DESIGNATION,
    this.CONTACTPERSON_FAX,
    this.CONTACTPERSON_EMAIL});


  Map<String, dynamic> toMap() {
    return {
      'sLID': sLID,
      'sLCODE': sLCODE,
      'sLDESC': sLDESC,
      'sLTYPE': sLTYPE,
      'aDDRESS': aDDRESS,

      'eMAIL': eMAIL,
      'pHONE': pHONE,
      'mBOILE': mBOILE,
      'vENDORCODE': vENDORCODE,
      'cITY': cITY,
      'sALESPERSON': sALESPERSON,
      'cONTACTPERSON': cONTACTPERSON,
      'cURRENCY': cURRENCY,
      'cREDITACCOUNTDETAIL': cREDITACCOUNTDETAIL,
      'fAX': fAX,
      'CONTACTPERSON_MOBILE': CONTACTPERSON_MOBILE,
      'CONTACTPERSON_DESIGNATION': CONTACTPERSON_DESIGNATION,
      'CONTACTPERSON_FAX': CONTACTPERSON_FAX,
      'CONTACTPERSON_EMAIL': CONTACTPERSON_EMAIL,
    };
  }

  factory BussinessPartnersListModel.fromMap(Map<String, dynamic> map) {
    return BussinessPartnersListModel(
      sLID : map['SLID'].toString() ?? '',
      sLCODE : map['SLCODE'] ?? '',
      sLDESC : map['SLDESC'] ?? '',
      sLTYPE : map['SLTYPE'] ?? '',
      aDDRESS : map['ADDRESS'] ?? '',
      eMAIL : map['EMAIL'] ?? '',
      pHONE : map['PHONE'] ?? '',
      mBOILE : map['MOBILE'] ?? '',
      vENDORCODE : map['VENDORCODE'] ?? '',
      cITY : map['CITY'] ?? '',
      cONTACTPERSON : map['CONTACTPERSON'] ?? ''
    );
  }






}