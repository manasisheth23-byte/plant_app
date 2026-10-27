class GetBIPageSheetRequestModel {
  XMLFILEPAGESHEET? xMLFILE;

  GetBIPageSheetRequestModel({this.xMLFILE});

  GetBIPageSheetRequestModel.fromJson(Map<String, dynamic> json) {
    xMLFILE =
    json['XMLFILE'] != null ? new XMLFILEPAGESHEET.fromJson(json['XMLFILE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xMLFILE != null) {
      data['XMLFILE'] = this.xMLFILE!.toJson();
    }
    return data;
  }
}

class XMLFILEPAGESHEET {
  String? fLAG;
  String? pAGESHEETID;
  String? pAGESHEETNAME;
  String? tOKEN;
  String? uSERID;

  XMLFILEPAGESHEET(
      {this.fLAG,
        this.pAGESHEETID,
        this.pAGESHEETNAME,
        this.tOKEN,
        this.uSERID});

  XMLFILEPAGESHEET.fromJson(Map<String, dynamic> json) {
    fLAG = json['FLAG'];
    pAGESHEETID = json['PAGESHEETID'];
    pAGESHEETNAME = json['PAGESHEETNAME'];
    tOKEN = json['TOKEN'];
    uSERID = json['USERID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FLAG'] = this.fLAG;
    data['PAGESHEETID'] = this.pAGESHEETID;
    data['PAGESHEETNAME'] = this.pAGESHEETNAME;
    data['TOKEN'] = this.tOKEN;
    data['USERID'] = this.uSERID;
    return data;
  }
}
