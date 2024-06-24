import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/emplyee/manage_emplyee.dart';

final _firebase = FirebaseAuth.instance;

class AddEmployee extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  AddEmployee({
    required this.userId,
    required this.userCredential,
    required this.signedInUserEmail
  });

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  String? selectedCity;
  String? selectedEmploymentType;
  DateTime? selectedContractStart;
  DateTime? selectedContractEnd;
  String? contractValidationMessage;
  String? selectedPosition;

    @override
  void initState() {
    super.initState();
    selectedPosition = 'Inventory Clerk'; 
    
  }

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

  List<String> employmentTypes = ['Full-time', 'Part-time'];
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

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedContractEnd) {
      setState(() {
        selectedContractEnd = picked;
        contractValidationMessage = contractDateValidator();
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  String? positionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a position';
    }
    if (value.length < 5 || value.length > 20) {
      return 'Position must be between 5 and 20 characters';
    }
    return null;
  }

  String? contactNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a contact number';
    }
    if (value.length != 10) {
      return 'Contact number must be 10 digits';
    }
    return null;
  }

  String? cityValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a city';
    }
    return null;
  }

  Future<void> signupEmployee(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic> userData = {
        'username': nameController.text,
        'email': email,
        'position': selectedPosition ,
        'contactNumber': contactNumberController.text,
        'Location': selectedCity,
        'userType': 'employee',
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Employee added successfully'),
        ),
      );

    Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ManageEmployee(
                    userId: widget.userId,
                    userCredential: widget.userCredential,
                    signedInUserEmail: widget.signedInUserEmail,
                  )),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Firebase signing up employee: $e'),
        ),
      );
    }
  }

  Future<void> addEmployee() async {
    if (_formKey.currentState!.validate()) {
      final urlReq = url + 'users/${widget.userId}/addEmployee';
      final response = await http.post(
        Uri.parse(urlReq),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'position': selectedPosition ,
          'contactNumber': contactNumberController.text,
          'city': selectedCity,
          'EmplymentType': selectedEmploymentType,
          'userType': 'employee',
          'ContractDuration': {
            'startDate': selectedContractStart.toString(),
            'endDate': selectedContractEnd.toString(),
            'duration': selectedContractEnd
                ?.difference(selectedContractStart!)
                .inDays
                .toString(),
          }
        }),
      );

      if (response.statusCode == 201) {
        await signupEmployee(emailController.text, passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee added successfully'),
          ),
        );
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
            content: Text('Error adding employee'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
   final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Approved.PrimaryColor,
        title:  Text(
          'Add Employee',
          style: TextStyle(
            color: Colors.black,
            fontSize: isDesktop ? 28:20,
            
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
               if(!isDesktop)Image.asset(
                'assets/images/add_employee.png',
                height: isDesktop? 200: 150,
                width: isDesktop? 250:200,
              ),
              SizedBox(height: isDesktop? Approved.defaultPadding*2 : 0,),
               SizedBox(
                height: isDesktop ? 90 : 80,
                child: TextFormField(
                  controller: nameController,
                  decoration:  InputDecoration(
                    labelText: 'Name',
                     labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                    filled: true,
                    prefixIcon: Icon(Icons.person, size: isDesktop ? 30 : 20),
                    fillColor: Colors.white,
                    contentPadding:
                      EdgeInsets.symmetric(vertical: isDesktop ? 25 : 16),
                  ),
                  validator: nameValidator,
                  style: TextStyle(fontSize: isDesktop ? 22: 18),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding/2),
              SizedBox(
                  height: isDesktop ? 90 : 80,
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.email, size: isDesktop ? 30 : 20),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                  ),
                  validator: emailValidator,
                  style: TextStyle(fontSize: isDesktop ? 22: 18)
                ),
              ),
              const SizedBox(height: Approved.defaultPadding/2),
              SizedBox(
                  height: isDesktop ? 90 : 80,

                child: TextFormField(
                  controller: passwordController,
                  decoration:  InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    prefixIcon: Icon(Icons.password, size: isDesktop ? 30 : 20),

                    fillColor: Colors.white,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                  ),
                  obscureText: true,
                  validator: passwordValidator,
                  style: TextStyle(fontSize: isDesktop ? 22: 18)

                ),
              ),
              const SizedBox(height: Approved.defaultPadding/2),
              
               SizedBox(
                 height: isDesktop ? 90 : 80,

                 child: DropdownButtonFormField<String>(
                  decoration:  InputDecoration(
                    labelText: 'Position',
                    filled: true,
                    fillColor: Colors.white,
                  prefixIcon: Icon(Icons.badge, size: isDesktop ? 30 : 20),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                  ),
                  value: selectedPosition,
                  onChanged: (newValue) {
                    setState(() {
                      selectedPosition = newValue!;
                    });
                  },
                  validator: positionValidator,
                  style: TextStyle(fontSize: isDesktop ? 22: 18, color: Colors.black),

                  items: ['Inventory Clerk', 'Sales Associate'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, 
                      style: TextStyle(fontSize: isDesktop ? 22: 18, color: Colors.black),),
                    );
                  }).toList(),
                               ),
               ),
              const SizedBox(height: Approved.defaultPadding/2),
              SizedBox(
                     height: isDesktop ? 90 : 80,

                child: TextFormField(
                  controller: contactNumberController,
                  decoration:  InputDecoration(
                    labelText: 'Contact Number',
                    filled: true,
                    fillColor: Colors.white,
                     prefixIcon: Icon(Icons.phone, size: isDesktop ? 30 : 20),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                  ),
                  validator: contactNumberValidator,
                  style: TextStyle(fontSize: isDesktop ? 22: 18)

                ),
              ),
              const SizedBox(height: Approved.defaultPadding/2),
              SizedBox(
               height: isDesktop ? 90 : 80,

                child: DropdownButtonFormField<String>(
                  decoration:  InputDecoration(
                    labelText: 'City',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.location_city_outlined, size: isDesktop ? 30 : 20),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                  ),
                  value: selectedCity,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCity = newValue;
                    });
                  },
                  validator: cityValidator,
                  style: TextStyle(fontSize: isDesktop ? 22: 18),
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city,
                                            style: TextStyle(fontSize: isDesktop ? 22: 18, color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
              ),
              /** New fields */
              const SizedBox(height: Approved.defaultPadding/2),
              SizedBox(
                height: isDesktop ? 90 : 80,

                child: DropdownButtonFormField<String>(
                  decoration:  InputDecoration(
                    labelText: 'Employment Type',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.person_2_sharp, size: isDesktop ? 30 : 20),
                     contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                  ),
                  value: selectedEmploymentType,
                  onChanged: (newValue) {
                    setState(() {
                      selectedEmploymentType = newValue;
                    });
                  },
                  items: employmentTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding/2),
              Row(
                children: [
                 Expanded(
                      child: InkWell(
                        onTap: () => _selectStartDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                    
                            filled: true,
                            fillColor: Colors.white,
                             prefixIcon: Icon(Icons.calendar_month_outlined, size: isDesktop ? 30 : 20),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                          ),
                          child: selectedContractStart != null
                              ? Text(
                                  DateFormat('yyyy-MM-dd',
                                  )
                                      .format(selectedContractStart!),
                                )
                              : Text('Contract Start Date',
                              style: TextStyle(
                              fontSize: isDesktop ? 20: 14
                            ),),
                        ),
                      ),
                    ),
                 
                  const SizedBox(width: Approved.defaultPadding/2),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: InputDecorator(
                        decoration:  InputDecoration(

                          filled: true,
                          fillColor: Colors.white,
                           prefixIcon: Icon(Icons.calendar_month_outlined, size: isDesktop ? 30 : 20),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: isDesktop ? 22 : 16),
                    labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                        ),
                        child: selectedContractEnd != null
                            ? Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(selectedContractEnd!),
                              )
                            : Text('Contract End Date', style: TextStyle(
                              fontSize: isDesktop ? 20: 14
                            ),),
                      ),
                    ),
                  ),
                ],
              ),
             SizedBox(height: isDesktop ?Approved.defaultPadding*2: Approved.defaultPadding),
              SizedBox(
                height: isDesktop ? 80 : 70,
                child: ElevatedButton(
                  onPressed: addEmployee,
                  child: Text('Add Employee',
                  style: TextStyle(
                                fontSize: isDesktop ? 20: 16
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
