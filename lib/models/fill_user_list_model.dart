class FillUserListModel {
  DATA? dATA;

  FillUserListModel({this.dATA});

  FillUserListModel.fromJson(Map<String, dynamic> json) {
    dATA = json['DATA'] != null ? new DATA.fromJson(json['DATA']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dATA != null) {
      data['DATA'] = this.dATA!.toJson();
    }
    return data;
  }
}

class DATA {
  String? status;
  String? message;
  List<LISTUSER>? lIST;

  DATA({this.status, this.message, this.lIST});

  DATA.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
    if (json['LIST'] != null) {
      lIST = <LISTUSER>[];
      json['LIST'].forEach((v) {
        lIST!.add(new LISTUSER.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Message'] = this.message;
    if (this.lIST != null) {
      data['LIST'] = this.lIST!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LISTUSER {
  String? uSERID;
  String? uSERNAME;
  String? lOGINID;
  String? uTYPEID;
  String? tMZONEID;
  String? iSACTIVE;

  LISTUSER(
      {this.uSERID,
        this.uSERNAME,
        this.lOGINID,
        this.uTYPEID,
        this.tMZONEID,
        this.iSACTIVE});

  LISTUSER.fromJson(Map<String, dynamic> json) {
    uSERID = json['USERID'];
    uSERNAME = json['USERNAME'];
    lOGINID = json['LOGINID'];
    uTYPEID = json['UTYPEID'];
    tMZONEID = json['TMZONEID'];
    iSACTIVE = json['ISACTIVE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['USERID'] = this.uSERID;
    data['USERNAME'] = this.uSERNAME;
    data['LOGINID'] = this.lOGINID;
    data['UTYPEID'] = this.uTYPEID;
    data['TMZONEID'] = this.tMZONEID;
    data['ISACTIVE'] = this.iSACTIVE;
    return data;
  }
}
