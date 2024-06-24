import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/main.dart';
import 'package:welecome_login_out/pages/Profile/profile_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';
import 'package:welecome_login_out/pages/userPages/AllStoresForUsers/homePage.dart';
import 'package:welecome_login_out/pages/userPages/CartScreen/cart_page.dart';
import 'package:welecome_login_out/pages/userPages/CartScreen/order_screen.dart';
import 'package:welecome_login_out/pages/userPages/FavoriteScreen/favorite_page.dart';
import 'package:welecome_login_out/pages/userPages/notifications/notifications.dart';
import 'package:http/http.dart' as http;


class UserTabsScreen extends StatefulWidget {
  const UserTabsScreen({
    Key? key,
    required this.userCredential,
    required this.userId,
    required this.signedInUserEmail,
  }) : super(key: key);

  final UserCredential userCredential;
  final String userId;
  final String signedInUserEmail;

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<UserTabsScreen> {
  int selectedPageIndex = 0;
  var fbm = FirebaseMessaging.instance;

  void _selectPage(int index) {
    if (index < 3) { // Ensures index is within range
      setState(() {
        selectedPageIndex = index;
      });
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


  @override
  void initState() {
    requestPermession();

    fbm.getToken().then((token) {
      print('token: $token');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.of(context).pushNamed("UserTabsScreen");
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
  Widget build(BuildContext context) {
     final isDesktop = MediaQuery.of(context).size.width > 600;
     
    final pages = [
      homePage(
        userId: widget.userId,
        userCredential: widget.userCredential,
      ),
      CartPage(
        userId: widget.userId,
        signedInUserEmail: widget.signedInUserEmail,
        userCredential: widget.userCredential,
      ),
      FavoritePage(
        userId: widget.userId,
        userCredential: widget.userCredential,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        actions: [
          IconButton(
            icon: Tooltip(
              message: 'Switch to Merchant Screen',
              child: const Icon(
                Icons.transfer_within_a_station_sharp,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TabsScreen(
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
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Desktop layout with fixed sidebar
            return Row(
              children: [
                _buildSidebar(),
                Expanded(
                  flex: 10,
                  child: pages[selectedPageIndex],
                ),
              ],
            );
          } else {
            // Mobile layout
            return pages[selectedPageIndex];
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 600) {
            return BottomNavigationBar(
              currentIndex: selectedPageIndex,
              onTap: _selectPage,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_cart),
                  label: 'My Cart',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite),
                  label: 'Favorite',
                ),
              ],
            );
          } else {
            return const SizedBox.shrink(); // No bottom nav bar on desktop
          }
        },
      ),
    );
  }


  Drawer _buildDrawer(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Approved.PrimaryColor,
            ),
            child: Image.asset("assets/images/menu.png"),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            text: S.of(context).Profile,
             isDesktop: isDesktop,
            
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
          _buildDrawerItem(
            icon: Icons.shopping_cart_sharp,
            text: S.of(context).Orders,
             isDesktop: isDesktop,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return UserOrderPage(
                      signedInUserEmail: widget.signedInUserEmail,
                      userId: widget.userId,
                      userCredential: widget.userCredential,
                    );
                  },
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            text: S.of(context).Notifications,
             isDesktop: isDesktop,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return UserNotificatiosPage(
                      userId: widget.userId,
                      signedInUserEmail: widget.signedInUserEmail,
                      userCredential: widget.userCredential,
                    );
                  },
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.exit_to_app,
            text: S.of(context).LogOut,
             isDesktop: isDesktop,
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
    );
  }

  ListTile _buildDrawerItem({
    required IconData icon,
     required String text, 
     required VoidCallback onTap,
     required bool isDesktop,
     }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Approved.PrimaryColor,
      ),
      title: Text(text, 
      style: TextStyle(
        fontSize: isDesktop ? 24 : 16,
        color: Colors.black,
      ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSidebar() {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Container(
      width: 300, 
      color: Approved.PrimaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Approved.PrimaryColor,
            ),
            child: Image.asset("assets/images/menu.png"),
          ),
          _buildSidebarItem(
            icon: Icons.home,
            text: 'Home',
            index: 0,
            isDesktop : isDesktop
          ),
          _buildSidebarItem(
            icon: Icons.shopping_cart,
            text: 'My Cart',
            index: 1,
              isDesktop : isDesktop
          ),
          _buildSidebarItem(
            icon: Icons.favorite,
            text: 'Favorite',
            index: 2,
              isDesktop : isDesktop
          ),
          _buildSidebarItem(
            icon: Icons.person,
            text: S.of(context).Profile,
            index: 3,
            isPage: false,
              isDesktop : isDesktop
          ),
          _buildSidebarItem(
            icon: Icons.notifications,
            text: S.of(context).Notifications,
            index: 4,
            isPage: false,
              isDesktop : isDesktop
          ),
          _buildSidebarItem(
            icon: Icons.exit_to_app,
            text: S.of(context).LogOut,
            index: 5,
            isPage: false,
              isDesktop : isDesktop
          ),
        ],
      ),
    );
  }

  ListTile _buildSidebarItem(
      {required IconData icon, 
      required String text, 
      required int index, bool isPage = true,
      required bool isDesktop}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      size: isDesktop ? 30 : 20,
        
      ),
      title: Text(
        text,
        style:  TextStyle(color: Colors.white,
        fontSize: isDesktop ? 20: 16
        ),
      ),
      onTap: () {
        if (index == 5) {
          FirebaseAuth.instance.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const MyApp();
              },
            ),
          );
        } else if (isPage) {
          _selectPage(index);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(            builder: (context) {
              switch (index) {
                case 3:
                  return ProfilePage(
                    userCredential: widget.userCredential,
                    userId: widget.userId,
                  );
                case 4:
                  return UserNotificatiosPage(
                    userId: widget.userId,
                    signedInUserEmail: widget.signedInUserEmail,
                    userCredential: widget.userCredential,
                  );
                default:
                  // Handle any other cases if needed
                  return Container();
              }
            },
          ),
          );
        }
      },
    );
  }
}

             
