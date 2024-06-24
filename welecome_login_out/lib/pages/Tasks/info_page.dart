import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:welecome_login_out/approved.dart';

class InfoTask extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> taskDetails;
  final String EmployeeName;

  InfoTask({
    required this.userId,
    required this.taskDetails,
    required this.EmployeeName,
  });

  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: Text(
          'Task Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: isDesktop? 30:28
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Approved.defaultPadding*2,),
              Card(
                  margin: EdgeInsets.symmetric(vertical: isDesktop? 20: 8.0, horizontal: isDesktop? 50 :16.0),

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
                            'Title: ${taskDetails['title']}',
                            style:  TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Approved.PrimaryColor,
                              fontSize: isDesktop? 28:22,
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
                            'Description:',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop?22: 18.0,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          Text(
                            '${taskDetails['description']}',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop?20: 15.0,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(
                            height: Approved.defaultPadding,
                          ),
                          Text(
                            'Employee Name:',
                            style: TextStyle(
                              fontSize: isDesktop? 22: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '$EmployeeName',
                            style: TextStyle(
                              fontSize: isDesktop? 20: 16,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(
                            height: Approved.defaultPadding,
                          ),
                          Text(
                            'Deadline Date:',
                            style: TextStyle(
                              fontSize: isDesktop? 22:18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                           'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(taskDetails['DeadlineDate']))} \nTime ${DateFormat('HH:mm:ss.SSS').format(DateTime.parse(taskDetails['DeadlineDate']))}',
                            style: TextStyle(
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: Approved.defaultPadding,
                          ),
                          Text(
                            'Date:',
                            style: TextStyle(
                              fontSize: isDesktop? 22:18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                             'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(taskDetails['date']))} \nTime ${DateFormat('HH:mm:ss.SSS').format(DateTime.parse(taskDetails['date']))}',

                            style: TextStyle(
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: Approved.defaultPadding,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: Approved.defaultPadding,
                              ),
                              Text(
                                '${taskDetails['status']}',
                                style: TextStyle(
                                  color: taskDetails['status'] == 'In Progress'
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: isDesktop? 20:17.0,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Approved.defaultPadding),
                  ],
                ),
              ),

              if (taskDetails.containsKey('response'))
                Card(
                 margin: EdgeInsets.symmetric(vertical: isDesktop? 20: 8.0, horizontal: isDesktop? 50 :16.0),
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
                              'Response:',
                              style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Approved.PrimaryColor,
                                fontSize: isDesktop? 28:22.0,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: Approved.defaultPadding),
                            Text(
                              '${taskDetails['response']}',
                              style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize:isDesktop? 22: 18.0,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No response on this task',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: isDesktop? 24:18.0,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}