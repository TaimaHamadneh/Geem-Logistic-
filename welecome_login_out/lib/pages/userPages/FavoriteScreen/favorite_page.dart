import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritePage extends StatefulWidget {
  final String userId;
  final UserCredential userCredential;

  const FavoritePage({Key? key, required this.userId, required this.userCredential}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<dynamic> favoriteProducts = [];

  @override
  void initState() {
    
    fetchFavoriteProducts();
    super.initState();
  }
  
  static Future<void> addToCart(String userId, String productId, BuildContext  context) async {
    final urlReq = url + '$userId/addToCart';
    print('url : $urlReq');

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
print('productId: $productId');
      if (response.statusCode == 200) {
         print('Product added to cart successfully');
         showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Approved.PrimaryColor,
            title: Text('Success',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20
            ),),
            content: Text('Product added to cart successfully',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16
            ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK',
                style: TextStyle(
              color: Colors.white,
              fontSize: 16
            ),),
              ),
            ],
          );
        },
      );
      } else {
        throw Exception('Failed to add product to cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding to Cart: $e');
      throw e;
    }
  }

    Future<void> DeleteFavorite(String userId, String FavId) async {
    String urlReq = url + '$userId/$FavId/deleteFavorite';
    try {
      final response = await http.delete(Uri.parse(urlReq));
      if (response.statusCode == 200) {
        print('delete Favorites Products successfully');
        
         setState(() {
              favoriteProducts.removeWhere((product) => product['_id'] == FavId);

            });
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product removed from favorites.'),
      ));

      } else {
        throw Exception(
            'Failed to delete Favorites Products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting Favorites Products: $e');
    }
  }

  Future<void> fetchFavoriteProducts() async {
    String urlReq = url + '${widget.userId}/AllFavorites';
        print('url: $urlReq');

    try {
      final response = await http.get(Uri.parse(urlReq));
          print('response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> favorites = jsonDecode(response.body);
        for (var favorite in favorites) {

          final productResponse = await http.get(Uri.parse('$url${favorite['productId']}/product'));
          print('url2: ${'$url/${favorite['productId']}/product'}');
          print('productResponse: ${productResponse.body}');
          if (productResponse.statusCode == 200) {
            final productDetails = jsonDecode(productResponse.body);
            setState(() {
              favoriteProducts.add(productDetails);

            });
          } else {
            throw Exception('Failed to load product details: ${productResponse.statusCode}');
          }
        }
      } else {
        throw Exception('Failed to load favorite products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorite products: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  final bool isDesktop = MediaQuery.of(context).size.width > 600;

  return Scaffold(
    backgroundColor: Approved.LightColor,
    body: favoriteProducts.isEmpty
        ? const Center(
            child: Text(
              'No products added to favorite tab',
              style: TextStyle(fontSize: 18),
            ),
          )
        :  ListView.builder(
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        return GestureDetector(
          onTap: () {

          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: isDesktop? 20: 8.0, horizontal: isDesktop? 150 :16.0),

              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Approved.defaultPadding,),
                  Row(
                    children: [
                        const SizedBox(width: Approved.defaultPadding,),
                      Container(
                        height: isDesktop? 190: 120,
                        width: isDesktop? 120: 90,
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
                      const SizedBox(width: Approved.defaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? '',
                              style:  TextStyle(
                                fontSize: isDesktop? 28: 20,
                                fontWeight: FontWeight.bold,
                                color: Approved.PrimaryColor,
                              ),
                            ),
                            const SizedBox(height: Approved.defaultPadding/2),
                            Text(
                              'Price: ${product['sellingPrice'] ?? ''}',
                              style:  TextStyle(
                                fontSize: isDesktop? 24: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Approved.defaultPadding/2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Description:\n${product['description'] ?? ''}',
                      style:  TextStyle(fontSize: isDesktop? 22: 16,
                      fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await DeleteFavorite(widget.userId, product['_id']);
                        },
                        icon:  Icon(
                          Icons.delete,
                          color: Approved.PrimaryColor,
                          size: isDesktop? 40: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          addToCart(widget.userId, product['_id'], context);
                        },
                        icon:  Icon(Icons.add_shopping_cart,
                        color: Approved.PrimaryColor,
                         size: isDesktop? 40: 30,
                        ),
                        color: Approved.PrimaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

}
