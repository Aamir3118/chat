import 'dart:io';

import 'package:chat/widgets/chat/group/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('/chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctxcontext, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasError) {
          return Text("Something went wrong");
        }

        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (streamSnapshot.hasData) {
          if (streamSnapshot.data!.docs.length < 1) {
            return Center(
              child: Text('No data'),
            );
          }
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
                  child: Text(
                    '$groupByValue',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                )),
          ),
          itemBuilder: (context, dynamic element) {
            var string1 = element['type'] == 'text';
            var file1 = element['type'] == 'img';

            return MessageBubble(
              element['userId'],
              element['id'],
              string1,
              file1,
              string1 ? element['text'] : element['text'],
              element['createdAt'].toDate(),
              element['username'],
              element['userImage'],
              element['userId'] == user!.uid,
              key: ValueKey(element.id),
            );
          },
        );
        /* ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) => MessageBubble(
            chatDocs[index]['text'],
            chatDocs[index]['createdAt'].toDate(),
            chatDocs[index]['username'],
            chatDocs[index]['userImage'],
            chatDocs[index]['userId'] == user!.uid,
            key: ValueKey(chatDocs[index].id),
          ),
        );*/
      },
    );
  }
}
