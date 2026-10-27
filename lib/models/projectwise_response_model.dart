class MasterProjectNo {
  final int projId;
  final String projNo;
  final String projDesc;
  final int priority;
  final String accountDesc;
  final String creationDate;

  MasterProjectNo({
    required this.projId,
    required this.projNo,
    required this.projDesc,
    required this.priority,
    required this.accountDesc,
    required this.creationDate,
  });

  factory MasterProjectNo.fromJson(Map<String, dynamic> json) {
    return MasterProjectNo(
      projId: json['PROJID'],
      projNo: json['PROJNO'],
      projDesc: json['PROJDESC'],
      priority: json['PRIORITY'],
      accountDesc: json['ACCOUNTDESC'],
      creationDate: json['Createdon'],
    );
  }
}

class ProjectWiseDetailResponse {
  final bool status;
  final List<MasterProjectNo> masterProjectNo;

  ProjectWiseDetailResponse({
    required this.status,
    required this.masterProjectNo,
  });

  factory ProjectWiseDetailResponse.fromJson(Map<String, dynamic> json) {
    var list = json['MasterProjectNo'] as List;
    List<MasterProjectNo> masterProjectList = list.map((i) => MasterProjectNo.fromJson(i)).toList();

    return ProjectWiseDetailResponse(
      status: json['STATUS'] == 'true',
      masterProjectNo: masterProjectList,
    );
  }
}
