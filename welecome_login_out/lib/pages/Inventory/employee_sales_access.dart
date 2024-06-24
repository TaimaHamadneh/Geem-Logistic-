import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/components/splash.dart';
import 'package:welecome_login_out/config.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/pages/Inventory/employee_edit.dart';
import 'package:welecome_login_out/pages/Inventory/info_page.dart';
import 'package:welecome_login_out/pages/Inventory/reuseable_dropdown.dart';

class SalesEmployeeScreen extends StatefulWidget {
  const SalesEmployeeScreen(
      {Key? key,
      required this.userId,
      required this.userCredential,
      required this.signedInUserEmail})
      : super(key: key);

  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;
  @override
  State<SalesEmployeeScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<SalesEmployeeScreen> {
  final List<String> recentSearches = [];
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
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

  @override
  void initState() {
    super.initState();
    fetchStores().then((value) {
      setState(() {
        storeNames = value;
      });
      fetchProductData();
    });
  }

  Future<void> fetchProductData() async {
    final urlReq = Uri.parse(url + 'users/${widget.userId}/products');
    try {
      final response = await http.get(urlReq);
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
        print('products: ${products}');

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
        print('storeCat: ${storeCat}');
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

  Widget _buildStatusCircle(String? status) {
    IconData iconData = Icons.check;
    Color iconColor = Colors.white;
    Color circleColor = Approved.green;

    if (status == 'sold out') {
      iconData = Icons.close;
      circleColor = Approved.red;
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      child: Center(
        child: Icon(
          iconData,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildProductCards() {
    List<dynamic> filteredProducts = products.where((product) {
      final String status = product['status'];
      final String enteredStatus = selectedStatus;

      if (enteredStatus.isNotEmpty &&
          enteredStatus != 'all' &&
          status != enteredStatus) {
        return false;
      }

      final String? category = product['category'];
      final String enteredCategory =
          selectedCategory.isNotEmpty ? selectedCategory : 'all';

      if (enteredCategory != 'all' && category != enteredCategory) {
        return false;
      }

      final String? id = product['store'];
      final String? enteredId = storeIDs[index_id];

      if (enteredId != null && id != null) {
        if (enteredId.isNotEmpty &&
            !id.contains(enteredId) &&
            selectedStore != null) {
          return false;
        }
      }

      if (selectedQuantity != 'all') {
        final int? quantity = product['quantity'];
        switch (selectedQuantity) {
          case 'less than 10':
            if (quantity == null || quantity >= 10) {
              return false;
            }
            break;
          case 'between 10-50':
            if (quantity == null || quantity < 10 || quantity > 50) {
              return false;
            }
            break;
          case 'above 50':
            if (quantity == null || quantity <= 50) {
              return false;
            }
            break;
          default:
            break;
        }
      }

      if (selectedPrice != 'all') {
        final double? sellingPrice = product['sellingPrice']?.toDouble();

        switch (selectedPrice) {
          case 'less than 10':
            if (sellingPrice == null || sellingPrice >= 10.0) {
              return false;
            }
            break;
          case 'between 10-50':
            if (sellingPrice == null ||
                sellingPrice < 10.0 ||
                sellingPrice > 50.0) {
              return false;
            }
            break;
          case 'above 50':
            if (sellingPrice == null || sellingPrice <= 50.0) {
              return false;
            }
            break;
          default:
            break;
        }
      }

      return true;
    }).toList();

    return Expanded(
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];

          return Card(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 65,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Approved.PrimaryColor),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            color: Colors.white,
                            child: product['image'] != null
                                ? Image.file(File(product['image']),
                                    fit: BoxFit.cover)
                                : Image.asset(
                                    'assets/images/unknown_product.jpg'),
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
                                fontSize: 22.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              '${product['quantity'] ?? 'Unknown'} items',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black54,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Text(
                                '\$ ${product['sellingPrice'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              _buildStatusCircle(product['status']),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 20.0),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Approved.PrimaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductEmployeePage(
                                product: product,
                                userId: widget.userId,
                                userCredential: widget.userCredential,
                                signedInUserEmail: widget.signedInUserEmail,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.info),
                        color: Approved.PrimaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductInfoPage(
                                product: product,
                              ),
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
        },
      ),
    );
  }

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

  final List<String> status = [
    'available',
    'sold out',
  ];

  final List<String> quantity = [
    'all',
    'less than 10',
    'between 10-50',
    'above 50',
  ];
  final List<String> price = [
    'all',
    'less than 10',
    'between 10-50',
    'above 50',
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
                width: 5,
              ),
              ReusableDropdown(
                items: ['All', ...storeNames],
                valueListenable: valueListenable3,
                onChanged: (value) {
                  setState(() {
                    selectedStore = value == 'All' ? null : value;
                    index_id = selectedStore == null
                        ? 0
                        : storeNames.indexOf(selectedStore!);
                    print(storeIDs.isNotEmpty
                        ? storeIDs[index_id]
                        : 'No store selected');
                  });
                  valueListenable3.value = value;
                },
                icon: const Icon(Icons.store, size: 16, color: Colors.white),
                hintText: 'Select Store',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
              ReusableDropdown(
                items: ['All', ...storeCat],
                valueListenable: valueListenable1,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value == 'All' ? '' : value!;
                  });
                  valueListenable1.value = value;
                },
                icon: const Icon(Icons.category, size: 16, color: Colors.white),
                hintText: 'Category',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
              ReusableDropdown(
                items: ['All', ...status],
                valueListenable: valueListenable2,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value == 'All' ? '' : value!;
                  });
                  valueListenable2.value = value;
                },
                icon: const Icon(Icons.align_vertical_bottom,
                    size: 16, color: Colors.white),
                hintText: 'Select status',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
              ReusableDropdown(
                items: quantity,
                valueListenable: valueListenable4,
                onChanged: (value) {
                  setState(() {
                    selectedQuantity = value == 'All' ? '' : value!;
                  });
                  valueListenable4.value = value;
                },
                icon: const Icon(Icons.store_mall_directory_outlined,
                    size: 16, color: Colors.white),
                hintText: 'Quantity',
                hintStyle: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                width: 5,
              ),
              ReusableDropdown(
                items: price,
                valueListenable: valueListenable5,
                onChanged: (value) {
                  setState(() {
                    selectedPrice = value == 'All' ? '' : value!;
                  });
                  valueListenable5.value = value;
                },
                icon: const Icon(Icons.monetization_on_rounded,
                    size: 16, color: Colors.white),
                hintText: 'Selling Price',
                hintStyle: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
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
          title: const Text(
            'Stock Management',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
/**
 *           actions: [
            IconButton(
              icon: const Icon(Icons.add),
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
 */
        ),
        body: Column(children: [
          _buildFilters(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading ? const SplashScreen() : _buildProductCards(),
            ),
          ),
        ]),
      ),
    );
  }
}
