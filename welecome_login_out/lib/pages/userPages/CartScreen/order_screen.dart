import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Inventory/reuseable_dropdown.dart';
import 'package:welecome_login_out/pages/userPages/CartScreen/order_details.dart';
import 'package:welecome_login_out/pages/userPages/Screen/userpage.dart';

class UserOrderPage extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  const UserOrderPage({Key? key, required this.userId, required this.userCredential, required this.signedInUserEmail}) : super(key: key);

  @override
  State<UserOrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<UserOrderPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    final urlReq = Uri.parse('$url${widget.userId}/orders');
    try {
      final response = await http.get(urlReq);
      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          isLoading = false;
        });
        print("orders: $orders");
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.red;
      case 'processing':
        return Colors.yellow;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  final List<String> location = [
    'Nablus',
    'Jerusalem',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Beit Sahour',
    'Jericho',
    'Salfit',
    'Jenin',
    'Ramallah',
    'Al-Bireh',
    'Tubas',
    'Hebron'
  ];
  final List<String> status = ['pending', 'processing', 'shipped', 'delivered'];

  final List<String> Date = [
    'all',
    'last 3 days',
    'last 7 days',
    'last month',
  ];
  final List<String> price = [
    'all',
    'less than 100',
    'between 100-500',
    'above 500',
  ];

  final valueListenable1 = ValueNotifier<String?>(null);
  final valueListenable2 = ValueNotifier<String?>(null);
  final valueListenable4 = ValueNotifier<String?>(null);
  final valueListenable5 = ValueNotifier<String?>(null);
  final valueListenable3 = ValueNotifier<String?>(null);

  Widget _buildFilters() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                width: 8,
              ),
              ReusableDropdown(
                items: ['All', ...location],
                valueListenable: valueListenable3,
                onChanged: (value) {
                  setState(() {});
                  valueListenable3.value = value;
                },
                icon: const Icon(Icons.store, size: 16, color: Colors.white),
                hintText: 'Location',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
              ReusableDropdown(
                items: ['All', ...status],
                valueListenable: valueListenable1,
                onChanged: (value) {
                  setState(() {

                  });
                  valueListenable1.value = value;
                },
                icon: const Icon(Icons.align_vertical_bottom,
                    size: 16, color: Colors.white),
                hintText: 'Status',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
              ReusableDropdown(
                items: [...price],
                valueListenable: valueListenable2,
                onChanged: (value) {
                  setState(() {

                  });
                  valueListenable2.value = value;
                },
                icon: const Icon(Icons.price_change,
                    size: 16, color: Colors.white),
                hintText: 'Price',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
              ReusableDropdown(
                items: Date,
                valueListenable: valueListenable4,
                onChanged: (value) {
                  setState(() {

                  });
                  valueListenable4.value = value;
                },
                icon:
                    const Icon(Icons.date_range, size: 16, color: Colors.white),
                hintText: 'Date',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String status = order["status"];
    String location = order["customerInfo"]["address"].split(',')[0];
    double totalPrice = double.tryParse(order["totalPrice"].toString()) ?? 0.0;
    DateTime orderDate = DateTime.parse(order["date"]);
    bool showOrder = true;

    if (valueListenable3.value != null && valueListenable3.value != 'All') {
      if (location != valueListenable3.value) {
        showOrder = false;
      }
    }

    if (valueListenable1.value != null && valueListenable1.value != 'All') {
      if (status != valueListenable1.value) {
        showOrder = false;
      }
    }

    if (valueListenable2.value != null && valueListenable2.value != 'All') {
      switch (valueListenable2.value) {
        case 'less than 100':
          if (totalPrice >= 100) {
            showOrder = false;
          }
          break;
        case 'between 100-500':
          if (totalPrice < 100 || totalPrice >= 500) {
            showOrder = false;
          }
          break;
        case 'above 500':
          if (totalPrice <= 500) {
            showOrder = false;
          }
          break;
        default:
          break;
      }
    }
    if (valueListenable4.value != null && valueListenable4.value != 'all') {
      switch (valueListenable4.value) {
        case 'last 3 days':
          if (DateTime.now().difference(orderDate).inDays > 3) {
            showOrder = false;
          }
          break;
        case 'last 7 days':
          if (DateTime.now().difference(orderDate).inDays > 7) {
            showOrder = false;
          }
          break;
        case 'last month':
          if (DateTime.now().difference(orderDate).inDays > 30) {
            showOrder = false;
          }
          break;
        default:
          break;
      }
    }

    if (!showOrder) {
      return Container(); 
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(Approved.defaultPadding / 2),
      child: Padding(
        padding: const EdgeInsets.all(Approved.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #:: ${order["_id"].toString().substring(0, 20)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Approved.PrimaryColor,
                fontSize: 18.0,
                fontFamily: 'Montserrat',
              ),
            ),
            const Divider(),
            const SizedBox(
              height: Approved.defaultPadding,
            ),
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_sharp,
                  size: 40,
                  color: Approved.PrimaryColor,
                ),
                const SizedBox(width: Approved.defaultPadding /2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order["customerInfo"]["name"]}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      '${order["customerInfo"]["address"]}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '$status',
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               Text(
                  '${order["date"] != null ? order["date"].toString().split('T')[0] : ''}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  'Total Price: ${order["totalPrice"]}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_circle_right_outlined,
                      size: 30, color: Approved.PrimaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserOrderDetails(
                          signedInUserEmail: widget.signedInUserEmail,
                            orderDetails: order, userId: widget.userId, userCredential: widget.userCredential,),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserTabsScreen(
                        userId: widget.userId, 
                        userCredential: widget.userCredential,
                        signedInUserEmail: widget.signedInUserEmail,
                      )),
            );

          
          },
        ),

      ),

      body: Column(children: [
        SizedBox(
          height: Approved.defaultPadding,
        ),
        _buildFilters(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text('No orders available'))
                    : RefreshIndicator(
                        onRefresh: fetchOrders,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(orders[index]);
                            },
                          ),
                        ),
                      ),
          ),
        ),
      ]),
    );
  }
}
