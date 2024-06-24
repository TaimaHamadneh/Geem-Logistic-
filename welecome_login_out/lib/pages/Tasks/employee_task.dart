import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Inventory/reuseable_dropdown.dart';

class EmployeeTasks extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;

  EmployeeTasks({Key? key, required this.userCredential, required this.userId})
      : super(key: key);

  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<EmployeeTasks> {
  late List<dynamic> tasks = [];
  late String statusFilter = 'All';
  late String dateFilter = 'All';
  late TextEditingController searchController = TextEditingController();


  var fbm = FirebaseMessaging.instance;
 @override
  void initState() {
     fetchTasks();
    fbm.getToken().then((token) {
      print('token: $token');
    });
    super.initState();
  }


  Future<void> fetchTasks() async {
    final response =
        await http.get(Uri.parse(url + 'employee/${widget.userId}/tasks'));
    print(url + 'employee/${widget.userId}/tasks');

    if (response.statusCode == 200) {
        List<dynamic> fetchedTasks = jsonDecode(response.body);
    fetchedTasks.sort((task1, task2) {
      DateTime dateTime1 = DateTime.parse(task1['DeadlineDate']);
      DateTime dateTime2 = DateTime.parse(task2['DeadlineDate']);
      return dateTime2.compareTo(dateTime1);
    });
    
    setState(() {
      tasks = fetchedTasks;
      print('Tasks: $tasks');
    });
    /*
      setState(() {
        tasks = jsonDecode(response.body);
        print('Tasks: $tasks');
      });*/
    } else {
      throw Exception('Failed to load Tasks');
    }
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  Future<void> updateTaskStatus(String taskId, String status,
      [String? note]) async {
    final response = await http.put(
      Uri.parse(url + 'task/$taskId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'status': status,
        if (note != null) 'response': note,
      }),
    );

    if (response.statusCode == 200) {
      fetchTasks();
    } else {
      throw Exception('Failed to update task');
    }
  }

  void showMarkAsDoneDialog(BuildContext context, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Approved.PrimaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mark as Done',
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Text(
            'Do you want to send with a note or without a note?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateTaskStatus(task['_id'], 'Completed');
                Navigator.of(context).pop();
              },
              child: Text(
                'Without Note',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showSendNoteDialog(context, task, withDoneAction: true);
              },
              child: Text(
                'With Note',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSendNoteDialog(BuildContext context, Map<String, dynamic> task,
      {bool withDoneAction = false}) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Approved.PrimaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send Note',
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(
                hintText: 'Write your note here', fillColor: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateTaskStatus(
                    task['_id'],
                    withDoneAction ? 'Completed' : 'In Progress',
                    noteController.text);
                Navigator.of(context).pop();
              },
              child: Text(
                'Send',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  bool filterTaskByStatus(Map<String, dynamic> task) {
    if (statusFilter == 'All') {
      return true;
    } else {
      return task['status'] == statusFilter;
    }
  }

  bool filterTaskByDate(Map<String, dynamic> task) {
    if (dateFilter == 'All') {
      return true;
    } else {
      DateTime now = DateTime.now();
      DateTime taskDate = DateTime.parse(task['DeadlineDate']);
      if (dateFilter == 'Last 3 Days') {
        return now.difference(taskDate).inDays <= 3;
      } else if (dateFilter == 'Last 10 Days') {
        return now.difference(taskDate).inDays <= 10;
      } else if (dateFilter == 'Last Month') {
        return now.month == taskDate.month && now.year == taskDate.year;
      } else {
        return false;
      }
    }
  }

  bool filterTaskBySearch(Map<String, dynamic> task) {
    String searchQuery = searchController.text.toLowerCase();
    String taskTitle = task['title'].toLowerCase();
    return taskTitle.contains(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Approved.LightColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           const SizedBox(height: Approved.defaultPadding/2),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {

                });
              },
            ),
          ),
           const SizedBox(height: Approved.defaultPadding/2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ReusableDropdown(
                items: ['All', 'Completed', 'In Progress'],
                valueListenable: ValueNotifier<String>(statusFilter),
                onChanged: (value) {
                  setState(() {
                    statusFilter = value!;
                  });
                },
                icon: Icon(Icons.filter_list, color: Colors.white),
                hintText: 'Filter by Status',
                hintStyle: TextStyle(color: Colors.black),
              ),
              ReusableDropdown(
                items: ['All', 'Last 3 Days', 'Last 10 Days', 'Last Month'],
                valueListenable: ValueNotifier<String>(dateFilter),
                onChanged: (value) {
                  setState(() {
                    dateFilter = value!;
                  });
                },
                icon: Icon(Icons.date_range, color: Colors.white),
                hintText: 'Filter by Date',
                hintStyle: TextStyle(color: Colors.black),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                if (filterTaskByStatus(task) &&
                    filterTaskByDate(task) &&
                    filterTaskBySearch(task)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
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
                                  '${task['title']} #${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Approved.PrimaryColor,
                                    fontSize: 22.0,
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
                                  'Description: ${task['description']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: Approved.defaultPadding),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDate(task['DeadlineDate']),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const SizedBox(
                                        width: Approved.defaultPadding),
                                    Text(
                                      task['status'],
                                      style: TextStyle(
                                        color: task['status'] == 'In Progress'
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          if (task['status'] != 'Completed')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: Approved.defaultPadding),
                                IconButton(
                                  icon: Icon(Icons.cancel,
                                      color: Approved.PrimaryColor, size: 30),
                                  onPressed: () =>
                                      showSendNoteDialog(context, task),
                                ),
                                IconButton(
                                  icon: Icon(Icons.check_circle,
                                      color: Approved.PrimaryColor, size: 30),
                                  onPressed: () =>
                                      showMarkAsDoneDialog(context, task),
                                ),
                                const SizedBox(width: Approved.defaultPadding),
                              ],
                            ),
                          const SizedBox(height: Approved.defaultPadding),
                        ],
                      ),
                    ),
                  );
                } else {

                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
