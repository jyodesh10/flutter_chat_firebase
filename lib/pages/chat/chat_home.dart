// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/pages/chat/group_chat.dart';
import 'package:firebase_chat_app/pages/chat/widgets/floating_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/firebase_services.dart';
import 'chat_service.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  static const routename = '/chat';

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;

  late int currentuserId;
  var selectedProductImage = '';
  final storageRef = FirebaseStorage.instance.ref();

  final groupname = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    FirebaseServices()
        .users
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({"status": true});
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }

  var chatDocs = [];

  fetchChat() async {
    final data = await ChatService().getChat();
    for (int i = 0; i <= data.docs.length; i++) {
      chatDocs.add(data.docs[i].id);
    }
  }

  final currentuser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FirebaseServices()
            .users
            .doc(FirebaseAuth.instance.currentUser?.email)
            .update({"status": false});
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            title: const Text("Chat"),
            actions: [
              IconButton(
                  onPressed: () {
                    context.go('/');
                  },
                  icon: const Icon(Icons.logout))
            ],
            bottom: const PreferredSize(
                preferredSize: Size(double.infinity, 60),
                child: TabBar(tabs: [
                  Tab(
                    text: 'People',
                    icon: Icon(Icons.person),
                  ),
                  Tab(
                    text: 'Groups',
                    icon: Icon(Icons.group),
                  ),
                ])),
          ),
          body: TabBarView(children: [_buildPeopleTab(), _buildGroupsTab()]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const FloatingButton();
                  });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('disposed');
    WidgetsBinding.instance.removeObserver(this);

    FirebaseServices()
        .users
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({"status": false});
    super.dispose();
  }

  _buildPeopleTab() {
    return StreamBuilder(
      stream: FirebaseServices().users.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) => FirebaseAuth
                        .instance.currentUser!.email !=
                    snapshot.data?.docs[index]['email']
                ? Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      onTap: () async {
                        for (int i = 0;
                            i <= snapshot.data!.docs.length - 1;
                            i++) {
                          if (currentuser!.email ==
                              snapshot.data?.docs[i]['email']) {
                            currentuserId = snapshot.data?.docs[i]['id'];
                            // print(currentuserId);
                          }
                        }
                        print(currentuserId);

                        await ChatService().createChat(
                            currentuserId > snapshot.data?.docs[index]['id']
                                ? "$currentuserId-${snapshot.data?.docs[index]['id']}"
                                : "${snapshot.data?.docs[index]['id']}-$currentuserId",
                            currentuser!.email,
                            snapshot.data?.docs[index]['email']);
                        context.pushNamed('oneOnone', queryParams: {
                          'username': snapshot.data?.docs[index]['username'],
                          'email': snapshot.data?.docs[index]['email'],
                          'chatDoc': currentuserId >
                                  snapshot.data?.docs[index]['id']
                              ? "$currentuserId-${snapshot.data?.docs[index]['id']}"
                              : "${snapshot.data?.docs[index]['id']}-$currentuserId",
                          'pushToken': snapshot.data?.docs[index]['pushToken'],
                          'profilePic': snapshot.data?.docs[index]
                              ['profile_img'],
                        });
                      },
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black45,
                        backgroundImage: NetworkImage(
                            snapshot.data?.docs[index]['profile_img']),
                      ),
                      title: Text(snapshot.data?.docs[index]['username']),
                      subtitle: Text(snapshot.data?.docs[index]['email']),
                      trailing: CircleAvatar(
                        radius: 5,
                        backgroundColor:
                            snapshot.data?.docs[index]['status'] == true
                                ? Colors.green.shade300
                                : Colors.black45,
                      ),
                    ),
                  )
                : Container(),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  _buildGroupsTab() {
    return StreamBuilder(
      stream: FirebaseServices().groups.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black45,
                    backgroundImage:
                        NetworkImage(snapshot.data?.docs[index]['group_img']),
                  ),
                  title: Text(snapshot.data?.docs[index]['group_name']),
                  trailing: snapshot.data!.docs[index]['members']
                          .contains(currentuser?.email)
                      ? const Text('')
                      : TextButton(
                          onPressed: () {
                            ChatService().joinGroup(
                                snapshot.data!.docs[index].id,
                                currentuser?.email);
                          },
                          child: const Text('Join')),
                  onTap: () {
                    snapshot.data!.docs[index]['members']
                            .contains(currentuser?.email)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChat(
                                data: snapshot.data!.docs[index],
                              ),
                            ))
                        : Scaffold.of(context).showSnackBar(const SnackBar(
                            content: Text('Not in theis group')));
                  },
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
