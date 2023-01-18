import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../services/firebase_services.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String fireToken = '';

  @override
  void initState() {
    FirebaseServices().getUsers();
    getFCMToken();
    email.text = 'jyodeshshakya@gmail.com';
    password.text = '123456';

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      FlutterLocalNotificationsPlugin();
    });

    super.initState();
  }

  getFCMToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log("Token : " + fcmToken.toString());
    fireToken = fcmToken.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FutureBuilder(
            //   future: FirebaseServices().users.get(),
            //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //     if (snapshot.hasError) {
            //       return Text('Eor');
            //     }
            //     if (snapshot.hasData) {
            //       final allData =
            //           snapshot.data!.docs.map((doc) => doc).toList();
            //       return Text(allData[0].id.toString());
            //     }
            //     return CircularProgressIndicator();
            //   },
            // ),
            Text(FirebaseServices().documents.length.toString()),
            const Text('Email'),
            TextField(
              controller: email,
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
            MaterialButton(
                child: const Text('SUBMIT'),
                onPressed: () async {
                  // FirebaseServices().verifyEmail();
                  if (fireToken != '') {
                    await FirebaseServices()
                        .signIn(email.text, password.text, context);

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .update({'pushToken': fireToken});
                  }
                }),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
                child: const Text('REGISTER'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ));
                })
          ],
        ),
      ),
    );
  }
}
