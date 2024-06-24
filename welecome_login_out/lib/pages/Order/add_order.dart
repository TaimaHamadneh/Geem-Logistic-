import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Order/add_order_details.dart';

class AddOrder extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  const AddOrder({Key? key, required this.userId,
  required this.signedInUserEmail,
   required this.userCredential}) : super(key: key);
  @override
  _AddOrderState createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  List<dynamic> products = [];
  List<bool> checkedStates = []; 
  List<int> quantities = []; 

  List<String> selectedProducts = [];
  double totalPrice = 0.0; 

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void clearSelection() {
    setState(() {
      selectedProducts.clear();
      totalPrice = 0.0;
    });
  }

  Future<void> fetchProducts() async {
    final urlReq = Uri.parse(url + 'users/${widget.userId}/products');
    print('urlReq : $urlReq');
    try {
      final response = await http.get(urlReq);

      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          checkedStates = List<bool>.filled(
              products.length, false);
          quantities =
              List<int>.filled(products.length, 0); 
          print('products: $products');
        });

        
      } else {
        print('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  String? validateQuantity(int index) {
    int? enteredQuantity = quantities[index];
    int availableQuantity = products[index]["quantity"];

    if (enteredQuantity <= 0) {
    return 'Please enter a quantity greater than 0.';
  } else if (enteredQuantity > availableQuantity) {
    return 'Quantity cannot exceed available stock (${availableQuantity}).';
  }

    return null;
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Approved.defaultPadding),
            const Text(
              'Products:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 22.0,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: Approved.defaultPadding),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  if (index < products.length && index < checkedStates.length) {
                    final product = products[index];

                    return Card(
                      color: Approved.LightColor,
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: checkedStates[index],
                              onChanged: (value) {
                                setState(() {
                                  checkedStates[index] = value!;
                                  if (!value) {
                                    totalPrice -= quantities[index] *
                                        products[index]['sellingPrice'];
                                    clearSelection();
                                  }
                                });
                              },
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 70,
                                  width: 80,
                                  child: Container(
                                    child: product["image"] != null
                                        ? Image.file(File(product["image"]))
                                        : Image.asset(
                                            'assets/images/unknown_product.jpg'),
                                  ),
                                ),
                                const SizedBox(
                                  width: Approved.defaultPadding,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Text(
                                      'Price: ${product['sellingPrice']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: checkedStates[
                                index], 
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Approved.defaultPadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const SizedBox(
                                    width: Approved.defaultPadding * 4,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        prefixIcon:
                                            Icon(Icons.inventory_rounded),
                                        fillColor: Colors.white,
                                        labelText: 'Quantity',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        quantities[index] =
                                            int.tryParse(value) ?? 0;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: Approved.defaultPadding,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                bool isValid = true;
                List<int> selectedIndices = [];

                for (int i = 0; i < products.length; i++) {
                  if (checkedStates[i]) {
                    selectedIndices.add(i);
                    String? validationMessage = validateQuantity(i);
                    if (validationMessage != null) {
                      isValid = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(validationMessage),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      break;
                    }
                  }
                }

                if (isValid) {
                   selectedProducts.clear();
                    totalPrice = 0.0; 
                  for (int index in selectedIndices) {
                    selectedProducts.add(
                      '${products[index]['_id']} - Name: ${products[index]['name']} - Quantity: ${quantities[index]}',
                    );
                    totalPrice +=
                        quantities[index] * products[index]['sellingPrice'];
                  }

                  print('Selected Products:');
                  selectedProducts.forEach((product) {
                    print(product);
                  });

                  print('Total Price: $totalPrice');

                  if (selectedProducts.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderAddingDetails(
                          selectedProducts: selectedProducts,
                          totalPrice: totalPrice,
                          userId: widget.userId, userCredential: widget.userCredential,
                          signedInUserEmail: widget.signedInUserEmail,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select at least one product.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Text('Complete the order process'),
            ),
          ],
        ),
      ),
    );
  }
}
