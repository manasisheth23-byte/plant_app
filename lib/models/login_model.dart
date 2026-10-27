class LoginResponseModelBiometry {
  final LoginDataBiometry? data;

  LoginResponseModelBiometry({this.data});

  factory LoginResponseModelBiometry.fromJson(Map<String, dynamic>? json) {
    return LoginResponseModelBiometry(
      data: json?["DATA"] != null
          ? LoginDataBiometry.fromJson(json?["DATA"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "DATA": data?.toJson(),
    };
  }
}

class LoginDataBiometry {
  final String status;
  final String userId;
  final String userTypeId;
  final String userType;
  final String loginId;
  final String userName;
  final String email;
  final String imgDesc;
  final String posId;
  final String posDesc;
  final String slId;
  final String slCode;
  final String slDesc;
  final String buIds;
  final String orgStrucId;
  final String orgDesc;
  final String controlNo;
  final String finYearDesc;
  final String sDate;
  final String eDate;
  final String token;
  final String tokenCreatedOn;
  final String tokenExpiresOn;
  final String rfidFlag;
  final String timeLogout;
  final String shiftDate;
  final String shiftDesc;
  final String businessType;
  final String forceUpdate;
  final String isVerified;
  final String enableBiometric;
  final String resetData;
  final String kioskModeId;
  final String kioskModeDesc;
  final String machineId;
  final String machineDesc;
  final String isOtp;
  final String mobileNo;
  final String message;

  final BuDetails? buDetails;
  final PositionDetails? positionDetails;
  final MenuList? menuList;

  LoginDataBiometry({
    required this.status,
    required this.userId,
    required this.userTypeId,
    required this.userType,
    required this.loginId,
    required this.userName,
    required this.email,
    required this.imgDesc,
    required this.posId,
    required this.posDesc,
    required this.slId,
    required this.slCode,
    required this.slDesc,
    required this.buIds,
    required this.orgStrucId,
    required this.orgDesc,
    required this.controlNo,
    required this.finYearDesc,
    required this.sDate,
    required this.eDate,
    required this.token,
    required this.tokenCreatedOn,
    required this.tokenExpiresOn,
    required this.rfidFlag,
    required this.timeLogout,
    required this.shiftDate,
    required this.shiftDesc,
    required this.businessType,
    required this.forceUpdate,
    required this.isVerified,
    required this.enableBiometric,
    required this.resetData,
    required this.kioskModeId,
    required this.kioskModeDesc,
    required this.machineId,
    required this.machineDesc,
    required this.isOtp,
    required this.mobileNo,
    required this.message,
    this.buDetails,
    this.positionDetails,
    this.menuList,
  });

  factory LoginDataBiometry.fromJson(Map<String, dynamic>? json) {
    return LoginDataBiometry(
      status: json?["Status"]?.toString() ?? "",
      userId: json?["USERID"]?.toString() ?? "",
      userTypeId: json?["USERTYPEID"]?.toString() ?? "",
      userType: json?["USERTYPE"]?.toString() ?? "",
      loginId: json?["LOGINID"]?.toString() ?? "",
      userName: json?["USERNAME"]?.toString() ?? "",
      email: json?["EMAIL"]?.toString() ?? "",
      imgDesc: json?["IMGDESC"]?.toString() ?? "",
      posId: json?["POSID"]?.toString() ?? "",
      posDesc: json?["POSDESC"]?.toString() ?? "",
      slId: json?["SLID"]?.toString() ?? "",
      slCode: json?["SLCODE"]?.toString() ?? "",
      slDesc: json?["SLDESC"]?.toString() ?? "",
      buIds: json?["BUIDS"]?.toString() ?? "",
      orgStrucId: json?["ORGSTRUCID"]?.toString() ?? "",
      orgDesc: json?["ORGDESC"]?.toString() ?? "",
      controlNo: json?["CONTROLNO"]?.toString() ?? "",
      finYearDesc: json?["FINYEARDESC"]?.toString() ?? "",
      sDate: json?["SDATE"]?.toString() ?? "",
      eDate: json?["EDATE"]?.toString() ?? "",
      token: json?["TOKEN"]?.toString() ?? "",
      tokenCreatedOn: json?["TokenCreatedOn"]?.toString() ?? "",
      tokenExpiresOn: json?["TokenExpiresOn"]?.toString() ?? "",
      rfidFlag: json?["RFIDFLAG"]?.toString() ?? "",
      timeLogout: json?["timelogout"]?.toString() ?? "",
      shiftDate: json?["SHIFTDATE"]?.toString() ?? "",
      shiftDesc: json?["SHIFTDESC"]?.toString() ?? "",
      businessType: json?["BusinessType"]?.toString() ?? "",
      forceUpdate: json?["FORCEUPDATE"]?.toString() ?? "",
      isVerified: json?["ISVERIFIED"]?.toString() ?? "",
      enableBiometric: json?["ENABLEBIOMETRIC"]?.toString() ?? "",
      resetData: json?["RESETDATA"]?.toString() ?? "",
      kioskModeId: json?["KIOSKMODEID"]?.toString() ?? "",
      kioskModeDesc: json?["KIOSKMODEDESC"]?.toString() ?? "",
      machineId: json?["MACHINEID"]?.toString() ?? "",
      machineDesc: json?["MACHINEDESC"]?.toString() ?? "",
      isOtp: json?["ISOTP"]?.toString() ?? "",
      mobileNo: json?["MOBILENO"]?.toString() ?? "",
      message: json?["MESSAGE"]?.toString() ?? "",
      buDetails: json?["BUDETAILS"] != null
          ? BuDetails.fromJson(json?["BUDETAILS"])
          : null,
      positionDetails: json?["POSITIONDETAILS"] != null
          ? PositionDetails.fromJson(json?["POSITIONDETAILS"])
          : null,
      menuList: json?["MENULIST"] != null
          ? MenuList.fromJson(json?["MENULIST"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Status": status,
      "USERID": userId,
      "USERTYPEID": userTypeId,
      "USERTYPE": userType,
      "LOGINID": loginId,
      "USERNAME": userName,
      "EMAIL": email,
      "IMGDESC": imgDesc,
      "POSID": posId,
      "POSDESC": posDesc,
      "SLID": slId,
      "SLCODE": slCode,
      "SLDESC": slDesc,
      "BUIDS": buIds,
      "ORGSTRUCID": orgStrucId,
      "ORGDESC": orgDesc,
      "CONTROLNO": controlNo,
      "FINYEARDESC": finYearDesc,
      "SDATE": sDate,
      "EDATE": eDate,
      "TOKEN": token,
      "TokenCreatedOn": tokenCreatedOn,
      "TokenExpiresOn": tokenExpiresOn,
      "RFIDFLAG": rfidFlag,
      "timelogout": timeLogout,
      "SHIFTDATE": shiftDate,
      "SHIFTDESC": shiftDesc,
      "BusinessType": businessType,
      "FORCEUPDATE": forceUpdate,
      "ISVERIFIED": isVerified,
      "ENABLEBIOMETRIC": enableBiometric,
      "RESETDATA": resetData,
      "KIOSKMODEID": kioskModeId,
      "KIOSKMODEDESC": kioskModeDesc,
      "MACHINEID": machineId,
      "MACHINEDESC": machineDesc,
      "ISOTP": isOtp,
      "MOBILENO": mobileNo,
      "MESSAGE": message,
      "BUDETAILS": buDetails?.toJson(),
      "POSITIONDETAILS": positionDetails?.toJson(),
      "MENULIST": menuList?.toJson(),
    };
  }
}

class BuDetails {
  final Map<String, dynamic>? data;

  BuDetails({this.data});

  factory BuDetails.fromJson(Map<String, dynamic>? json) {
    return BuDetails(
      data: json?["DATA"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "DATA": data,
    };
  }
}

class PositionDetails {
  final List<PositionItem> list;

  PositionDetails({required this.list});

  factory PositionDetails.fromJson(Map<String, dynamic>? json) {
    List<dynamic> rawList = json?["DATA"]?["LIST"] ?? [];

    return PositionDetails(
      list: rawList
          .map((e) => PositionItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "DATA": {
        "LIST": list.map((e) => e.toJson()).toList(),
      }
    };
  }
}

class PositionItem {
  final String positionId;
  final String description;
  final String orgPath;
  final String orgStrucId;
  final String plant;
  final String timeLogout;

  PositionItem({
    required this.positionId,
    required this.description,
    required this.orgPath,
    required this.orgStrucId,
    required this.plant,
    required this.timeLogout,
  });

  factory PositionItem.fromJson(Map<String, dynamic>? json) {
    return PositionItem(
      positionId: json?["POSITIONID"]?.toString() ?? "",
      description: json?["DESCRIPTION"]?.toString() ?? "",
      orgPath: json?["ORGPATH"]?.toString() ?? "",
      orgStrucId: json?["ORGSTRUCID"]?.toString() ?? "",
      plant: json?["Plant"]?.toString() ?? "",
      timeLogout: json?["timelogout"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "POSITIONID": positionId,
      "DESCRIPTION": description,
      "ORGPATH": orgPath,
      "ORGSTRUCID": orgStrucId,
      "Plant": plant,
      "timelogout": timeLogout,
    };
  }
}

class MenuList {
  final dynamic data;

  MenuList({this.data});

  factory MenuList.fromJson(Map<String, dynamic>? json) {
    return MenuList(
      data: json?["DATA"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "DATA": data,
    };
  }
}