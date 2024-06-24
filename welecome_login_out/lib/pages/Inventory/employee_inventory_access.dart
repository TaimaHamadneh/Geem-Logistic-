import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/components/splash.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/Inventory/add_inventory.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/pages/Inventory/reuseable_dropdown.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryEmployeeScreen extends StatefulWidget {
  const InventoryEmployeeScreen({
    Key? key,
    required this.userId,
    required this.userCredential,
    required this.signedInUserEmail,
  }) : super(key: key);

  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  @override
  State<InventoryEmployeeScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryEmployeeScreen> {
  final List<String> recentSearches = [];
  List<dynamic> products = [];
  String selectedStatus = 'all';
  bool isLoading = true;
  String selectedCategory = 'all';
  String selectedQuantity = 'all';
  String selectedPrice = 'all';
  String selectedName = '';
  int index_id = 0;
  String? selectedStore;
  var store;
  var product;
  List<String> storeNames = [];
  List<String> storeIDs = [];
  List<String> storeCat = [];
  List<String> storeQuantity = [];
  List<String> storePrice = [];
  String searchQuery = '';
  late List<TextEditingController> _quantityControllers;
  late List<bool> _isIconFilled;
  Map<String, int> updatedQuantities = {};

  @override
  void initState() {
    super.initState();
    fetchStores().then((value) {
      setState(() {
        storeNames = value;
      });
      fetchProductData();
    });
    _loadPersistedState();
  }

 Future<void> _loadPersistedState() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _isIconFilled = List<bool>.from(prefs.getStringList('isIconFilled')?.map((e) => e == 'true') ?? []);
    updatedQuantities = Map<String, int>.from(jsonDecode(prefs.getString('updatedQuantities') ?? '{}'));
  });
}

Future<void> _savePersistedState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('isIconFilled', _isIconFilled.map((e) => e.toString()).toList());
  await prefs.setString('updatedQuantities', jsonEncode(updatedQuantities));
}



  void onSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  List<dynamic> getFilteredProducts() {
    return products.where((product) {
      final productName = product['name']?.toLowerCase() ?? '';
      return productName.contains(searchQuery);
    }).toList();
  }

  Future<void> fetchProductData() async {
    final urlReq = Uri.parse(url + 'users/${widget.userId}/products');
    try {
      final response = await http.get(urlReq);
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
          _quantityControllers = List.generate(products.length, (index) => TextEditingController());
          if (_isIconFilled.length != products.length) {
            _isIconFilled = List.generate(products.length, (index) => false);
          }
        });

        Set<String> uniqueCategories = Set();
        for (product in products) {
          final category = product['category'];
          if (category != null) {
            uniqueCategories.add(category);
          }
        }
        setState(() {
          storeCat = uniqueCategories.toList();
        });
      } else {
        throw Exception('Failed to load store data');
      }
    } catch (e) {
      print('Error fetching store data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProductQuantity(String storeId, String productId, int quantity, int index) async {
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

    final urlReq = Uri.parse(url + 'stores/$storeId/products/$productId');
    final body = jsonEncode({'quantity': quantity});
    final headers = {"Content-Type": "application/json"};

    try {
      final response = await http.put(urlReq, body: body, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          updatedQuantities[productId] = quantity;
          _isIconFilled[index] = true;
          _savePersistedState();

          Timer(Duration(hours: 24), () {
            setState(() {
              _isIconFilled[index] = false;
              _savePersistedState();
            });
          });
        });
        print('Product updated successfully');

        String uniqueId = '${DateTime.now().millisecondsSinceEpoch}';

             //  await FirebaseMessaging.instance.subscribeToTopic('merchant');
           await sendNotfiy("Product Updated",
                "A product has been updated successfully!", uniqueId);
      } else {
        print('Failed to update product: ${response.body}');
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Widget _buildProductCards() {
    List<dynamic> filteredProducts = getFilteredProducts();

    return Expanded(
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          final quantityController = _quantityControllers[index];
          final productId = product['_id'];

          return Column(
            children: [
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Approved.ThirdColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 80,
                              width: 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Approved.PrimaryColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  color: Colors.white,
                                  child: product['image'] != null
                                      ? Image.file(
                                          File(product['image']),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/unknown_product.jpg',
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    product['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    '${updatedQuantities[productId] ?? product['quantity'] ?? 'Unknown'} items',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 80,
                                      child: TextFormField(
                                        controller: quantityController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        textInputAction: TextInputAction.next,
                                        decoration: const InputDecoration(
                                          labelText: 'quantity',
                                          hintText: ' ',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            _isIconFilled[index]
                                                ? Icons.check_circle
                                                : Icons.check_circle_outlined,
                                            size: 30,
                                          ),
                                          color: Approved.PrimaryColor,
                                          onPressed: () {
                                            final newQuantity = int.parse(quantityController.text);
                                            updateProductQuantity(storeIDs[index_id], productId, newQuantity, index);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<String>> fetchStores() async {
    final response = await http.get(Uri.parse(url + '${widget.userId}/storesById'));

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

  final List<String> status = ['available', 'sold out'];
  final List<String> quantity = ['all', 'less than 10', 'between 10-50', 'above 50'];
  final List<String> price = ['all', 'less than 10', 'between 10-50', 'above 50'];

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
              SizedBox(width: 5),
              ReusableDropdown(
                items: ['All', ...storeNames],
                valueListenable: valueListenable3,
                onChanged: (value) {
                  setState(() {
                    selectedStore = value == 'All' ? null : value;
                    index_id = selectedStore == null ? 0 : storeNames.indexOf(selectedStore!);
                    print(storeIDs.isNotEmpty ? storeIDs[index_id] : 'No store selected');
                  });
                  valueListenable3.value = value;
                },
                icon: Icon(Icons.store, size: 16, color: Colors.white),
                hintText: 'Select Store',
                hintStyle: TextStyle(color: Colors.black),
              ),
              SizedBox(width: 5),
              ReusableDropdown(
                items: ['All', ...storeCat],
                valueListenable: valueListenable1,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value == 'All' ? '' : value!;
                  });
                  valueListenable1.value = value;
                },
                icon: Icon(Icons.category, size: 16, color: Colors.white),
                hintText: 'Category',
                hintStyle: TextStyle(color: Colors.black),
              ),
              SizedBox(width: 5),
              ReusableDropdown(
                items: ['All', ...status],
                valueListenable: valueListenable2,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value == 'All' ? '' : value!;
                  });
                  valueListenable2.value = value;
                },
                icon: Icon(Icons.align_vertical_bottom, size: 16, color: Colors.white),
                hintText: 'Select status',
                hintStyle: TextStyle(color: Colors.black),
              ),
              SizedBox(width: 5),
              ReusableDropdown(
                items: quantity,
                valueListenable: valueListenable4,
                onChanged: (value) {
                  setState(() {
                    selectedQuantity = value == 'All' ? '' : value!;
                  });
                  valueListenable4.value = value;
                },
                icon: Icon(Icons.store_mall_directory_outlined, size: 16, color: Colors.white),
                hintText: 'Quantity',
                hintStyle: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Note: You should add the new quantity of products,\nthen click "Check" to save your update.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Approved.LightColor,
        appBar: AppBar(
          backgroundColor: Approved.LightColor,
          title: TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              labelText: 'Search by product name',
              prefixIcon: Icon(Icons.search, color: Colors.black),
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              color: Colors.black,
              iconSize: 24.0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: Approved.PrimaryColor,
                      ),
                      body: AddInventoryForm(
                        userId: widget.userId,
                        userCredential: widget.userCredential,
                        signedInUserEmail: widget.signedInUserEmail,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading ? SplashScreen() : _buildProductCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}