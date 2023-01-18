import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String category;
  String detail;
  String name;
  int price;

  ProductModel({
    required this.category,
    required this.detail,
    required this.name,
    required this.price,
  });

  ProductModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : category = doc.data()!['product_category'],
        detail = doc.data()!['product_detail'],
        name = doc.data()!['product_name'],
        price = doc.data()!['product_price'];
}
