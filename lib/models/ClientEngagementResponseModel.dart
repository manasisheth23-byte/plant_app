class ClientEngagementResponseModel {
  DATA? dATA;

  ClientEngagementResponseModel({this.dATA});

  ClientEngagementResponseModel.fromJson(Map<String, dynamic> json) {
    dATA = json['DATA'] != null ? new DATA.fromJson(json['DATA']) : null;
  }
  ClientEngagementResponseModel.withError(String errorValue)
  {
    var error = errorValue;

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
  Null? lIST;

  DATA({this.lIST});

  DATA.fromJson(Map<String, dynamic> json) {
    lIST = json['LIST'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LIST'] = this.lIST;
    return data;
  }
}
