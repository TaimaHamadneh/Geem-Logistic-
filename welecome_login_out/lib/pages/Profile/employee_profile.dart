// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:image_picker/image_picker.dart';

class EmployeeProfilePage extends StatefulWidget {
  final UserCredential userCredential;
  final String userId;
  final String merchantId;

  const EmployeeProfilePage(
      {Key? key, required this.userCredential, required this.userId,
       required this.merchantId
       })
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EmployeeProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _employmentTypeController;
  late TextEditingController _positionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _contactNumController;
  late TextEditingController _CityNumController;

  late String _imageUrl;
  bool _isUploading = false;
  File? _imageFile;
  bool _isLoading = true;

  String _selectedLocation = 'other';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _employmentTypeController = TextEditingController();
    _positionController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _contactNumController = TextEditingController();
    _CityNumController = TextEditingController();
    _imageUrl = '';
    _fetchEmployeeDetails(widget.userId);
  }

  Future<void> _fetchEmployeeDetails(String userId) async {
    try {
      var req = '${url}employees/$userId';
      final response = await http.get(Uri.parse(req));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _usernameController.text = data['name'];
          _emailController.text = data['email'];
          _passwordController.text = data['password'];
          _employmentTypeController.text = data['EmplymentType'];
          _positionController.text = data['position'];
          _selectedLocation = data['city'] ?? 'other';
          _startDateController.text = data['ContractDuration']['startDate'].split(' ')[0];
          _endDateController.text = data['ContractDuration']['endDate'].split(' ')[0];
          _contactNumController.text = '0${data['contactNumber'].toString()}';
          _CityNumController.text = data['city'];
          _imageUrl = data['image'] ?? '';

           if (_imageUrl.isNotEmpty) {
            _imageFile = File(_imageUrl);
          }

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load employee details');
      }
    } catch (error) {
      print('Error fetching employee details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load employee details')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> locations = [
      'other',
      'Jerusalem',
      'Nablus',
      'Tulkarm',
      'Qalqilya',
      'Bethlehem',
      'Beit Sahour',
      'Jericho',
      'Salfit',
      'Jenin',
      'Ramallah',
      'Al_Bireh',
      'Tubas',
      'Hebron'
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: Text('Back',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500
         ),),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Approved.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null ? Icon(Icons.account_circle, size: 50,
                        color: Approved.PrimaryColor
                        ) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.camera_alt, color: Approved.PrimaryColor),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                            IconButton(
                              icon: Icon(Icons.upload, color: Approved.PrimaryColor),
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Approved.defaultPadding/2),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: S.of(context).UserName,
                      prefixIcon: Icon(Icons.person),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: S.of(context).Email,
                      prefixIcon: Icon(Icons.email),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                  TextField(
                    controller: _passwordController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.password),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                  TextField(
                    controller: _positionController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Position',
                      prefixIcon: Icon(Icons.assignment ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                  TextField(
                    controller: _employmentTypeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Employment Type',
                    prefixIcon: Icon(Icons.business_center ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                    Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.date_range_rounded),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    const SizedBox(width: Approved.defaultPadding),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icon(Icons.date_range_rounded),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: Approved.defaultPadding),
                  TextField(
                    controller: _contactNumController,
                    
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      prefixIcon: Icon(Icons.contact_page_rounded),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    items: locations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLocation = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).Location,
                      prefixIcon: Icon(Icons.location_on),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding ),
                  if (_isUploading) const CircularProgressIndicator(),
                  if (!_isUploading)
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text(S.of(context).Update),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and email cannot be empty')),
      );
      return;
    }
    try {
      setState(() {
        _isUploading = true;
      });

      var reqBody = {
       "image": _imageFile != null ? _imageFile!.path : "",
        "name": _usernameController.text,
        "email": _emailController.text,
        "contactNumber":int.parse(_contactNumController.text),
        "city": _selectedLocation
      };

      var response = await http.put(Uri.parse(url + '${widget.merchantId}/employees/${widget.userId}'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));
      var jsonResponse = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      setState(() {
        _isUploading = false;
      });
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }
}
