class GetNotificationModel {
  DATA? dATA;

  GetNotificationModel({this.dATA});

  GetNotificationModel.fromJson(Map<String, dynamic> json) {
    dATA = json['DATA'] != null ? DATA.fromJson(json['DATA']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dATA != null) {
      data['DATA'] = dATA!.toJson();
    }
    return data;
  }
}

class DATA {
  List<NitificationLIST>? lIST;
  String? status;
  String? message;

  DATA({this.lIST, this.status, this.message});

  DATA.fromJson(Map<String, dynamic> json) {
    if (json['LIST'] != null) {
      lIST = <NitificationLIST>[];
      json['LIST'].forEach((v) {
        lIST!.add(NitificationLIST.fromJson(v));
      });
    } else if (json['Status'] != null && json['Message'] != null) {
      status = json['Status'] ?? '';
      message = json['Message'] ?? '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lIST != null) {
      data['LIST'] = lIST!.map((v) => v.toJson()).toList();
    }
    if (status != null) {
      data['Status'] = status;
    }
    if (message != null) {
      data['Message'] = message;
    }
    return data;
  }
}

class NitificationLIST {
  String? nID;
  String? mENUID;
  String? dISMISS;
  String? ISREAD;
  String? dIVDATETIME;
  String? nOTIFYBY;
  String? nOTIFYDATE;
  String? notifytime;
  String? nOTIFYTO;
  String? sNOOZMIN;
  String? sUBJECT;
  String? uRL;
  String? mID;
  String? dOCID;
  String? nTYPE;
  String? tITLEID;
  String? tITLE;
  String? sTATUSID;
  String? sTATUS;
  String? nOTIFYBYNAME;
  String? tRANSACTIONTYPE;
  String? pAGESHEETID;
  String? mSGBODY;
  dynamic dOCDATA; // Handle Null safely by using dynamic for optional data

  NitificationLIST(
      {this.nID,
        this.mENUID,
        this.dISMISS,
        this.ISREAD,
        this.dIVDATETIME,
        this.nOTIFYBY,
        this.nOTIFYDATE,
        this.notifytime,
        this.nOTIFYTO,
        this.sNOOZMIN,
        this.sUBJECT,
        this.uRL,
        this.mID,
        this.dOCID,
        this.nTYPE,
        this.tITLEID,
        this.tITLE,
        this.sTATUSID,
        this.sTATUS,
        this.nOTIFYBYNAME,
        this.mSGBODY,
        this.dOCDATA,
      this.pAGESHEETID,
      this.tRANSACTIONTYPE});

  NitificationLIST.fromJson(Map<String, dynamic> json) {
    nID = json['NID'] ?? '';
    mENUID = json['MENUID'] ?? '';
    dISMISS = json['DISMISS'] ?? '';
    ISREAD = json['ISREAD'] ?? '';
    dIVDATETIME = json['DIVDATETIME'] ?? '';
    nOTIFYBY = json['NOTIFYBY'] ?? '';
    nOTIFYDATE = json['NOTIFYDATE'] ?? '';
    notifytime = json['Notifytime'] ?? '';
    nOTIFYTO = json['NOTIFYTO'] ?? '';
    sNOOZMIN = json['SNOOZMIN'] ?? '';
    sUBJECT = json['SUBJECT'] ?? '';
    uRL = json['URL'] ?? '';
    mID = json['MID'] ?? '';
    dOCID = json['DOCID'] ?? '';
    nTYPE = json['NTYPE'] ?? '';
    tITLEID = json['TITLEID'] ?? '';
    tITLE = json['TITLE'] ?? '';
    sTATUSID = json['STATUSID'] ?? '';
    sTATUS = json['STATUS'] ?? '';
    nOTIFYBYNAME = json['NOTIFYBYNAME'] ?? '';
    mSGBODY = json['MSGBODY'] ?? '';
    dOCDATA = json['DOCDATA']?? '';
    pAGESHEETID=json['PAGESHEETID']?? '';
    tRANSACTIONTYPE = json['TRANSACTIONTYPE']?? '';// Keep this as dynamic to handle null or other types
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NID'] = nID ?? '';
    data['MENUID'] = mENUID ?? '';
    data['DISMISS'] = dISMISS ?? '';
    data['ISREAD'] = ISREAD ?? '';
    data['DIVDATETIME'] = dIVDATETIME ?? '';
    data['NOTIFYBY'] = nOTIFYBY ?? '';
    data['NOTIFYDATE'] = nOTIFYDATE ?? '';
    data['Notifytime'] = notifytime ?? '';
    data['NOTIFYTO'] = nOTIFYTO ?? '';
    data['SNOOZMIN'] = sNOOZMIN ?? '';
    data['SUBJECT'] = sUBJECT ?? '';
    data['URL'] = uRL ?? '';
    data['MID'] = mID ?? '';
    data['DOCID'] = dOCID ?? '';
    data['NTYPE'] = nTYPE ?? '';
    data['TITLEID'] = tITLEID ?? '';
    data['TITLE'] = tITLE ?? '';
    data['STATUSID'] = sTATUSID ?? '';
    data['STATUS'] = sTATUS ?? '';
    data['DOCDATA'] = dOCDATA;
    data['NOTIFYBYNAME'] = nOTIFYBYNAME;
    data['MSGBODY'] = mSGBODY;
    data['PAGESHEETID'] = pAGESHEETID;
    data['TRANSACTIONTYPE'] = tRANSACTIONTYPE;
    return data;
  }
}
