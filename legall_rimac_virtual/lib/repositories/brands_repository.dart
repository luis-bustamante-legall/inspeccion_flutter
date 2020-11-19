import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legall_rimac_virtual/models/models.dart';

class BrandsRepository {
  final _brandCollection = FirebaseFirestore.instance.collection('brands');

  Stream<List<BrandModel>> search(String searchTerm) {
    return _brandCollection
        .snapshots()
        .map((docs) => docs
          .docs
          .map((doc) => BrandModel.fromJSON(data: doc.data(),id: doc.id))
          .where((brand) => brand?.brandName?.toLowerCase()?.contains(searchTerm)?? false).toList());
  }
  
  Future<BrandModel> get(String brandId) async {
    var docRef = await _brandCollection.doc(brandId).get();
    if (docRef.exists)
      return BrandModel.fromJSON(data: docRef.data(),id: docRef.id);
    else
      return null;
  }
}