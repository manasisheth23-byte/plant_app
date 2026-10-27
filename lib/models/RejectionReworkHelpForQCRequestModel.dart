class RejectionReworkHelpForQCRequestModel {
  XMLFILEREJECTIONQC? xMLFILE;

  RejectionReworkHelpForQCRequestModel({this.xMLFILE});

  RejectionReworkHelpForQCRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEREJECTIONQC.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEREJECTIONQC {
  String? dOCID;
  String? fLAG;
  String? oRGSTRUCID;
  String? pRODLINEID;
  String? qCMID;
  String? qCTID;
  String? tOKEN;
  String? uSERID;

  XMLFILEREJECTIONQC(
      {this.dOCID,
        this.fLAG,
        this.oRGSTRUCID,
        this.pRODLINEID,
        this.qCMID,
        this.qCTID,
        this.tOKEN,
        this.uSERID});

  XMLFILEREJECTIONQC.fromJson(Map<String, dynamic> json) {
    dOCID = json['DOCID'];
    fLAG = json['FLAG'];
    oRGSTRUCID = json['ORGSTRUCID'];
    pRODLINEID = json['PRODLINEID'];
    qCMID = json['QCMID'];
    qCTID = json['QCTID'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DOCID'] = this.dOCID;
    data['FLAG'] = this.fLAG;
    data['ORGSTRUCID'] = this.oRGSTRUCID;
    data['PRODLINEID'] = this.pRODLINEID;
    data['QCMID'] = this.qCMID;
    data['QCTID'] = this.qCTID;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
