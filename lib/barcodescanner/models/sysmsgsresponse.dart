class SysMsgsResponse {
  final SysMsgs? sysMsgs;

  SysMsgsResponse({this.sysMsgs});

  factory SysMsgsResponse.fromJson(Map<String, dynamic> json) {
    return SysMsgsResponse(
      sysMsgs: json['DATA'] != null && json['DATA']['SYSMSGS'] != null
          ? SysMsgs.fromJson(json['DATA']['SYSMSGS'])
          : null,
    );
  }

  bool get isError => sysMsgs?.type == 'E';
  String get message => sysMsgs?.errorMsgs ?? '';
}

class SysMsgs {
  final String id;
  final String errorMsgs;
  final String type;
  final String title;

  SysMsgs({
    required this.id,
    required this.errorMsgs,
    required this.type,
    required this.title,
  });

  factory SysMsgs.fromJson(Map<String, dynamic> json) {
    return SysMsgs(
      id: json['ID']?.toString() ?? '',
      errorMsgs: json['ERRORMSGS']?.toString() ?? '',
      type: json['TYPE']?.toString() ?? '',
      title: json['TITLE']?.toString() ?? '',
    );
  }
}

