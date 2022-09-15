import 'package:chat/screens/single_chat.dart';
import 'package:chat/screens/users_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AddFriends extends StatefulWidget {
  @override
  State<AddFriends> createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  final user = FirebaseAuth.instance.currentUser;
  var friendTextType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .collection('messages')
              .snapshots(),
          builder: (ctx, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              if (streamSnapshot.data!.docs.length < 1) {
                return Center(
                  child: Text('No Chats Available !'),
                );
              }
              return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    friendTextType = streamSnapshot.data!.docs[index]['type'];
                    var friendId = streamSnapshot.data!.docs[index].id;
                    var lastMsg = streamSnapshot.data!.docs[index]['last_msg'];
                    var createdAt =
                        streamSnapshot.data!.docs[index]['createdAt'].toDate();

                    String formatted2 = DateFormat.jm().format(createdAt);

                    String formatted = '';
                    print(DateTime.now().weekday);
                    if (createdAt.day == DateTime.now().day) {
                      formatted = formatted2;
                    } else if (createdAt.day == DateTime.now().day - 1) {
                      print('Yesterday');
                      formatted = 'Yesterday';
                    } else {
                      formatted = DateFormat.yMMMEd().format(createdAt);
                    }

                    //final yesterday = DateTime(createdAt.day);

                    return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(friendId)
                          .get(),
                      builder: (ctx, AsyncSnapshot streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          var friend = streamSnapshot.data;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                friend['image_url'],
                              ),
                            ),
                            title: Text(
                              friend['username'],
                            ),
                            subtitle: Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: friendTextType == 'text'
                                      ? Text(
                                          '$lastMsg',
                                          maxLines: 1,
                                          style: TextStyle(color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : Row(
                                          children: const <Widget>[
                                            Icon(
                                              Icons.photo,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text('Photo'),
                                          ],
                                        ),
                                ),
                                Text('$formatted'),
                              ],
                            )),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => SingleChat(
                                        friend['status'],
                                        friendId,
                                        user!.uid ==
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user!.uid),
                                        friend['username'],
                                        friend['image_url'],
                                      )));
                            },
                          );
                        }
                        return LinearProgressIndicator();
                      },
                    );
                  });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => UsersList()));
        },
      ),
    );
  }
}
