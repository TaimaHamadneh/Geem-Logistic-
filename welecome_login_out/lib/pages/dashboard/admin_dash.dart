import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/pages/dashboard/orders.dart';
import 'package:welecome_login_out/pages/dashboard/users.dart';
import 'package:welecome_login_out/pages/dashboard/warehouses.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Approved.ThirdColor,
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   SizedBox(
                height: isDesktop ? Approved.defaultPadding * 2 : 0,
              ),
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: isDesktop ? 30 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: isDesktop
                    ? Approved.defaultPadding * 8
                    : Approved.defaultPadding * 2,
              ),
                  buildDashboardCard(
                    title: 'Users',
                    icon: Icons.person,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UsersPageForAdmin()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildDashboardCard(
                    title: 'Orders',
                    icon: Icons.shopping_cart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrdersForAdmin()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildDashboardCard(
                    title: 'Warehouses',
                    icon: Icons.home,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WarehousesForAdmin()),
                      );
                    },
                  ),
                ],
              ),
          
          ),
    );
  }

  Widget buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = MediaQuery.of(context).size.width > 600;
        double cardWidth =
            isDesktop ? constraints.maxWidth /0.5 : constraints.maxWidth;
        double cardHeight = isDesktop ? 190 : 150;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Approved.PrimaryColor, Approved.PrimaryColor],
                    stops: [0.5, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: isDesktop ? 50 : 40,
                        color: Colors.black,
                      ),
                       SizedBox(width:isDesktop ?16: 8),
                      Text(
                        title,
                        style:  TextStyle(
                          fontSize: isDesktop? 30 :20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
