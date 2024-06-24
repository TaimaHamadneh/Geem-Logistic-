import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Order/customer_details.dart';
import 'package:welecome_login_out/pages/Order/manage_order.dart';

class OrderDetails extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final UserCredential userCredential;
  final List<dynamic>? products;
  final String signedInUserEmail;

  final String userId;
  const OrderDetails(
      {Key? key,
      required this.orderDetails,
      required this.userId,
      required this.userCredential,
      required this.signedInUserEmail,
      this.products})
      : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
       DateTime now = new DateTime.now();

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
  Future<void> addNotification(
      String title, String body, String date, String id) async {
    try {
      var reqBody = {
        'userId': widget.orderDetails["user"],
        'title': title,
        'body': body,
        "date": date,
        "id": id
      };

      var response = await http.post(
        Uri.parse(url + 'addnotifications'),
        
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );
      print('$url + addnotifications');
      if (response.statusCode == 200 || response.statusCode == 201) {
       
        print('Notification added successfully');
      } else {
        print('Failed to add Notification');
      }
    } catch (e) {
      print('Error adding Notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    List<dynamic> products = widget.orderDetails["products"];

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title:  Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: isDesktop? 26: 22.0,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Approved.defaultPadding),
        child: SingleChildScrollView(
          child: Card(
          margin: EdgeInsets.symmetric(vertical: isDesktop? 20: 8.0, horizontal: isDesktop? 150 :16.0),
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: const BorderSide(color: Approved.PrimaryColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Approved.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        'Order Information',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize:isDesktop? 22: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        'ID: ${widget.orderDetails["_id"].toString().substring(0, 8)}',
                        style:  TextStyle(
                          color: Colors.black,
                          fontSize: isDesktop? 20: 18.0,
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
                       Text(
                        'Delivery to: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isDesktop?22:18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                  /*    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetails(
                                userId: widget.userId,
                                customerInfo:
                                    widget.orderDetails["customerInfo"],
                                orderId: widget.orderDetails["_id"],
                                orderDetails: widget.orderDetails,
                                userCredential: widget.userCredential,
                                signedInUserEmail: widget.signedInUserEmail,
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
                      ),*/
                    ],
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Approved.PrimaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                               Icon(Icons.location_on,
                                  color: Approved.PrimaryColor,
                                  size: isDesktop? 30: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Address: ${widget.orderDetails["customerInfo"]["address"]}',
                                style:  TextStyle(
                                  fontSize: isDesktop? 20: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                               Icon(Icons.person,
                                  color: Approved.PrimaryColor,
                                  size: isDesktop? 30: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Customer name: ${widget.orderDetails["customerInfo"]["name"]}',
                                style:  TextStyle(
                                  fontSize:  isDesktop? 20: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                               Icon(Icons.contact_page,
                                  color: Approved.PrimaryColor,
                                  size: isDesktop? 30: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Customer #: ${widget.orderDetails["customerInfo"]["phone"]}',
                                style:  TextStyle(
                                  fontSize:  isDesktop? 20: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                               Icon(Icons.email,
                                  color: Approved.PrimaryColor,
                                  size: isDesktop? 30: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Email: ${widget.orderDetails["customerInfo"]["email"]}',
                                style:  TextStyle(
                                  fontSize:  isDesktop? 20: 16,
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
                         Text(
                        'Products: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize:  isDesktop? 22: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),

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
                                side:const BorderSide(color: Approved.PrimaryColor),
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
                                      height:isDesktop? 100: 80,
                                      width: isDesktop? 100: 80,
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
                                                  ? isDesktop? 20: 14
                                                  : isDesktop? 22: 16,
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
                                            style:  TextStyle(
                                              fontSize: isDesktop? 20: 16,
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
                            return  Text("Product not found",
                            style:TextStyle(
                                              fontSize: isDesktop? 20: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ), );
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        'Total Price: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize:isDesktop? 22: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        '\$${widget.orderDetails["totalPrice"]}',
                        style:  TextStyle(
                          color: Approved.PrimaryColor,
                          fontSize: isDesktop? 20: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        'Status: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isDesktop? 22: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        '${widget.orderDetails["status"]}',
                        style:  TextStyle(
                          color: Approved.PrimaryColor,
                          fontSize: isDesktop? 20: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        'Date : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isDesktop? 22: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        '${widget.orderDetails["date"] != null ? widget.orderDetails["date"].toString().split('T')[0] : ''}',
                        style:  TextStyle(
                          color: Approved.PrimaryColor,
                          fontSize: isDesktop? 20: 16,
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
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Approved.PrimaryColor,
                          border: Border.all(color: Colors.white),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            String selectedStatus =
                                widget.orderDetails["status"];
                            final confirmed = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context, setState) {
                                    return AlertDialog(
                                      backgroundColor: Approved.PrimaryColor,
                                      title:  Text(
                                        'Edit Status',
                                        style: TextStyle(
                                            fontSize: isDesktop? 24: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title:  Text(
                                              'Pending',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isDesktop? 22: 18,
                                              ),
                                            ),
                                            leading: Radio(
                                              value: 'pending',
                                              groupValue: selectedStatus,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedStatus =
                                                      value.toString();
                                                });
                                              },
                                              activeColor: Colors.white,
                                            ),
                                          ),
                                          ListTile(
                                            title:  Text(
                                              'Processing',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isDesktop? 22: 18,
                                              ),
                                            ),
                                            leading: Radio(
                                              value: 'processing',
                                              groupValue: selectedStatus,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedStatus =
                                                      value.toString();
                                                });
                                              },
                                              activeColor: Colors.white,
                                            ),
                                          ),
                                          ListTile(
                                            title:  Text(
                                              'Shipped',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isDesktop? 22: 18,
                                              ),
                                            ),
                                            leading: Radio(
                                              value: 'shipped',
                                              groupValue: selectedStatus,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedStatus =
                                                      value.toString();
                                                });
                                              },
                                              activeColor: Colors.white,
                                            ),
                                          ),
                                          ListTile(
                                            title:  Text(
                                              'Delivered',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isDesktop? 22: 18,
                                              ),
                                            ),
                                            leading: Radio(
                                              value: 'delivered',
                                              groupValue: selectedStatus,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedStatus =
                                                      value.toString();
                                                });
                                              },
                                              activeColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                                false); 
                                          },
                                          child:  Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: isDesktop? 24: 20,),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderPage(
                                                        userId: widget.userId,
                                                        userCredential: widget
                                                            .userCredential,
                                                            signedInUserEmail: widget.signedInUserEmail,
                                                      )),
                                            );
                                          },
                                          child:  Text(
                                            'Confirm Edit',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: isDesktop? 24: 20,
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );

                            if (confirmed == true) {
                              final orderId = widget.orderDetails["_id"];
                              final urlReq = url + 'orders/$orderId';
                              final Map<String, dynamic> data = {
                                "products": products,
                                "customerInfo":
                                    widget.orderDetails["customerInfo"],
                                "status": selectedStatus,
                              };

                              try {
                                final response = await http.put(
                                  Uri.parse(urlReq),
                                  body: jsonEncode(data),
                                  headers: {
                                    'Content-Type': 'application/json',
                                  },
                                );

                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Status updated successfully'),
                                    ),
                                  );
                                  setState(() {
                                    widget.orderDetails["status"] =
                                        selectedStatus;
                                  });
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
          'to': '/topics/users'
        },
      ),
    );
  }
String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

            //   await FirebaseMessaging.instance.subscribeToTopic('users');
           await sendNotfiy("Your order status",
                "Your Order status has change to : $selectedStatus!", uniqueId);

                    addNotification(
          "Your order status",
             "Your Order status has change to : $selectedStatus!",
          DateTime.parse(now.toString()).toString(),
          uniqueId,
        );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update status'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to update status, Exception occurred'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Edit Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop? 24: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 10), 
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Approved.PrimaryColor,
                          border: Border.all(color: Colors.white),
                        ),
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Approved.PrimaryColor,
                                  title:  Text(
                                    'Confirm Delete',
                                    style: TextStyle(
                                      fontSize:  isDesktop? 28: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  content:  Text(
                                    'Are you sure you want to delete this product?',
                                    style: TextStyle(
                                      fontSize:isDesktop? 22: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child:  Text(
                                        'Cancel',
                                        style: TextStyle(
                                       fontSize: isDesktop? 24: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final urlReq = url +
                                            '${widget.orderDetails["_id"]}/deleteOrder';
                                        print('urlReq: $urlReq');
                                        try {
                                          final response = await http
                                              .delete(Uri.parse(urlReq));

                                          if (response.statusCode == 200) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Order deleted successfully.'),
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderPage(
                                                        userId: widget.userId,
                                                        userCredential: widget
                                                            .userCredential,
                                                            signedInUserEmail: widget.signedInUserEmail,
                                                      )),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Failed to delete Order.'),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Failed to delete Order.'),
                                            ),
                                          );
                                          print('Error deleting Order: $e');
                                        }
                                      },
                                      child:  Text(
                                        'Delete',
                                        style: TextStyle(
                                       fontSize: isDesktop? 24: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child:  Row(
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop? 24: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
