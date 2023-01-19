// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../chat_service.dart';

class FloatingButton extends StatefulWidget {
  const FloatingButton({super.key});

  @override
  State<FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  final _picker = ImagePicker();
  var selectedProductImage = '';
  final storageRef = FirebaseStorage.instance.ref();
  final currentuser = FirebaseAuth.instance.currentUser;

  final groupname = TextEditingController();
  addImg() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedProductImage = pickedImage.path;
      });
    } else {}
  }

  createGroup(name) async {
    if (selectedProductImage != "") {
      storageRef
          .child("group/$name.jpg")
          .putFile(File(selectedProductImage))
          .snapshotEvents
          .listen((event) {
        if (event.state == TaskState.success) {
          storageRef.child("group/$name.jpg").getDownloadURL().then((value) =>
              ChatService().createGroup(name, value, currentuser?.email));
        }
      });
    } else {
      log('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Create a Group'),
      contentPadding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            addImg();
          },
          child: CircleAvatar(
            radius: 30,
            child: selectedProductImage != ''
                ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.file(File(selectedProductImage)),
                  )
                : const Icon(Icons.add_a_photo),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Center(child: Text('Add Group Image')),
        const SizedBox(
          height: 15,
        ),
        TextField(
          controller: groupname,
          decoration: const InputDecoration(hintText: 'Group Name'),
        ),
        const SizedBox(
          height: 15,
        ),
        MaterialButton(
          onPressed: () {
            if (selectedProductImage != '' && groupname.text.isNotEmpty) {
              createGroup(groupname.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
