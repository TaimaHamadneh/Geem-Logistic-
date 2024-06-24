import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:http/http.dart' as http;

class MerchentWarehouses extends StatefulWidget {
  const MerchentWarehouses({Key? key, required this.userId}) : super(key: key);

  final String userId;
  @override
  State<MerchentWarehouses> createState() => _MerchentWarehousesState();
}

class _MerchentWarehousesState extends State<MerchentWarehouses> {
  late List<String?> _offers;
  late List<bool> _selectedProducts;
  late List<ChartData> _storeChartData = [];

  @override
  void initState() {
    super.initState();
    _offers = List<String?>.filled(5, '0');
    _selectedProducts = List<bool>.generate(5, (index) => false);
    fetchStores();
    _fetchOrders();
  }

  Future<void> fetchStores() async {
    try {
      final response =
          await http.get(Uri.parse(url + '${widget.userId}/storesById'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _storeChartData = _parseChartData(data);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  List<ChartData> _parseChartData(List<dynamic> data) {
    return data.map((store) {
      final String storeName = store['name'] ?? '';
      final int productCount = store['products']?.length ?? 0;
      return ChartData(storeName, productCount);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: buildLeftSideContent(),
                  ),
                  Expanded(
                    flex: 4,
                    child: buildRightSideContent(),
                  ),
                ],
              )
            : buildSingleColumnContent(),
      ),
    );
  }

  Widget buildLeftSideContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Warehouses Overview',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 40),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildDashboardCard(
                  title: 'All Warehouses',
                  icon: Icons.store,
                  number: 20,
                  chartData: _storeChartData,
                ),
                SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRightSideContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: Approved.defaultPadding * 4,
          ),
          buildDataTable(),
        ],
      ),
    );
  }

  Widget buildSingleColumnContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Warehouses Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildDashboardCard(
                  title: 'All Warehouses',
                  icon: Icons.store,
                  number: 20,
                  chartData: _storeChartData,
                ),
                SizedBox(height: 22),
                buildDataTable(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDashboardCard({
    required String title,
    required IconData icon,
    required int number,
    required List<ChartData> chartData,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    int totalStores = chartData.length;
    int totalProducts = 0;

    if (topProductsDetails.isNotEmpty) {
      totalProducts = topProductsDetails
          .map((product) => product['quantity'] as int)
          .reduce((a, b) => a + b);
    }

    return Column(
      children: [
        SizedBox(
          width: isDesktop ? 600 : double.infinity,
          child: Card(
            color: Approved.PrimaryColor,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: isDesktop ? 50 : 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: isDesktop ? 30 : 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: isDesktop ? 30 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total: $totalStores',
                            style: TextStyle(
                              fontSize: isDesktop ? 22 : 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 30 : 16),
        Container(
          width: MediaQuery.of(context).size.width,
          height: isDesktop ? 350 : 300,
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.label,
                yValueMapper: (ChartData data, _) => data.quantity.toDouble(),
                dataLabelMapper: (ChartData data, _) =>
                    '${data.quantity} in ${data.label}',
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                      color: Colors.white, fontSize: isDesktop ? 22 : 14),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: isDesktop ? 600 : double.infinity,
          child: Card(
            color: Approved.PrimaryColor,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_sharp,
                        size: isDesktop ? 50 : 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Products',
                            style: TextStyle(
                              fontSize: isDesktop ? 30 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total: $totalProducts',
                            style: TextStyle(
                              fontSize: isDesktop ? 22 : 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDataTable() {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Container(
      width: isDesktop ? 700 : 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 16 : 8.0),
            child: Text(
              'Top 5 Selling Products',
              style: TextStyle(
                fontSize: isDesktop ? 30 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: [
                DataColumn(
                  label: Text(
                    'Select',
                    style: TextStyle(fontSize: isDesktop ? 20 : 15),
                  ),
                ),
                DataColumn(
                    label: Text(
                  'Product Name',
                  style: TextStyle(fontSize: isDesktop ? 20 : 15),
                )),
                DataColumn(
                    label: Text(
                  'Price',
                  style: TextStyle(fontSize: isDesktop ? 20 : 15),
                )),
                DataColumn(
                    label: Text(
                  'Offer',
                  style: TextStyle(fontSize: isDesktop ? 20 : 15),
                )),
              ],
              rows: List.generate(
                topProductsDetails.length,
                (index) => DataRow(
                  cells: [
                    DataCell(
                      Checkbox(
                        value: _selectedProducts[index],
                        onChanged: (newValue) {
                          setState(() {
                            for (int i = 0; i < _selectedProducts.length; i++) {
                              if (i != index) {
                                _selectedProducts[i] = false;
                              } else {
                                _selectedProducts[i] = newValue!;
                                if (newValue == true) {
                                  _showOfferDialog(context, index);
                                }
                              }
                            }
                          });
                        },
                      ),
                    ),
                    DataCell(
                      Text(
                        topProductsDetails[index]['name'],
                        style: TextStyle(fontSize: isDesktop ? 20 : 15),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${topProductsDetails[index]['sellingPrice']}',
                        style: TextStyle(fontSize: isDesktop ? 20 : 15),
                      ),
                    ),
                    DataCell(
                      topProductsDetails[index]['offer'] == null
                          ? Text('%${_offers[index]!}')
                          : Text(
                              '%${topProductsDetails[index]['offer']}',
                              style: TextStyle(fontSize: isDesktop ? 20 : 15),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> topProductsDetails = [];
  Future<void> _fetchOrders() async {
    final response =
        await http.get(Uri.parse(url + 'merchant/${widget.userId}/orders'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      final List<dynamic> data = responseData['merchantOrders'];

      Map<String, int> productFrequencyMap = {};

      data.forEach((order) {
        List<dynamic> products = order['products'];
        products.forEach((product) {
          String productId = product['productId'];
          productFrequencyMap[productId] =
              (productFrequencyMap[productId] ?? 0) + 1;
        });
      });

      List<MapEntry<String, int>> sortedProductFrequencies =
          productFrequencyMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      List<String> topProducts =
          sortedProductFrequencies.take(5).map((entry) => entry.key).toList();

      topProductsDetails = await _fetchtopProducts(topProducts);

      setState(() {
        topProductsDetails = topProductsDetails;
      });
    } else {
      throw Exception('Failed to load orders data');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchtopProducts(
      List<String> productIds) async {
    List<Map<String, dynamic>> productsDetails = [];

    for (String productId in productIds) {
      final response = await http.get(Uri.parse(url + '$productId/product'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        productsDetails.add(responseData);
      } else {
        throw Exception('Failed to load product details for ID: $productId');
      }
    }

    return productsDetails;
  }

  Future<void> _showOfferDialog(BuildContext context, int index) async {
    String? newOffer = _offers[index];
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Offer',
                style: TextStyle(
                    color: Colors.white, fontSize: isDesktop ? 20 : 15),
              ),
              backgroundColor: Approved.PrimaryColor,
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'New Offer',
                          labelStyle: TextStyle(fontSize: isDesktop ? 20 : 15)),
                      onChanged: (value) {
                        setState(() {
                          newOffer = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.white, fontSize: isDesktop ? 20 : 15),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedProducts[index] = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white, fontSize: isDesktop ? 20 : 15),
                  ),
                  onPressed: () async {
                    try {
                      final response = await http.put(
                        Uri.parse(url +
                            '${topProductsDetails[index]['_id']}/product'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({'offer': newOffer}),
                      );

                      if (response.statusCode == 200) {
                        setState(() {
                          _offers[index] = newOffer;
                          topProductsDetails[index]['offer'] = newOffer;
                          if (newOffer == '0') {
                            _selectedProducts[index] = false;
                          }
                        });
                        Navigator.of(context).pop();
                      } else {
                        throw Exception('Failed to update product offer');
                      }
                    } catch (error) {
                      print('Error updating product offer: $error');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ChartData {
  final String label;
  final int quantity;

  ChartData(this.label, this.quantity);
}
