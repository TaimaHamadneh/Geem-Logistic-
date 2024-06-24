import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';


class ProductInfoPage extends StatefulWidget {

   final Map<String, dynamic> product;

  const ProductInfoPage({Key? key, 
  required this.product, 
  }) : super(key: key);

  @override
  State<ProductInfoPage> createState() => _StoreInfoPageState();
}

class _StoreInfoPageState extends State<ProductInfoPage> {
  String _storeName= '';
  

    Future<void> fetchStoreName() async {
    try {
      final response = await http.get(Uri.parse(url+ 'stores/${widget.product['store']}/name'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _storeName = data['storeName']!;
          print('_storeName: $_storeName');
        });
      } else {
        throw Exception('Failed to fetch store name');
      }
    } catch (error) {
      print('Error fetching store name: $error');
    }
  }
  @override
  void initState() {
    super.initState();
    fetchStoreName();
  }


  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Container(
                  height: isDesktop? 300: 200,
                  width: isDesktop? 400:300,
                  child: Container(
                              color: Colors.white,
                              child: widget.product['image'] != null
                                  ? Image.file(File(widget.product['image']))
                                  : Image.asset(
                                      'assets/images/unknown_product.jpg'),
                            ),
                ),
                
                SizedBox(height: 20),
                Text(
                  '${widget.product['name']}',
                  style:  TextStyle(
                    fontSize:isDesktop? 28: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ProductInfoCard(
                  title: 'Description:',
                  value: '${widget.product['description']}',
                ),
                ProductInfoCard(
                  title: 'Quantity:',
                  value: '${widget.product['quantity']}',
                ),
                ProductInfoCard(
                  title: 'Store Name:',
                  value: '$_storeName',
                ),
                ProductInfoCard(
                  title: 'Price:',
                  value: '${widget.product['sellingPrice']}',
                ),
                ProductInfoCard(
                  title: 'Category:',
                  value: '${widget.product['category']}',
                ),
                ProductInfoCard(
                  title: 'Status:',
                  value: '${widget.product['status']}',
                ),
                ProductInfoCard(
                  title: 'Added Date:',
                  value: '${widget.product['date']}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const ProductInfoCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
            final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return Card(
                 margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: isDesktop? 50 :16.0),
      color:  Approved.offwhite,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( 
              flex: 5, 
              child: Text(
                title,
                style:  TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 24: 16
                ),
              ),
            ),
            const SizedBox(width: Approved.defaultPadding/2), 
            Expanded( 
              flex: 6,
              child: Text(
                value,
                maxLines: 9,
                overflow: TextOverflow.ellipsis,
                 style:  TextStyle(
                  fontSize: isDesktop ? 24: 16
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
