class WebViewModel {
  SOLDETAILS? sOLDETAILS;

  WebViewModel({this.sOLDETAILS});

  WebViewModel.fromJson(Map<String, dynamic> json) {
    sOLDETAILS = json['SOLDETAILS'] != null
        ? new SOLDETAILS.fromJson(json['SOLDETAILS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sOLDETAILS != null) {
      data['SOLDETAILS'] = this.sOLDETAILS!.toJson();
    }
    return data;
  }
}

class SOLDETAILS {
  List<SOLUTIONS>? sOLUTIONS;

  SOLDETAILS({this.sOLUTIONS});

  SOLDETAILS.fromJson(Map<String, dynamic> json) {
    if (json['SOLUTIONS'] != null) {
      sOLUTIONS = <SOLUTIONS>[];
      json['SOLUTIONS'].forEach((v) {
        sOLUTIONS!.add(new SOLUTIONS.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sOLUTIONS != null) {
      data['SOLUTIONS'] = this.sOLUTIONS!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SOLUTIONS {
  String? sOLFOLID;
  String? sOLID;
  String? tITLE;
  String? sOLUTIONTYPEDESC;
  String? sOLUTIONSTATUSDESC;
  String? dATE;
  String? dESCRIPTION;
  String? lIKES;
  String? dISLIKES;

  SOLUTIONS(
      {this.sOLFOLID,
      this.sOLID,
      this.tITLE,
      this.sOLUTIONTYPEDESC,
      this.sOLUTIONSTATUSDESC,
      this.dATE,
      this.dESCRIPTION,
      this.lIKES,
      this.dISLIKES});

  SOLUTIONS.fromJson(Map<String, dynamic> json) {
    sOLFOLID = json['SOLFOLID'];
    sOLID = json['SOLID'];
    tITLE = json['TITLE'];
    sOLUTIONTYPEDESC = json['SOLUTIONTYPEDESC'];
    sOLUTIONSTATUSDESC = json['SOLUTIONSTATUSDESC'];
    dATE = json['DATE'];
    dESCRIPTION = json['DESCRIPTION'];
    lIKES = json['LIKES'];
    dISLIKES = json['DISLIKES'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SOLFOLID'] = this.sOLFOLID;
    data['SOLID'] = this.sOLID;
    data['TITLE'] = this.tITLE;
    data['SOLUTIONTYPEDESC'] = this.sOLUTIONTYPEDESC;
    data['SOLUTIONSTATUSDESC'] = this.sOLUTIONSTATUSDESC;
    data['DATE'] = this.dATE;
    data['DESCRIPTION'] = this.dESCRIPTION;
    data['LIKES'] = this.lIKES;
    data['DISLIKES'] = this.dISLIKES;
    return data;
  }
}
