import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/firebase_services.dart';

class ChatService {
  CollectionReference chat = FirebaseFirestore.instance.collection('chat');

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

  sendmessage(chatDoc, receiver, sender, text, timeStamp, isImg, replyTo,
      {pushToken}) async {
    await chat.doc(chatDoc).collection('messages').doc().set({
      'receiver': receiver,
      'sender': sender,
      'text': text,
      'timeStamp': timeStamp,
      'isImg': isImg,
      'replyTo': replyTo,
    });
    FirebaseServices()
        .sendNotificationApi(pushToken, 'Sent by : $sender', text);
  }
}
