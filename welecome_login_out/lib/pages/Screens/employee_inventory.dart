// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/Inventory/employee_inventory_access.dart';
import 'package:welecome_login_out/pages/Profile/employee_profile.dart';
import 'package:welecome_login_out/main.dart';
import 'package:welecome_login_out/pages/Tasks/employee_inventory_task.dart';
import 'package:welecome_login_out/pages/admin/employee.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:welecome_login_out/pages/notifications/inventory_employee_noti.dart';

class EmployeeInventoryTabsScreen extends StatefulWidget {
  const EmployeeInventoryTabsScreen(
      {Key? key, required this.userCredential, required this.userId,
      required this.merchantId,
      required this.signedInUserEmail
    
      })
      : super(key: key);

  final UserCredential userCredential;
  final String userId;
  final String merchantId;
    final String signedInUserEmail;
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<EmployeeInventoryTabsScreen> {
  int selectedPageIndex = 0;
    var fbm = FirebaseMessaging.instance;


  void _selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

 @override
  void initState() {
    fbm.getToken().then((token) {
      print('token: $token');
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final pages = [
      InventoryEmployeeScreen(
        userId: widget.merchantId,
        userCredential: widget.userCredential,
        signedInUserEmail: widget.signedInUserEmail,
      ),
     EmployeeInventoryTasks(userId: widget.userId, userCredential: widget.userCredential),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const MyApp();
                  },
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Approved.PrimaryColor,
              ),
              child: Image.asset("assets/images/menu.png"),
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Approved.PrimaryColor,
              ),
              title: Text(S.of(context).Profile),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EmployeeProfilePage(
                        userCredential: widget.userCredential,
                        userId: widget.userId,
                        merchantId: widget.merchantId,
                      );
                    },
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.chat,
                color: Approved.PrimaryColor,
              ),
              title: Text(S.of(context).Chat),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomeUsersEmployee( signedInUserEmail: widget.signedInUserEmail,);
                    },
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.notifications,
                color: Approved.PrimaryColor,
              ),
              title: Text(S.of(context).Notifications),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return InventoryEmployeeNotificatiosPage(
                        userId: widget.userId,
                        userCredential: widget.userCredential,
                        merchantId: widget.merchantId,
                        signedInUserEmail: widget.signedInUserEmail,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: Approved.PrimaryColor,
              ),
              title: Text(S.of(context).LogOut),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const MyApp();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: pages[selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPageIndex,
        onTap: _selectPage,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.inventory_2_rounded,
            ),
            label: S.of(context).Inventory,
          ),
      
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.task,
            ),
            label: 'Tasks',
          ),
          
        ],
      ),
    );
  }
}
