class ChangePasswordResponseModel {
  final SuccessData? successData; // for SYSMSGS
  final FailureData? failureData; // for DATA
  final String? error;             // for exceptions

  ChangePasswordResponseModel({this.successData, this.failureData, this.error});

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('SYSMSGS')) {
      return ChangePasswordResponseModel(
        successData: SuccessData.fromJson(json['SYSMSGS']),
      );
    } else if (json.containsKey('DATA')) {
      return ChangePasswordResponseModel(
        failureData: FailureData.fromJson(json['DATA']),
      );
    } else {
      return ChangePasswordResponseModel(error: "Unknown response format");
    }
  }

  factory ChangePasswordResponseModel.withError(String error) =>
      ChangePasswordResponseModel(error: error);
}

class SuccessData {
  final String? id;
  final String? errorMsg;
  final String? type;
  final String? title;

  SuccessData({this.id, this.errorMsg, this.type, this.title});

  factory SuccessData.fromJson(Map<String, dynamic> json) => SuccessData(
    id: json['ID'],
    errorMsg: json['ERRORMSGS'],
    type: json['TYPE'],
    title: json['TITLE'],
  );
}

class FailureData {
  final String? status;
  final String? message;

  FailureData({this.status, this.message});

  factory FailureData.fromJson(Map<String, dynamic> json) => FailureData(
    status: json['Status'].toString(),
    message: json['Message'],
  );
}