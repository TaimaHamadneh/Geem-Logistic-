import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';
import 'package:welecome_login_out/pages/emplyee/add_employee.dart';
import 'package:welecome_login_out/pages/emplyee/edit_employee.dart';
import 'package:welecome_login_out/pages/emplyee/info_page.dart';

class ManageEmployee extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;

  final String signedInUserEmail;
  ManageEmployee(
      {Key? key,
      required this.userCredential,
      required this.signedInUserEmail,
      required this.userId})
      : super(key: key);

  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
  late List<dynamic> employees = [];

  @override
  void initState() {
    fetchEmployees();
    super.initState();
  }

  Future<void> fetchEmployees() async {
    final response =
        await http.get(Uri.parse(url + '${widget.userId}/employees'));
    print('after get req');

    if (response.statusCode == 200) {
      final dynamic responseBody = jsonDecode(response.body);
      print('responseBody: $responseBody');

      if (responseBody != null) {
        setState(() {
          employees = responseBody;
        });
      } else {
        throw Exception(
            'Expected a list of employees, but received: $responseBody');
      }
    } else {
      throw Exception('Failed to load employees');
    }
  }

  @override
  Widget build(BuildContext context) {
        final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title:  Text(
          'Manage Employees',
          style: TextStyle(
            color: Colors.black,
            fontSize: isDesktop ? 28: 20
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TabsScreen(
                        userId: widget.userId,
                        userCredential: widget.userCredential,
                        signedInUserEmail: widget.signedInUserEmail,
                      )),
            );
          },
        ),
        actions: [
          IconButton(
            icon:  Icon(
              Icons.add,
              color: Colors.black,
              size: isDesktop ? 30 :20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEmployee(
                    userId: widget.userId,
                    userCredential: widget.userCredential,
                    signedInUserEmail: widget.signedInUserEmail,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: Approved.defaultPadding * 2,
          ),
          Image.asset(
            'assets/images/manageEmployee.png',
            height: isDesktop? 200: 150,
            width: isDesktop? 205:  200,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> employee = employees[index];
                return Padding(
                  padding:  EdgeInsets.symmetric(
                      vertical: isDesktop? 16 : 8, horizontal:isDesktop? 250: 16),
                  child: SizedBox(
                     width: isDesktop ? MediaQuery.of(context).size.width / 0.5 : null,
                    child: Card(
                        shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${employee['name']}',
                                  style:  TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Approved.PrimaryColor,
                                    fontSize: isDesktop? 28 : 22,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: Approved.defaultPadding),
                              ],
                            ),
                            subtitle: Text(
                              'Position: ${employee['position']}\nEmail: ${employee['email']}',
                              style:  TextStyle(
                                color: Colors.black,
                                fontSize: isDesktop? 22 : 16,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                          const SizedBox(height: Approved.defaultPadding),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              square(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InfoEmployee(
                                        userId: widget.userId,
                                        employeeDetails: employee,
                                      ),
                                    ),
                                  );
                                },
                                child:  Text('Details',
                                 style:  TextStyle(
                                color: Colors.black,
                                fontSize: isDesktop? 22 : 16,
                                fontFamily: 'Montserrat',
                              ),
                                ),
                              ),
                              const SizedBox(
                                width: Approved.defaultPadding * 2,
                              ),
                              const SizedBox(
                                width: Approved.defaultPadding * 2,
                              ),
                              square(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditEmployee(
                                        userId: widget.userId,
                                        employeeDetails: employee,
                                        userCredential: widget.userCredential,
                                        signedInUserEmail:
                                            widget.signedInUserEmail,
                                      ),
                                    ),
                                  );
                                },
                                child:  Text('Edit',
                                 style:  TextStyle(
                                color: Colors.black,
                                fontSize: isDesktop? 22 : 16,
                                fontFamily: 'Montserrat',
                              ),),
                              ),
                            ],
                          ),
                          const SizedBox(height: Approved.defaultPadding),
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
    );
  }
}

Widget square({required VoidCallback onPressed, required Widget child}) {
  return TextButton(
    onPressed: onPressed,
    child: child,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.all(8.0),
      backgroundColor: Approved.PrimaryColor,
      shape: RoundedRectangleBorder(),
    ),
  );
}
