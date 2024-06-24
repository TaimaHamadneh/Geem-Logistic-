import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/emplyee/manage_emplyee.dart';

class EditEmployee extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  final Map<String, dynamic> employeeDetails;

  EditEmployee({Key? key, required this.userCredential, 
  required this.signedInUserEmail,
  required this.userId, required this.employeeDetails})
      : super(key: key);

  @override
  _EditEmployeeState createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController positionController;
   late TextEditingController EmploymentTypeController;
  late TextEditingController contactNumberController;
  late TextEditingController passwordController;
  late String selectedCity;

  List<String> cities = [
    'other',
    'Jerusalem',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Beit Sahour',
    'Jericho',
    'Salfit',
    'Jenin',
    'Nablus',
    'Ramallah',
    'Al-Bireh',
    'Tubas',
    'Hebron'
  ];

  List<String> positions = ['Inventory Clerk', 'Sales Associate'];
  List<String> employmentTypes = ['Part-time', 'Full-time'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.employeeDetails['name']);
    emailController = TextEditingController(text: widget.employeeDetails['email']);
    positionController =
        TextEditingController(text: widget.employeeDetails['position']);
        EmploymentTypeController=  TextEditingController(text: widget.employeeDetails['EmplymentType']);
    contactNumberController =
        TextEditingController(text: widget.employeeDetails['contactNumber'].toString());
    passwordController = TextEditingController(text: widget.employeeDetails['password']);
    selectedCity = widget.employeeDetails['city']; 
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(Approved.defaultPadding/2),
                    ),
                    padding: const EdgeInsets.all(Approved.defaultPadding),
                    child: Column(
                      children: [
                        SizedBox(height: Approved.defaultPadding/2),
                        Text(
                          'Edit Employee',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize:isDesktop?28: 22.0,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Image(
                          image: AssetImage('assets/images/edit_employee.png'),
                          height:isDesktop? 200: 150,
                          width:isDesktop? 200: 150,
                        ),
                        SizedBox(height: Approved.defaultPadding),
                        SizedBox(
                height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,

                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: 'Name', fillColor: Colors.white),
                            validator: nameValidator,
                             style: TextStyle(fontSize: isDesktop ? 22: 18),
                          ),
                        ),
                        SizedBox(height: Approved.defaultPadding),
                         SizedBox(
                height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,
                          child: TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: 'Email', fillColor: Colors.white),
                            validator: emailValidator,
                             style: TextStyle(fontSize: isDesktop ? 22: 18),
                          ),
                        ),
                        SizedBox(height: Approved.defaultPadding),                        
                           SizedBox(
                height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,
                            child: DropdownButtonFormField<String>(
                            value: positionController.text,
                            onChanged: (String? value) {
                              setState(() {
                                positionController.text = value!;
                              });
                            },
                            validator: positionValidator,
                             style: TextStyle(fontSize: isDesktop ? 22: 18, color: Colors.black),
                            items: positions.map((position) {
                              return DropdownMenuItem<String>(
                                value: position,
                                child: Text(position),
                              );
                            }).toList(),
                            decoration: InputDecoration(labelText: 'Position', fillColor: Colors.white),
                          
                                                    ),
                          ),
                          SizedBox(height: Approved.defaultPadding),
                       
                         SizedBox(
                height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,
                          child: DropdownButtonFormField<String>(
                            value: EmploymentTypeController.text,
                            onChanged: (String? value) {
                              setState(() {
                                EmploymentTypeController.text = value!;
                              });
                            },
                            validator: positionValidator,
                             style: TextStyle(fontSize: isDesktop ? 22: 18, color: Colors.black),
                            items: employmentTypes.map((employmentType) {
                              return DropdownMenuItem<String>(
                                value: employmentType,
                                child: Text(employmentType),
                              );
                            }).toList(),
                            decoration: InputDecoration(labelText: 'Position', fillColor: Colors.white),
                          ),
                        ),
                       
                        SizedBox(height: Approved.defaultPadding),
                         SizedBox(
                height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,
                          child: TextFormField(
                            controller: contactNumberController,
                            decoration: InputDecoration(labelText: 'Contact Number', fillColor: Colors.white),
                            validator: contactNumberValidator,
                             style: TextStyle(fontSize: isDesktop ? 22: 18),
                          ),
                        ),
                        SizedBox(height: Approved.defaultPadding),
                         SizedBox(
                height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,
                          child: TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: 'Password', fillColor: Colors.white),
                            validator: passwordValidator,
                             style: TextStyle(fontSize: isDesktop ? 22: 18),
                          ),
                        ),
                        SizedBox(height: Approved.defaultPadding),

                         SizedBox(
                height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                updateEmployee();
                              }
                            },
                            child: Text('Update',
                            style: TextStyle( 
                              fontSize: isDesktop ? 22: 18
                            ),),

                          ),
                        ),
                         SizedBox(height: isDesktop ? Approved.defaultPadding*2 : 0,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    if (value.length < 3 || value.length > 20) {
      return 'Name must be between 3 and 20 characters';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  String? contactNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a contact number';
    }
    if (value.length != 9) {
      return 'Contact number must be 10 digits';
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

  Future<void> updateEmployee() async {
    final urlReq = url +
        '${widget.userId}/employees/${widget.employeeDetails['_id']}';
    try {
      final response = await http.put(
        Uri.parse(urlReq),
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "position": positionController.text,
          "EmplymentType": EmploymentTypeController.text,
          "contactNumber": contactNumberController.text,
          "password": passwordController.text, 
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee updated successfully.'),
          ),
        );

        Navigator.pop(context); 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ManageEmployee(
                userId: widget.userId,
                 userCredential: widget.userCredential,
                 signedInUserEmail: widget.signedInUserEmail,
                 )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update employee.'),
          ),
        );

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update employee.'),
        ),
      );
      print('Error updating employee: $e');
    }
  }
}
