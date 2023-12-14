import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/firebase_services.dart';

class ChatService {
  CollectionReference chat = FirebaseFirestore.instance.collection('chat');
  CollectionReference group = FirebaseFirestore.instance.collection('groups');

  createChat(chatDoc, user1, user2) async {
    // final data =await getChat();
    // data.docs.
    chat.doc(chatDoc).set({
      'user_1': user1,
      'user_2': user2,
    }).then((value) => log('CHAT Created'));
  }

  Future<QuerySnapshot<Object?>> getChat() async {
    final data = await chat.get();
    return data;
    // for (int i = 0; i <= data.docs.length; i++) {
    //   print(data.docs[i].id);
    // }
  }

  sendmessage(
      chatDoc, receiver, sender, text, timeStamp, isImg, replyIsImg, replyTo,
      {pushToken}) async {
    await chat.doc(chatDoc).collection('messages').doc().set({
      'receiver': receiver,
      'sender': sender,
      'text': text,
      'timeStamp': timeStamp,
      'isImg': isImg,
      'replyIsImg': replyIsImg,
      'replyTo': replyTo,
    });
    FirebaseServices()
        .sendNotificationApi(pushToken, 'Sent by : $sender', text);
  }

  deleteMsg(chatDoc, msg) async {
    await chat.doc(chatDoc).collection('messages').doc(msg).delete();
  }

  createGroup(groupName, groupImg, createdBy) async {
    await group.doc().set({
      'group_name': groupName,
      'group_img': groupImg,
      'created_by': createdBy,
      'members': [createdBy]
    });
  }

  joinGroup(groupId, email) async {
    await group.doc(groupId).update({
      'members': FieldValue.arrayUnion([email])
    });
  }

  sendGrpmessage(
      chatDoc, receiver, sender, text, timeStamp, isImg, replyIsImg, replyTo,
      {pushToken}) async {
    await group.doc(chatDoc).collection('messages').doc().set({
      'receiver': receiver,
      'sender': sender,
      'text': text,
      'timeStamp': timeStamp,
      'isImg': isImg,
      'replyIsImg': replyIsImg,
      'replyTo': replyTo,
    });
    FirebaseServices()
        .sendNotificationApi(pushToken, 'Sent by : $sender', text);
  }

  deleteGrpMsg(chatDoc, msg) async {
    await group.doc(chatDoc).collection('messages').doc(msg).delete();
  }
}
