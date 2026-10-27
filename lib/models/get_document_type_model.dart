class DocumentTypeModel {

  int? dOCID;
  String? dOCDESC;





  DocumentTypeModel({


    this.dOCID,
    this.dOCDESC,



  });

  // Convert a Breed into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'dOCID': dOCID,
      'dOCDESC': dOCDESC,


    };
  }

  factory DocumentTypeModel.fromMap(Map<String, dynamic> map) {
    return DocumentTypeModel(
      dOCID: map['dOCID'] ?? '',
      dOCDESC: map['dOCDESC'] ?? '',



    );
  }



}