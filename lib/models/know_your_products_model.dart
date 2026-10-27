class KnowYourProductsModel {
  CATEGORY? cATEGORY;

  KnowYourProductsModel({this.cATEGORY});

  KnowYourProductsModel.fromJson(Map<String, dynamic> json) {
    cATEGORY = json['CATEGORY'] != null
        ? new CATEGORY.fromJson(json['CATEGORY'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cATEGORY != null) {
      data['CATEGORY'] = this.cATEGORY!.toJson();
    }
    return data;
  }
}

class CATEGORY {
  List<SOLCAR>? sOLCAR;

  CATEGORY({this.sOLCAR});

  CATEGORY.fromJson(Map<String, dynamic> json) {
    if (json['SOLCAR'] != null) {
      sOLCAR = <SOLCAR>[];
      json['SOLCAR'].forEach((v) {
        sOLCAR!.add(new SOLCAR.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sOLCAR != null) {
      data['SOLCAR'] = this.sOLCAR!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SOLCAR {
  String? sOLCATID;
  String? cATNAME;
  String? sFNT;
  List<SOLFOLDER>? sOLFOLDER;

  SOLCAR({this.sOLCATID, this.cATNAME, this.sFNT, this.sOLFOLDER});

  SOLCAR.fromJson(Map<String, dynamic> json) {
    sOLCATID = json['SOLCATID'];
    cATNAME = json['CATNAME'];
    sFNT = json['SFNT'];
    if (json['SOLFOLDER'] != null) {
      sOLFOLDER = <SOLFOLDER>[];
      json['SOLFOLDER'].forEach((v) {
        sOLFOLDER!.add(new SOLFOLDER.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SOLCATID'] = this.sOLCATID;
    data['CATNAME'] = this.cATNAME;
    data['SFNT'] = this.sFNT;
    if (this.sOLFOLDER != null) {
      data['SOLFOLDER'] = this.sOLFOLDER!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SOLFOLDER {
  String? sOLFOLID;
  String? nAME;
  String? sCNT;
  List<SOLUTIONS>? sOLUTIONS;

  SOLFOLDER({this.sOLFOLID, this.nAME, this.sCNT, this.sOLUTIONS});

  SOLFOLDER.fromJson(Map<String, dynamic> json) {
    sOLFOLID = json['SOLFOLID'];
    nAME = json['NAME'];
    sCNT = json['SCNT'];
    if (json['SOLUTIONS'] != null) {
      sOLUTIONS = <SOLUTIONS>[];
      json['SOLUTIONS'].forEach((v) {
        sOLUTIONS!.add(new SOLUTIONS.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SOLFOLID'] = this.sOLFOLID;
    data['NAME'] = this.nAME;
    data['SCNT'] = this.sCNT;
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

  SOLUTIONS({this.sOLFOLID, this.sOLID, this.tITLE});

  SOLUTIONS.fromJson(Map<String, dynamic> json) {
    sOLFOLID = json['SOLFOLID'];
    sOLID = json['SOLID'];
    tITLE = json['TITLE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SOLFOLID'] = this.sOLFOLID;
    data['SOLID'] = this.sOLID;
    data['TITLE'] = this.tITLE;
    return data;
  }
}
