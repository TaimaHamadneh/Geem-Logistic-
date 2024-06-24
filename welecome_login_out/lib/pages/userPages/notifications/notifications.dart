import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'dart:convert';

import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/userPages/Screen/userpage.dart';

class UserNotificatiosPage extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  const UserNotificatiosPage(
      {Key? key,
      required this.userId,
      required this.userCredential,
      required this.signedInUserEmail})
      : super(key: key);

  @override
  State<UserNotificatiosPage> createState() => _NotificatiosPageState();
}

class _NotificatiosPageState extends State<UserNotificatiosPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
  fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response =
          await http.get(Uri.parse(url + 'notifications/${widget.userId}'));
      print(url + 'notifications/${widget.userId}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        Set<String> uniqueDates = Set();

        data.retainWhere((notification) {
          if (!uniqueDates.contains(notification['date'])) {
            uniqueDates.add(notification['date']);
            return true;
          }
          return false;
        });

        data.sort((a, b) {
          DateTime dateTimeA = DateTime.parse(a['date']);
          DateTime dateTimeB = DateTime.parse(b['date']);
          return dateTimeB.compareTo(dateTimeA);
        });

        setState(() {
          notifications = data.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }


  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse(url + 'notifications/${widget.userId}/$notificationId'),
      );
      print(
          'delete url: ${url + 'notifications/${widget.userId}/$notificationId'}');

      if (response.statusCode == 200) {
        print('Notification deleted successfully');
        setState(() {
          print('Remove the deleted notification from the list');
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserNotificatiosPage(
              userCredential: widget.userCredential,
              userId: widget.userId,
              signedInUserEmail: widget.signedInUserEmail,
            ),
          ),
        );
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
          title: const Text(
            'Notifications ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Approved.PrimaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserTabsScreen(
                            userCredential: widget.userCredential,
                            userId: widget.userId,
                            signedInUserEmail: widget.signedInUserEmail,
                          )),
                );
              })),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildCard(
            notifications[index]['title'],
            notifications[index]['body'],
            notifications[index]['date'],
            notifications[index]['_id'].toString(),
          );
        },
      ),
    );
  }

  Widget _buildCard(
      String title, String body, String date, String notificationId) {
    return Row(children: [
      Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            child: Column(
              children: [
                const SizedBox(
                  height: Approved.defaultPadding / 2,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Approved.PrimaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.notifications,
                                color: Approved.PrimaryColor,
                                size: 24.0,
                              ),
                              Text(
                                title,
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Approved.PrimaryColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                width: Approved.defaultPadding,
                              ),
                            ],
                          ),
                          const SizedBox(height: Approved.defaultPadding / 3),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                            height: 0.0,
                          ),
                          const SizedBox(height: Approved.defaultPadding / 3),
                          Text(
                            body,
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.black),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date: $date',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Approved.PrimaryColor,
                                  size: 24.0,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Approved.PrimaryColor,
                                        title: const Text(
                                          "Confirm Delete",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        content: const Text(
                                          "Are you sure you want to delete this notification?",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteNotification(
                                                  notificationId);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      )
    ]);
  }
}
