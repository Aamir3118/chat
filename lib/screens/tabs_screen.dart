import 'package:chat/add_friends.dart';
import 'package:chat/screens/group_chat.dart';
import 'package:chat/screens/users_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabsScrren extends StatefulWidget {
  @override
  State<TabsScrren> createState() => _TabsScrrenState();
}

class _TabsScrrenState extends State<TabsScrren> with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
    super.initState();
  }

  void setStatus(String status) async {
    QuerySnapshot<Map<String, dynamic>> _query =
        await FirebaseFirestore.instance.collection('users').get();
    if (_query.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update(
        {
          "status": status,
        },
      ).then((value) => null);
    } else {
      print("Collection not exists");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    QuerySnapshot<Map<String, dynamic>> _query =
        await FirebaseFirestore.instance.collection('users').get();
    if (_query.docs.isNotEmpty) {
      if (state == AppLifecycleState.resumed) {
        setStatus("Online");
      } else {
        setStatus("Offline");
      }
    } else {
      print('Not exists');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Let\'s chat'),
          actions: [
            Row(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.exit_to_app,
                                color: Theme.of(context).accentColor),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                        value: 'logout',
                      ),
                    ],
                    onChanged: (itemIdentifier) {
                      if (itemIdentifier == 'logout') {
                        FirebaseAuth.instance.signOut();
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          ],
          bottom: const TabBar(tabs: <Widget>[
            Tab(
              text: 'Group',
            ),
            Tab(
              text: 'Chats',
            ),
          ]),
        ),
        body: TabBarView(children: <Widget>[
          ChatScreen(),
          AddFriends(),
          //UsersList(),
        ]),
      ),
    );
  }
}
