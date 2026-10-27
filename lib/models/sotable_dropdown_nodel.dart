class SoTableDropdownModel {
  SoTableDropdownModel({
    required this.status,
    required this.data,
  });

  final String? status;
  final DropDownData? data;

  factory SoTableDropdownModel.fromJson(Map<String, dynamic> json) {
    return SoTableDropdownModel(
      status: json["STATUS"],
      data: json["Data"] == null ? null : DropDownData.fromJson(json["Data"]),
    );
  }
}

class DropDownData {
  DropDownData({
    required this.exWorkColor,
    required this.cddColor,
    required this.customer,
    required this.fgCode,
    required this.soNo,
    required this.project,
    required this.itemSubgroup,
    required this.alerts,
    required this.plant, // Added plant list
  });

  final List<Color> exWorkColor;
  final List<Color> cddColor;
  final List<Customer> customer;
  final List<FgCode> fgCode;
  final List<SONO> soNo;
  final List<Project> project; // Changed to dedicated class
  final List<ItemSubgroup> itemSubgroup;
  final List<Alert> alerts;
  final List<Plant> plant; // Added plant list

  factory DropDownData.fromJson(Map<String, dynamic> json) {
    return DropDownData(
      exWorkColor: json["Ex-Work Color"] == null
          ? []
          : List<Color>.from(json["Ex-Work Color"]!.map((x) => Color.fromJson(x))),
      cddColor: json["CDD Color"] == null
          ? []
          : List<Color>.from(json["CDD Color"]!.map((x) => Color.fromJson(x))),
      customer: json["Customer"] == null
          ? []
          : List<Customer>.from(json["Customer"]!.map((x) => Customer.fromJson(x))),
      fgCode: json["FGCode"] == null
          ? []
          : List<FgCode>.from(json["FGCode"]!.map((x) => FgCode.fromJson(x))),
      soNo: json["SONo"] == null
          ? []
          : List<SONO>.from(json["SONo"]!.map((x) => SONO.fromJson(x))),
      project: json["Project"] == null
          ? []
          : List<Project>.from(json["Project"]!.map((x) => Project.fromJson(x))),
      itemSubgroup: json["ItemSubgroup"] == null
          ? []
          : List<ItemSubgroup>.from(json["ItemSubgroup"]!.map((x) => ItemSubgroup.fromJson(x))),
      alerts: json["Alerts"] == null
          ? []
          : List<Alert>.from(json["Alerts"]!.map((x) => Alert.fromJson(x))),
      plant: json["Plant"] == null // Added plant parsing
          ? []
          : List<Plant>.from(json["Plant"]!.map((x) => Plant.fromJson(x))),
    );
  }
}

// Add the Plant class
class Plant {
  Plant({
    required this.orgstrucid,
    required this.description,
    required this.level,
    required this.parentId,
    required this.hasChild,
    required this.seq,
    required this.fieldtypeid,
    required this.fieldtypedesc,
    required this.orgPath,
    required this.code,
    required this.doctypeprefix,
    required this.noshift,
    required this.mappedslid,
    required this.mappedsldesc,
    required this.mappedslcode,
    required this.planttype,
    required this.planttypedesc,
    required this.geosalesid,
    required this.gslocdesc,
    required this.intertransacctid,
    required this.glcode,
    required this.gldesc,
    required this.currencyid,
    required this.currencydesc,
  });

  final int? orgstrucid;
  final String? description;
  final int? level;
  final int? parentId;
  final int? hasChild;
  final int? seq;
  final int? fieldtypeid;
  final String? fieldtypedesc;
  final String? orgPath;
  final String? code;
  final String? doctypeprefix;
  final int? noshift;
  final int? mappedslid;
  final String? mappedsldesc;
  final String? mappedslcode;
  final int? planttype;
  final String? planttypedesc;
  final String? geosalesid;
  final String? gslocdesc;
  final int? intertransacctid;
  final String? glcode;
  final String? gldesc;
  final int? currencyid;
  final String? currencydesc;

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      orgstrucid: json["ORGSTRUCID"],
      description: json["Description"],
      level: json["Level"],
      parentId: json["ParentID"],
      hasChild: json["HasChild"],
      seq: json["Seq"],
      fieldtypeid: json["FIELDTYPEID"],
      fieldtypedesc: json["FIELDTYPEDESC"],
      orgPath: json["OrgPath"],
      code: json["CODE"],
      doctypeprefix: json["DOCTYPEPREFIX"],
      noshift: json["NOSHIFT"],
      mappedslid: json["MAPPEDSLID"],
      mappedsldesc: json["MAPPEDSLDESC"],
      mappedslcode: json["MAPPEDSLCODE"],
      planttype: json["PLANTTYPE"],
      planttypedesc: json["PLANTTYPEDESC"],
      geosalesid: json["GEOSALESID"],
      gslocdesc: json["GSLOCDESC"],
      intertransacctid: json["INTERTRANSACCTID"],
      glcode: json["GLCODE"],
      gldesc: json["GLDESC"],
      currencyid: json["currencyid"],
      currencydesc: json["currencydesc"],
    );
  }
}

class Alert {
  Alert({
    required this.statusid,
    required this.name,
    required this.extra,
  });

  final int? statusid;
  final String? name;
  final String? extra;

  factory Alert.fromJson(Map<String, dynamic> json){
    return Alert(
      statusid: json["statusid"],
      name: json["name"],
      extra: json["EXTRA"],
    );
  }

}

class Color {
  Color({
    required this.id,
    required this.text,
  });

  final int? id;
  final String? text;

  factory Color.fromJson(Map<String, dynamic> json){
    return Color(
      id: json["id"],
      text: json["text"],
    );
  }

}

class Customer {
  Customer({
    required this.custid,
    required this.custcode,
    required this.customer,
  });

  final int? custid;
  final String? custcode;
  final String? customer;

  factory Customer.fromJson(Map<String, dynamic> json){
    return Customer(
      custid: json["CUSTID"],
      custcode: json["CUSTCODE"],
      customer: json["CUSTOMER"],
    );
  }

}

class FgCode {
  FgCode({
    required this.itemid,
    required this.itemcode,
    required this.itemdesc,
    required this.erpitemid,
    required this.uom,
  });

  final int? itemid;
  final String? itemcode;
  final String? itemdesc;
  final int? erpitemid;
  final String? uom;

  factory FgCode.fromJson(Map<String, dynamic> json){
    return FgCode(
      itemid: json["ITEMID"],
      itemcode: json["ITEMCODE"],
      itemdesc: json["ITEMDESC"],
      erpitemid: json["ERPITEMID"],
      uom: json["UOM"],
    );
  }

}

class ItemSubgroup {
  ItemSubgroup({
    required this.grpid,
    required this.grpcode,
    required this.grpdesc,
    required this.inventory,
    required this.isactive,
    required this.isauth,
    required this.pgrpid,
    required this.autoitemcode,
    required this.itemtypeid,
    required this.itemtypedesc,
    required this.uomid,
    required this.uomname,
    required this.maingrpid,
    required this.maingrpdesc,
    required this.isparam,
  });

  final int? grpid;
  final String? grpcode;
  final String? grpdesc;
  final bool? inventory;
  final bool? isactive;
  final bool? isauth;
  final int? pgrpid;
  final bool? autoitemcode;
  final int? itemtypeid;
  final String? itemtypedesc;
  final int? uomid;
  final String? uomname;
  final int? maingrpid;
  final String? maingrpdesc;
  final int? isparam;

  factory ItemSubgroup.fromJson(Map<String, dynamic> json){
    return ItemSubgroup(
      grpid: json["GRPID"],
      grpcode: json["GRPCODE"],
      grpdesc: json["GRPDESC"],
      inventory: json["INVENTORY"],
      isactive: json["ISACTIVE"],
      isauth: json["ISAUTH"],
      pgrpid: json["PGRPID"],
      autoitemcode: json["AUTOITEMCODE"],
      itemtypeid: json["ITEMTYPEID"],
      itemtypedesc: json["ITEMTYPEDESC"],
      uomid: json["UOMID"],
      uomname: json["UOMNAME"],
      maingrpid: json["MAINGRPID"],
      maingrpdesc: json["MAINGRPDESC"],
      isparam: json["ISPARAM"],
    );
  }

}

class Project {
  Project({
    required this.projectId,
    required this.name,
    required this.projectno,
    // Add other fields from your JSON here
  });

  final int? projectId;
  final String? name;
  final String? projectno;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json["PROJID"], // Verify JSON keys
      name: json["PROJDESC"],
      projectno: json["PROJNO"],
    );
  }
}

class SONO {
  SONO({
    required this.usoid,
    required this.sono,


  });

  final int? usoid;
  final String? sono;


  factory SONO.fromJson(Map<String, dynamic> json) {
    return SONO(
      usoid: json["USOID"], // Verify JSON keys
      sono: json["SONO"],
    );
  }
}
