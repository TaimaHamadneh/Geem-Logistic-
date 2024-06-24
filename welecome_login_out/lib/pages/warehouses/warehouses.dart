
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/components/splash.dart';
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';
import 'package:welecome_login_out/pages/warehouses/add_warehouses.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/pages/warehouses/info_page.dart';
import 'package:welecome_login_out/pages/warehouses/store_edit.dart';
import '../../../config.dart';

class Warehouses extends StatefulWidget {
  const Warehouses(
      {Key? key, required this.userId, required this.userCredential, required this.signedInUserEmail})
      : super(key: key);

  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  @override
  State<Warehouses> createState() => _WarehousesState();
}

class _WarehousesState extends State<Warehouses> {
  List<dynamic> stores = [];

  bool isLoading = true;

  String? selectedLocation;
  String? selectedSpace;
  final TextEditingController _spaceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  double? enteredSpace;
  String placeM = '';

  @override
  void dispose() {
    _spaceController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    fetchStoreData();
  }

  Future<void> fetchStoreData() async {
    final urlReq = Uri.parse(url + '${widget.userId}/storesById');

    try {
      final response = await http.get(urlReq);
      if (response.statusCode == 200) {
        setState(() {
          stores = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load store data');
      }
    } catch (e) {
      print('Error fetching store data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> getCityName(double latitude, double longitude) async {
    print('Latitude: $latitude, Longitude: $longitude');

    final List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    String? cityName;

    if (placemarks.isNotEmpty) {
      final Placemark placemark = placemarks.first;
      cityName = placemark.locality; 
    }
    return cityName;
  }

  Future<void> _fetchPlacemark(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      print(placemarks[0]);
    } catch (e) {
      print('Error fetching placemark: $e');
    }
  }

  Widget _buildStoreCards() {
    List<dynamic> filteredStores = stores.where((store) {

      final String name = store['name'].toLowerCase();
      final String enteredName = _nameController.text.toLowerCase();
      if (enteredName.isNotEmpty && !name.contains(enteredName)) {
        return false;
      }

      final String address = store['address'].toLowerCase();
      final String enteredAddress = _addressController.text.toLowerCase();
      if (enteredAddress.isNotEmpty && !address.contains(enteredAddress)) {
        return false;
      }

      final String contactNumber = store['contactNumber'].toLowerCase();
      final String enteredContactNumber = _contactController.text.toLowerCase();
      if (enteredContactNumber.isNotEmpty &&
          !contactNumber.contains(enteredContactNumber)) {
        return false;
      }

      return true;
    }).toList();

    return ListView.builder(
      itemCount: filteredStores.length,
      itemBuilder: (context, index) {
        final store = filteredStores[index];
        final bool isDesktop = MediaQuery.of(context).size.width > 600;
        String address = store['address'];
        List<String> addressComponents = address.split(',');
        List<String> nonEmptyComponents = addressComponents
            .where((component) => component.trim().isNotEmpty)
            .toList();
        String formattedAddress = nonEmptyComponents.join(', ');

        return Card(
            color: Colors.white,
           margin: EdgeInsets.symmetric(vertical: isDesktop? 20: 8.0, horizontal: isDesktop? 50 :8.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                    Container(
                          height: isDesktop ? 150 : 80,
                width: isDesktop ? 150 : 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color:
                               Approved.PrimaryColor
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              color: Colors.white,
                              child: store['image'] != null
                                  ? Image.file(File(store['image']),
                                      fit: BoxFit.cover)
                                  : Image.asset(
                                      'assets/images/store_icon0.png'),
                            ),
                          ),
                        ),
                   
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['name'].toString().toUpperCase(),
                          style:  TextStyle(
                            fontSize: isDesktop ? 24 : 18.0,
                            color: Approved.PrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                         SizedBox(height: isDesktop? 15: 10.0),
                        RichText(
                          text: TextSpan(
                            children: [
                               WidgetSpan(
                                child: Icon(
                                  Icons
                                      .location_on, 
                                  color: Colors.black,
                                  size: isDesktop ? 30 : 20,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' $formattedAddress',
                                style:  TextStyle(
                                  fontSize: isDesktop? 22: 15,
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                         SizedBox(height: isDesktop? 20: 16),
                       Row(
                        children: [
                           RichText(
                          text: TextSpan(
                            children: [
                               WidgetSpan(
                                child: Icon(
                                  Icons
                                      .warehouse_sharp, 
                                  color: Colors.black,
                                  size: isDesktop ? 30 : 20,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' ${store['area']} m', 
                                style:  TextStyle(
                                  fontSize: isDesktop? 22: 15,
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                         const SizedBox(width: Approved.defaultPadding*4,),
                         RichText(
                          text: TextSpan(
                            children: [
                               WidgetSpan(
                                child: Icon(
                                  Icons
                                      .contact_page, 
                                  color: Colors.black,
                                  size: isDesktop ? 30 : 20,
                                ),
                              ),
                             
                              TextSpan(
                                text:
                                    ' ${store['contactNumber']}',
                                style:  TextStyle(
                                  fontSize: isDesktop? 22: 15,
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                        ],
                       ),
                       Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: isDesktop ? Approved.defaultPadding : 0,),
                      IconButton(
                        icon:  Icon(Icons.edit,
                          size: isDesktop? 40: 20,
                          ),
                        color: Approved.PrimaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreDetailsPage(
                                store: store,
                                userId: widget.userId,
                                userCredential: widget.userCredential,
                                signedInUserEmail: widget.signedInUserEmail,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon:  Icon(Icons.info, 
                        size: isDesktop? 40: 20,),
                        color: Approved.PrimaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreInfoPage(
                                store: store, 
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon:  Icon(Icons.delete,
                          size: isDesktop? 40: 20,
                          ),
                        color: Approved.PrimaryColor,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Approved.PrimaryColor,
                                      title:  Text(
                                        'Confirm Delete',
                                        style: TextStyle(
                                            fontSize: isDesktop? 28: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      content:  Text(
                                          'Are you sure you want to delete this store?',
                                          style: TextStyle(
                                            fontSize:isDesktop? 22:  18,
                                            color: Colors.white),
                                          ),
                                      actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child:  Text('Cancel',
                                     style: TextStyle(
                                            fontSize: isDesktop? 22: 18,
                                            color: Colors.white),),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final storeId = store['_id'];
                                      if (storeId != null) {
                                        deleteStore(storeId);
                                      } else {
                                        print('Store ID is null');
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child:  Text('Delete',
                                     style: TextStyle(
                                            fontSize: isDesktop? 22: 18,
                                            color: Colors.white),),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                       
                     
                      const SizedBox(height: 16.0),
                    ],
                  ),
                      ],
                      
                    ),
                  ),
                  
                ],
              ),
            ),
          );
       
      },
    );
  }

  Future<void> deleteStore(String storeId) async {
    
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


    print("Delete store function called with ID: $storeId");

    final urlReq = Uri.parse(url + '${widget.userId}/stores/$storeId');
    try {
      final response = await http.delete(urlReq);
      if (response.statusCode == 200) {
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
        setState(() {
          stores.removeWhere((store) => store['id'] == storeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store deleted successfully.'),
          ),
        );
        String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

            //   await FirebaseMessaging.instance.subscribeToTopic('merchant');
           await sendNotfiy("Warehouse Deleted",
                "A new warehouse has been deleted successfully!", uniqueId);
      } else {
        throw Exception('Failed to delete warehouse');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete store.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Approved.LightColor,
        appBar: AppBar(
          backgroundColor: Approved.LightColor,
          title: Text(
            'Your Warehouses',
            style: TextStyle(
              fontSize: isDesktop? 28: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              color: Colors.black,
              iconSize:isDesktop? 30: 24,
              onPressed: () {
                 Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Approved.PrimaryColor,
          ),
          body: AddWarehouseForm(
            userId: widget.userId,
            userCredential: widget.userCredential,
            signedInUserEmail: widget.signedInUserEmail,
          ),
        ),
      ),
    );
                
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              color: Colors.black,
             iconSize:isDesktop? 30: 24,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext ctx) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: isDesktop? 24: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Approved.defaultPadding),
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              filled: true,
                              fillColor: Approved.LightColor.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                enteredSpace = double.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(height: Approved.defaultPadding),
                          TextFormField(
                            controller: _addressController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              filled: true,
                              fillColor: Approved.LightColor.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                enteredSpace = double.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(height: Approved.defaultPadding),
                          TextFormField(
                            controller: _contactController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Contact Number',
                              filled: true,
                              fillColor: Approved.LightColor.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                enteredSpace = double.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(height: Approved.defaultPadding),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                            },
                            child:  Text('Apply Filters',
                             style: TextStyle(
                              fontSize: isDesktop? 24: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading ? const SplashScreen() : _buildStoreCards(),
        ),
      ),
    );
  }
}
