import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Tasks/manage_task.dart';

class EditTasks extends StatefulWidget {
  final String userId;
  final dynamic taskDetails;
  final UserCredential userCredential;
  final String signedInUserEmail;

  EditTasks({
    required this.userId,
    required this.userCredential,
    required this.taskDetails,
    required this.signedInUserEmail
  });

  @override
  _EditTasksState createState() => _EditTasksState();
}

class _EditTasksState extends State<EditTasks> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedEmployee;
  DateTime? selectedContractStart;
  DateTime? selectedContractEnd;
  String? contractValidationMessage;

  late List<dynamic> employees = [];
  late List<String> employeesIds = [];
  late List<String> employeesNames = [];

  String getEmployeeName(String employeeId) {
    dynamic employee = employees.firstWhere(
      (emp) => emp['_id'] == employeeId,
      orElse: () => null,
    );
    return employee != null ? employee['name'] : 'Unknown Employee';
  }

  @override
  void initState() {
    super.initState();
    titleController.text = widget.taskDetails['title'];
    descriptionController.text = widget.taskDetails['description'];
    fetchEmployees();
    selectedEmployee = widget.taskDetails['employeeId'];
    selectedContractStart = DateTime.parse(widget.taskDetails['DeadlineDate']);
  }

  String? contractDateValidator() {
    if (selectedContractStart == null || selectedContractEnd == null) {
      return 'Please select both start and end dates';
    }

    if (selectedContractStart!.isAfter(selectedContractEnd!)) {
      return 'Contract start date must be before end date';
    }

    if (selectedContractEnd!.difference(selectedContractStart!).inDays < 30) {
      return 'Contract duration must be at least a month';
    }

    return null;
  }

  Future<void> fetchEmployees() async {
    final response =
        await http.get(Uri.parse(url + '${widget.userId}/employees'));

    if (response.statusCode == 200) {
      setState(() {
        employees = jsonDecode(response.body);

        for (var employee in employees) {
          employeesIds.add(employee['_id']);
          employeesNames.add(employee['name']);
          print('employeesIds: $employeesIds');
        }
      });
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedContractStart) {
      setState(() {
        selectedContractStart = picked;
        contractValidationMessage = contractDateValidator();
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    if (value.length < 3 || value.length > 60) {
      return 'Title must be between 3 and 60 characters';
    }
    return null;
  }

  String? descriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an description';
    }
    if (value.length < 5 || value.length > 500) {
      return 'Description must be between 5 and 500 characters';
    }

    return null;
  }

  String? positionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a position';
    }
    if (value.length < 5 || value.length > 20) {
      return 'Position must be between 5 and 20 characters';
    }
    return null;
  }

  String? cityValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a city';
    }
    return null;
  }

  Future<void> EditTask() async {
    final formattedDeadlineDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        .format(selectedContractStart!);
    if (_formKey.currentState!.validate()) {
      final urlReq = url + 'task/${widget.taskDetails['_id']}';
      print('url:$urlReq ');
      final response = await http.put(
        Uri.parse(urlReq),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': titleController.text,
          'description': descriptionController.text,
          'DeadlineDate': formattedDeadlineDate,
          'employeeId': selectedEmployee
        }),
      );
      print('title ${titleController.text}');
      print('description ${descriptionController.text}');
      print('DeadlineDate ${selectedContractStart.toString()}');
      print('employeeId ${selectedEmployee}');

      print('response.statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task editied successfully'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ManageTasks(
                    userId: widget.userId,
                    userCredential: widget.userCredential,
                    signedInUserEmail: widget.signedInUserEmail,
                  )),
        );
       
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Editing Task'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Approved.PrimaryColor,
        title:  Text(
          'Edit Task',
          style: TextStyle(
            color: Colors.black,
            fontSize: isDesktop ? 30:22
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              const SizedBox(height: Approved.defaultPadding * 2),
              Image.asset(
                'assets/images/add_employee.png',
                height: isDesktop? 200:150,
                width: isDesktop? 250:200,
              ),
              const SizedBox(height: Approved.defaultPadding * 2),
              Center(
                child: SizedBox(
                  height: isDesktop ? 60 : 50,
                  width: isDesktop ? 700 : 400,
                
                  child: TextFormField(
                    controller: titleController,
                    decoration:  InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                    ),
                    validator: titleValidator,
                     style: TextStyle(fontSize: isDesktop ? 22: 18),
                  ),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Center(
                child: SizedBox(
                 height: isDesktop ? 100 : 60,
                  width: isDesktop ? 700 : 400,
                
                  child: TextFormField(
                    controller: descriptionController,
                    decoration:  InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                    ),
                    style: TextStyle(fontSize: isDesktop ? 22: 18),
                    maxLines: null,
                    validator: descriptionValidator,
                  ),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Center(
                child: SizedBox(
                  height: isDesktop ? 60 : 60,
                  width: isDesktop ? 700 : 400,
                
                  child: DropdownButtonFormField<String>(
                    decoration:  InputDecoration(
                      labelText: 'Select Employee',
                      filled: true,
                      fillColor: Colors.white,
                     labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                    ),
                    style: TextStyle(fontSize: isDesktop ? 22: 18),
                    value: selectedEmployee,
                    onChanged: (newValue) {
                      setState(() {
                        selectedEmployee = newValue;
                      });
                    },
                    validator: cityValidator,
                    items: employeesNames.map((name) {
                      var index = employeesNames.indexOf(name);
                      return DropdownMenuItem<String>(
                        value: employeesIds[index],
                        child: Text(name,
                        style: TextStyle(fontSize: isDesktop ? 22: 18,  color: Colors.black)
),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Center(
                child: SizedBox(
                  height: isDesktop ? 60 : 60,
                  width: isDesktop ? 700 : 400,
                
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                         labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                      ),
                      
                      child: selectedContractStart != null
                          ? Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(selectedContractStart!),
                            )
                          : Text('Deadline date',
                          style: TextStyle(fontSize: isDesktop ? 22: 18)
),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding * 2),
              Center(
                child: SizedBox(
                  height: isDesktop ? 60 : 50,
                  width: isDesktop ? 700 : 400,
                
                  child: ElevatedButton(
                    onPressed: EditTask,
                    child: Text('Edit Task',
                    style: TextStyle(fontSize: isDesktop ? 22: 18)
),
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
