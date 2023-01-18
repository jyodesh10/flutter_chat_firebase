import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String password;
  String username;
  int id;

  UserModel(
      {required this.email,
      required this.password,
      required this.username,
      required this.id});

  UserModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : email = doc.data()!['email'],
        password = doc.data()!['email'],
        id = doc.data()!['id'],
        username = doc.data()!['username'];
}
