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
import 'package:intl/intl.dart';

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
  late ScrollController scrollController;
  bool replyIsImg = false;

  List<QueryDocumentSnapshot<Object?>> userslist = [];

  @override
  void initState() {
    getusers();
    scrollController = ScrollController();
    scroll();

    super.initState();
  }

  void scroll() async {
    scrollController.addListener(() {
      print(scrollController.offset.toString());
    });
    Future.delayed(
      const Duration(seconds: 1),
      () => scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn),
    );
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
          .child("group_chat/${widget.data['group_name']}/$name.jpg")
          .putFile(File(selectedProductImage))
          .snapshotEvents
          .listen((event) {
        if (event.state == TaskState.success) {
          storageRef
              .child("group_chat/${widget.data['group_name']}/$name.jpg")
              .getDownloadURL()
              .then((value) => ChatService().sendGrpmessage(
                  widget.data.id,
                  '',
                  currentuser!.email,
                  value,
                  // storageRef.child("chat/chatDoc/$name.jpg").getDownloadURL(),
                  DateTime.now().toLocal(),
                  true,
                  false,
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
      controller: scrollController,
      // reverse: true,
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
                    Timestamp timestamp = data![index]['timeStamp'];
                    DateTime d = timestamp.toDate();
                    String formatted = DateFormat('kk:mm').format(d);
                    return Column(
                      crossAxisAlignment: data[index]['sender'] ==
                              FirebaseAuth.instance.currentUser!.email
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            formatted.toString(),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        snapshot.data?.docs[index]['replyTo'] == ''
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  print("oFFSET ${scrollController.offset}");
                                  scrollController.animateTo(108.50214420988739,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.ease);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: data[index]['sender'] ==
                                              FirebaseAuth
                                                  .instance.currentUser!.email
                                          ? 0
                                          : 40),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.grey.shade600),
                                  child: snapshot.data?.docs[index]
                                              ['replyIsImg'] ==
                                          true
                                      ? Image.network(
                                          snapshot.data?.docs[index]['replyTo'],
                                          height: 100,
                                        )
                                      : Text(snapshot.data?.docs[index]
                                          ['replyTo']),
                                ),
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
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ...List.generate(
                                        userslist.length,
                                        (i) => userslist[i].id ==
                                                data[index]['sender']
                                            ? CircleAvatar(
                                                radius: 15,
                                                backgroundImage: NetworkImage(
                                                    userslist[i]
                                                        ['profile_img']),
                                                child: Text(index.toString()))
                                            : Container(),
                                      )
                                    ],
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            PopupMenuButton(
                                position: PopupMenuPosition.over,
                                offset: Offset(
                                    data[index]['sender'] == FirebaseAuth.instance.currentUser!.email
                                        ? 10
                                        : -10,
                                    50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 1,
                                        enabled: data[index]['sender'] ==
                                                FirebaseAuth
                                                    .instance.currentUser!.email
                                            ? false
                                            : true,
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
                                                snapshot.data?.docs[index]
                                                    ['text'];
                                          });
                                          if (snapshot.data?.docs[index]
                                                  ['isImg'] ==
                                              true) {
                                            replyIsImg = true;
                                          } else {
                                            replyIsImg = false;
                                          }
                                        },
                                      ),
                                      PopupMenuItem(
                                        value: 1,
                                        enabled: data[index]['sender'] !=
                                                FirebaseAuth
                                                    .instance.currentUser!.email
                                            ? false
                                            : true,
                                        height: 40,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.delete),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("Delete")
                                          ],
                                        ),
                                        onTap: () {
                                          ChatService().deleteGrpMsg(
                                              widget.data.id, data[index].id);
                                        },
                                      ),
                                    ],
                                child: snapshot.data?.docs[index]['isImg'] ==
                                        false
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        margin:
                                            const EdgeInsets.only(bottom: 5),
                                        decoration: BoxDecoration(
                                            color: data[index]['sender'] == FirebaseAuth.instance.currentUser!.email
                                                ? Colors.purple
                                                : Colors.blue,
                                            borderRadius: BorderRadius.circular(15).copyWith(
                                                topLeft: data[index]['sender'] != FirebaseAuth.instance.currentUser!.email
                                                    ? const Radius.circular(0)
                                                    : const Radius.circular(15),
                                                bottomRight: data[index]
                                                            ['sender'] ==
                                                        FirebaseAuth.instance.currentUser!.email
                                                    ? const Radius.circular(0)
                                                    : const Radius.circular(15))),
                                        child: Text(snapshot.data?.docs[index]['text']))
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FadeInImage(
                                          placeholder: const AssetImage(
                                            'assets/logo.png',
                                          ),
                                          image: NetworkImage(
                                            snapshot.data?.docs[index]['text'],
                                          ),
                                          height: 150,
                                        )
                                        // Image.network(
                                        //   snapshot.data?.docs[index]['text'],
                                        //   // "https://firebasestorage.googleapis.com/v0/b/auth-3725d.appspot.com/o/images%2F25.jpg?alt=media&token=bc0677cb-437f-430b-aeb6-25ea79846a93",
                                        //   height: 150,

                                        //   fit: BoxFit.fitHeight,

                                        //   loadingBuilder: (context, child,
                                        //       loadingProgress) {
                                        //     print(loadingProgress
                                        //         ?.expectedTotalBytes
                                        //         .toString());
                                        //     if (loadingProgress == null) {
                                        //       return child;
                                        //     }
                                        //     return const CircularProgressIndicator();
                                        //   },
                                        // ),
                                        )),
                          ],
                        ),
                      ],
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
        height: isReply == true ? 130 : 60,
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
                            replyIsImg == true
                                ? Image.network(
                                    textToReplyTo,
                                    height: 50,
                                  )
                                : Text(textToReplyTo),
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
                            replyIsImg,
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
