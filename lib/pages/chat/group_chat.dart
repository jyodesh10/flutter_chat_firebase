import 'dart:developer' as l;
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/pages/chat/chat_service.dart';
import 'package:firebase_chat_app/services/firebase_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key, required this.data});
  final QueryDocumentSnapshot<Object?> data;

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  bool isReply = false;
  String textToReplyTo = '';
  final msg = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  var selectedProductImage = '';
  final storageRef = FirebaseStorage.instance.ref();
  final currentuser = FirebaseAuth.instance.currentUser;

  List<QueryDocumentSnapshot<Object?>> userslist = [];

  @override
  void initState() {
    getusers();
    super.initState();
  }

  getusers() async {
    final data = await FirebaseServices().users.get();
    setState(() {
      userslist.addAll(data.docs);
    });
    print('first$userslist');
    // if (data.docs.isNotEmpty) {
    //   for (int i = 0; i <= data.docs.length - 1; i++) {
    //     userslist.(data.docs[i]);

    //   }
    // }
  }

  addImg() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedProductImage = pickedImage.path;
      });
    } else {}
  }

  uploadImg(name) async {
    if (selectedProductImage != "") {
      storageRef
          .child("group_chat/$name.jpg")
          .putFile(File(selectedProductImage))
          .snapshotEvents
          .listen((event) {
        if (event.state == TaskState.success) {
          storageRef
              .child("chat/$name.jpg")
              .getDownloadURL()
              .then((value) => ChatService().sendGrpmessage(
                  widget.data.id,
                  '',
                  currentuser!.email,
                  value,
                  // storageRef.child("chat/chatDoc/$name.jpg").getDownloadURL(),
                  DateTime.now().toLocal(),
                  true,
                  '',
                  pushToken: ''));
        }
      });
    } else {
      l.log('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['group_name']),
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
    );
  }

  buildBody() {
    return SingleChildScrollView(
      reverse: true,
      child: StreamBuilder(
        stream: ChatService()
            .group
            .doc(widget.data.id)
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
                      alignment: data![index]['sender'] ==
                              FirebaseAuth.instance.currentUser!.email
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: data[index]['sender'] ==
                                FirebaseAuth.instance.currentUser!.email
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          data[index]['sender'] ==
                                  FirebaseAuth.instance.currentUser!.email
                              ? Container()
                              : Column(
                                  children: [
                                    ...List.generate(
                                      userslist.length,
                                      (i) => userslist[i].id ==
                                              data[index]['sender']
                                          ? CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  userslist[0]['profile_img']),
                                            )
                                          : Container(),
                                    )
                                  ],
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                                color: data[index]['sender'] ==
                                        FirebaseAuth.instance.currentUser!.email
                                    ? Colors.purple
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(15)
                                    .copyWith(
                                        topLeft: data[index]['sender'] !=
                                                FirebaseAuth
                                                    .instance.currentUser!.email
                                            ? const Radius.circular(0)
                                            : const Radius.circular(15),
                                        bottomRight: data[index]['sender'] ==
                                                FirebaseAuth
                                                    .instance.currentUser!.email
                                            ? const Radius.circular(0)
                                            : const Radius.circular(15))),
                            child: Text(snapshot.data?.docs[index]['text']),
                          ),
                        ],
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
                      if (isReply) {
                        ChatService().sendGrpmessage(
                            widget.data.id,
                            '',
                            currentuser!.email,
                            msg.text,
                            DateTime.now().toLocal(),
                            false,
                            textToReplyTo,
                            pushToken: '');
                        msg.clear();
                      } else {
                        ChatService().sendGrpmessage(
                            widget.data.id,
                            '',
                            currentuser!.email,
                            msg.text,
                            DateTime.now().toLocal(),
                            false,
                            '',
                            pushToken: '');
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
