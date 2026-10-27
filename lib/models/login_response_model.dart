class LoginModel {
  int? uSERID;
  String? uSERNAME;
  String? mESSAGE;
  int? uTYPEID;
  bool? iSVERIFIED;
  String? mOBILENO;
  String? fINGERPRINT1;
  String? fINGERPRINT2;
  String? fINGERPRINT3;
  String? bIOKEY;
  String? fCMKEY;
  bool? fORCEUPDATE;
  bool? eNABLEBIOMETRIC;
  String? tOEKN;

  LoginModel(
      {this.uSERID,
        this.uSERNAME,
        this.mESSAGE,
        this.uTYPEID,
        this.iSVERIFIED,
        this.mOBILENO,
        this.fINGERPRINT1,
        this.fINGERPRINT2,
        this.fINGERPRINT3,
        this.bIOKEY,
        this.fCMKEY,
        this.fORCEUPDATE,
        this.eNABLEBIOMETRIC,
        this.tOEKN});

  LoginModel.fromJson(Map<String, dynamic> json) {
    uSERID = json['USERID'];
    uSERNAME = json['USERNAME'];
    mESSAGE = json['MESSAGE'];
    uTYPEID = json['UTYPEID'];
    iSVERIFIED = json['ISVERIFIED'];
    mOBILENO = json['MOBILENO'];
    fINGERPRINT1 = json['FINGERPRINT1'];
    fINGERPRINT2 = json['FINGERPRINT2'];
    fINGERPRINT3 = json['FINGERPRINT3'];
    bIOKEY = json['BIOKEY'];
    fCMKEY = json['FCMKEY'];
    fORCEUPDATE = json['FORCEUPDATE'];
    eNABLEBIOMETRIC = json['ENABLEBIOMETRIC'];
    tOEKN = json['TOEKN'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['USERID'] = this.uSERID;
    data['USERNAME'] = this.uSERNAME;
    data['MESSAGE'] = this.mESSAGE;
    data['UTYPEID'] = this.uTYPEID;
    data['ISVERIFIED'] = this.iSVERIFIED;
    data['MOBILENO'] = this.mOBILENO;
    data['FINGERPRINT1'] = this.fINGERPRINT1;
    data['FINGERPRINT2'] = this.fINGERPRINT2;
    data['FINGERPRINT3'] = this.fINGERPRINT3;
    data['BIOKEY'] = this.bIOKEY;
    data['FCMKEY'] = this.fCMKEY;
    data['FORCEUPDATE'] = this.fORCEUPDATE;
    data['ENABLEBIOMETRIC'] = this.eNABLEBIOMETRIC;
    data['TOEKN'] = this.tOEKN;
    return data;
  }
}
