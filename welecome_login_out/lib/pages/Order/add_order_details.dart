import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Order/manage_order.dart';

class OrderAddingDetails extends StatefulWidget {
  final String userId;
  final List<String> selectedProducts;
  final double totalPrice;
  final UserCredential userCredential;
  final String signedInUserEmail;
  
  const OrderAddingDetails(
      {Key? key,
      required this.userId,
      required this.selectedProducts,
      required this.signedInUserEmail,
      required this.totalPrice, required this.userCredential})
      : super(key: key);
  @override
  _OrderAddingDetailsState createState() => _OrderAddingDetailsState();
}

class _OrderAddingDetailsState extends State<OrderAddingDetails> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Future<void> addOrder() async {
  List<Map<String, dynamic>> orderProducts = [];

  for (String product in widget.selectedProducts) {
    List<String> productInfo = product.split(' - ');
    String productId = productInfo[0];
    int quantity = int.parse(productInfo[2].split(': ')[1]);
    
    orderProducts.add({
      'productId': productId,
      'quantity': quantity,
    });
  }

  final Map<String, dynamic> orderData = {
    'userId': widget.userId,
    'products': orderProducts,
    'customerInfo': {
      'name': nameController.text,
      'email': emailController.text,
      'address': '${selectedLocation}, ${townController.text}',
      'phone': phoneController.text,
    },
    'status': 'pending',
  };

  final Uri urlReq = Uri.parse(url + 'AddOrder');

  try {
    final response = await http.post(
      urlReq,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order added successfully'),
        ),
      );
      
      Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderPage(
                userId: widget.userId,
                 userCredential: widget.userCredential,
                 signedInUserEmail: widget.signedInUserEmail,
                 )
            ),
          );

      
          } else {
      print('response.statusCode : ${response.reasonPhrase}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add order'),
        ),
      );
    }
  } catch (e) {
    print('Error adding order: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error adding order: $e'),
      ),
    );
  }
}
bool _validateCustomerInfo() {
  if (nameController.text.isEmpty || nameController.text.length < 3 || nameController.text.length > 20) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Name must be between 3 and 20 characters')));
    return false;
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid email')));
    return false;
  }

  if (!RegExp(r'^05\d{8}$').hasMatch(phoneController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Phone number must be 10 digits and start with 05')));
    return false;
  }

  return true;
}

  final List<String> locations = [
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
  String selectedLocation = 'Jerusalem';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: const Text(
          'Add Order',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 22.0,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Approved.defaultPadding),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Selected Products',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Approved.PrimaryColor,
                        ),
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.selectedProducts.map((product) {
                          List<String> productInfo = product.split(' - ');
                          String productId = productInfo[0];
                          String productName = productInfo[1].split(': ')[1];
                          String quantity = productInfo[2].split(': ')[1];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $productId',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Name: $productName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Quantity: $quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: Approved.defaultPadding),
                            ],
                          );
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Approved.PrimaryColor,
                            ),
                          ),
                          Text(
                            '${widget.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding/2),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Customer Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Approved.PrimaryColor),
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedLocation,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedLocation = newValue!;
                                });
                              },
                              items: locations.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Approved
                                          .LightColor), 
                                          
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: townController,
                              decoration:
                                  const InputDecoration(labelText: 'Town'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding/2,),
             ElevatedButton(
  onPressed: () {
    bool isValidCustomerInfo = _validateCustomerInfo();
    if (isValidCustomerInfo) {
      addOrder();
    }
  },
  child: const Text('Add Order'),
),

            ],
          ),
        ),
      ),
    );
  }
}
