import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'dart:convert';

import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';

class NotificatiosPage extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  const NotificatiosPage({Key? key, 
  required this.signedInUserEmail
  ,
  required this.userId, required this.userCredential}) : super(key: key);

  @override
  State<NotificatiosPage> createState() => _NotificatiosPageState();
}

class _NotificatiosPageState extends State<NotificatiosPage> {
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
      Uri.parse(url+'notifications/${widget.userId}/$notificationId'),
    );
    print('delete url: ${url+'notifications/${widget.userId}/$notificationId'}');

    if (response.statusCode == 200) {
      print('Notification deleted successfully');
      setState(() {
        print('Remove the deleted notification from the list');
      });
       Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NotificatiosPage(
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
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        centerTitle: true,
        title:  Text(
          'Notifications ',
          style: TextStyle(fontSize: isDesktop? 28: 20, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Approved.PrimaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TabsScreen(
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
    if (title.startsWith("Order Added")) {
      return Container();
    }
    if (title == "Your order status") {
      return Container();
    }
    if (title == "New Task Added ") {
      return Container();
    }
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Row(children: [
      Expanded(
        child: Card(
                     margin: EdgeInsets.symmetric(vertical: isDesktop? 20: 8.0, horizontal: isDesktop? 100 :16.0),

          color: Colors.white,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                     Icon(
                      Icons.notifications,
                      color: Approved.PrimaryColor,
                      size:isDesktop? 30: 24.0,
                    ),
                    const SizedBox(width: Approved.defaultPadding / 2),
                    Text(
                      title,
                      style:  TextStyle(
                          fontSize:isDesktop? 22: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Approved.PrimaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      width: Approved.defaultPadding,
                    ),
                   
                  ],
                ),
                const SizedBox(height: Approved.defaultPadding / 2),
                const Divider(
                  color: Colors.grey,
                  thickness: 1.0,
                  height: 0.0,
                ),
                const SizedBox(height: Approved.defaultPadding / 2),
                Text(
                  body,
                  style:  TextStyle(fontSize: isDesktop? 20:16.0, color: Colors.black),
                ),
                const SizedBox(height: 8.0),
               Row(
                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                children: [ 
                 Text(
                  'Date: $date',
                  style:  TextStyle(
                    fontSize: isDesktop? 18: 14.0,
                    color: Colors.grey,
                  ),
                ),
                 IconButton(
                      icon:  Icon(
                        Icons.delete,
                        color: Approved.PrimaryColor,
                        size: isDesktop? 30:24.0,
                      ),
                      onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Approved.PrimaryColor,
          title:  Text("Confirm Delete", style: TextStyle( 
            fontSize: isDesktop ?22: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),),
          content:  Text("Are you sure you want to delete this notification?",
          style: TextStyle( 
            fontSize: isDesktop ?20: 16,
             color: Colors.white
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child:  Text("Cancel", style: TextStyle( 
            fontSize: isDesktop ?22: 18,
             color: Colors.white
          ),),
            ),
            TextButton(
              onPressed: () {
                deleteNotification(notificationId);
                Navigator.of(context).pop();
              },
              child:  Text("Delete", style: TextStyle( 
            fontSize: isDesktop ?22: 18,
             color: Colors.white
          ),),
            ),
          ],
        );
      },
    );
  },
                    ),
               ],)
              ],
            ),
          ),
        ),
      )
    ]);
  }
}
