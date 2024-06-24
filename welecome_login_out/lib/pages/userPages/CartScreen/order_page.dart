// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/userPages/Screen/userpage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

enum PaymentMethod { cash, visa }

class UserOrder extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final List<String> selectedProducts;
  final String totalPrice;
  final String signedInUserEmail;

  const UserOrder({
    Key? key,
    required this.userId,
    required this.selectedProducts,
    required this.totalPrice,
    required this.userCredential,
    required this.signedInUserEmail,
  }) : super(key: key);

  @override
  _UserOrderState createState() => _UserOrderState();
}

class _UserOrderState extends State<UserOrder> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController =
      TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  List<dynamic> cartProducts = [];

     DateTime now = new DateTime.now();


  @override
  void initState() {
    super.initState();
    fetchCartDetails();
  }
  

  Future<void> fetchCartDetails() async {
    final response =
        await http.get(Uri.parse(url + '${widget.userId}/getCartProducts'));

    if (response.statusCode == 200) {
      setState(() {
        cartProducts = json.decode(response.body);
        print('cartProducts: $cartProducts');
      });
    } else {
      throw Exception('Failed to load cart details');
    }
  }
   Future<void> addNotification(
      String title, String body, String date, String id) async {
    try {
      var reqBody = {
        'userId': widget.userId,
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

  Future<void> deleteCart(String userId) async {
    String urlReq = url + '$userId/removeAllCartProducts';

    try {
      final response = await http.delete(Uri.parse(urlReq));
      if (response.statusCode == 200) {
        print('delete cart Products successfully');
      } else {
        throw Exception(
            'Failed to cart Favorites Products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting cart Products: $e');
    }
  }


// inside your _UserOrderState class
  Future<void> addOrder() async {
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
    try {
      final List<Map<String, dynamic>> products = cartProducts.map((product) {
        return {
          'productId': product['productId'],
          'quantity': product['quantity'],
          'storeId': product['storeId']
        };
      }).toList();

      final Map<String, dynamic> orderData = {
        'userId': widget.userId,
        'products': products,
        'customerInfo': {
          'name': nameController.text,
          'email': emailController.text,
          'address': '$selectedLocation,${townController.text}',
          'phone': phoneController.text,
        },
        'status': 'pending',
        'paymentMethod': _selectedPaymentMethod
            .toString()
            .split('.')
            .last, // Added payment method
        if (_selectedPaymentMethod == PaymentMethod.visa) ...{
          'cardInfo': {
            'cardNumber': cardNumberController.text,
            'cardHolderName': cardHolderNameController.text,
            'expiryDate': expiryDateController.text,
            'cvv': cvvController.text,
          }
        }
      };

      String urlReq = url + 'AddOrder';
      final response = await http.post(
        Uri.parse(urlReq),
        body: json.encode(orderData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201) {
          String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

             //  await FirebaseMessaging.instance.subscribeToTopic('merchant');
           await sendNotfiy("Order created successfully",
                "An Order has been created successfully!", uniqueId);

                addNotification(
          "Order created successfully",
            "An Order has been created successfully!",
          DateTime.parse(now.toString()).toString(),
          uniqueId,
        );

        final responseData = json.decode(response.body);
        final orderId = responseData['order']['_id'];
        print('responseData : $responseData');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserTabsScreen(
                      userCredential: widget.userCredential,
                      userId: widget.userId,
                      signedInUserEmail: widget.signedInUserEmail,
                    ),
                  ),
                );
                return true;
              },
              child: AlertDialog(
                backgroundColor: Approved.PrimaryColor,
                title: const Text(
                  'Success',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                content: const Text(
                  'Order created successfully. Do you want to delete cart\'s products?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      deleteCart(widget.userId);
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserTabsScreen(
                            userCredential: widget.userCredential,
                            userId: widget.userId,
                            signedInUserEmail: widget.signedInUserEmail,
                          ),
                        ),
                      );
                      showFeedbackDialog(context); // Show feedback dialog

                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserTabsScreen(
                            userCredential: widget.userCredential,
                            userId: widget.userId,
                            signedInUserEmail: widget.signedInUserEmail,
                          ),
                        ),
                      );
                      showFeedbackDialog(context); // Show feedback dialog
                    },
                    child: const Text(
                      'NO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          },
        );

        print('Order created successfully: $responseData');
      } else {
        final errorMessage = json.decode(response.body)['message'];
        print('Failed to create order: $errorMessage');

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('The product is sold out ')));
      }
    } catch (error) {
      print('Error creating order: $error');
    }
  }

  void showFeedbackDialog(BuildContext context) {
    double _rating = 0.0;
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Add Feedback',
            style: TextStyle(color: Approved.PrimaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await submitFeedback(
                    _rating, feedbackController.text as TextEditingController);
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Approved.PrimaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitFeedback(
      double stars, TextEditingController feedbackController) async {
    final feedback = Feedback(
      userId: widget.userId,
      note: feedbackController.text, // Use feedbackController to get the text
      stars: stars,
    );

    String urlReq = url + 'addFeedback';

    try {
      final response = await http.post(
        Uri.parse(urlReq),
        body: json.encode(feedback.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201) {
        print('Feedback submitted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thank you for your feedback!')),
        );
      } else {
        print('Failed to submit feedback');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback')),
        );
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while submitting feedback')),
      );
    }
  }

  bool _validateCustomerInfo() {
    if (nameController.text.isEmpty ||
        nameController.text.length < 3 ||
        nameController.text.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name must be between 3 and 20 characters')));
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a valid email')));
      return false;
    }

    if (!RegExp(r'^05\d{8}$').hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Phone number must be 10 digits and start with 05')));
      return false;
    }

    if (_selectedPaymentMethod == PaymentMethod.visa) {
      if (cardNumberController.text.isEmpty ||
          cardNumberController.text.length != 16) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Card number must be 16 digits')));
        return false;
      }

      if (cardHolderNameController.text.isEmpty ||
          cardHolderNameController.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Cardholder name must be at least 3 characters')));
        return false;
      }

      if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$')
          .hasMatch(expiryDateController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Expiry date must be in MM/YY format')));
        return false;
      }

      if (cvvController.text.isEmpty || cvvController.text.length != 3) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('CVV must be 3 digits')));
        return false;
      }
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
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: const Text(
          'Order',
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
              const SizedBox(height: Approved.defaultPadding * 2),
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
                            '${widget.totalPrice}',
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
                                  borderSide:
                                      BorderSide(color: Approved.LightColor),
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
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
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
                        'Payment Method',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Approved.PrimaryColor,
                        ),
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<PaymentMethod>(
                              title: const Text('Cash'),
                              value: PaymentMethod.cash,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (PaymentMethod? value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<PaymentMethod>(
                              title: const Text('Visa'),
                              value: PaymentMethod.visa,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (PaymentMethod? value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_selectedPaymentMethod == PaymentMethod.visa) ...[
                        const SizedBox(height: Approved.defaultPadding),
                        TextField(
                          controller: cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Card Number',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: Approved.defaultPadding),
                        TextField(
                          controller: cardHolderNameController,
                          decoration: const InputDecoration(
                            labelText: 'Cardholder Name',
                          ),
                        ),
                        const SizedBox(height: Approved.defaultPadding),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: expiryDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Expiry Date (MM/YY)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: cvvController,
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Approved.defaultPadding * 2),
              ElevatedButton(
                onPressed: () {
                  bool isValidCustomerInfo = _validateCustomerInfo();
                  if (isValidCustomerInfo) {
                    addOrder();
                  }
                },
                child: const Text('Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Feedback {
  final String userId;
  final String note;
  final double stars;

  Feedback({
    required this.userId,
    required this.note,
    required this.stars,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'note': note,
      'stars': stars,
    };
  }
}
