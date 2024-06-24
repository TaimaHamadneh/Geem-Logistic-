import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Inventory/reuseable_dropdown.dart';
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';
import 'package:welecome_login_out/pages/Tasks/add_task.dart';
import 'package:welecome_login_out/pages/Tasks/edit_task.dart';
import 'package:welecome_login_out/pages/Tasks/info_page.dart';


class ManageTasks extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  ManageTasks({Key? key, required this.userCredential,
  required this.signedInUserEmail,
  required this.userId})
      : super(key: key);

  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageTasks> {
  late List<dynamic> employees = [];
  late List<dynamic> Tasks = [];
  late String selectedStatus = "All";
  late String selectedDeadline = "All"; 

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    fetchTaska();
  }

  Future<void> fetchEmployees() async {
  final response = await http.get(Uri.parse(url + '${widget.userId}/employees'));

  if (response.statusCode == 200) {
    dynamic jsonData = jsonDecode(response.body);
    
    if (jsonData is List) {
      setState(() {
        employees = jsonData;
         print('employees: $employees ' );

      });
    } else if (jsonData is Map) {
      setState(() {
        employees = [jsonData];
      });
    }
    
    print('employees: $employees');
  } else {
    throw Exception('Failed to load employees');
  }
}
 
 
 String getEmployeeName(String employeeId) {
    print('employee id insid the loop: $employeeId');
    dynamic employee = employees.firstWhere(
      (emp) => emp['_id'] == employeeId,
      orElse: () => null,
    );
    print('employee name insid the loop: $employeeId');

    return employee != null ? employee['name'] : 'Unknown Employee';
}



  Future<void> fetchTaska() async {
    final response = await http.get(Uri.parse(url + 'getTasksForUser/${widget.userId}'));
    print(url + 'getTasksForUser/${widget.userId}');

    if (response.statusCode == 200) {
        List<dynamic> fetchedTasks = jsonDecode(response.body);
    fetchedTasks.sort((task1, task2) {
      DateTime dateTime1 = DateTime.parse(task1['DeadlineDate']);
      DateTime dateTime2 = DateTime.parse(task2['DeadlineDate']);

      bool isLate1 = dateTime1.isBefore(DateTime.now());
      bool isLate2 = dateTime2.isBefore(DateTime.now());

      if (isLate1 && isLate2) {
        return task1['status'].compareTo(task2['status']);
      }

      if (isLate1 && !isLate2) {
        return 1; 
      } else if (!isLate1 && isLate2) {
        return -1;
      }

      return dateTime1.compareTo(dateTime2);
    });

    setState(() {
      Tasks = fetchedTasks;
      print('Tasks: $Tasks ');
    });
     /* setState(() {
        Tasks = jsonDecode(response.body);
        print('Tasks: $Tasks ');
      });*/
    } else {
      throw Exception('Failed to load Tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title:  Text(
          'Manage Tasks',
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
             size: isDesktop ? 30 :20,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TabsScreen(
                        userId: widget.userId,
                        userCredential: widget.userCredential, signedInUserEmail: widget.signedInUserEmail,
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
                  builder: (context) => AddTasks(
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

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
               
                 Expanded(
   
                    child: ReusableDropdown(
                      items: ["All", "Completed", "In Progress"],
                      valueListenable: ValueNotifier(selectedStatus),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                      icon: Icon(Icons.filter_list),
                      hintText: 'Status',hintStyle: TextStyle(color: Colors.black,
                      fontSize: isDesktop? 28: 16
                      ),
                    ),
                  ),
             
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: ReusableDropdown(
                    items: ["All", "Finished", "Still there time to deadline"],
                    valueListenable: ValueNotifier(selectedDeadline),
                    onChanged: (value) {
                      setState(() {
                        selectedDeadline = value!;
                      });
                    },
                    icon: Icon(Icons.timer),
                    hintText: 'Deadline Comparison', 
                    hintStyle: TextStyle(color: Colors.black,
                    fontSize: isDesktop? 28: 16),
                  ),
                ),
              ],
            ),
          ),

          Image.asset(
            'assets/images/Checklist.png',
             height: isDesktop? 120: 90,
            width: isDesktop? 330:  300,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Tasks.length,
              itemBuilder: (context, index) {
                final Task = Tasks[index];
                   if ((selectedStatus == "All" || Task['status'] == selectedStatus) &&
                    (selectedDeadline == "All" || checkDeadline(Task, selectedDeadline))) {
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
                                  '${Task['title']} #${index + 1}',
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description: ${Task['description']}',
                                  style:  TextStyle(
                                    color: Colors.black,
                                    fontSize: isDesktop? 22 : 16,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: Approved.defaultPadding,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [ 
                                    const SizedBox(width: Approved.defaultPadding,),
                                   Text(
                                  '${Task['status']}',
                                  style: TextStyle(
                                    color: Task['status'] == 'In Progress'
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: isDesktop? 22 : 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                ],),
                              ],
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              square(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InfoTask(
                                        userId: widget.userId,
                                        taskDetails: Task, EmployeeName: getEmployeeName(Task['employeeId']),
                                      ),
                                    ),
                                  );
                                  print('employee Id: ${Task['employeeId']}');
                                  print('employee name: ${getEmployeeName(Task['employeeId'])}');
                                },
                                child:  Text('Details',
                                  style:  TextStyle(
                                color: Colors.black,
                                fontSize: isDesktop? 22 : 16,
                                fontFamily: 'Montserrat',
                              ),),
                              ),
                              const SizedBox(
                                width: Approved.defaultPadding * 2,
                              ),
                              square(
                                onPressed: () {
                                  showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Approved.PrimaryColor,
                                  title:  Text('Confirm Delete',
                                  style: TextStyle(
                                            fontSize: isDesktop? 28: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),),
                                  content:  Text(
                                      'Are you sure you want to delete this store?',
                                      style: TextStyle(
                                            fontSize: isDesktop? 22: 18,
                                            color: Colors.white),),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child:  Text('Cancel',
                                      style: TextStyle(
                                            fontSize: isDesktop?22:18,
                                            color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        
                                        final urlReq = url + 'task/${Task['_id']}';
                                            print('urlReq: $urlReq');
                                        try {
                                          final response = await http.delete(Uri.parse(urlReq));
                    
                                          if (response.statusCode == 200) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                          'Emplyee deleted successfully.'),
                                                    ),
                                                  );
                                                  Navigator.of(context).pop();
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ManageTasks(
                                                                userId: widget
                                                                    .userId, userCredential: widget.userCredential, signedInUserEmail: widget.signedInUserEmail,)),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: 
                                                Text('Failed to delete employee.'),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Failed to delete employee.'),
                                            ),
                                          );
                                          print('Error deleting employee: $e');
                                        }
                                      },
                                      child:  Text('Delete',style: TextStyle(
                                            fontSize:isDesktop? 22: 18,
                                            color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );
                                },
                                child:  Text('Delete',
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
                              square(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTasks(
                                        userId: widget.userId,
                                        taskDetails: Task,
                                        userCredential: widget.userCredential,
                                        signedInUserEmail: widget.signedInUserEmail,
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
                    }else{
                       return SizedBox(); 
                    }
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
      //primary: Colors.white,
      backgroundColor: Approved.PrimaryColor,
      shape: RoundedRectangleBorder(),
    ),
  );
  
}

  bool checkDeadline(dynamic Task, String selectedDeadline) {
    DateTime now = DateTime.now();
    DateTime deadline = DateTime.parse(Task['DeadlineDate']);

    if (selectedDeadline == "Finished") {
      return deadline.isBefore(now);
    } else if (selectedDeadline == "Still there time to deadline") {
      return deadline.isAfter(now);
    } else {
      return true; 
    }
  }