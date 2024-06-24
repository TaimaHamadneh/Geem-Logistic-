import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';

class StoreInfoPage extends StatefulWidget {
  final Map<String, dynamic> store;

  const StoreInfoPage({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  State<StoreInfoPage> createState() => _StoreInfoPageState();
}

class _StoreInfoPageState extends State<StoreInfoPage> {
  List<dynamic> products = [];
  int totalQuantity = 0;

  Future<void> fetchProductData() async {
    final urlReq = Uri.parse(url + 'stores/${widget.store['_id']}/products');
    try {
      final response = await http.get(urlReq);
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          totalQuantity = calculateTotalQuantity();
        });
      } else {
        throw Exception('Failed to load store data');
      }
    } catch (e) {
      print('Error fetching store data: $e');
    }
  }

  int calculateTotalQuantity() {
    int sum = 0;
    for (var product in products) {
      sum += (product['quantity'] as num).toInt();
    }
    return sum;
  }

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }
  

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;
    String address = widget.store['address'];
        List<String> addressComponents = address.split(',');
        List<String> nonEmptyComponents = addressComponents
            .where((component) => component.trim().isNotEmpty)
            .toList();
        String formattedAddress = nonEmptyComponents.join(', ');

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.LightColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black,),
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
                        height: isDesktop? 250:200,
                        width: isDesktop?300:250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            
                            child: widget.store['image'] != null
                                ? Image.file(File(widget.store['image']),
                                    fit: BoxFit.cover)
                                : Image.asset(
                                    'assets/images/store_icon.png'),
                          ),
                        ),
                      ),
              const SizedBox(height: Approved.defaultPadding,),
                Text(
                  '${widget.store['name']}',
                  style: TextStyle(
                    fontSize: isDesktop? 30: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Approved.defaultPadding),
                ProductInfoCard(
                  title: 'Location:',
                  value: '$formattedAddress',
                ),
                ProductInfoCard(
                  title: 'Area:',
                  value: '${widget.store['area']}',
                ),
                ProductInfoCard(
                  title: 'Contact number:',
                  value: '${widget.store['contactNumber']}',
                ),
                ProductInfoCard(
                  title: 'Quantity of products:',
                  value: totalQuantity.toString()+' items',
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
      color:  Colors.white ,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Approved.defaultPadding/2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( 
              flex: 5, 
              child: Text(
                title,
                style:  TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 22: 16
                ),
              ),
            ),
            const SizedBox(width: Approved.defaultPadding/2,height: Approved.defaultPadding*2,), 
            Expanded( 
              flex: 6,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                  fontSize: isDesktop ? 18: 14
                ),
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
