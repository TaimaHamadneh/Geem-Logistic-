import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/userPages/CartScreen/order_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key, required this.userId, required this.userCredential, required this.signedInUserEmail})
      : super(key: key);

  final String userId;
  final UserCredential userCredential;
  final String signedInUserEmail;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartProducts = [];
  Map<String, int> quantity = {};
  List<double> sellingPrices = [];
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartDetails();
  }

  Future<void> DeleteProductsFromCart(String userId, String productId) async {
    String urlReq = url + '$userId/$productId/removeFromCart';
    try {
      final response = await http.delete(Uri.parse(urlReq));
      if (response.statusCode == 200) {
        print('Deleted product successfully');
        await fetchCartDetails();
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  static Future<void> UpdateQuantity(String userId, String productId, int selectedQuantity) async {
    final urlReq = url + '$userId/updateQuantityInCart';
    try {
      final response = await http.put(
        Uri.parse(urlReq),
        body: json.encode({'productId': productId, 'quantity': selectedQuantity}),
        headers: {'Content-Type': 'application/json'},
      );
      print('Quantity: $selectedQuantity');
      if (response.statusCode == 200) {
        print('Product quantity updated successfully');
      } else {
        throw Exception('Failed to update product quantity');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchCartDetails() async {
    final response = await http.get(Uri.parse(url + '${widget.userId}/getCartProducts'));

    if (response.statusCode == 200) {
      setState(() {
        cartProducts = json.decode(response.body);
        print('Cart Products: $cartProducts');
        for (var product in cartProducts) {
          quantity[product['productId']] = product['quantity'];
        }
      });
    } else {
      throw Exception('Failed to load cart details');
    }
  }

  Future<dynamic> fetchProductDetails(String productId) async {
    final response = await http.get(Uri.parse(url + '$productId/product'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  double calculateTotalPrice() {
    totalPrice = 20.0; // Base delivery charge
    for (var product in cartProducts) {
      String productId = product['productId'];
      int? productQuantity = quantity[productId];
      double productPrice = product['sellingPrice'].toDouble();
      double discount = product['offer'] != null ? product['offer'].toDouble() / 100 : 0.0;

      if (productQuantity != null) {
        double priceAfterDiscount = productPrice * (1 - discount);
        totalPrice += priceAfterDiscount * productQuantity;
      }
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
      final isDesktop = MediaQuery.of(context).size.width > 600;
    double totalPrice = cartProducts.isEmpty ? 0.0 : calculateTotalPrice();
    return Scaffold(
      backgroundColor: Approved.LightColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return buildGridView();
          } else {
            return buildListView();
          }
        },
      ),
      floatingActionButton: cartProducts.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Approved.PrimaryColor,
                      title: const Text(
                        'Total Price',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      content: Text(
                        'Total Price: ${totalPrice - 20}\$ \nComprehensive delivery +\$20',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            String price = calculateTotalPrice().toStringAsFixed(2).toString();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserOrder(
                                  userId: widget.userId,
                                  selectedProducts: [],
                                  totalPrice: price.toString(),
                                  userCredential: widget.userCredential,
                                  signedInUserEmail: widget.signedInUserEmail,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              backgroundColor: Approved.PrimaryColor,
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget buildListView() {
     final isDesktop = MediaQuery.of(context).size.width > 600;
    return cartProducts.isEmpty
        ? const Center(
            child: Text(
              'No products added to your cart',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18
                ),
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio:2,
            ),
            itemCount: cartProducts.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: fetchProductDetails(cartProducts[index]['productId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final product = snapshot.data;
                    final productId = cartProducts[index]['productId'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             SizedBox(width: 8,),
                            Row( mainAxisAlignment: MainAxisAlignment.start,
                              children: [ 
                                SizedBox(width: 8,),
                              ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                color: Colors.white,
                                child: product['image'] != null
                                    ? Image.file(
                                        File(product['image']),
                                        fit: BoxFit.cover,
                                        height: 160,
                                        width:150,
                                      )
                                    : Image.asset(
                                        'assets/images/signup.png',
                                        fit: BoxFit.cover,
                                        height: 160,
                                        width: 150,
                                      ),
                              ),
                            ),
                           Column(children: [ 
                             Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['name'],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                                Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Price: ${product['sellingPrice']}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                             Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: buildQuantityControl(productId, product['_id']),
                            ),
                           ],)
                            ],),
                            
                        
                           
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
  }

 /* Widget buildListView() {
    return cartProducts.isEmpty
        ? const Center(
            child: Text(
              'No products added to your cart',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ListView.builder(
            itemCount: cartProducts.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: fetchProductDetails(cartProducts[index]['productId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final product = snapshot.data;
                    final productId = cartProducts[index]['productId'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              color: Colors.white,
                              child: product['image'] != null
                                  ? Image.file(
                                      File(product['image']),
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                    )
                                  : Image.asset(
                                      'assets/images/signup.png',
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                    ),
                            ),
                          ),
                          title: Text(
                            product['name'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('Price: ${product['sellingPrice']}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          trailing: buildQuantityControl(productId, product['_id']),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
  }*/

  Widget buildGridView() {
    return cartProducts.isEmpty
        ? const Center(
            child: Text(
              'No products added to your cart',
              style: TextStyle(fontSize: 22),
            ),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: cartProducts.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: fetchProductDetails(cartProducts[index]['productId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final product = snapshot.data;
                    final productId = cartProducts[index]['productId'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
 
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['name'],
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Price: ${product['sellingPrice']}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: buildQuantityControl(productId, product['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
  }

  Widget buildQuantityControl(String productId, String productDbId) {
      final isDesktop = MediaQuery.of(context).size.width > 600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove, size:  isDesktop ? 30 : 15,),
          onPressed: () {
            setState(() {
              if (quantity[productId]! > 1) {
                quantity[productId] = quantity[productId]! - 1;
                UpdateQuantity(widget.userId, productDbId, quantity[productId]!);
              }
            });
          },
        ),
        Text('${quantity[productId]}',
        style: TextStyle( 
          fontSize:  isDesktop ? 20 : 16 
        ),),
        IconButton(
          icon:  Icon(Icons.add, size:  isDesktop ? 30 : 15,),
          onPressed: () {
            setState(() {
              quantity[productId] = (quantity[productId] ?? 0) + 1;
              UpdateQuantity(widget.userId, productId, quantity[productId]!);
            });
          },
        ),
        IconButton(
          icon:  Icon(Icons.delete, size:  isDesktop ? 30 : 15,),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Approved.PrimaryColor,
                  title:  Text(
                    'Confirm Delete',
                    style: TextStyle(color: Colors.white, fontSize: isDesktop ? 22 : 20, fontWeight: FontWeight.w500),
                  ),
                  content:  Text(
                    'Are you sure you want to delete this product from the cart?',
                    style: TextStyle(color: Colors.white, fontSize:  isDesktop ? 20 : 18  , fontWeight: FontWeight.w400),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child:  Text('Cancel', style: TextStyle(color: Colors.white, fontSize:  isDesktop ? 20 : 18 , fontWeight: FontWeight.w500)),
                    ),
                    TextButton(
                      onPressed: () {
                        DeleteProductsFromCart(widget.userId, productDbId);
                        Navigator.pop(context);
                      },
                      child:  Text('Confirm', style: TextStyle(color: Colors.white, fontSize:  isDesktop ? 20 : 18 , fontWeight: FontWeight.w500)),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
