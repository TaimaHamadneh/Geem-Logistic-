import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Order/manage_order.dart';

class EditProducts extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final Map<String, dynamic> orderDetails;
  final String signedInUserEmail;

  const EditProducts(
      {Key? key,
      required this.userId,
      required this.userCredential,
      required this.signedInUserEmail,
      required this.orderDetails})
      : super(key: key);
  @override
  _EditProductsState createState() => _EditProductsState();
}

class _EditProductsState extends State<EditProducts> {
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
          checkedStates = List<bool>.filled(products.length, false);
          quantities = List<int>.filled(products.length, 0);

          for (var i = 0; i < products.length; i++) {
            var product = products[i];

            for (var orderProduct in widget.orderDetails['products']) {
              if (orderProduct['productId'] == product['_id']) {
                checkedStates[i] = true;
                quantities[i] = orderProduct['quantity'];
                break;
              }
            }
          }

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
    int availableQuantity = products[index]["quantity"] + quantities[index];

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
          'Update Order',
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
                            visible: checkedStates[index],
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
                                      controller: TextEditingController(
                                          text: checkedStates[index]
                                              ? '${quantities[index]}'
                                              : ''),
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
              onPressed: () async {
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
                  List<Map<String, dynamic>> selectedProductsData = [];

                  for (int index in selectedIndices) {
                    selectedProducts.add(
                      '${products[index]['_id']} - Name: ${products[index]['name']} - Quantity: ${quantities[index]}',
                    );
                    totalPrice +=
                        quantities[index] * products[index]['sellingPrice'];

                    selectedProductsData.add({
                      'productId': products[index]['_id'],
                      'quantity': quantities[index],
                    });
                  }

                  print('Selected Products:');
                  selectedProducts.forEach((product) {
                    print(product);
                  });

                  print('Total Price: $totalPrice');

                  if (selectedProducts.isNotEmpty) {

                    final urlReq =
                        url + 'orders/${widget.orderDetails['_id']}/products';
                    print('urlReq: $urlReq');

                    final response = await http.put(
                      Uri.parse(urlReq),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode({'products': selectedProductsData}),
                    );

                    if (response.statusCode == 200) {

                      print('Products added to order successfully.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Products updated successfully'),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderPage(
                                  userId: widget.userId,
                                  userCredential: widget.userCredential,
                                  signedInUserEmail: widget.signedInUserEmail,
                                )),
                      );
                    } else {

                      print(
                          'Failed to add products to order. Error: ${response.reasonPhrase}');
                    }
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
              child: Text('Update Products'),
            ),
          ],
        ),
      ),
    );
  }
}
