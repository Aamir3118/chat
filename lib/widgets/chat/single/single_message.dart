import 'package:chat/widgets/chat/single/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';

class SingleMessage extends StatelessWidget {
  final String newId;

  SingleMessage(this.newId);
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('messages')
          .doc(newId)
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctxcontext, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasError) {
          return Text("Something went wrong");
        }
        if (streamSnapshot.connectionState == ConnectionState.active) {
          print(streamSnapshot.connectionState);
        }
        if (streamSnapshot.hasData) {
          if (streamSnapshot.data!.docs.length < 1) {
            return Center(
              child: Text('Say Hi'),
            );
          }
          final chatDocs = streamSnapshot.data!.docs;

          return GroupedListView<dynamic, String>(
            reverse: true,
            sort: false,
            elements: chatDocs,
            groupBy: (element) {
              if (element['createdAt'].toDate().day == DateTime.now().day) {
                return 'Today';
              } else if (element['createdAt'].toDate().day ==
                  DateTime.now().day - 1) {
                return 'Yesterday';
              }
              return DateFormat.yMMMEd().format(element['createdAt'].toDate());
            },
            groupSeparatorBuilder: (String groupByValue) => Center(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('$groupByValue'),
                  )),
            ),
            itemBuilder: (context, dynamic element) {
              bool isMe = element['senderId'] == user!.uid;
              var string1 = element['type'] == 'text';
              var file1 = element['type'] == 'img';
              return //Text(element['text']);
                  MessageList(
                      string1,
                      file1,
                      element['id'],
                      string1 ? element['text'] : element['text'],
                      element['receiverId'],
                      element['senderId'],
                      element['createdAt'].toDate(),
                      isMe);
            },
            floatingHeader: true, // optional
            order: GroupedListOrder.ASC, // optional
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
