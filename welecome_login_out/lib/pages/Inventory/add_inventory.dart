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
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';

class AddInventoryForm extends StatefulWidget {
  const AddInventoryForm(
      {Key? key, required this.userId, 
      required this.signedInUserEmail,
      required this.userCredential})
      : super(key: key);
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  @override
  _AddInventoryFormState createState() => _AddInventoryFormState();
}

class _AddInventoryFormState extends State<AddInventoryForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  double? enteredSpace;
  String? _nameError;
  String? _descriptionError;
  String? _categoryError;
  String? _priceError;
  String? _quantityError;
  String? _locationError;
  String? _imageError;
  File? _image;
  String? selectedStore;
  var store;
  List<String> storeNames = [];
  List<String> storeIDs = [];
  int? index;
  String imagePath = "";



  String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

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
    fetchStores().then((value) {
      setState(() {
        storeNames = value;
      });
    });
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

  bool _validateFields() {
    bool isValid = true;
    _nameError = null;
    _descriptionError = null;
    _categoryError = null;
    _priceError = null;
    _quantityError = null;
    _imageError = null;
    _locationError = null;
    final RegExp nameRegex = RegExp(r'^.{3,60}$');
    final RegExp categoryRegex = RegExp(r'^.{3,50}$');
    final RegExp priceRegex = RegExp(r'^[1-9]\d*(\.\d+)?$');
    final RegExp quantityRegex = RegExp(r'^\d+$');

    if (_nameController.text.isEmpty ||
        !nameRegex.hasMatch(_nameController.text)) {
      _nameError = 'Enter a valid product name (3-60 characters)';
      isValid = false;
    }

    if (_descriptionController.text.isNotEmpty &&
        _descriptionController.text.length > 1000) {
      _descriptionError = 'Description must be less than 1000 characters';
      isValid = false;
    }

    if (_categoryController.text.isEmpty ||
        !categoryRegex.hasMatch(_categoryController.text)) {
      _categoryError = 'Enter a valid category (3-50 characters)';
      isValid = false;
    }

    if (_priceController.text.isEmpty ||
        !priceRegex.hasMatch(_priceController.text)) {
      _priceError = 'Enter a valid selling price';
      isValid = false;
    }

    if (_quantityController.text.isEmpty ||
        !quantityRegex.hasMatch(_quantityController.text)) {
      _quantityError = 'Enter a valid quantity';
      isValid = false;
    }

    if (_image == null) {
      _imageError = 'Please select a product image';
      isValid = false;
    }

    setState(() {});

    return isValid;
  }

  void addProduct() async {

    
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

    if (_validateFields()) {
      try {
        var quantity = int.parse(_quantityController.text);
        var status = quantity == 0 ? 'sold out' : 'available';

        var product = {
          "name": _nameController.text,
          "quantity": int.parse(_quantityController.text),
          "sellingPrice": double.parse(_priceController.text),
          "image": imagePath,
          "description": _descriptionController.text,
          "category": _categoryController.text,
          "status": status,
        };

        var requestBody = {
          "products": [product]
        };

        var response = await http.post(
          Uri.parse(
              url + '${widget.userId}/stores/${storeIDs[index!]}/products'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          print('Product added successfully!');
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

             //  await FirebaseMessaging.instance.subscribeToTopic('merchant');
           await sendNotfiy("Product added successfully",
                "A Product has been added successfully!", uniqueId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add product.')),
          );
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
          print('Failed to add product. Status code: ${response.statusCode}');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding product')),
        );
        print('Error adding product: $error');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           Center(
            child: Text(
              'Add Product',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Approved.TextColor,
                fontSize: isDesktop? 28 : 24.0,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/add_product0.png',
              width: isDesktop? 350: 300,
              height: isDesktop? 250: 200,
            ),
          ),
          SizedBox(
              height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,

            child: TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                 labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),
                labelText: 'Product Name',
                prefixIcon:  Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.shopping_bag, size: isDesktop? 30 : 20 ),
                ),
                errorText: _nameError,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius:
                      BorderRadius.circular(Approved.defaultPadding / 2),
                ),
              ),
              style: TextStyle(fontSize: isDesktop ? 22: 18)

            ),
          ),
          const SizedBox(height: Approved.defaultPadding / 2),
          SizedBox(
              height: isDesktop ? 60 : 55,
                width: isDesktop ? 700 : 400,

            child: TextFormField(
              controller: _descriptionController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                 labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                labelText: 'Product Description',
                prefixIcon:  Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.description,  size: isDesktop? 30 : 20),
                ),
                errorText: _descriptionError,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius:
                      BorderRadius.circular(Approved.defaultPadding / 2),
                ),
              ),
              style: TextStyle(fontSize: isDesktop ? 22: 18)

            ),
          ),
          const SizedBox(height: Approved.defaultPadding / 2),
          SizedBox(
              height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,

            child: TextFormField(
              controller: _categoryController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                 labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                labelText: 'Product Category',
                prefixIcon:  Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.category,  size: isDesktop? 30 : 20),
                ),
                errorText: _categoryError,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius:
                      BorderRadius.circular(Approved.defaultPadding / 2),
                ),
              ),
              style: TextStyle(fontSize: isDesktop ? 22: 18)

            ),
          ),
          const SizedBox(height: Approved.defaultPadding / 2),
          SizedBox(
              height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,

            child: TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                 labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                labelText: 'Product Silling Price',
                prefixIcon:  Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.monetization_on,  size: isDesktop? 30 : 20),
                ),
                errorText: _priceError,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius:
                      BorderRadius.circular(Approved.defaultPadding / 2),
                ),
              ),
              style: TextStyle(fontSize: isDesktop ? 22: 18)

            ),
          ),
          const SizedBox(height: Approved.defaultPadding / 2),
          SizedBox(
              height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,

            child: TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                 labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                labelText: 'Product Quantity',
                prefixIcon:  Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.format_list_numbered,  size: isDesktop? 30 : 20),
                ),
                errorText: _quantityError,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius:
                      BorderRadius.circular(Approved.defaultPadding / 2),
                ),
              ),
              style: TextStyle(fontSize: isDesktop ? 22: 18)

            ),
          ),
          const SizedBox(height: Approved.defaultPadding / 2),
          SizedBox(
              height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,

            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Approved.LightColor,
                borderRadius: BorderRadius.circular(Approved.defaultPadding / 2),
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
                         size: isDesktop? 30 : 20
                      ),
                    ),
                    Text(
                      'Product Image',
style: TextStyle(fontSize: isDesktop ? 22: 18)
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Approved.defaultPadding / 2),
          SizedBox(
              height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 400,

            child: DropdownButtonFormField<String>(
              value: selectedStore,
              onChanged: (newValue) {
                setState(() {
                  selectedStore = newValue!;
                  index = storeNames.indexOf(selectedStore!);
                  print(storeIDs[index!]);
                });
              },
              items: storeNames.map((String storeName) {
                return DropdownMenuItem<String>(
                  value: storeName,
                  child: Text(storeName,
                  style: TextStyle(fontSize: isDesktop ? 22: 18, color: Colors.black)
),
                );
              }).toList(),
              decoration: InputDecoration(
                 labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18, color: Colors.black),

                labelText: 'Select store location',
                prefixIcon:  Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.info,  size: isDesktop? 30 : 20),
                ),
                errorText: _locationError,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius:
                      BorderRadius.circular(Approved.defaultPadding / 2),
                ),
              ),
              style: TextStyle(fontSize: isDesktop ? 22: 18)

            ),
          ),
          const SizedBox(height: Approved.defaultPadding / 2),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
            SizedBox(
              height: isDesktop ? 60 : 50,
                width: isDesktop ? 700 : 350,

            child: ElevatedButton(
              onPressed: addProduct,
              child:  Text('Add Product',
              style: TextStyle(fontSize: isDesktop ? 22: 18)

              ),
            ),
          ),
          ],)
        ],
      ),
    );
  }
}
