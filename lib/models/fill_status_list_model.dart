class FillStatusListModel {
  DATA? dATA;

  FillStatusListModel({this.dATA});

  FillStatusListModel.fromJson(Map<String, dynamic> json) {
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
  List<LISTSTATUS>? lIST;

  DATA({this.lIST});

  DATA.fromJson(Map<String, dynamic> json) {
    if (json['LIST'] != null) {
      lIST = <LISTSTATUS>[];
      json['LIST'].forEach((v) {
        lIST!.add(new LISTSTATUS.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lIST != null) {
      data['LIST'] = this.lIST!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LISTSTATUS {
  String? statusid;
  String? name;
  String? tYPEID;
  String? eXTRA;
  String? sEQ;

  LISTSTATUS({this.statusid, this.name, this.tYPEID, this.eXTRA, this.sEQ});

  LISTSTATUS.fromJson(Map<String, dynamic> json) {
    statusid = json['statusid'];
    name = json['name'];
    tYPEID = json['TYPEID'];
    eXTRA = json['EXTRA'];
    sEQ = json['SEQ'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusid'] = this.statusid;
    data['name'] = this.name;
    data['TYPEID'] = this.tYPEID;
    data['EXTRA'] = this.eXTRA;
    data['SEQ'] = this.sEQ;
    return data;
  }
}
