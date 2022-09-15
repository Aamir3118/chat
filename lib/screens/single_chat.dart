import 'dart:io';
import 'dart:math';

import 'package:chat/widgets/chat/single/single_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';

class SingleChat extends StatefulWidget {
  String status;
  String userId;
  bool uid;
  String userName;
  String userImage;
  SingleChat(this.status, this.userId, this.uid, this.userName, this.userImage);
  @override
  State<SingleChat> createState() => _SingleChatState();
}

class _SingleChatState extends State<SingleChat> {
  String formattedDateTime = DateFormat.yMMMEd().format(DateTime.now());

  final _controller = TextEditingController();
  var _enteredMessage = '';
  //final getUser = FirebaseFirestore.instance.collection('users').get();
  final user = FirebaseAuth.instance.currentUser;

  final picker = ImagePicker();
  File? _pickedImage;
  void _fromGallery() async {
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    _sendImage();
  }

  void _fromCamera() async {
    final pickedImage = await picker.getImage(
      source: ImageSource.camera,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    _sendImage();
  }

  void _remove() async {
    //final picker = ImagePicker();

    setState(() {
      _pickedImage = null;
    });
  }

  void _sendMessage() async {
    //print(check.persistenceEnabled);

    final user = await FirebaseAuth.instance.currentUser;
    DateTime now = DateTime.now();
    DateTime ct = DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    print('ct: $ct');
    FocusScope.of(context).unfocus();

//Sending text to current user id

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('messages')
        .doc(widget.userId)
        .collection('chats')
        .doc();
    docRef.set({
      'type': 'text',
      'senderId': user.uid,
      'receiverId': widget.userId,
      'text': _enteredMessage,
      'createdAt': DateTime.now(),
      'id': ct.toString(),
    }).then((value) => FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('messages')
            .doc(widget.userId)
            .set({
          'last_msg': _enteredMessage,
          'createdAt': DateTime.now(),
          'type': 'text',
          'id': ct.toString(),
        }));

//Sending text to friend id

    DocumentReference docRef2 = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('messages')
        .doc(user.uid)
        .collection('chats')
        .doc();
    docRef2.set({
      'type': 'text',
      'senderId': user.uid,
      'receiverId': widget.userId,
      'text': _enteredMessage,
      'createdAt': DateTime.now(),
      'id': ct.toString()
      //'username': userData.data()!['username'],
      //'userImage': userData.data()!['image_url'],
    }).then((value) => FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('messages')
            .doc(user.uid)
            .set({
          'last_msg': _enteredMessage,
          'createdAt': DateTime.now(),
          'type': 'text',
          'id': ct.toString(),
        }));

    _controller.clear();
    print(DateFormat.yMMMEd().format(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    print(widget.status);
    //print('user: ${widget.userId}');
    return Scaffold(
      appBar: _appBar(),

      //backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          Container(
            child: Image.asset(
              'assets/images/chat_background.png',
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(child: SingleMessage(widget.userId)),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 5, top: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          style: TextStyle(fontSize: 14),
                          minLines: 1,
                          maxLines: 7,
                          autocorrect: true,
                          controller: _controller,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              //textColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                _showBottomSheet(context);
                              },
                              //height: 45,
                              icon: Icon(Icons.image),
                              // label: Text("Add Image"),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            // hintStyle: TextStyle(height: 3),
                            hintText: 'Send a message...',
                            // hintStyle: TextStyle(fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _enteredMessage = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: CircleAvatar(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                              color: Colors.white,
                              icon: const Icon(
                                Icons.send,
                              ),
                              onPressed: () {
                                _enteredMessage.trim().isEmpty
                                    ? null
                                    //: check.persistenceEnabled == false
                                    //  ? null
                                    : _sendMessage();
                              }),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      // automaticallyImplyLeading: false,
      leadingWidth: 25,
      title: Container(
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.userImage),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              //mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.userName),
                Text(
                  widget.status == 'Unavailable'
                      ? 'Offline'
                      : widget.status, //streamSnapshot.data!['status'],
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _fromCamera();
                },
                //_fromCamera,
                leading: Icon(Icons.camera),
                title: Text('Take a photo'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _fromGallery();
                },
                leading: Icon(Icons.image),
                title: Text('Choose from gallery'),
              ),
            ],
          );
        });
  }

  void _sendImage() async {
    var now = DateTime.now().toString();
    final ref =
        FirebaseStorage.instance.ref().child('send_image').child(now + '.jpg');

    await ref.putFile(_pickedImage!).whenComplete(() async {
      final url = await ref.getDownloadURL();

      final user = await FirebaseAuth.instance.currentUser;

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('messages')
          .doc(widget.userId)
          .collection('chats')
          .doc();
      docRef.set({
        'type': 'img',
        'senderId': user.uid,
        'receiverId': widget.userId,
        'text': url,
        'createdAt': DateTime.now(),
        'id': docRef.id
      }).then((value) => FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('messages')
          .doc(widget.userId)
          .set({'last_msg': url, 'createdAt': DateTime.now(), 'type': 'img'}));

      DocumentReference docRef2 = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('messages')
          .doc(user.uid)
          .collection('chats')
          .doc();
      docRef2.set({
        'type': 'img',
        'senderId': user.uid,
        'receiverId': widget.userId,
        'text': url,
        'createdAt': DateTime.now(),
        'id': docRef2.id
        //'username': userData.data()!['username'],
        //'userImage': userData.data()!['image_url'],
      }).then((value) => FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('messages')
          .doc(user.uid)
          .set({'last_msg': url, 'createdAt': DateTime.now(), 'type': 'img'}));

      //widget.imageFn(pickedImageFile);
    });
  }
}
