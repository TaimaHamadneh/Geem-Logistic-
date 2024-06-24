import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/Profile/admin_profie.dart';
import 'package:welecome_login_out/pages/admin/admin_home_users.dart';
import 'package:welecome_login_out/pages/dashboard/admin_dash.dart';
import 'package:welecome_login_out/main.dart';
import 'package:welecome_login_out/pages/notifications/admin_noti.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AdminTabsScreen extends StatefulWidget {
  const AdminTabsScreen({
    Key? key,
    required this.userCredential,
    required this.userId,
    required this.userEmail,
    required this.signedInUserEmail,
  }) : super(key: key);

  final UserCredential userCredential;
  final String userId;
  final String userEmail;
  final String signedInUserEmail;

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<AdminTabsScreen> {
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
      const AdminDashboard(),
      HomeUsers(signedInUserEmail: widget.signedInUserEmail),
    ];

    // Define the width threshold for desktop layout
    const double desktopWidthThreshold = 800;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > desktopWidthThreshold) {
          final isDesktop = MediaQuery.of(context).size.width > 600;
          // Desktop layout with fixed sidebar
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Approved.PrimaryColor,
              actions: [
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
            body: Row(
              children: [
                // Fixed Sidebar
                Container(
                  width: 350,
                  color: Colors.white,
                  child: _buildSidebar(context),
                ),
                // Main Content
                Expanded(
                  child: pages[selectedPageIndex],
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedPageIndex,
              onTap: _selectPage,
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
                    color: Colors.black,
                    size: isDesktop ? 35 : 25,
                  ),
                  label: S.of(context).Dashboard,
                ),
                 BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat,
                    color: Colors.black,
                    size: isDesktop ? 35 : 25,
                  ),
                  label: 'Chat',
                ),
              ],
            ),
          );
        } else {
          // Mobile layout with drawer
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Approved.PrimaryColor,
              actions: [
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
            drawer: Drawer(
              child: _buildSidebar(context),
            ),
            body: pages[selectedPageIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedPageIndex,
              onTap: _selectPage,
              selectedItemColor: Colors.black,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(
                    Icons.dashboard,
                    color: Colors.black,
                  ),
                  label: S.of(context).Dashboard,
                ),
                const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat,
                    color: Colors.black,
                  ),
                  label: 'Chat',
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
     final isDesktop = MediaQuery.of(context).size.width > 600;
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Approved.PrimaryColor,
          ),
          child: Image.asset(
            "assets/images/menu.png",
          //  fit: BoxFit.cover, // Ensure the image fits well
          ),
        ),
        ListTile(
          leading:  Icon(
            Icons.person,
            color: Colors.black,
            size: isDesktop ? 35 : 25,
          ),
          title: Text(S.of(context).Profile,
          style: TextStyle(
            fontSize: isDesktop ? 24 : 18,
          ),),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return AmdinProfilePage(
                    userCredential: widget.userCredential,
                    userId: widget.userId,
                    userEmail: widget.userEmail,
                    signedInUserEmail: widget.signedInUserEmail,
                  );
                },
              ),
            );
          },
        ),
       /* ListTile(
          leading:  Icon(
            Icons.notifications,
            color: Colors.black,
             size: isDesktop ? 35 : 25,
          ),
          title: Text(S.of(context).Notifications,
          style: TextStyle(
            fontSize: isDesktop ? 24 : 18,
          ),),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return AdminNotificatiosPage();
                },
              ),
            );
          },
        ),*/
        const Divider(),
        ListTile(
          leading:  Icon(
            Icons.exit_to_app,
            color: Colors.black,
             size: isDesktop ? 35 : 25,
          ),
          title: Text(S.of(context).LogOut, 
          style: TextStyle(
            fontSize: isDesktop ? 24 : 18,
          ),),
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
    );
  }
}
