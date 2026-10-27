// Updated model with proper null-safety handling
import 'dart:convert';

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  LoginResponseModelData? data;
  String? error;

  // Main constructor
  LoginResponseModel({this.data, this.error});

  // Named constructor for error handling
  LoginResponseModel.withError(String errorMessage) {
    error = errorMessage;
  }

  // Factory for parsing from JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      data: json["DATA"] != null
          ? LoginResponseModelData.fromJson(json["DATA"])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    "DATA": data?.toJson(),
  };
}


class LoginResponseModelData {
  String status;
  String? message;
  String userid;
  String usertypeid;
  String usertype;
  String loginid;
  String username;
  String email;
  String imgdesc;
  String posid;
  String posdesc;
  String branchid;
  String branchcode;
  String branchname;
  String crmcustid;
  String crmcustcode;
  String crmcustname;
  String slid;
  String slcode;
  String sldesc;
  String buids;
  String orgstrucid;
  String orgdesc;
  String controlno;
  String finyeardesc;
  String sdate;
  String edate;
  String token;
  String mobilesync;
  String tokenCreatedOn;
  String tokenExpiresOn;
  String rfidflag;
  String timelogout;
  String shiftdate;
  String shiftdesc;
  Budetails? budetails;
  Positiondetails? positiondetails;
  Sodetails? sodetails;
  Menulist? menulist;
  String? BusinessType;
  String? eNABLEBIOMETRIC;
  String? ISVERIFIED;
  String? FORCEUPDATE;
  String? RESETDATA;
  String? KIOSKMODEID;
  String? KIOSKMODEDESC;
  String? MESSAGE;
  String? ISOTP;
  String? MOBILENO;

  LoginResponseModelData({
    required this.status,
    required this.message,
    required this.userid,
    required this.usertypeid,
    required this.usertype,
    required this.loginid,
    required this.username,
    required this.email,
    required this.imgdesc,
    required this.posid,
    required this.posdesc,
    required this.branchid,
    required this.branchcode,
    required this.branchname,
    required this.crmcustid,
    required this.crmcustcode,
    required this.crmcustname,
    required this.slid,
    required this.slcode,
    required this.sldesc,
    required this.buids,
    required this.orgstrucid,
    required this.orgdesc,
    required this.controlno,
    required this.finyeardesc,
    required this.sdate,
    required this.edate,
    required this.token,
    required this.mobilesync,
    required this.tokenCreatedOn,
    required this.tokenExpiresOn,
    required this.rfidflag,
    required this.timelogout,
    required this.shiftdate,
    required this.shiftdesc,
    required this.BusinessType,
    required this.eNABLEBIOMETRIC,
    required this.ISVERIFIED,
    required this.FORCEUPDATE,
    required this.RESETDATA,
    required this.KIOSKMODEID,
    required this.KIOSKMODEDESC,
    required  this.MESSAGE,
    required  this.ISOTP,
    required  this.MOBILENO,
    this.budetails,
    this.positiondetails,
    this.sodetails,
    this.menulist,

  });

  factory LoginResponseModelData.fromJson(Map<String, dynamic> json) =>
      LoginResponseModelData(
        status: json["Status"] ?? '',
        message: json["MESSAGE"]?? '',
        userid: json["USERID"] ?? '',
        usertypeid: json["USERTYPEID"] ?? '',
        usertype: json["USERTYPE"] ?? '',
        loginid: json["LOGINID"] ?? '',
        username: json["USERNAME"] ?? '',
        email: json["EMAIL"] ?? '',
        imgdesc: json["IMGDESC"] ?? '',
        posid: json["POSID"] ?? '',
        posdesc: json["POSDESC"] ?? '',
        branchid: json["BRANCHID"] ?? '',
        branchcode: json["BRANCHCODE"] ?? '',
        branchname: json["BRANCHNAME"] ?? '',
        crmcustid: json["CRMCUSTID"] ?? '',
        crmcustcode: json["CRMCUSTCODE"] ?? '',
        crmcustname: json["CRMCUSTNAME"] ?? '',
        slid: json["SLID"] ?? '',
        slcode: json["SLCODE"] ?? '',
        sldesc: json["SLDESC"] ?? '',
        buids: json["BUIDS"] ?? '',
        orgstrucid: json["ORGSTRUCID"] ?? '',
        orgdesc: json["ORGDESC"] ?? '',
        controlno: json["CONTROLNO"] ?? '',
        finyeardesc: json["FINYEARDESC"] ?? '',
        sdate: json["SDATE"] ?? '',
        edate: json["EDATE"] ?? '',
        token: json["TOKEN"] ?? '',
        mobilesync: json["MOBILESYNC"] ?? '',
        tokenCreatedOn: json["TokenCreatedOn"] ?? '',
        tokenExpiresOn: json["TokenExpiresOn"] ?? '',
        rfidflag: json["RFIDFLAG"] ?? '',
        timelogout: json["timelogout"] ?? '',
        shiftdate: json["SHIFTDATE"] ?? '',
        shiftdesc: json["SHIFTDESC"] ?? '',
        BusinessType: json['BusinessType'],


        eNABLEBIOMETRIC: json['ENABLEBIOMETRIC'],
        ISVERIFIED: json['ISVERIFIED'],
        FORCEUPDATE: json['FORCEUPDATE'],
        RESETDATA: json['RESETDATA'],
        KIOSKMODEID: json['KIOSKMODEID'],
        KIOSKMODEDESC: json['KIOSKMODEDESC'],
        MESSAGE: json['MESSAGE'],
        ISOTP: json['ISOTP'],
        MOBILENO: json['MOBILENO'],
        budetails: json["BUDETAILS"] != null && json["BUDETAILS"] is Map
            ? Budetails.fromJson(json["BUDETAILS"])
            : null,
        positiondetails: json["POSITIONDETAILS"] != null && json["POSITIONDETAILS"] is Map
            ? Positiondetails.fromJson(json["POSITIONDETAILS"])
            : null,
        sodetails: json["SODETAILS"] != null && json["SODETAILS"] is Map
            ? Sodetails.fromJson(json["SODETAILS"])
            : null,
        menulist: json["MENULIST"] != null && json["MENULIST"] is Map
            ? Menulist.fromJson(json["MENULIST"])
            : null,


      );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
    "USERID": userid,
    "USERTYPEID": usertypeid,
    "USERTYPE": usertype,
    "LOGINID": loginid,
    "USERNAME": username,
    "EMAIL": email,
    "IMGDESC": imgdesc,
    "POSID": posid,
    "POSDESC": posdesc,
    "BRANCHID": branchid,
    "BRANCHCODE": branchcode,
    "BRANCHNAME": branchname,
    "CRMCUSTID": crmcustid,
    "CRMCUSTCODE": crmcustcode,
    "CRMCUSTNAME": crmcustname,
    "SLID": slid,
    "SLCODE": slcode,
    "SLDESC": sldesc,
    "BUIDS": buids,
    "ORGSTRUCID": orgstrucid,
    "ORGDESC": orgdesc,
    "CONTROLNO": controlno,
    "FINYEARDESC": finyeardesc,
    "SDATE": sdate,
    "EDATE": edate,
    "TOKEN": token,
    "MOBILESYNC": mobilesync,
    "TokenCreatedOn": tokenCreatedOn,
    "TokenExpiresOn": tokenExpiresOn,
    "RFIDFLAG": rfidflag,
    "timelogout": timelogout,
    "SHIFTDATE": shiftdate,
    "SHIFTDESC": shiftdesc,
    "BusinessType": BusinessType,

    "ENABLEBIOMETRIC": eNABLEBIOMETRIC,

    "ISVERIFIED": ISVERIFIED,

    "FORCEUPDATE": FORCEUPDATE,

    "RESETDATA": RESETDATA,

    "KIOSKMODEID": KIOSKMODEID,
    "KIOSKMODEDESC": KIOSKMODEDESC,
    "MESSAGE": MESSAGE,
    "ISOTP": ISOTP,
    "MOBILENO": MOBILENO,
    "BUDETAILS": budetails?.toJson(),
    "POSITIONDETAILS": positiondetails?.toJson(),
    "SODETAILS": sodetails?.toJson(),
    "MENULIST": menulist?.toJson(),


  };
}


class Budetails {
  BudetailsData data;

  Budetails({
    required this.data,
  });

  factory Budetails.fromJson(Map<String, dynamic>? json) => Budetails(
    data: BudetailsData.fromJson(json!["DATA"]),
  );

  Map<String, dynamic> toJson() => {
    "DATA": data.toJson(),
  };
}

class BudetailsData {
  List<PurpleList> list;

  BudetailsData({
    required this.list,
  });

  factory BudetailsData.fromJson(Map<String, dynamic> json) => BudetailsData(
    list: json["LIST"] == null
        ? [] // Provide an empty list if json["LIST"] is null
        : List<PurpleList>.from(json["LIST"].map((x) => PurpleList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "LIST": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}


class PurpleList {
  String buid;
  String parentid;
  String isactive;
  String bucode;
  String budesc;
  String lvl;
  String bupath;
  String buids;

  PurpleList({
    required this.buid,
    required this.parentid,
    required this.isactive,
    required this.bucode,
    required this.budesc,
    required this.lvl,
    required this.bupath,
    required this.buids,
  });

  factory PurpleList.fromJson(Map<String, dynamic> json) => PurpleList(
    buid: json["BUID"] ?? '',
    parentid: json["PARENTID"] ?? '',
    isactive: json["ISACTIVE"] ?? '',
    bucode: json["BUCODE"] ?? '',
    budesc: json["BUDESC"] ?? '',
    lvl: json["LVL"] ?? '',
    bupath: json["BUPATH"] ?? '',
    buids: json["BUIDS"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "BUID": buid,
    "PARENTID": parentid,
    "ISACTIVE": isactive,
    "BUCODE": bucode,
    "BUDESC": budesc,
    "LVL": lvl,
    "BUPATH": bupath,
    "BUIDS": buids,
  };
}


class Menulist {
  List<Datum> data;

  Menulist({
    required this.data,
  });

  factory Menulist.fromJson(Map<String, dynamic> json) => Menulist(
    data: json["DATA"] == null
        ? []
        : List<Datum>.from(json["DATA"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "DATA": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  List<DatumList> list;

  Datum({
    required this.list,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    list: json["LIST"] == null
        ? []
        : List<DatumList>.from(
        json["LIST"].map((x) => DatumList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "LIST": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}




class DatumList {
  String id;
  String name;
  String menucode;
  String seq;

  DatumList({
    required this.id,
    required this.name,
    required this.menucode,
    required this.seq,
  });

  factory DatumList.fromJson(Map<String, dynamic> json) => DatumList(
    id: json["ID"]?? '',
    name: json["NAME"]?? '',
    menucode: json["MENUCODE"]?? '',
    seq: json["SEQ"]?? '',
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "NAME": name,
    "MENUCODE": menucode,
    "SEQ": seq,
  };
}

class Positiondetails {
  PositiondetailsData data;

  Positiondetails({
    required this.data,
  });

  factory Positiondetails.fromJson(Map<String, dynamic> json) => Positiondetails(
    data: json["DATA"] != null
        ? PositiondetailsData.fromJson(json["DATA"])
        : PositiondetailsData(list: []), // fallback to empty list
  );

  Map<String, dynamic> toJson() => {
    "DATA": data.toJson(),
  };
}

class PositiondetailsData {
  List<FluffyList> list;

  PositiondetailsData({
    required this.list,
  });

  factory PositiondetailsData.fromJson(Map<String, dynamic> json) =>
      PositiondetailsData(
        list: json["LIST"] == null
            ? []
            : List<FluffyList>.from(
            json["LIST"].map((x) => FluffyList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "LIST": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class FluffyList {
  String positionid;
  String description;
  String orgpath;
  String orgstrucid;
  String company;
  String plant;
  String timelogout;

  FluffyList({
    required this.positionid,
    required this.description,
    required this.orgpath,
    required this.orgstrucid,
    required this.company,
    required this.plant,
    required this.timelogout,
  });

  factory FluffyList.fromJson(Map<String, dynamic> json) => FluffyList(
    positionid: json["POSITIONID"] ?? '',
    description: json["DESCRIPTION"] ?? '',
    orgpath: json["ORGPATH"] ?? '',
    orgstrucid: json["ORGSTRUCID"] ?? '',
    company: json["Company"] ?? '',
    plant: json["Plant"] ?? '',
    timelogout: json["timelogout"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "POSITIONID": positionid,
    "DESCRIPTION": description,
    "ORGPATH": orgpath,
    "ORGSTRUCID": orgstrucid,
    "Company": company,
    "Plant": plant,
    "timelogout": timelogout,
  };
}



class Sodetails {
  SodetailsData data;

  Sodetails({
    required this.data,
  });

  factory Sodetails.fromJson(Map<String, dynamic> json) => Sodetails(
    data: json["DATA"] != null
        ? SodetailsData.fromJson(json["DATA"])
        : SodetailsData(menuid: '', list: []),
  );

  Map<String, dynamic> toJson() => {
    "DATA": data.toJson(),
  };
}

class SodetailsData {
  String menuid;
  List<TentacledList> list;

  SodetailsData({
    required this.menuid,
    required this.list,
  });

  factory SodetailsData.fromJson(Map<String, dynamic> json) => SodetailsData(
    menuid: json["MENUID"] ?? '',
    list: json["LIST"] == null
        ? []
        : List<TentacledList>.from(
        json["LIST"].map((x) => TentacledList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "MENUID": menuid,
    "LIST": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class TentacledList {
  String docid;
  String description;
  String orgstrucid;

  TentacledList({
    required this.docid,
    required this.description,
    required this.orgstrucid,
  });

  factory TentacledList.fromJson(Map<String, dynamic> json) => TentacledList(
    docid: json["DOCID"] ?? '',
    description: json["DESCRIPTION"] ?? '',
    orgstrucid: json["ORGSTRUCID"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "DOCID": docid,
    "DESCRIPTION": description,
    "ORGSTRUCID": orgstrucid,
  };
}

