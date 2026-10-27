import '../barcodescanner/models/sysmsgsresponse.dart';

class SysMsgsRegisterResponse {
  final SysMsgsRegsietr sysMsgs;

  SysMsgsRegisterResponse({required this.sysMsgs});

  factory SysMsgsRegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['DATA'];
    final sysMsgsJson =
    data != null && data['SYSMSGS'] != null ? data['SYSMSGS'] : null;

    return SysMsgsRegisterResponse(
      sysMsgs: sysMsgsJson != null
          ? SysMsgsRegsietr.fromJson(sysMsgsJson)
          : SysMsgsRegsietr.empty(),
    );
  }

  /// Convenience helpers (SAFE)
  bool get isSuccess => sysMsgs.type == 'S';
  bool get isError => sysMsgs.type == 'E';
  String get message => sysMsgs.errorMsgs;
}
class SysMsgsRegsietr {
  final String id;
  final String errorMsgs;
  final String type;
  final String title;

  SysMsgsRegsietr({
    required this.id,
    required this.errorMsgs,
    required this.type,
    required this.title,
  });

  factory SysMsgsRegsietr.fromJson(Map<String, dynamic> json) {
    return SysMsgsRegsietr(
      id: json['ID']?.toString() ?? '',
      errorMsgs: json['ERRORMSGS']?.toString() ?? '',
      type: json['TYPE']?.toString() ?? 'E',
      title: json['TITLE']?.toString() ?? '',
    );
  }

  /// 🔥 Default fallback (VERY IMPORTANT)
  factory SysMsgsRegsietr.empty() {
    return SysMsgsRegsietr(
      id: '',
      errorMsgs: 'Unexpected response from server',
      type: 'E',
      title: '',
    );
  }
}
