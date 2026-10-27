import 'activity_request_model.dart';

class ActivityTaskRequestModel {
  XMLFILETaskACTIVITY? xMLFILE;

  ActivityTaskRequestModel({this.xMLFILE});

  ActivityTaskRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILETaskACTIVITY.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}
class XMLFILETaskACTIVITY {
  String? aCTIVITYID;
  String? dESC;
  String? fLAG;
  String? oRGSTRUCTID;
  String? pOSID;
  String? tOKEN;
  String? uSERID;
  String? controlno;

  XMLFILETaskACTIVITY(
      {this.aCTIVITYID,
        this.dESC,
        this.fLAG,
        this.oRGSTRUCTID,
        this.pOSID,
        this.tOKEN,
        this.uSERID,
      this.controlno,});

  XMLFILETaskACTIVITY.fromJson(Map<String, dynamic> json) {
    aCTIVITYID = json['ACTIVITYID'];
    dESC = json['DESC'];
    fLAG = json['FLAG'];
    oRGSTRUCTID = json['ORGSTRUCTID'];
    pOSID = json['POSID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
    controlno = json['CONTROLNO '];

  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ACTIVITYID'] = this.aCTIVITYID;
    data['DESC'] = this.dESC;
    data['FLAG'] = this.fLAG;
    data['ORGSTRUCTID'] = this.oRGSTRUCTID;
    data['POSID'] = this.pOSID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    data['CONTROLNO '] = this.controlno;
    return data;
  }
}

