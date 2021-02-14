import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legall_rimac_virtual/models/models.dart';

class BrandsRepository {
  final _brandCollection = FirebaseFirestore.instance.collection('brands');

  Future<List<BrandModel>> search(String searchTerm) async {
    return (await _brandCollection
        .where('brand_name',isGreaterThanOrEqualTo: searchTerm.toUpperCase())
        .limit(20)
        .get())
        .docs
        .map((doc) => BrandModel.fromJSON(data: doc.data(),id: doc.id))
        .toList();
  }
  
  Future<BrandModel> get(String brandId) async {
    var docRef = await _brandCollection.doc(brandId).get();
    if (docRef.exists)
      return BrandModel.fromJSON(data: docRef.data(),id: docRef.id);
    else
      return null;
  }
}