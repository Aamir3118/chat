import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/widgets/chat/group_chat_preview.dart';
import 'package:chat/widgets/chat/single_Image_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class MessageBubble extends StatefulWidget {
  MessageBubble(this.userId, this.msgId, this.string, this.file, this.message,
      this.createdAt, this.userName, this.userImage, this.isMe,
      {required this.key});

  final String userId;
  final String msgId;
  bool string;
  bool file;
  var message;
  final DateTime createdAt;
  final bool isMe;
  final String userName;
  final String userImage;
  final Key key;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final user = FirebaseAuth.instance.currentUser;
  var deletemsg = 'message deleted';
  final widgetKey = GlobalKey();
  bool selected = false;
  String? selectedId;
  @override
  Widget build(BuildContext context) {
    String formatted = DateFormat.jm().format(widget.createdAt);
    String formattedDateTime = DateFormat.yMMMEd().format(widget.createdAt);
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 45),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GestureDetector(
            key: widgetKey,
            onLongPress: () async {
              widget.isMe
                  ? showTopModalSheet(
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
                    )
                  : null;
              //print(widget.msgId);
              // print(widget.message);
              widget.isMe
                  ? setState(() {
                      selected = !selected;
                    })
                  : null;
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  topLeft:
                      widget.isMe ? Radius.circular(12) : Radius.circular(0),
                  topRight:
                      widget.isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )),
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                color: widget.isMe ? Color(0xffdcf8c6) : Colors.white,
                child: Stack(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 5),
                        child: Text(
                          widget.userName,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget.isMe ? Colors.black : Colors.purple),
                        ),
                      ),
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  GroupImagePreview(
                                                      widget.message,
                                                      formattedDateTime))));
                                    },
                                    child: Container(
                                        child: CachedNetworkImage(
                                      height: 300,
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      fit: BoxFit.cover,
                                      imageUrl: widget.message,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )),
                                  )
                                : null,
                      ),
                    ],
                  ),
                  Positioned(
                      bottom: 4,
                      right: 10,
                      child: Row(
                        children: [Text(formatted)],
                      ))
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
              FirebaseFirestore.instance
                  .collection('chat')
                  .doc(widget.msgId)
                  .delete();
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }
}
