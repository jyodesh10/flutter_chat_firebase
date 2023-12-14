import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../pages/chat/chat_home.dart';

class FirebaseServices {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference cart = FirebaseFirestore.instance.collection('cart');
  CollectionReference groups = FirebaseFirestore.instance.collection('groups');

  var uuid = '';
  createUser(String emailAddress, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      uuid = credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  signIn(String emailAddress, String password, context) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);

      if (credential.user!.uid.isNotEmpty) {
        log('Logged in');
        // context.push(
        //   HomePage.routeName,
        // );
        GoRouter.of(context).push(ChatHome.routename
            // HomePage.routeName
            );
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => HomePage(),
        //     ));
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> addUser(
    String username,
    String email,
    String password,
    String profileImg,
    int id,
  ) async {
    // Call the user's CollectionReference to add a new user
    await createUser(email, password);

    users.doc(email).set({
      "username": username,
      "email": email,
      "password": password,
      "uuid": uuid,
      "profile_img": profileImg,
      "id": id,
      'pushToken': '',
      'status': false
    })
        // .add({
        //   'name': fullName, // John Doe
        // })
        .then((value) {
      print('user Added');
    }).catchError((error) => print("Failed to add user: $error"));
  }

  List documents = [];

  getUsers() async {
    await users.get().then((QuerySnapshot value) {
      // print(value.docs[0].id);
      for (int i = 0; i < value.docs.length; i++) {
        print(value.docs[i].id.toString());
        documents.add(value.docs[i].id.toString());
      }
      print(documents.toString());
      // for (var element in value.docs) {
      //   documents.add(element.id);
      // }
    });

    // print(data.toString());
  }

  Future<void> addtoCart(String useremail,
      {id, category, detail, name, price, qty}) async {
    // Call the user's CollectionReference to add a new user
    // cart.doc(productId).set({
    //   "uuid": [uid]
    // }, SetOptions(merge: true)).then((value) {
    //   print('product Added to Cart');
    // }).catchError((error) => print("Failed to add product: $error"));

    // cart.doc(productId).update({
    //   "uuid": FieldValue.arrayUnion([uid])
    // });
    FirebaseFirestore.instance
        .collection('users')
        .doc(useremail)
        .collection('cart')
        .doc(name)
        .set({
      "product_id": id,
      "product_category": category,
      "product_detail": detail,
      "product_name": name,
      "product_price": price,
      "qty": qty,
    }).then((value) => print('added to cart'));
  }

  Future<void> addtoOrder(String useremail,
      {required List productList, status}) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(useremail)
        .collection('order')
        .doc()
        .set({
      "products": productList,
      "status": status,
    }).then((value) => print('added to cart'));
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }

  verifyEmail() async {
    try {
      await FirebaseAuth.instance.sendSignInLinkToEmail(
          email: "jyodeshshakya@gmail.com",
          actionCodeSettings: ActionCodeSettings(
              url: "https://jyodes.page.link",
              androidInstallApp: true,
              // minimumVersion
              androidMinimumVersion: '12',
              handleCodeInApp: true));
    } on FirebaseAuthException catch (e) {
      log(e.toString());
    }
  }

  Future<void> sendNotificationApi(pushToken, body, title) async {
    try {
      final data = jsonEncode({
        "to": pushToken,
        "notification": {"body": body, "title": title}
      });
      var res = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: data,
          headers: {
            "Authorization":
                "key=AAAAJLwsNuc:APA91bFMTGbLgpsCi65hPv9v8Yd0i7RylZVXqjHW5SZwWKOoCK8G7daP6oKGhyWuCs7GvDI_YfyMzF_C6R9N3sNDDwBikwKH5c8Ijeg0g3w00zPU0yfSru2gK5fKHiKpO_CHXefkd_VN",
            "Content-Type": "application/json"
          });
      print(res.statusCode);
      print(data);
      if (res.statusCode == 200) {
        log('Notification sent via firebase api');
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Future<void> deleteGrp(docID) async {
    await groups.doc(docID).delete();
  }
}
