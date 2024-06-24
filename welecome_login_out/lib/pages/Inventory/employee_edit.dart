// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Inventory/invntory_test.dart';

class EditProductEmployeePage extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductEmployeePage(
      {Key? key,
      required this.product,
      required this.userId,
      required this.userCredential,
      required this.signedInUserEmail
      })
      : super(key: key);

  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductEmployeePage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantity;
  late TextEditingController _sellingPrice;
  late TextEditingController _category;
  late TextEditingController _status;

  String _storeName = '';
  File? _image;
  late String imagePath;

  String? selectedStore;
  var store;
  List<String> storeNames = [];
  List<String> storeIDs = [];
  int? index;

  Future<List<String>> fetchStores() async {
    final response =
        await http.get(Uri.parse(url + '${widget.userId}/storesById'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      for (store in data) {
        storeNames.add(store['name']);
        storeIDs.add(store['_id']);
      }
      return storeNames;
    } else {
      throw Exception('Failed to load stores');
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController =
        TextEditingController(text: widget.product['description']);
    _quantity =
        TextEditingController(text: widget.product['quantity'].toString());
    _sellingPrice =
        TextEditingController(text: widget.product['sellingPrice'].toString());
    _category = TextEditingController(text: widget.product['category']);
    _status = TextEditingController(text: widget.product['status']);
   
    imagePath = '${widget.product['image']}';

    if (int.parse(_quantity.text) == 0) {
      _status.text = "sold out";
    } else {
      _status.text = "available";
    }

    fetchStores().then((value) {
      setState(() {
        storeNames = value;
        fetchStoreName();
      });
    });
  }

  Future<void> fetchStoreName() async {
    try {
      final response = await http
          .get(Uri.parse(url + 'stores/${widget.product['store']}/name'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _storeName = data['storeName']!;
          selectedStore = _storeName;
        });
      } else {
        throw Exception('Failed to fetch store name');
      }
    } catch (error) {}
  }

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantity.dispose();
    _sellingPrice.dispose();
    _category.dispose();
    _status.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, color: Approved.PrimaryColor),
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 200,
                    color: Colors.white,
                    child: widget.product['image'] != null
                        ? Image.file(
                            File(
                              widget.product['image'],
                            ),
                            fit: BoxFit.cover)
                        : Image.asset('assets/images/unknown_product.jpg'),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(Approved.defaultPadding),
                      child: Icon(
                        Icons.production_quantity_limits_outlined,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                    hintText: 'Enter the new name of your product',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(Approved.defaultPadding),
                      child: Icon(
                        Icons.description,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                    hintText: 'Enter the new description of your product',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                TextFormField(
                  controller: _quantity,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(Approved.defaultPadding),
                      child: Icon(
                        Icons.format_list_numbered_rounded,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                    hintText: 'Enter the new quantity of your product',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                TextFormField(
                  controller: _sellingPrice,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Selling Price',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(Approved.defaultPadding),
                      child: Icon(
                        Icons.price_change_sharp,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                    hintText: 'Enter the new Selling Price of your product',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Approved.defaultPadding / 2),
                    border: Border.all(color: Colors.black.withOpacity(0.5)),
                  ),
                  child: GestureDetector(
                    onTap: _getImage,
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(Approved.defaultPadding),
                          child: Icon(
                            Icons.add_a_photo,
                            color: Approved.PrimaryColor,
                          ),
                        ),
                        Text(
                          'Change Product Image',
                          style: TextStyle(fontSize: Approved.defaultPadding),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                TextFormField(
                  controller: _category,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(Approved.defaultPadding),
                      child: Icon(
                        Icons.category,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                    hintText: 'Enter the new category of your product',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                DropdownButtonFormField<String>(
                  value: selectedStore,
                  onChanged: (newValue) {
                    setState(() {
                      selectedStore = newValue!;
                      index = storeNames
                          .indexOf(selectedStore!); 
                      print(storeIDs[index!]);
                    });
                  },
                  items: storeNames.map((String storeName) {
                    return DropdownMenuItem<String>(
                      value: storeName,
                      child: Text(storeName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Change store location',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(Approved.defaultPadding),
                      child: Icon(
                        Icons.warehouse,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius:
                          BorderRadius.circular(Approved.defaultPadding / 2),
                    ),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding),
                ElevatedButton(
                  onPressed: () {
                    _updateproduct();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateproduct() async {
    

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

    if (!_validateFields()) {
      return;
    }
    final reqBody = {
      'name': _nameController.text,
      'quantity': int.parse(_quantity.text),
      'sellingPrice': double.parse(_sellingPrice.text),
      'image': imagePath,
      'description': _descriptionController.text,
      'category': _category.text,
      'status': int.parse(_quantity.text) == 0 ? "sold out" : "available",
      'store': widget.product['store'],
      /** _status.text = int.parse(_quantity.text) == 0 ? "sold out" : "available"; */
    };
    print('updated product: $reqBody');
    try {
      var response = await http.put(
        Uri.parse(url +
            'stores/${widget.product['store']}/products/${widget.product['_id']}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('product updated successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InventoryScreen(
                    userCredential: widget.userCredential,
                    userId: widget.userId,
                    signedInUserEmail: widget.signedInUserEmail,
                  ) 
              ),
        );

        String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

              // await FirebaseMessaging.instance.subscribeToTopic('merchant');
           await sendNotfiy("product updated successfully",
                "A product has been updated successfully!", uniqueId);
                
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product')),
        );
        print('Failed to update store: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating warehouse: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product')),
      );
    }
  }

  bool _validateFields() {
    if (_nameController.text.length < 3 || _nameController.text.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name should be between 3 and 50 characters')),
      );
      return false;
    }

    return true;
  }
}
