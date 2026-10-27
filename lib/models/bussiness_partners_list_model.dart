class BusinessPartnersListModel {
  final int id;
  final String code;
  final String desc;
  final String type;
  final String address;
  final String email;
  final String phone;
  final String mobile;
  final String vendorCode;
  final String city;
  final String contactPerson;
  final String uom;
  final String creditAccountDetail;
  final String fax;
  final String contactPersonName;
  final String contactPersonDesignation;
  final String contactPersonMobile;
  final String contactPersonFax;
  final String contactPersonEmail;
  final String salespersonName;

  BusinessPartnersListModel({
    required this.id,
    required this.code,
    required this.desc,
    required this.type,
    required this.address,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.vendorCode,
    required this.city,
    required this.contactPerson,
    required this.uom,
    required this.creditAccountDetail,
    required this.fax,
    required this.contactPersonName,
    required this.contactPersonDesignation,
    required this.contactPersonMobile,
    required this.contactPersonFax,
    required this.contactPersonEmail,
    required this.salespersonName,
  });

  // Convert a map into a BussinessPartnersListModel instance
  factory BusinessPartnersListModel.fromMap(Map<String, dynamic> map) {
    return BusinessPartnersListModel(
      id: map['SLID'] ?? 0,
      code: map['SLCODE'] ?? '',
      desc: map['SLDESC'] ?? '',
      type: map['SLTYPE'] ?? '',
      address: map['ADDRESS'] ?? '',
      email: map['EMAIL'] ?? '',
      phone: map['PHONE'] ?? '',
      mobile: map['MOBILE'] ?? '',
      vendorCode: map['VENDORCODE'] ?? '',
      city: map['CITY'] ?? '',
      contactPerson: map['CONTACTPERSON'] ?? '',
      uom: map['UOM'] ?? '',
      creditAccountDetail: map['CREDITACCOUNTDETAIL'] ?? '',
      fax: map['FAX'] ?? '',
      contactPersonName: map['CONTACTPERSON_NAME'] ?? '',
      contactPersonDesignation: map['CONTACTPERSON_DESIGNATION'] ?? '',
      contactPersonMobile: map['CONTACTPERSON_MOBILE'] ?? '',
      contactPersonFax: map['CONTACTPERSON_FAX'] ?? '',
      contactPersonEmail: map['CONTACTPERSON_EMAIL'] ?? '',
      salespersonName: map['SALESPERSONNAME'] ?? '',
    );
  }

  // Convert a BussinessPartnersListModel instance into a map
  Map<String, dynamic> toMap() {
    return {
      'SLID': id,
      'SLCODE': code,
      'SLDESC': desc,
      'SLTYPE': type,
      'ADDRESS': address,
      'EMAIL': email,
      'PHONE': phone,
      'MOBILE': mobile,
      'VENDORCODE': vendorCode,
      'CITY': city,
      'CONTACTPERSON': contactPerson,
      'UOM': uom,
      'CREDITACCOUNTDETAIL': creditAccountDetail,
      'FAX': fax,
      'CONTACTPERSON_NAME': contactPersonName,
      'CONTACTPERSON_DESIGNATION': contactPersonDesignation,
      'CONTACTPERSON_MOBILE': contactPersonMobile,
      'CONTACTPERSON_FAX': contactPersonFax,
      'CONTACTPERSON_EMAIL': contactPersonEmail,
      'SALESPERSONNAME': salespersonName,
    };
  }
}