import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/pages/admin/chat_screen.dart';

class HomeUsers extends StatefulWidget {
  final String? signedInUserEmail;

  const HomeUsers({Key? key, this.signedInUserEmail}) : super(key: key);

  @override
  State<HomeUsers> createState() => _HomeUsersState();
}

class _HomeUsersState extends State<HomeUsers> {
  List<DocumentSnapshot> usersWithReceivedMessages = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController dialogSearchController = TextEditingController();

  Future<void> getUsersWithReceivedMessages() async {
    QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: widget.signedInUserEmail)
        .get();

    Set<String> recipientEmails = {};
    messageSnapshot.docs.forEach((doc) {
      recipientEmails.add(doc['to']);
    });

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', whereIn: recipientEmails.toList())
        .get();

    setState(() {
      usersWithReceivedMessages = userSnapshot.docs;
    });
  }

  @override
  void initState() {
    super.initState();
    getUsersWithReceivedMessages();
  }

  List<DocumentSnapshot> getFilteredUsers() {
    List<DocumentSnapshot> filteredUsers = [];
    if (searchController.text.isEmpty) {
      filteredUsers = usersWithReceivedMessages;
    } else {
      String query = searchController.text.toLowerCase();
      filteredUsers = usersWithReceivedMessages.where((user) {
        return user['username'].toString().toLowerCase().contains(query);
      }).toList();
    }
    return filteredUsers;
  }

  Future<void> showUserSelectionDialog(BuildContext context) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'merchant')
        .get();

    List<DocumentSnapshot> usersList = userSnapshot.docs;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.orangeAccent,
              title: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dialogSearchController,
                      decoration: InputDecoration(
                        labelText: 'Search by name',
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    final user = usersList[index];
                    String name = user['username'].toString().toLowerCase();
                    String query = dialogSearchController.text.toLowerCase();
                    if (query.isEmpty || name.contains(query)) {
                      return ListTile(
                        title: Text(
                          user['username'],
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          user['email'],
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          Navigator.pop(context, user);
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    ).then((selectedUser) {
      if (selectedUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              signedInUserEmail: widget.signedInUserEmail,
              toUserEmail: selectedUser['email'],
              toUserName: selectedUser['username'],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Approved.LightColor,
      body: Column(
        children: [
          Padding(
             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //  padding: const EdgeInsets.all(8.0),
            child: Container(
              
             decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                        borderRadius: BorderRadius.circular(12.0),
                  ),
              
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by name',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredUsers().length,
              itemBuilder: (context, index) {
                final user = getFilteredUsers()[index];
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Container(
                     decoration: BoxDecoration(
                    border: Border.all(
                      color: Approved.PrimaryColor,
                      width: 2,
                    ),
                        borderRadius: BorderRadius.circular(12.0),
                  ),
                    child: Card(
                      margin: const EdgeInsets.all(0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(user['username']),
                              subtitle: Text(user['email']),
                              leading: const CircleAvatar(
                                child: Icon(Icons.person,
                                    color: Approved.PrimaryColor),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      signedInUserEmail: widget.signedInUserEmail,
                                      toUserEmail: user['email'],
                                      toUserName: user['username'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showUserSelectionDialog(context);
        },
        child: const Icon(
          Icons.add_comment_rounded,
          color: Colors.white,
        ),
        backgroundColor: Approved.PrimaryColor,
        shape: const CircleBorder(),
      ),
    );
  }
}
