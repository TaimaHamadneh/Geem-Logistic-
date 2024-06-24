import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/warehouses/warehouses.dart';

class StoreDetailsPage extends StatefulWidget {
  final Map<String, dynamic> store;
  final String signedInUserEmail;

  const StoreDetailsPage({Key? key, 
  required this.store, 
  required this.userId, 
  required this.userCredential, required this.signedInUserEmail}) : super(key: key);
  
  final String userId;
   final UserCredential userCredential;

  @override
  _StoreDetailsPageState createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _contactNumberController;
  late TextEditingController _category;

  LatLng? _selectedLocationLatLng;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store['name']);
    _addressController = TextEditingController(text: widget.store['address']);
    _areaController =
        TextEditingController(text: widget.store['area'].toString());
    _contactNumberController =
        TextEditingController(text: widget.store['contactNumber']);

     _category = TextEditingController(text: widget.store['category']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _contactNumberController.dispose();
    _category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Theme(
      data: Theme.of(context).copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: Approved.PrimaryColor,
            shape: const StadiumBorder(),
            maximumSize: const Size(double.infinity, 56),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Approved.LightColor,
        appBar: AppBar(
           backgroundColor: Approved.LightColor,
            centerTitle: true,
            title: Text('Edit Store'.toUpperCase(),
           style:  TextStyle(
       fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: isDesktop? 30: 24.0,
              fontFamily: 'Montserrat',
    ),
          ),
          leading: IconButton(
          icon:  Icon(Icons.close, color: Colors.black,
          size: isDesktop ? 35 : 20
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
               const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                  height: isDesktop ? 60 : 50,
                width: isDesktop ? 900 : 400,
                  child: TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: Colors.black, fontSize: isDesktop ? 22: 18),
                    decoration:  InputDecoration(
                      labelText: 'Name',
                      
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(Icons.warehouse, 
                        color: Colors.black),
                      ),
                      hintText: 'Enter the new name of your warehouse',
                      border: const OutlineInputBorder(),
                       labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                      focusedBorder:const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    
                    
                  ),
                  
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                      height: isDesktop ? 300 : 300,
                width: isDesktop ? 900 : 400,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          widget.store['location']['coordinates'][1], 
                          widget.store['location']['coordinates'][0], 
                          
                          ), 
                      zoom: 12,
                    ),
                    onTap: (LatLng latLng) {
                      setState(() {
                        _selectedLocationLatLng =
                            latLng; 
                      });
                    },
                    markers: _selectedLocationLatLng != null
                        ? {
                            Marker(
                              markerId: MarkerId('selected-location'),
                              position: _selectedLocationLatLng!,
                            )
                          }
                        : {},
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                    height: isDesktop ? 60 : 50,
                width: isDesktop ? 900 : 400,
                  child: TextFormField(
                    controller: _areaController,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: Colors.black, fontSize: isDesktop ? 22: 18),

                    decoration:  InputDecoration(
                      labelText: 'Area',
                      labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                      prefixIcon: Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(Icons.space_dashboard_rounded,
                        color: Colors.black
                        ),
                      ),
                      hintText: 'Enter the new Area of your warehouse',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                   height: isDesktop ? 60 : 50,
                width: isDesktop ? 900 : 400,
                  child: TextFormField(
                    style: TextStyle(color: Colors.black, fontSize: isDesktop ? 22: 18),
                    controller: _category,
                    textInputAction: TextInputAction.next,
                    decoration:  InputDecoration(
                        labelText: 'Category',
                      labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(
                          Icons.category,
                          color: Colors.black,
                        ),
                      ),
                      hintText: 'Enter the new category of your product',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),

                const SizedBox(height: Approved.defaultPadding),
                SizedBox(
                    height: isDesktop ? 60 : 50,
                width: isDesktop ? 900 : 400,
                  child: TextFormField(
                    controller: _contactNumberController,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: Colors.black, fontSize: isDesktop ? 22: 18), 
                    decoration:  InputDecoration(
                      
                      labelText: 'Contact Number',
                      labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                      prefixIcon: Padding(
                        padding: EdgeInsets.all(Approved.defaultPadding),
                        child: Icon(Icons.contact_page_outlined,
                        color: Colors.black),
                      ),
                      hintText: 'Enter the new Contact Number of your warehouse',
                      border: OutlineInputBorder(),
                     focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ 

                  SizedBox(
                   height: isDesktop ? 60 : 50,
                width: isDesktop ? 900 : 350,
                  child: ElevatedButton(
                    
                    onPressed: () {
                      if (_validateInputs()) {
                        _updateStore();
                        Navigator.of(context).pop();
                      }
                    },
                    
                    child:  Text('Save Changes',
                    style: TextStyle( fontSize: isDesktop ? 22: 18),),
                  ),
                ),
                ],)
              ],
            ),
          ),
        ),
      ),
    );
  }

 void _updateStore() async {
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



  final reqBody = {
    "name": _nameController.text,
    "address": await _getAddressFromCoordinates(),
    "area": _areaController.text,
    "contactNumber": _contactNumberController.text,
  
  };

  try {
     var response = await http.put(
          Uri.parse(url + '${widget.userId}/EditStores/${widget.store['_id']}'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );

    if (response.statusCode == 200) {
       ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Warehouse updated successfully')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  Warehouses( 
                userCredential: widget.userCredential,
                userId: widget.userId,
                signedInUserEmail: widget.signedInUserEmail,
                
                )/*
              TabsScreen(
                userCredential: widget.userCredential,
                userId: widget.userId,
              ), */
            ),
          );

          String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

          //     await FirebaseMessaging.instance.subscribeToTopic('merchant');
           await sendNotfiy("Warehouse Updated",
                "Your warehouse has been updated successfully!", uniqueId);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add warehouse')),
          );
      print('Failed to update store: ${response.statusCode}');
    }
  } catch (error) {
   print('Error updating warehouse: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update warehouse')),
      );
  }
}
bool _validateInputs() {
  if (_nameController.text.length < 3 || _nameController.text.length > 50) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Name should be between 3 and 50 characters')),
    );
    return false;
  }

  if (double.tryParse(_areaController.text) == null || double.parse(_areaController.text) < 4) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Area should be a number greater than or equal to 4')),
    );
    return false;
  }

  if (!_contactNumberController.text.startsWith('05')||
      _contactNumberController.text.length != 10 ||
      !RegExp(r'^05[0-9]{8}$').hasMatch(_contactNumberController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact Number should start with 05 and have 10 digits')),
    );
    return false;
  }

  return true;
}

Future<String> _getAddressFromCoordinates() async {
  if (_selectedLocationLatLng == null) {
     _selectedLocationLatLng = LatLng(
      widget.store['location']['coordinates'][1], // خط العرض
      widget.store['location']['coordinates'][0], // خط الطول
    );
  }
  if (_selectedLocationLatLng != null) {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      _selectedLocationLatLng!.latitude,
      _selectedLocationLatLng!.longitude,
    );
    String address = placemarks.isNotEmpty
        ? '${placemarks.first.name ?? ''}, ${placemarks.first.thoroughfare ?? ''}, ${placemarks.first.locality ?? ''}, ${placemarks.first.administrativeArea ?? ''}, ${placemarks.first.country ?? ''}, ${placemarks.first.postalCode ?? ''}'
        : 'Unknown Address';
    return address;
  } else {
    return '';
  }
}

}
