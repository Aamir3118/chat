import 'package:chat/screens/single_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersList extends StatefulWidget {
  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Users'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('/users').snapshots(),
            builder: (ctxcontext, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasError) {
                return Text("Something went wrong");
              }
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (streamSnapshot.data!.docs.length < 1) {
                return const Center(
                  child: Text('No data'),
                );
              }

              final usersList = streamSnapshot.data!.docs;
              return ListView.builder(
                  itemCount: usersList.length,
                  itemBuilder: (ctx, index) => AllUsers(
                        usersList[index]['status'],
                        usersList[index].id,
                        usersList[index].id == user!.uid,
                        usersList[index]['username'],
                        usersList[index]['image_url'],
                      ));
            }),
      ),
    );
  }
}

class AllUsers extends StatelessWidget {
  String status;
  String uid;
  bool isMe;
  String userName;
  String imageUrl;
  AllUsers(this.status, this.uid, this.isMe, this.userName, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return !isMe
        ? GestureDetector(
            onTap: () {
              print('Reciver uid: $uid');
              print('user: $userName');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) =>
                      SingleChat(status, uid, isMe, userName, imageUrl)));
              print('isMe: $isMe');
            },
            child: ListTile(
              horizontalTitleGap: 25,
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(imageUrl),
              ),
              title: Text(userName),
            ),
          )
        : Container();
  }
}
