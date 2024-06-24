import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';

class AdminNotificatiosPage extends StatefulWidget {
  @override
  _AdminNotificationsPageState createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificatiosPage> {
  String _title = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: Text('Admin Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Title',
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Container(
              height: 200, // Adjust the height as needed
              child: TextFormField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  labelText: 'Description\n\n.',
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Implement send notification logic here
                _sendNotification();
              },
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendNotification() {
    // Implement your logic to send notification here
    // For demonstration, we'll just print the title and description
    print('Title: $_title');
    print('Description: $_description');
    // You can replace this with your actual logic to send notifications
    // e.g., send HTTP request to a server, call a notification service, etc.
  }
}

