import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  var _enteredMessage = '';

  final picker = ImagePicker();
  File? _pickedImage;
  void _fromGallery() async {
    //final picker = ImagePicker();
    // ignore: deprecated_member_use
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    _sendImage();
    //widget.imageFn(pickedImageFile);
  }

  void _fromCamera() async {
    //final picker = ImagePicker();
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
    setState(() {
      _pickedImage = null;
    });
  }

  void _sendMessage() async {
    final user = await FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    FocusScope.of(context).unfocus();
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('chat').doc();

    docRef.set({
      'type': 'text',
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
      'id': docRef.id
    });
    _controller.clear();
  }

//  final recorder = FlutterSoundRecorder();

//  Codec _codec = Codec.aacMP4;
//  String _mPath = 'my_audio.mp4';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 5),
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
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed:
                      _enteredMessage.trim().isEmpty ? null : _sendMessage,
                ),
              ),
            )
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
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _remove();
                },
                leading: Icon(Icons.delete_rounded),
                title: Text('Remove photo'),
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
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('chat').doc();
      docRef.set({
        'type': 'img',
        'text': url,
        'createdAt': DateTime.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
        'id': docRef.id,
      });
    });
  }
}
