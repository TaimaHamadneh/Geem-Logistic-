import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/userPages/AllStoresForUsers/products_page.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key, required this.userCredential, required this.userId})
      : super(key: key);

  final UserCredential userCredential;
  final String userId;

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List<Map<String, dynamic>> _cardDetails = [];
  List<Map<String, dynamic>> _cardOfferDetails = [];
  List<dynamic> AllFavorites = [];
  var fbm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    fbm.getToken().then((token) {
      print('token: $token');
    });

    fetchData();
    fetchOffersProducts();
    GetAllFavoritesProducts();
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

  Future<void> fetchData() async {
    String urlReq = url + 'storesWithProducts';
    try {
      final response = await http.get(Uri.parse(urlReq));
      print('urlReq : $urlReq');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _cardDetails = data.map((store) {
              return {
                '_id': '${store['_id']}',
                'title': '${store['name']}',
                'location': store['address'] ?? '',
                'category': store['category'] ?? '',
                'imagePath': store['image'],
                'contactNumber':
                    store['contactNumber'] ?? 'There is no Contact Number',
              };
            }).toList();
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
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
      int offer) async {
    int quantity = 1;

    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        final isDesktop = MediaQuery.of(context).size.width > 600;
        return AlertDialog(
          backgroundColor: Approved.PrimaryColor,
          title:  Text(
            'Select Quantity',
            style: TextStyle(
                color: Colors.white, 
                fontSize: isDesktop ? 24: 20, fontWeight: FontWeight.w500),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white,
                     size: isDesktop ? 30: 20,),
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
                        fontSize: isDesktop ? 22: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white,
                    size: isDesktop ? 30: 20,),
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
                    fontSize: isDesktop ? 20: 16,
                    fontWeight: FontWeight.w500),
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
                    fontSize: isDesktop ? 20: 16,
                    fontWeight: FontWeight.w500),
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
              final isDesktop = MediaQuery.of(context).size.width > 600;
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
                      fontSize: isDesktop ? 24 :20,
                    ),
                  ),
                  content: Text(
                    'Product added to cart successfully',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 22 :16,
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
                          fontSize: isDesktop ? 22 :16,
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

  Future<void> fetchOffersProducts() async {
    String urlReq = url + 'getProductsWithOffers';
    try {
      final response = await http.get(Uri.parse(urlReq));
      print('urlReq : $urlReq');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('data : $data');
        if (mounted) {
          setState(() {
            _cardOfferDetails = data.map((product) {
              return {
                '_id': '${product['_id']}',
                'title': '${product['name']}',
                'sellingPrice': product['sellingPrice'] ?? '',
                'category': product['category'] ?? '',
                'imagePath': product['image'],
                'offer': product['offer'] ?? 0,
                'store': product['store']
              };
            }).toList();
          });
          print('_cardOfferDetails: $_cardOfferDetails');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    List<Map<String, dynamic>> flowerStores =
        _cardDetails.where((card) => card['category'] == 'Flowers').toList();
    List<Map<String, dynamic>> electronicsStores = _cardDetails
        .where((card) => card['category'] == 'Electronics')
        .toList();
    List<Map<String, dynamic>> clothesStores =
        _cardDetails.where((card) => card['category'] == 'Clothes').toList();
    List<Map<String, dynamic>> shoesStores =
        _cardDetails.where((card) => card['category'] == 'Shoes').toList();
    List<Map<String, dynamic>> accessoriesStores = _cardDetails
        .where((card) => card['category'] == 'Accessories')
        .toList();
    List<Map<String, dynamic>> cosmeticsStores =
        _cardDetails.where((card) => card['category'] == 'Cosmetics').toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Approved.LightColor,
          padding: EdgeInsets.all(isDesktop ? 16 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 16 : 8,
                  horizontal: isDesktop ? 16 : 8,
                  ),
                child: Container(
                   width: isDesktop ? double.infinity : double.infinity,
        height: isDesktop ? 100 : 40,
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
              vertical: isDesktop ? 20 : 10,
              horizontal: isDesktop ? 50 : 15,
            ),
                      hintText: 'Search...',
                      hintStyle: TextStyle(
              fontSize: isDesktop ? 20 : 14, 
              color: Colors.grey, 
            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                "Offers",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cardOfferDetails.length,
                  itemBuilder: (context, index) {
                    return _buildOfferCard(_cardOfferDetails[index]);
                  },
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Text(
                "All Stores",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cardDetails.length,
                  itemBuilder: (context, index) {
                    return _buildCard(_cardDetails[index]);
                  },
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Text(
                "Flowers",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: flowerStores.length,
                  itemBuilder: (context, index) {
                    return _buildCard(flowerStores[index]);
                  },
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Text(
                "Electronics",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: electronicsStores.length,
                  itemBuilder: (context, index) {
                    return _buildCard(electronicsStores[index]);
                  },
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Text(
                "Clothes",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: clothesStores.length,
                  itemBuilder: (context, index) {
                    return _buildCard(clothesStores[index]);
                  },
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Text(
                "Shoes",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shoesStores.length,
                  itemBuilder: (context, index) {
                    return _buildCard(shoesStores[index]);
                  },
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Text(
                "Accessories",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: accessoriesStores.length,
                  itemBuilder: (context, index) {
                    return _buildCard(accessoriesStores[index]);
                  },
                ),
              ),
              const SizedBox(height: Approved.defaultPadding),
              Text(
                "Cosmetics",
                style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Approved.TextColor),
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              SizedBox(
                height: isDesktop ? 250 : 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cosmeticsStores.length,
                  itemBuilder: (context, index) {
                    return _buildCard(cosmeticsStores[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoreDetailsDialog(Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Approved.PrimaryColor,
          title: Text(
            store['title'],
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location: ${store['location']}\n',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                'Contact Number: ${store['contactNumber']}\n',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                'Category: ${store['category']}',
                style: TextStyle(
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
              child: Text(
                'Close',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Container(
      width: isDesktop ? 300 : 280,
      height: isDesktop ? 400 : 350,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.black,
                ),
                onPressed: () {
                  _showStoreDetailsDialog(card);
                },
              ),
              Text(
                card['title'],
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Container(
            height: isDesktop ? 90 : 80,
            width: isDesktop ? 100 : 90,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Approved.PrimaryColor),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                color: Colors.white,
                child: card['imagePath'] != null
                    ? Image.file(File(card['imagePath']), fit: BoxFit.cover)
                    : Image.asset('assets/images/signup.png'),
              ),
            ),
          ),
          Text(
            'Location: ${card['location']}',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 14,
              color: Colors.black,
            ),
            maxLines: 1,
          ),
          SizedBox(
            height: isDesktop ? 16 : 8,
          ),
          SizedBox(
            width: isDesktop ? 150 : 120,
            height: isDesktop ? 50 : 30,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeeProductsPage(
                      storeId: card['_id'],
                      userId: widget.userId,
                      userCredential: widget.userCredential,
                    ),
                  ),
                );
              },
              child: Text('Products'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> card) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    bool isFavorite = AllFavorites.any(
        (favProduct) => favProduct['productId'] == card['_id']);

    return Container(
      width: isDesktop ? 300 : 280,
      height: isDesktop ? 400 : 350,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: isDesktop ? 10 : 5,
              ),
              Text(
                card['title'],
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: isDesktop ? 10 : 5,
              ),
              Container(
                height: isDesktop ? 90 : 80,
                width: isDesktop ? 100 : 90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Approved.PrimaryColor),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    color: Colors.white,
                    child: card['imagePath'] != null
                        ? Image.file(File(card['imagePath']), fit: BoxFit.cover)
                        : Image.asset('assets/images/signup.png'),
                  ),
                ),
              ),
              SizedBox(
                height: isDesktop ? 10 : 0,
              ),
              Text(
                'Price: ${card['sellingPrice']}',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 14,
                  color: Colors.black,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: Approved.defaultPadding / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (isFavorite) {
                        await DeleteFavoriate(widget.userId, card['_id']);
                      } else {
                        await addFavorite(widget.userId, card['_id']);
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
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Add to cart logic
                      addToCart(
                          widget.userId,
                          card['_id'],
                          context,
                          card['sellingPrice'].toString(),
                          card['store'].toString(),
                          card['offer'] ?? 0);
                    },
                    icon: Icon(
                      Icons.add_shopping_cart,
                    ),
                    color: Approved.PrimaryColor,
                  ),
                  const SizedBox(height: Approved.defaultPadding / 2),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red, // Or any other color for the circle
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${card['offer']}%', // Display the offer value
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
