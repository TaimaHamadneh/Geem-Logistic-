// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/Tasks/manage_task.dart';
import 'package:welecome_login_out/pages/admin/merchant_home_users.dart';
import 'package:welecome_login_out/pages/dashboard/dashboard.dart';
import 'package:welecome_login_out/pages/Order/manage_order.dart';
import 'package:welecome_login_out/pages/emplyee/manage_emplyee.dart';
import 'package:welecome_login_out/main.dart';
import 'package:welecome_login_out/pages/Inventory/invntory_test.dart';
import 'package:welecome_login_out/pages/Profile/profile_screen.dart';
import 'package:welecome_login_out/pages/notifications/notifications.dart';
import 'package:welecome_login_out/pages/warehouses/warehouses.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:welecome_login_out/pages/userPages/Screen/userpage.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen(
      {Key? key,
      required this.userCredential,
      required this.userId,
      required this.signedInUserEmail})
      : super(key: key);

  final UserCredential userCredential;
  final String userId;
  final String signedInUserEmail;
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int selectedPageIndex = 0;
  var fbm = FirebaseMessaging.instance;

  void _selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  initMessage() async {
    var message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      Navigator.of(context).pushNamed("TabsScreen");
    }
  }

  requestPermession() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }


  Future<void> addNotification(
      String title, String body, String date, String id) async {
    try {
      var reqBody = {
        'userId': widget.userId,
        'title': title,
        'body': body,
        "date": date,
        
        "id": id
      };

      var response = await http.post(
        Uri.parse(url + 'addnotifications'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Notification added successfully');
      } else {
        print('Failed to add Notification');
      }
    } catch (e) {
      print('Error adding Notification: $e');
    }
  }

  @override
  void initState() {
    requestPermession();

    fbm.getToken().then((token) {
      print('token: $token');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.of(context).pushNamed("TabsScreen");
    });

    Set<String> processedNotificationIds = Set();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String notificationId = message.data['id'];
      print('*******************Notification*******************');
      print('${message.notification!.title}');
      print('${message.notification!.body}');
      print('${message.data['date']}');
      if (!processedNotificationIds.contains(notificationId)) {
        processedNotificationIds.add(notificationId);
        addNotification(
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          DateTime.parse(message.data['date']).toString(),
          notificationId,
        );

      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   final isDesktop = MediaQuery.of(context).size.width > 600;

    final pages = [
      Dashboard(
        userId: widget.userId,
      ),
      Warehouses(
        userId: widget.userId,
        userCredential: widget.userCredential,
        signedInUserEmail: widget.signedInUserEmail,
      ),
      InventoryScreen(
        userId: widget.userId,
        userCredential: widget.userCredential,
        signedInUserEmail: widget.signedInUserEmail,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        actions: [
          IconButton(
            icon: const Tooltip(
              message: 'Switch to User Screen',
              child: Icon(
                Icons.transfer_within_a_station_sharp,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return UserTabsScreen(
                      userCredential: widget.userCredential,
                      userId: widget.userId,
                      signedInUserEmail: widget.signedInUserEmail,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
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
      drawer: isDesktop ?  
      SizedBox(
        width: 300,
        
        child: Drawer(
        
         elevation: 4,
          child: ListView(
            
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                    borderRadius: null,
                   
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
                        return ProfilePage(
                          userCredential: widget.userCredential,
                          userId: widget.userId,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.shopping_cart_sharp,
                  color: Approved.PrimaryColor,
                ),
                title: Text(S.of(context).Orders),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return OrderPage(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
                        );
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
                        return NotificatiosPage(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
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
                        return HomeAdmins(
                          signedInUserEmail: widget.signedInUserEmail,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.people,
                  color: Approved.PrimaryColor,
                ),
                title: Text(S.of(context).ManageEmployee),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ManageEmployee(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.assignment,
                  color: Approved.PrimaryColor,
                ),
                title: Text(S.of(context).Tasks),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ManageTasks(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
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
      )
      : Drawer(
        
          child: ListView(
            
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  borderRadius: null,
                  color: Approved.PrimaryColor,
                ),
                child: Image.asset("assets/images/menu.png"),
              ),
              ListTile(
                leading:  Icon(
                  Icons.person,
                  color: Approved.PrimaryColor,
                  size:  isDesktop ? 30 :20
                ),
                title: Text(S.of(context).Profile),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ProfilePage(
                          userCredential: widget.userCredential,
                          userId: widget.userId,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(
                  Icons.shopping_cart_sharp,
                  color: Approved.PrimaryColor,
                  size:  isDesktop ? 30 :20
                ),
                title: Text(S.of(context).Orders),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return OrderPage(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(
                  Icons.notifications,
                  color: Approved.PrimaryColor,
                  size:  isDesktop ? 30 :20
                ),
                title: Text(S.of(context).Notifications),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return NotificatiosPage(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(
                  Icons.chat,
                  color: Approved.PrimaryColor,
                  size:  isDesktop ? 30 :20
                ),
                title: Text(S.of(context).Chat),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return HomeAdmins(
                          signedInUserEmail: widget.signedInUserEmail,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(
                  Icons.assignment,
                  color: Approved.PrimaryColor,
                  size:  isDesktop ? 30 :20
                ),
                title: Text(S.of(context).Tasks),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ManageTasks(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(
                  Icons.people,
                  color: Approved.PrimaryColor,
                  size:  isDesktop ? 30 :20
                ),
                title: Text(S.of(context).ManageEmployee),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ManageEmployee(
                          userId: widget.userId,
                          userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(
                  Icons.exit_to_app,
                  color: Approved.PrimaryColor,
                  size:  isDesktop ? 30 :20
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
      body: Row(
        children: [
           if (isDesktop)
            Drawer(
              width: 350,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                  borderRadius: null,
                color: Approved.PrimaryColor,
              ),
              child: Image.asset("assets/images/menu.png"),
            ),
            ListTile(
              leading:  Icon(
                Icons.person,
                color: Approved.PrimaryColor,
                size:  isDesktop ? 30 :20
              ),
              title: Text(S.of(context).Profile,
              style: TextStyle( 
                fontSize:  isDesktop ? 22 :18
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ProfilePage(
                        userCredential: widget.userCredential,
                        userId: widget.userId,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading:  Icon(
                Icons.shopping_cart_sharp,
                color: Approved.PrimaryColor,
                size:  isDesktop ? 30 :20
              ),
              title: Text(S.of(context).Orders,
               style: TextStyle( 
                fontSize:  isDesktop ? 22 :18
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OrderPage(
                        userId: widget.userId,
                        userCredential: widget.userCredential,
                        signedInUserEmail: widget.signedInUserEmail,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.notifications,
                color: Approved.PrimaryColor,
                size:  isDesktop ? 30 :20
              ),
              title: Text(S.of(context).Notifications,
               style: TextStyle( 
                fontSize:  isDesktop ? 22 :18
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return NotificatiosPage(
                        userId: widget.userId,
                        userCredential: widget.userCredential,
                        signedInUserEmail: widget.signedInUserEmail,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading:  Icon(
                Icons.chat,
                color: Approved.PrimaryColor,
                size:  isDesktop ? 30 :20
              ),
              title: Text(S.of(context).Chat,
               style: TextStyle( 
                fontSize:  isDesktop ? 22 :18
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomeAdmins(
                        signedInUserEmail: widget.signedInUserEmail,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading:  Icon(
                Icons.assignment,
                color: Approved.PrimaryColor,
                size:  isDesktop ? 30 :20
              ),
              title: Text(S.of(context).Tasks,
               style: TextStyle( 
                fontSize:  isDesktop ? 22 :18
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ManageTasks(
                        userId: widget.userId,
                        userCredential: widget.userCredential,
                        signedInUserEmail: widget.signedInUserEmail,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading:  Icon(
                Icons.people,
                color: Approved.PrimaryColor,
                size:  isDesktop ? 30 :20
              ),
              title: Text(S.of(context).ManageEmployee,
               style: TextStyle( 
                fontSize:  isDesktop ? 22 :18
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ManageEmployee(
                        userId: widget.userId,
                        userCredential: widget.userCredential,
                        signedInUserEmail: widget.signedInUserEmail,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading:  Icon(
                Icons.exit_to_app,
                color: Approved.PrimaryColor,
                size:  isDesktop ? 30 :20
              ),
              title: Text(S.of(context).LogOut,
               style: TextStyle( 
                fontSize:  isDesktop ? 22 :18
              ),
              ),
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
      Expanded(child: pages[selectedPageIndex], 
      )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        
        currentIndex: selectedPageIndex,
        onTap: _selectPage,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
            selectedLabelStyle: TextStyle(
            fontSize: isDesktop ? 18 : 14, 
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isDesktop ? 18 : 14, 
          ),
        items: [
        
          BottomNavigationBarItem(
            icon:  Icon(
              Icons.dashboard,
               size:  isDesktop ? 30 :20
            ),
            label: S.of(context).Dashboard,
            
            
          ),
          BottomNavigationBarItem(
            icon:  Icon(
              Icons.map_outlined,
               size:  isDesktop ? 30 :20
            ),
            label: S.of(context).YourWarehouses,
          ),
          BottomNavigationBarItem(
            icon:  Icon(
              Icons.inventory_2_rounded,
               size:  isDesktop ? 30 :20
            ),
            label: S.of(context).Inventory,
          ),
        ],
      ),
    );
  }
}
