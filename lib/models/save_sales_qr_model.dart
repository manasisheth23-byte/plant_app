class SaveSalesQrScan {
  DATA? dATA;

  SaveSalesQrScan({this.dATA});

  SaveSalesQrScan.fromJson(Map<String, dynamic> json) {
    dATA = json['DATA'] != null ? DATA.fromJson(json['DATA']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (dATA != null) {
      data['DATA'] = dATA!.toJson();
    }
    return data;
  }
}

class DATA {
  String? status;
  String? message;
  SYSMSGS? sYSMSGS;

  DATA({
    this.status,
    this.message,
    this.sYSMSGS,
  });

  DATA.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
    sYSMSGS =
    json['SYSMSGS'] != null ? SYSMSGS.fromJson(json['SYSMSGS']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Message': message,
      'SYSMSGS': sYSMSGS?.toJson(),
    };
  }
}

class SYSMSGS {
  String? iD;
  String? eRRORMSGS;
  String? tYPE;
  String? tITLE;

  SYSMSGS({
    this.iD,
    this.eRRORMSGS,
    this.tYPE,
    this.tITLE,
  });

  SYSMSGS.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    eRRORMSGS = json['ERRORMSGS'];
    tYPE = json['TYPE'];
    tITLE = json['TITLE'];
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': iD,
      'ERRORMSGS': eRRORMSGS,
      'TYPE': tYPE,
      'TITLE': tITLE,
    };
  }
}