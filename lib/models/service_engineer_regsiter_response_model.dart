class ServiceEngineerRegisterResponseModel {
  int? iD;
  int? uSERID;
  String? mESSAGE;

  ServiceEngineerRegisterResponseModel({this.iD, this.uSERID, this.mESSAGE});

  ServiceEngineerRegisterResponseModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    uSERID = json['USERID'];
    mESSAGE = json['MESSAGE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['USERID'] = this.uSERID;
    data['MESSAGE'] = this.mESSAGE;
    return data;
  }
}