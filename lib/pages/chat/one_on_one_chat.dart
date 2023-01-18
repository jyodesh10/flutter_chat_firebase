import 'dart:convert';
import 'dart:developer' as l;
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_service.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class OneOnOneChat extends StatefulWidget {
  OneOnOneChat({
    super.key,
    this.username,
    this.email,
    this.chatDoc,
    this.pushToken,
    this.profilePic,
  });
  String? username;
  String? email;
  String? chatDoc;
  String? pushToken;
  String? profilePic;
  static const routename = '/oneOnone';

  @override
  State<OneOnOneChat> createState() => _OneOnOneChatState();
}

class _OneOnOneChatState extends State<OneOnOneChat> {
  final ImagePicker _picker = ImagePicker();
  var selectedProductImage = '';
  double selectedProductSize = 0.1;
  bool isReply = false;
  String textToReplyTo = '';
  final msg = TextEditingController();
  bool runnning = false;
  final currentuser = FirebaseAuth.instance.currentUser;
  final storageRef = FirebaseStorage.instance.ref();

  addImg() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedProductImage = pickedImage.path;
        selectedProductSize = File(selectedProductImage)
            .readAsBytesSync()
            .lengthInBytes
            .toDouble();
      });
    } else {}
  }

  uploadImg(name) async {
    if (selectedProductImage != "") {
      storageRef
          .child("chat/${widget.chatDoc}/$name.jpg")
          .putFile(File(selectedProductImage))
          .snapshotEvents
          .listen((event) {
        if (event.state == TaskState.success) {
          storageRef
              .child("chat/${widget.chatDoc}/$name.jpg")
              .getDownloadURL()
              .then((value) => ChatService().sendmessage(
                  widget.chatDoc,
                  widget.email,
                  currentuser!.email,
                  value,
                  // storageRef.child("chat/chatDoc/$name.jpg").getDownloadURL(),
                  DateTime.now().toLocal(),
                  true,
                  '',
                  pushToken: widget.pushToken));
        }
      });
    } else {
      l.log('No image selected');
    }
  }

  reply() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: Text(widget.username!),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          buildBody(),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildBottomInput(),
          )
        ],
      ),
      // bottomNavigationBar: buildBottomInput()
    );
  }

  buildBody() {
    return SingleChildScrollView(
      reverse: true,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .doc(widget.chatDoc)
            .collection('messages')
            .orderBy("timeStamp", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10).copyWith(
                    bottom: isReply ? 105 : 60,
                  ),
                  physics: const BouncingScrollPhysics(),
                  reverse: true,
                  itemBuilder: (context, index) {
                    final data = snapshot.data?.docs;
                    return Align(
                      alignment:
                          //  data![index]['receiver'] ||
                          data![index]['sender'] ==
                                  FirebaseAuth.instance.currentUser!.email
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: PopupMenuButton(
                        position: PopupMenuPosition.over,
                        offset: const Offset(40, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        enabled: data[index]['sender'] ==
                                FirebaseAuth.instance.currentUser!.email
                            ? false
                            : true,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            height: 40,
                            child: Row(
                              children: const [
                                Icon(Icons.reply),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Reply")
                              ],
                            ),
                            onTap: () {
                              // print(snapshot.data?.docs[index]['replyTo']);
                              setState(() {
                                isReply = true;
                                textToReplyTo =
                                    //  "asdsad";
                                    snapshot.data?.docs[index]['text'];
                              });
                            },
                          ),
                        ],
                        child: Column(
                          crossAxisAlignment: data[index]['sender'] ==
                                  FirebaseAuth.instance.currentUser!.email
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            snapshot.data?.docs[index]['replyTo'] == ''
                                ? Container()
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.grey.shade600),
                                    child: Text(
                                        snapshot.data?.docs[index]['replyTo']),
                                  ),
                            Row(
                              mainAxisAlignment: data[index]['sender'] ==
                                      FirebaseAuth.instance.currentUser!.email
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                data[index]['sender'] ==
                                        FirebaseAuth.instance.currentUser!.email
                                    ? Container()
                                    : CircleAvatar(
                                        radius: 15,
                                        backgroundImage: NetworkImage(
                                            widget.profilePic.toString()),
                                      ),
                                const SizedBox(
                                  width: 10,
                                ),
                                //message box
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                        color: data[index]['sender'] ==
                                                FirebaseAuth
                                                    .instance.currentUser!.email
                                            ? Colors.purple
                                            : Colors.blue,
                                        borderRadius: BorderRadius.circular(15).copyWith(
                                            topLeft: data[index]['receiver'] ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.email
                                                ? const Radius.circular(0)
                                                : const Radius.circular(15),
                                            bottomRight: data[index]['sender'] ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.email
                                                ? const Radius.circular(0)
                                                : const Radius.circular(15))),
                                    child: snapshot.data?.docs[index]['isImg'] == false
                                        ? Text(snapshot.data?.docs[index]['text'])
                                        : Image.network(
                                            snapshot.data?.docs[index]['text'],
                                            // "https://firebasestorage.googleapis.com/v0/b/auth-3725d.appspot.com/o/images%2F25.jpg?alt=media&token=bc0677cb-437f-430b-aeb6-25ea79846a93",
                                            height: 150,
                                            fit: BoxFit.fitHeight,
                                          )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  buildBottomInput() {
    return Material(
      child: Container(
        height: isReply ? 105 : 60,
        color: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isReply
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Reply To:"),
                            Text(textToReplyTo),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isReply = false;
                                textToReplyTo = '';
                              });
                            },
                            icon: const Icon(Icons.close))
                      ],
                    ),
                  )
                : Container(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 15,
                ),
                Flexible(
                    child: TextField(
                  controller: msg,
                )),
                IconButton(
                    onPressed: () async {
                      await addImg();
                      int i = Random().nextInt(100);
                      uploadImg(i);
                    },
                    icon: const Icon(Icons.add_a_photo)),
                IconButton(
                    onPressed: () {
                      // print(widget.pushToken);
                      // FirebaseServices().sendNotificationApi(
                      //     widget.pushToken, 'hello', 'jyodes');
                      if (isReply) {
                        ChatService().sendmessage(
                            widget.chatDoc,
                            widget.email,
                            currentuser!.email,
                            msg.text,
                            DateTime.now().toLocal(),
                            false,
                            textToReplyTo,
                            pushToken: widget.pushToken);
                        msg.clear();
                      } else {
                        ChatService().sendmessage(
                            widget.chatDoc,
                            widget.email,
                            currentuser!.email,
                            msg.text,
                            DateTime.now().toLocal(),
                            false,
                            '',
                            pushToken: widget.pushToken);
                        msg.clear();
                      }
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
            isReply
                ? const SizedBox(
                    height: 5,
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
