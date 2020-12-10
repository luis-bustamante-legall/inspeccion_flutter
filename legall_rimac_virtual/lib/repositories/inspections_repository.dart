import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legall_rimac_virtual/models/models.dart';

class InspectionsRepository {
  final _inspectionCollection = FirebaseFirestore.instance.collection('inspections');

  Stream<InspectionModel> get(String inspectionId) {
    return _inspectionCollection
        .where(FieldPath.documentId,isEqualTo: inspectionId)
        .snapshots()
        .map((docs) => docs.docs.length > 0 ? InspectionModel.fromJSON(docs.docs.first.data(),id: inspectionId) : null);
  }

  Future<InspectionModel> fromId(String id) async {
    var inspections = await _inspectionCollection
        .where(FieldPath.documentId,isEqualTo: id)
        .get();

    if (inspections.docs.isEmpty) {
      return null;
    }
    else {
      var doc = inspections.docs.first;
      return InspectionModel.fromJSON(doc.data(),id: doc.id);
    }
  }

  Future<void> updateStatus(InspectionModel inspectionModel) {
    return _inspectionCollection
        .doc(inspectionModel.inspectionId)
        .update(inspectionModel.toJSONWithUpdateStatus()
      );
  }

  Future<void> updateData(InspectionModel inspectionModel) {
    return _inspectionCollection
        .doc(inspectionModel.inspectionId)
        .update(inspectionModel.toJSONWithInspectionData()
    );
  }

  Future<void> updateSchedule(InspectionModel inspectionModel) {
    return _inspectionCollection
        .doc(inspectionModel.inspectionId)
        .update(inspectionModel.toJSONWithSchedule()
    );
  }
}