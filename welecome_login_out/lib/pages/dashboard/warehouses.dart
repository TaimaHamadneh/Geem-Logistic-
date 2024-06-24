import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';

class WarehousesForAdmin extends StatefulWidget {
  const WarehousesForAdmin({Key? key}) : super(key: key);

  @override
  State<WarehousesForAdmin> createState() => _WarehousesForAdminState();
}

class _WarehousesForAdminState extends State<WarehousesForAdmin> {
  
  late int _selectedYear = DateTime.now().year;
  late List<int> _years = [];
  late int _totalStores = 0;
  late int _totalProducts = 0;

  late List<_StoreData> _storeData = [];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    int currentYear = DateTime.now().year;
    _years = List<int>.generate(currentYear - 2019, (index) => 2020 + index);
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      final response = await http.get(Uri.parse(url + 'stores'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _totalStores = data.length;
          _totalProducts = data.fold<int>(
              0, (total, store) => total + (store['products'] as List).length);
          _storeData = _getStoreData(data);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  List<_StoreData> _getStoreData(List<dynamic> stores) {
    List<_StoreData> storeData = [];
    stores.forEach((store) {
      String storeName = store['name'];
      int productCount = (store['products'] as List).length;
      storeData.add(_StoreData(storeName, productCount));
    });
    return storeData;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Text(
              'Warehouses Overview',
              style: TextStyle(
                fontSize: isDesktop ? 32: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = isDesktop ?constraints.maxWidth/3 : constraints.maxWidth * 0.7;
                double cardHeight = isDesktop ?cardWidth/3: cardWidth * 0.55;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildCategoryCard('All Warehouses', Icons.store,
                          _totalStores, cardWidth, cardHeight),
                      buildCategoryCard(
                          'All Products',
                          Icons.attach_money_outlined,
                          _totalProducts,
                          cardWidth,
                          cardHeight),
                    ],
                  ),
                );
              },
            ),
             SizedBox(height: isDesktop ? 32: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Approved.PrimaryColor,
                  width: isDesktop? 4: 2,
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              height: isDesktop? 600: 400,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Warehouses Overview for $_selectedYear',
                    style:  TextStyle(
                        fontSize: isDesktop? 28 : 18, fontWeight: FontWeight.bold),
                  ),
                   SizedBox(height: isDesktop? 32: 16),
                  Expanded(
                    child: SfCircularChart(
                      legend: const Legend(isVisible: true),
                      series: <CircularSeries>[
                        PieSeries<_StoreData, String>(
                          dataSource: _storeData,
                          xValueMapper: (_StoreData data, _) => data.storeName,
                          yValueMapper: (_StoreData data, _) =>
                              data.productCount,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                        ),
                      ],
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryCard(String title, IconData icon, int count,
      double cardWidth, double cardHeight) {
         final isDesktop = MediaQuery.of(context).size.width > 600;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Approved.PrimaryColor,
          width:isDesktop ? 4: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        margin: const EdgeInsets.all(0),
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: isDesktop ? 60 : 50,
                      color: Approved.PrimaryColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:  TextStyle(
                        fontSize: isDesktop ? 30: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                    Text(
                      '$count',
                      style:  TextStyle(
                        fontSize: isDesktop? 28: 20,
                        fontWeight: FontWeight.bold,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreData {
  _StoreData(this.storeName, this.productCount);

  final String storeName;
  final int productCount;
}
