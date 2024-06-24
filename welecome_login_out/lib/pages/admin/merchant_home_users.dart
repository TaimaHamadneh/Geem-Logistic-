// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/pages/admin/chat_screen.dart';

class HomeAdmins extends StatefulWidget {
  final String? signedInUserEmail;

  const HomeAdmins({Key? key, this.signedInUserEmail}) : super(key: key);

  @override
  State<HomeAdmins> createState() => _HomeAdminsState();
}

class _HomeAdminsState extends State<HomeAdmins> {
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

    if (recipientEmails.isEmpty) {
      setState(() {
        usersWithReceivedMessages = [];
      });
      return;
    }

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
Future<void> showAdminSelectionDialog(BuildContext context) async {
  QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('userType', isEqualTo: 'admin')
      .get();

  List<DocumentSnapshot> adminsList = adminSnapshot.docs;

  QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('userType', isEqualTo: 'employee')
      .get();

  List<DocumentSnapshot> employeesList = employeeSnapshot.docs;

  List<DocumentSnapshot> combinedList = [...adminsList, ...employeesList];

  showDialog(
    context: context,
    builder: (BuildContext context) {
       final bool isDesktop = MediaQuery.of(context).size.width > 600;
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: Approved.PrimaryColor,
             contentPadding: EdgeInsets.zero,
             insetPadding: EdgeInsets.all(16.0),
            title: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dialogSearchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Search Admin/Employee',
                      prefixIcon: Icon(Icons.search, color: Colors.white,
                      size: isDesktop ? 40 : 30,),
                      labelStyle: TextStyle(color: Colors.white, 
                      fontSize: isDesktop? 24: 18),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white,
                  size: isDesktop ? 40 : 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.height * 0.6,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView.builder(
                itemCount: combinedList.length,
                itemBuilder: (context, index) {
                  final user = combinedList[index];
                  String name = user['username'].toString().toLowerCase();
                  String query = dialogSearchController.text.toLowerCase();
                  String userType = user['userType'];

                  if (query.isEmpty || name.contains(query)) {
                    return ListTile(
                      title: Text(
                        '${user['username']} - ${userType}',
                        style: TextStyle(color: Colors.white, fontSize:  isDesktop? 22: 18),
                      ),
                      subtitle: Text(
                        user['email'],
                        style: TextStyle(color: Colors.white,
                        fontSize:  isDesktop? 20: 16),
                      ),
                      onTap: () {
                        Navigator.pop(context, user);
                      },
                    );
                  } else {
                    return SizedBox.shrink();
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


/*
  Future<void> showAdminSelectionDialog(BuildContext context) async {
    QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'admin')
        .get();

    List<DocumentSnapshot> adminsList = adminSnapshot.docs;

    QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'employee')
        .get();

    List<DocumentSnapshot> employeesList = employeeSnapshot.docs;

    List<DocumentSnapshot> combinedList = [...adminsList, ...employeesList];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Approved.PrimaryColor,
              title: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dialogSearchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Search Admin/Employee',
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: combinedList.length,
                  itemBuilder: (context, index) {
                    final user = combinedList[index];
                    String name = user['username'].toString().toLowerCase();
                    String query = dialogSearchController.text.toLowerCase();
                    String userType = user['userType'];

                    if (query.isEmpty || name.contains(query)) {
                      return ListTile(
                        title: Text(
                          '${user['username']} - ${userType}',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        subtitle: Text(
                          user['email'],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context, user);
                        },
                      );
                    } else {
                      return SizedBox.shrink();
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
*/
  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        title:  Text('Home Chat', 
        style: TextStyle( fontSize: isDesktop ? 28: 24,
        fontWeight: FontWeight.bold,

        ),
        ),
        backgroundColor: Approved.PrimaryColor,
        centerTitle: true,
      ),
      body: Column(
        
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            
            child: Container(
              width: isDesktop? 1300 : double.infinity,
              color: Colors.white,
              child: TextField(
                controller: searchController,
                decoration:  InputDecoration(
                  labelText: 'Search by name',
                prefixIcon: Icon(Icons.search, size: isDesktop ? 30 : 20),
                labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

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
                String userType = user['userType'] == 'admin' ? 'Admin' : 'Employee';
                return Card(
                             margin: EdgeInsets.symmetric(vertical: isDesktop? 10: 8.0, horizontal: isDesktop? 300 :16.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${user['username']} - $userType',
                              style: TextStyle( fontSize: isDesktop ? 24: 18,
        fontWeight: FontWeight.bold,

        ),),
                              Text(user['email'],
                               style: TextStyle( fontSize: isDesktop ? 20: 16,
        fontWeight: FontWeight.w300,

        )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    leading:  SizedBox(
                      width: isDesktop? 100:50,
                      height: isDesktop? 100:50,
                      child: CircleAvatar(
                        child: Icon(
                          Icons.person,
                          color: Approved.PrimaryColor,
                          size: isDesktop? 50: 30,
                        ),
                      ),
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAdminSelectionDialog(context);
        },
        child:  Icon(Icons.add_comment_rounded, color: Colors.white
        , size: isDesktop ? 40: 30),
        backgroundColor: Approved.PrimaryColor,
        shape: CircleBorder(),
        elevation: 50,
      ),
    );
  }
}
