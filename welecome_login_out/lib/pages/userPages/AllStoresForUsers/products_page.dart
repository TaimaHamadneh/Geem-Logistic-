import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'dart:convert';

import 'package:welecome_login_out/config.dart';

class SeeProductsPage extends StatefulWidget {
  const SeeProductsPage({
    Key? key,
    required this.storeId,
    required this.userCredential,
    required this.userId,
  }) : super(key: key);

  final UserCredential userCredential;
  final String userId;
  final String storeId;

  @override
  _SeeProductsPageState createState() => _SeeProductsPageState();
}

class _SeeProductsPageState extends State<SeeProductsPage> {
  List<dynamic> products = [];
  List<dynamic> AllFavorites = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    GetAllFavoritesProducts();
  }

  Future<void> fetchProducts() async {
    String urlReq = url + 'stores/${widget.storeId}/products';
    try {
      final response = await http.get(Uri.parse(urlReq));
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> GetAllFavoritesProducts() async {
    String urlReq = url + '${widget.userId}/AllFavorites';
    try {
      final response = await http.get(Uri.parse(urlReq));
      if (response.statusCode == 200) {
        setState(() {
          AllFavorites = jsonDecode(response.body);
        });
      } else {
        throw Exception(
            'Failed to load All Favorites Products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching All Favorites Products: $e');
    }
  }

  Future<void> DeleteFavoriate(String userId, String FavId) async {
    String urlReq = url + '$userId/$FavId/deleteFavorite';

    try {
      final response = await http.delete(Uri.parse(urlReq));
      if (response.statusCode == 200) {
        print('delete Favorites Products successfully');
      } else {
        throw Exception(
            'Failed to delete Favorites Products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting Favorites Products: $e');
    }
  }

  static Future<void> addFavorite(String userId, String productId) async {
    final urlReq = url + '$userId/addFavorite';

    try {
      final response = await http.post(
        Uri.parse(urlReq),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'productId': productId,
        }),
      );

      if (response.statusCode == 201) {
        print('Favorite added successfully');
      } else {
        throw Exception('Failed to add favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding favorite: $e');
      throw e;
    }
  }

  static Future<void> addToCart(
    String userId,
    String productId,
    BuildContext context,
    String sellingPrice,
    String storeId,
    int offer,
  ) async {
    int quantity = 1;

    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Approved.PrimaryColor,
          title: const Text(
            'Select Quantity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                  ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(quantity);
              },
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    ).then((selectedQuantity) async {
      if (selectedQuantity != null) {
        final urlReq = url + '$userId/addToCart';
        print('url: $urlReq');

        try {
          final response = await http.post(
            Uri.parse(urlReq),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'productId': productId,
              'quantity': selectedQuantity,
              'sellingPrice': sellingPrice,
              'storeId': storeId,
              'offer': offer,
            }),
          );

          // Log the request payload
          print('Request Payload: ${{
            'productId': productId,
            'quantity': selectedQuantity,
            'sellingPrice': sellingPrice,
            'storeId': storeId,
            'offer': offer,
          }}');

          if (response.statusCode == 200) {
            print('Product added to cart successfully');
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Approved.PrimaryColor,
                  title: Text(
                    'Success',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  content: Text(
                    'Product added to cart successfully',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            throw Exception(
                'Failed to add product to cart: ${response.statusCode}');
          }
        } catch (e) {
          print('Error adding to Cart: $e');
          throw e;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if the layout is for mobile or desktop
            bool isDesktop = constraints.maxWidth > 800;
            int crossAxisCount = isDesktop ? 4 : 2;
            double cardWidth = isDesktop
                ? (constraints.maxWidth / crossAxisCount) - 32
                : MediaQuery.of(context).size.width * 0.45;

            return ListView.builder(
              itemCount: (products.length / crossAxisCount).ceil(),
              itemBuilder: (context, rowIndex) {
                int startIndex = rowIndex * crossAxisCount;
                int endIndex = startIndex + crossAxisCount < products.length
                    ? startIndex + crossAxisCount
                    : products.length;

                return Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: List.generate(endIndex - startIndex, (index) {
                    final product = products[startIndex + index];
                    bool isFavorite = AllFavorites.any(
                        (favProduct) =>
                            favProduct['productId'] == product['_id']);

                    return GestureDetector(
                      onTap: () {
                        _showProductDetailsDialog(product);
                      },
                      child: Container(
                        width: cardWidth,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: Approved.defaultPadding),
                              Text(
                                product['name'],
                                style:  TextStyle(
                                  fontSize:  isDesktop ? 24 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Approved.PrimaryColor,
                                ),
                              ),
                              const SizedBox(
                                  height: Approved.defaultPadding / 2),
                              Container(
                                height:  isDesktop ? 150 : 120,
                                width:  isDesktop ? 150 : 120,
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
                                            'assets/images/signup.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: Approved.defaultPadding / 2),
                              Text(
                                'Price: ${product['sellingPrice']}',
                                style:  TextStyle(
                                    fontSize: isDesktop ? 20 : 16,
                                     color: Colors.black),
                                maxLines: 1,
                              ),
                              const SizedBox(
                                  height: Approved.defaultPadding / 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                      height: Approved.defaultPadding / 2),
                                  IconButton(
                                    onPressed: () async {
                                      if (isFavorite) {
                                        await DeleteFavoriate(
                                            widget.userId, product['_id']);
                                      } else {
                                        await addFavorite(
                                            widget.userId, product['_id']);
                                      }

                                      await GetAllFavoritesProducts();
                                      setState(() {
                                        isFavorite = !isFavorite;
                                      });
                                    },
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite_outlined
                                          : Icons.favorite_border,
                                      color: Approved.PrimaryColor,
                                      size: isDesktop ? 40 : 20
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      addToCart(
                                        widget.userId,
                                        product['_id'],
                                        context,
                                        product['sellingPrice'].toString(),
                                        product['store'],
                                        product['offer'] ?? 0,
                                      );
                                    },
                                    icon:  Icon(Icons.add_shopping_cart,
                                    size: isDesktop ? 40 : 20
                                    ),
                                    color: Approved.PrimaryColor,
                                    
                                  ),
                                  const SizedBox(
                                      height: Approved.defaultPadding / 2),
                                ],
                              ),
                              const SizedBox(height: Approved.defaultPadding),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showProductDetailsDialog(dynamic product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Approved.PrimaryColor,
          ),
          child: AlertDialog(
            title: Center(
              child: Text(product['name'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Approved.PrimaryColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: Colors.white,
                      child: product['image'] != null
                          ? Image.file(File(product['image']),
                              fit: BoxFit.cover)
                          : Image.asset('assets/images/signup.png'),
                    ),
                  ),
                ),
                const SizedBox(height: Approved.defaultPadding / 2),
                Text(
                  'Price: ${product['sellingPrice']}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: Approved.defaultPadding / 2),
                Text(
                  'Description:\n${product['description']}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
