// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';
import '../../../config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';


class AddWarehouseForm extends StatefulWidget {
  const AddWarehouseForm(
      {Key? key, required this.userId, required this.signedInUserEmail,
      required this.userCredential})
      : super(key: key);
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  @override
  _AddWarehouseFormState createState() => _AddWarehouseFormState();
}

class _AddWarehouseFormState extends State<AddWarehouseForm> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _spaceController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  String? _categoryError;
  bool _isLoading = false;
  double? enteredSpace;
  String? _nameError;
  String? _numberError;
  String? _ereaError;
  String? _imageError;
  File? _image;
  String imagePath = "";
  List<String> categories = [
    'Electronics',
    'Flowers',
    'Clothes',
    'Shoes',
    'Accessories',
    'Cosmetics',
  ];
  String? selectedCategory;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        imagePath = pickedFile.path;
      }
    });
  }

  LatLng? _selectedLocationLatLng;
  
  bool _validateFields() {
    final RegExp categoryRegex = RegExp(r'^.{3,50}$');
    bool isValid = true;
    _nameError = null;
    _numberError = null;
    _ereaError = null;
    _categoryError = null;

    if (_titleController.text.isEmpty) {
      setState(() {
        _nameError = 'Please enter your warehouse name';
      });
      isValid = false;
    }

    if (_contactController.text.isEmpty) {
      setState(() {
        _numberError = 'Please enter your warehouse contact number';
      });
      isValid = false;
    } else if (_contactController.text.length != 10) {
      setState(() {
        _numberError = 'Contact number should be 10 digits';
      });
      isValid = false;
    }
    if (_spaceController.text.isEmpty) {
      setState(() {
        _ereaError = 'Please enter your warehouse space';
      });
      isValid = false;
    }
    if (_categoryController.text.isEmpty ||
        !categoryRegex.hasMatch(_categoryController.text)) {
      _categoryError = 'Enter a valid category (3-50 characters)';
      isValid = false;
    }
    return isValid;
  }


 final String serverToken =
      'AAAAp-b_jbs:APA91bEdbKbMskpXgrhk_lnQrIF1AkLeiBFZOVCeq4Bwd0xezJyr7cUEjAIp13SvBLH0bHa1Ym8wvaUFtzxxh2-7sU7CGpkIGvi-DqFKnVGnr1OIuBHDSP2JCjeUoguJqFYOmyl9pip8';
  sendNotfiy(String title, String body, String id) async {
    DateTime currentTime = DateTime.now();
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body.toString(),
            'title': title.toString()
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': id.toString(),
            'status': 'done',
            'date': currentTime.toIso8601String(),
          },
          'to': '/topics/merchant'
        },
      ),
    );
  }


  void addWarehouse() async {
    if (_validateFields()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_selectedLocationLatLng != null) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            _selectedLocationLatLng!.latitude,
            _selectedLocationLatLng!.longitude,
          );

          String address = placemarks.isNotEmpty
              ? '${placemarks.first.name ?? ''}, ${placemarks.first.thoroughfare ?? ''}, ${placemarks.first.locality ?? ''}, ${placemarks.first.administrativeArea ?? ''}, ${placemarks.first.country ?? ''}, ${placemarks.first.postalCode ?? ''}'
              : 'Unknown Address';

          var reqBody = {
            'name': _titleController.text,
            'latitude': _selectedLocationLatLng!.latitude,
            'longitude': _selectedLocationLatLng!.longitude,
            'address': address,
            'contactNumber': _contactController.text,
            'area': enteredSpace,
            "image": imagePath,
            "category": _categoryController.text,
          };
          print('reqBody: $reqBody');
          var response = await http.post(
            Uri.parse(url + '${widget.userId}/addStore'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody),
          );

          if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Warehouse added successfully')),
            );

            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TabsScreen(
                  userCredential: widget.userCredential,
                  userId: widget.userId,
                  signedInUserEmail: widget.signedInUserEmail,
                ),
              ),
            );
                String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

          //     await FirebaseMessaging.instance.subscribeToTopic('merchant');
           await sendNotfiy("New Warehouse Added",
                "A new warehouse has been added successfully!", uniqueId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add warehouse')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a location on the map')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add warehouse')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contactController.dispose();
    _spaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) 
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Center(
                  child: Text(
                    'Add Warehouse',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Approved.TextColor,
                      fontSize: isDesktop? 28:24,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/images/add_warehouse.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                  height: isDesktop ? 60 : 50,
                 width: isDesktop ? 700 : 400,
                  child: TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                        labelText: 'Name',
                    filled: true,

                      prefixIcon:  Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(Icons.warehouse, size: isDesktop? 30: 20),
                      ),
                      errorText: _nameError,
                      hintText: 'Enter the name of your warehouse',
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: isDesktop ? 22: 18)
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                  height: isDesktop ? 300 : 300,
                 width: isDesktop? 700: double.infinity,
                  child: Container(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(32.2226, 35.2626),
                        zoom: 12,
                      ),
                      onTap: (LatLng latLng) {
                        setState(() {
                          _selectedLocationLatLng = latLng;
                        });
                      },
                      markers: _selectedLocationLatLng != null
                          ? {
                              Marker(
                                markerId: const MarkerId('selected-location'),
                                position: _selectedLocationLatLng!,
                              )
                            }
                          : {},
                    ),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),

                SizedBox(
                  height: isDesktop ? 60 : 50,
                 width: isDesktop?700: 400,

                  child: TextFormField(
                    controller: _spaceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                        labelText: 'Space / Area',
                    filled: true,
                      prefixIcon:  Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(Icons.space_dashboard,size: isDesktop? 30: 20),
                      ),
                      errorText: _ereaError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Enter the area in meters',
                    ),
                    style: TextStyle(fontSize: isDesktop ?22:18),
                    onChanged: (value) {
                      setState(() {
                        enteredSpace = double.tryParse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                  height: isDesktop ? 60 : 50,
                 width: isDesktop?700: 400,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Approved.LightColor,
                      borderRadius:
                          BorderRadius.circular(Approved.defaultPadding / 2),
                      border: Border.all(color: Colors.black.withOpacity(0.5)),
                    ),
                    child: GestureDetector(
                      onTap: _getImage,
                      child:  Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(Approved.defaultPadding),
                            child: Icon(
                              Icons.add_a_photo,
                              color: Approved.PrimaryColor,
                              size: isDesktop? 30: 20
                            ),
                          ),
                          Text(
                            'Warehouse Image or Logo',
                            style: TextStyle(fontSize: isDesktop? 22: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                    height: isDesktop ? 60 : 50,
                 width: isDesktop?700: 400,
                  child: TextFormField(
                    controller: _categoryController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                       labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                        labelText: 'Warehouse Category',
                    filled: true,
                      prefixIcon:  Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(Icons.category,
                        size: isDesktop? 30: 20),
                      ),
                      errorText: _categoryError,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius:
                            BorderRadius.circular(Approved.defaultPadding / 2),
                      ),
                    ),
                    style: TextStyle(fontSize: isDesktop? 22: 18),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                    height: isDesktop ? 60 : 50,
                 width: isDesktop?700: 400,
                  child: TextFormField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                        labelText: 'Contact Number',
                    filled: true,
                      prefixIcon:  Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(Icons.contact_phone,
                        size: isDesktop? 30: 20),
                      ),
                      errorText: _numberError,
                      hintText: 'Enter the contact number of your warehouse',
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: isDesktop? 22: 18),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                    height: isDesktop ? 60 : 50,
                 width: isDesktop?700: 400,
                  child: ElevatedButton(
                    onPressed: addWarehouse,
                    child:  Text('Add Warehouse', 
                    style: TextStyle(fontSize: isDesktop ?22: 18)
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
