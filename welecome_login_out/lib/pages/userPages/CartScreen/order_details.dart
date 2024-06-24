import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/userPages/CartScreen/customer_details.dart';

class UserOrderDetails extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final UserCredential userCredential;
   final List<dynamic>? products;
   final String signedInUserEmail;

  final String userId;
  const UserOrderDetails(
      {Key? key,
      required this.orderDetails,
      required this.userId,
      required this.userCredential, this.products, required this.signedInUserEmail})
      : super(key: key);

  @override
  State<UserOrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<UserOrderDetails> {
  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    Uri uri = Uri.parse('$url$productId/product');
    print('Making request to URI: $uri');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          'Failed to load product. Status code: ${response.statusCode}. Response body: ${response.body}');
      throw Exception(
          'Failed to load product. Server responded with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> products = widget.orderDetails["products"];

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 22.0,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Approved.defaultPadding),
        child: SingleChildScrollView(
          child: Column(children: [
            Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: Approved.PrimaryColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Approved.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Information',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        'ID: ${widget.orderDetails["_id"].toString().substring(0, 8)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: Approved.defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Delivery to: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserCustomerDetails(
                                userId: widget.userId,
                                signedInUserEmail: widget.signedInUserEmail,
                                customerInfo:
                                    widget.orderDetails["customerInfo"],
                                orderId: widget.orderDetails["_id"],
                                orderDetails: widget.orderDetails,
                                userCredential: widget.userCredential,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Change contact details',
                          style: TextStyle(
                            color: Approved.PrimaryColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Approved.PrimaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Approved.PrimaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Address: ${widget.orderDetails["customerInfo"]["address"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Approved.PrimaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Customer name: ${widget.orderDetails["customerInfo"]["name"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.contact_page,
                                  color: Approved.PrimaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Customer #: ${widget.orderDetails["customerInfo"]["phone"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.email,
                                  color: Approved.PrimaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Email: ${widget.orderDetails["customerInfo"]["email"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                   /*   const Text(
                        'Products: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          print('widget.orderDetails: ${widget.orderDetails}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => 

                              EditProducts(
                          userId: widget.userId, 
                          userCredential: widget.userCredential, 
                          orderDetails: widget.orderDetails,
                        )
                            ),
                          );
                        },
                        child: const Text(
                          'Change Product details',
                          style: TextStyle(
                            color: Approved.PrimaryColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),*/
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(products.length, (index) {
                      print(products[index]["productId"]);
                      return FutureBuilder<Map<String, dynamic>>(
                        future: getProductDetails(products[index]["productId"]),
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, dynamic>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Loading...");
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            return Card(

                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Approved.PrimaryColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      child: Container(
                                        child: snapshot.data!["image"] != null
                                            ? Image.file(
                                                File(snapshot.data!["image"]))
                                            : Image.asset(
                                                'assets/images/unknown_product.jpg'),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Approved.defaultPadding,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${snapshot.data!["name"]}',
                                            style: TextStyle(
                                              fontSize: snapshot.data!["name"]
                                                          .length >
                                                      20
                                                  ? 14
                                                  : 16, 
                                                  
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            maxLines:
                                                2,
                                            overflow: TextOverflow
                                                .ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${products[index]["quantity"]} items',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const Text("Product not found");
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        '\$${widget.orderDetails["totalPrice"]}',
                        style: const TextStyle(
                          color: Approved.PrimaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        '${widget.orderDetails["status"]}',
                        style: const TextStyle(
                          color: Approved.PrimaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    Text(
                        '${widget.orderDetails["date"] != null ? widget.orderDetails["date"].toString().split('T')[0] : ''}',
                        style: const TextStyle(
                          color: Approved.PrimaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: Approved.defaultPadding,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Approved.defaultPadding/2,),
  /*        Text("Payment upon delivery.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black
          ),)*/
          ],)
          
        ),
      ),
    );
  }
}
