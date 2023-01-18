import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/user_model.dart';
import '../../services/firebase_services.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();

  final email = TextEditingController();

  final password = TextEditingController();

  var userlist = <UserModel>[];

  final _picker = ImagePicker();
  String imgPicked = '';
  final storageRef = FirebaseStorage.instance.ref();

  @override
  void initState() {
    super.initState();
  }

  addPhoto() async {
    final pickedImg = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImg != null) {
      setState(() {});
      imgPicked = pickedImg.path;
    }
  }

  upoloadImg(name, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    storageRef
        .child("user/$name.jpg")
        .putFile(File(imgPicked))
        .snapshotEvents
        .listen((event) {
      if (event.state == TaskState.success) {
        storageRef.child("user/$name.jpg").getDownloadURL().then((value) =>
            FirebaseServices().addUser(username.text, email.text, password.text,
                value, snapshot.data!.docs.length + 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                addPhoto();
              },
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 40,
                  child: imgPicked != ''
                      ? Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.file(File(imgPicked)),
                        )
                      : const Icon(Icons.add_a_photo),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('Email'),
            TextField(
              controller: email,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Username'),
            TextField(
              controller: username,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Password`'),
            TextField(
              controller: password,
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: FirebaseServices().users.get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  return MaterialButton(
                      child: const Text('SUBMIT'),
                      onPressed: () async {
                        await upoloadImg(email.text, snapshot);
                        // FirebaseServices().addUser(
                        //     username.text,
                        //     email.text,
                        //     password.text,
                        //     snapshot.data!.docs.length + 1);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ));
                      });
                })
          ],
        ),
      ),
    );
  }
}
