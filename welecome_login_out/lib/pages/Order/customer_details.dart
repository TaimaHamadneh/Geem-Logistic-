import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Order/manage_order.dart';

class CustomerDetails extends StatefulWidget {
  final String userId;
  final String orderId;
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> orderDetails;
  final UserCredential userCredential;
  final String signedInUserEmail;

  CustomerDetails(
      {Key? key,
      required this.userId,
      required this.customerInfo,
      required this.signedInUserEmail,
      required this.orderId,
      required this.orderDetails,
      required this.userCredential})
      : super(key: key);

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  final List<String> _cities = [
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

  Future<void> _updateCustomerInfo(
    BuildContext context,
    Map<String, dynamic> updatedInfo,
    Map<String, dynamic> orderDetails,
  ) async {
    final urlReq = url + 'orders/${widget.orderId}';
    print('urlReq: $urlReq');

    final body = {
      "userId": widget.userId,
      "products": orderDetails["products"],
      "customerInfo": updatedInfo,
      "status": orderDetails["status"]
    };
    print('body: $body');

    final response = await http.put(
      Uri.parse(urlReq),
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Customer information updated successfully'),
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
      print('Failed to update customer info: ${response.statusCode}');
      print('Error message: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> addressParts = widget.customerInfo["address"].split(",");
    String selectedCity = addressParts[0];
    String town = addressParts.length > 1 ? addressParts[1] : '';

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: const Text('Customer Details'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
             const SizedBox(height: Approved.defaultPadding * 3),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Approved.PrimaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Approved.defaultPadding),
                  child: Column(
                    children: [
                      const Text(
                        'Update customer Delivery Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20.0,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: Approved.defaultPadding * 2),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              color: Approved.PrimaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: '${widget.customerInfo["name"]}'),
                              onChanged: (value) {
                                widget.customerInfo["name"] = value;
                              },
                              decoration: const InputDecoration(
                                fillColor: Approved.LightColor,
                                labelText: 'Customer Name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: Approved.defaultPadding,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.email, color: Approved.PrimaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: '${widget.customerInfo["email"]}'),
                              onChanged: (value) {
                                widget.customerInfo["email"] = value;
                              },
                              decoration: const InputDecoration(
                                fillColor: Approved.LightColor,
                                labelText: 'Email',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      Row(
                        children: [
                          const Icon(
                            Icons.contact_page,
                            color: Approved.PrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: '${widget.customerInfo["phone"]}'),
                              onChanged: (value) {
                                widget.customerInfo["phone"] = value;
                              },
                              decoration: const InputDecoration(
                                fillColor: Approved.LightColor,
                                labelText: 'Customer Phone',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: Approved.defaultPadding,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Approved.PrimaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField(
                              value: selectedCity,
                              items: _cities.map((city) {
                                return DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                selectedCity = value!;
                                widget.customerInfo["address"] =
                                    "$selectedCity,$town";
                              },
                              decoration: const InputDecoration(
                                fillColor: Approved.LightColor,
                                labelText: 'City',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Approved.defaultPadding),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Approved.PrimaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: town),
                              onChanged: (value) {
                                town = value;
                                widget.customerInfo["address"] =
                                    "$selectedCity, $town";
                              },
                              decoration: const InputDecoration(
                                fillColor: Approved.LightColor,
                                labelText: 'Town',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: Approved.defaultPadding * 2,
                      ),
                      SizedBox(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            _updateCustomerInfo(
                              context,
                              {
                                "name": widget.customerInfo["name"],
                                "email": widget.customerInfo["email"],
                                "address": "$selectedCity, $town",
                                "phone": widget.customerInfo["phone"],
                              },
                              widget.orderDetails,
                            );
                          },
                          child: Text('Update'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
