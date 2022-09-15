import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/widgets/chat/single_Image_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class MessageList extends StatefulWidget {
  bool string;
  bool file;
  final String docId;
  var message;
  final String receiverId;
  final String senderId;
  final DateTime createdAt;
  //final String userImage;
  final bool isMe;

  MessageList(
    this.string,
    this.file,
    this.docId,
    this.message,
    this.receiverId,
    this.senderId,
    this.createdAt,
    //this.userImage,
    this.isMe,
  );

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  String txt = '';
  String txt2 = '';
  final widgetKey = GlobalKey();
  bool selected = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    print('docId: ${widget.docId}');
    String formattedDateTime = DateFormat.yMMMEd().format(widget.createdAt);
    String formatted = DateFormat.jm().format(widget.createdAt);

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: GestureDetector(
          key: widgetKey,
          onLongPress: () async {
            // widget.isMe ? _showDialog(context) : null;
            widget.isMe
                ? setState(() {
                    selected = !selected;
                  })
                : null;
            widget.isMe ? _showTopSheet(context) : null;
          },
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topLeft: widget.isMe ? Radius.circular(12) : Radius.circular(0),
              topRight: widget.isMe ? Radius.circular(0) : Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            color: widget.isMe ? Color(0xffdcf8c6) : Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: widget.file ? 8 : 75,
                    top: 5,
                    bottom: widget.file ? 25 : 10,
                  ),
                  child: widget.string
                      ? Text(
                          widget.message,
                          style: TextStyle(fontSize: 16),
                        )
                      : widget.file
                          ? InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: ((context) => SingleImagePreview(
                                          widget.message,
                                          formattedDateTime,
                                        ))));
                              },
                              child: Container(
                                  child: CachedNetworkImage(
                                height: 300,
                                width: MediaQuery.of(context).size.width - 100,
                                fit: BoxFit.cover,
                                imageUrl: widget.message,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              )),
                            )
                          : null,
                ),
                Positioned(
                    bottom: 4,
                    right: 10,
                    child: Row(
                      children: [Text(formatted)],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showTopSheet(BuildContext context) {
    return showTopModalSheet(
      context,
      Container(
        height: 90,
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.delete),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* Future<dynamic> _ShowDialog(BuildContext context) {
    return showMenu(
        context: context,
        position: _getRelativeRect(widgetKey),
        items: <PopupMenuEntry>[
          PopupMenuItem(
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  //_showDialog(context);
                },
                child: Container(child: Text('delete'))),
          )
        ]);
  }*/

  Future<dynamic> _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('Do you want to delete ${widget.message}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage() {
    print(widget.senderId);

// Delete message from user side
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.senderId)
        .collection('messages')
        .doc(widget.receiverId)
        .collection('chats')
        .where('id', isEqualTo: widget.docId)
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
        //print('ttt ${ds['text']}');
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('messages')
          .doc(widget.receiverId)
          .collection('chats')
          .orderBy('id')
          .get()
          .then((value) {
        for (DocumentSnapshot ds in value.docs) {
          txt = ds['text'];
          print('del: ${ds['text']}');
          print(user!.uid);
          print(widget.senderId);
          print(widget.receiverId);

          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.isMe ? widget.senderId : widget.receiverId)
              .collection('messages')
              .doc(widget.isMe ? widget.receiverId : widget.senderId)
              .collection('chats')
              .orderBy('id')
              .get()
              .then((value) {
            for (DocumentSnapshot ds in value.docs) {
              FirebaseFirestore.instance
                  .collection('users')
                  //.doc(user!.uid)
                  .doc(widget.isMe ? widget.senderId : widget.receiverId)
                  .collection('messages')
                  .doc(widget.isMe ? widget.receiverId : widget.senderId)
                  .update({
                'last_msg': ds['text'],
                'createdAt': ds['createdAt'],
                'type': 'text',
                'id': ds['id']
              });
            }
          });
        }
      });
    });

// Delete message from friend side

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .collection('messages')
        .doc(user!.uid)
        .collection('chats')
        .where('id', isEqualTo: widget.docId)
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
        print(ds['text']);
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.receiverId)
          .collection('messages')
          .doc(user!.uid)
          .collection('chats')
          .orderBy('id')
          .get()
          .then((value) {
        for (DocumentSnapshot ds in value.docs) {
          //txt2 = ds['text'];
          print('user: ${user!.uid}');
          print('sender: ${widget.senderId}');
          print('receiver: ${widget.receiverId}');

          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.isMe ? widget.receiverId : widget.senderId)
              .collection('messages')
              .doc(widget.isMe ? widget.senderId : widget.receiverId)
              .collection('chats')
              .orderBy('id')
              .get()
              .then((value) {
            for (DocumentSnapshot ds in value.docs) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.isMe ? widget.receiverId : widget.senderId)
                  .collection('messages')
                  .doc(widget.isMe ? widget.senderId : widget.receiverId)
                  .update({
                'last_msg': ds['text'],
                'createdAt': ds['createdAt'],
                'type': 'text',
                'id': ds['id']
              });
            }
          });
        }
      });
    });
  }
}
