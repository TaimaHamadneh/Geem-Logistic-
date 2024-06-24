// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';

class InfoEmployee extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> employeeDetails;

  InfoEmployee({required this.userId, required this.employeeDetails});

  String formatContractDuration(String durationString) {
  int durationInDays = int.tryParse(durationString) ?? 0; 

  if (durationInDays <= 0) {
    return 'Invalid Duration';
  }

  final int months = durationInDays ~/ 30;
  final int remainingDays = durationInDays % 30;

  if (months < 12) {
    return '$months months';
  } else {
    final int years = months ~/ 12;
    final int remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return '$years years';
    } else {
      return '$years years $remainingMonths months';
    }
  }
}
  String extractDate(String dateString) {
  List<String> parts = dateString.split(' ');
  return parts[0];
}



  @override
  Widget build(BuildContext context) {
           final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: Approved.defaultPadding/2),
                 Text(
                  'Employee Profile',
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize:isDesktop ? 28:  22.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
     
                Image.asset(
                  'assets/images/info_employee.png',
                  height: isDesktop ? 200:  150,
                  width: isDesktop ?200: 150,
                ),
                Container(
                  width: isDesktop ? 700: double.infinity,
                  child: DataTable(
                    columnSpacing:16.0,
                    dataRowColor: MaterialStateColor.resolveWith((states) => Approved.PrimaryColor),
                    columns: const [
                      DataColumn(
                        label: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows:  [
                      DataRow(
                        cells:  [
                          DataCell( Text('Employee name',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),),
                          ),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text(employeeDetails['name'],
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Employee email',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:  isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),),
                          ),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text(employeeDetails['email'],
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                      DataRow(
                        cells:  [
                          DataCell( Text('Position',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:  isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),),
                          ),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text(employeeDetails['position'],
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('Contact Number',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:  isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),)),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text('0'+ employeeDetails['contactNumber'].toString(),
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                  
                      /** Employment type */
                  
                        DataRow(
                        cells:  [
                          DataCell( Text('Emplyment Type',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:  isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),),
                          ),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text(employeeDetails['EmplymentType'],
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                  
                       DataRow(
                        cells:  [
                          DataCell( Text('Contract Start Date',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:  isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),),
                          ),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(
                            Text(
                             extractDate(employeeDetails['ContractDuration']['startDate']),
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                  
                       DataRow(
                        cells:  [
                          DataCell( Text('Contract End Date',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:  isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),),
                          ),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(
                            Text(
                              extractDate(employeeDetails['ContractDuration']['endDate']),
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                  
                         DataRow(
                        cells:  [
                          DataCell( Text('Contract Duration',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize:  isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),),
                          ),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(
                            Text(
                               formatContractDuration(employeeDetails['ContractDuration']['duration']),
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                  
                  
                      DataRow(
                        cells: [
                          DataCell(Text('City',
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 22:18,
                              fontFamily: 'Montserrat',
                            ),)),
                        ],
                      ),
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.white),
                        cells: [
                          DataCell(Text(employeeDetails['city'],
                            style:  TextStyle(
                              color: Colors.black,
                              fontSize: isDesktop? 20:16,
                              fontFamily: 'Montserrat',
                            ))),
                        ],
                      ),
                  
                  
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
