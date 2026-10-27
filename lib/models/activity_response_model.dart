class ActivityResponseModel {
  ActivityResponseModel({
     this.data,
  });

   Data? data;

  factory ActivityResponseModel.fromJson(Map<String, dynamic> json){
    return ActivityResponseModel(
      data: json["DATA"] == null ? null : Data.fromJson(json["DATA"]),
    );
  }

}

class Data {
  Data({
    required this.list,
  });

  final List<ListElement> list;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      list: json["LIST"] == null ? [] : List<ListElement>.from(json["LIST"]!.map((x) => ListElement.fromJson(x))),
    );
  }

}

class ListElement {
  ListElement({
    required this.activityid,
    required this.businesspartnerid,
    required this.businesspartner,
    required this.contactno,
    required this.contact,
    required this.typeid,
    required this.typedesc,
    required this.priorityid,
    required this.priority,
    required this.statusid,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.subject,
    required this.refmid,
    required this.refdocid,
    required this.refinvcnumb,
    required this.remarks,
    required this.content,
    required this.assignedby,
    required this.assignedbyname,
    required this.assignedto,
    required this.assignedtoname,
    required this.starttime,
    required this.endtime,
    required this.duedate,
    required this.createdon,
    required this.modifiedon,
    required this.createdby,
    required this.createdbydesc,
    required this.callplantypeid,
    required this.callpurposedid,
    required this.callpurpose,
    required this.calltypeid,
    required this.calltype,
    required this.callduration,
    required this.callresult,
    required this.contactpersonid,
    required this.contactto,
    required this.contactperson,
    required this.contactpersonnumber,
    required this.activitydetails,
    required this.color,
    required this.colorcode,
    required this.duedateday,
    required this.docdata,
    required this.attendees,
  });

  final String? activityid;
  final String? businesspartnerid;
  final String? businesspartner;
  final String? contactno;
  final String? contact;
  final String? typeid;
  final String? typedesc;
  final String? priorityid;
  final String? priority;
  final String? statusid;
  final String? latitude;
  final String? longitude;
  final String? status;
  final String? subject;
  final String? refmid;
  final String? refdocid;
  final String? refinvcnumb;
  final String? remarks;
  final String? content;
  final String? assignedby;
  final String? assignedbyname;
  final String? assignedto;
  final String? assignedtoname;
  final String? starttime;
  final String? endtime;
  final String? duedate;
  final String? createdon;
  final String? modifiedon;
  final String? createdby;
  final String? createdbydesc;
  final String? callplantypeid;
  final String? callpurposedid;
  final String? callpurpose;
  final String? calltypeid;
  final String? calltype;
  final String? callduration;
  final String? callresult;
  final String? contactpersonid;
  final String? contactto;
  final String? contactperson;
  final String? contactpersonnumber;
  final String? activitydetails;
  final String? color;
  final String? colorcode;
  final DateTime? duedateday;
  final dynamic docdata;
  final List<Attendee> attendees;

  factory ListElement.fromJson(Map<String, dynamic> json){
    return ListElement(
      activityid: json["ACTIVITYID"],
      businesspartnerid: json["BUSINESSPARTNERID"],
      businesspartner: json["BUSINESSPARTNER"],
      contactno: json["CONTACTNO"],
      contact: json["CONTACT"],
      typeid: json["TYPEID"],
      typedesc: json["TYPEDESC"],
      priorityid: json["PRIORITYID"],
      priority: json["PRIORITY"],
      statusid: json["STATUSID"],

      latitude: json["LATITUDE"],
      longitude: json["LONGITUDE"],
      status: json["STATUS"],
      subject: json["SUBJECT"],
      refmid: json["REFMID"],
      refdocid: json["REFDOCID"],
      refinvcnumb: json["REFINVCNUMB"],
      remarks: json["REMARKS"],
      content: json["CONTENT"],
      assignedby: json["ASSIGNEDBY"],
      assignedbyname: json["ASSIGNEDBYNAME"],
      assignedto: json["ASSIGNEDTO"],
      assignedtoname: json["ASSIGNEDTONAME"],
      starttime: json["STARTTIME"],
      endtime: json["ENDTIME"],
      duedate: json["DUEDATE"],
      createdon: json["CREATEDON"],
      modifiedon: json["MODIFIEDON"],
      createdby: json["CREATEDBY"],
      createdbydesc: json["CREATEDBYDESC"],
      callplantypeid: json["CALLPLANTYPEID"],
      callpurposedid: json["CALLPURPOSEDID"],
      callpurpose: json["CALLPURPOSE"],
      calltypeid: json["CALLTYPEID"],
      calltype: json["CALLTYPE"],
      callduration: json["CALLDURATION"],
      callresult: json["CALLRESULT"],
      contactpersonid: json["CONTACTPERSONID"],
      contactto: json["CONTACTTO"],
      contactperson: json["CONTACTPERSON"],
      contactpersonnumber: json["CONTACTPERSONNUMBER"],
      activitydetails: json["ACTIVITYDETAILS"],
      color: json["COLOR"],
      colorcode: json["COLORCODE"],
      duedateday: DateTime.tryParse(json["DUEDATEDAY"] ?? ""),
      docdata: json["DOCDATA"],
      attendees: json["ATTENDEES"] == null ? [] : List<Attendee>.from(json["ATTENDEES"]!.map((x) => Attendee.fromJson(x))),
    );
  }

}

class Attendee {
  Attendee({
    required this.activityid,
    required this.userid,
    required this.attendeesname,
  });

  final String? activityid;
  final String? userid;
  final String? attendeesname;

  factory Attendee.fromJson(Map<String, dynamic> json){
    return Attendee(
      activityid: json["ACTIVITYID"],
      userid: json["USERID"],
      attendeesname: json["ATTENDEESNAME"],
    );
  }

}
