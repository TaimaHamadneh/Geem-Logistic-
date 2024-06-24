import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/dashboard/show_order.dart';
import '../../approved.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MerchantOrders extends StatefulWidget {
  const MerchantOrders({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<MerchantOrders> createState() => _OrdersForAdminState();
}

class _OrdersForAdminState extends State<MerchantOrders> {
  late int _selectedYear = DateTime.now().year;
  late int _selectedMonth = DateTime.now().month;

  late List<int> _years = [];
  late List<int> _months = List<int>.generate(12, (index) => index + 1);

  late List<_OrderChartData> _orderChartData;
  late List<_CityOrderChartData> _cityOrderChartData;

  int _deliveredOrders = 0;
  int _shippedOrders = 0;
  int _pendingOrders = 0;
  int _processingOrders = 0;

  late int _selectedYearRevenue;
  late int _selectedYearCityOrders;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    _selectedYearRevenue = currentYear;
    _selectedYearCityOrders = currentYear;
    _years = List<int>.generate(currentYear - 2019, (index) => 2020 + index);
    _orderChartData = _getOrdersDataForYear(_selectedYearRevenue);
    _cityOrderChartData = _getCityOrdersData();
    _fetchOrdersDataForYear();
  }

  Future<void> _fetchOrdersDataForYear() async {
    final response = await http.get(Uri.parse(url + 'merchant/${widget.userId}/orders'));
    print('response: $response');
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      final List<dynamic> data = responseData['merchantOrders'];
      print('data: $data');

      int deliveredOrders = 0;
      int shippedOrders = 0;
      int pendingOrders = 0;
      int processingOrders = 0;
      List<double> monthlyRevenue = List<double>.filled(12, 0.0);
      Map<String, int> cityOrders = {
        'Jerusalem': 0,
        'Tulkarm': 0,
        'Qalqilya': 0,
        'Bethlehem': 0,
        'Beit Sahour': 0,
        'Jericho': 0,
        'Salfit': 0,
        'Jenin': 0,
        'Nablus': 0,
        'Ramallah': 0,
        'Al-Bireh': 0,
        'Tubas': 0,
        'Hebron': 0,
      };

      for (var order in data) {
        switch (order['status']) {
          case 'delivered':
            deliveredOrders++;
            break;
          case 'shipped':
            shippedOrders++;
            break;
          case 'pending':
            pendingOrders++;
            break;
          case 'processing':
            processingOrders++;
            break;
        }

        DateTime orderDate = DateTime.parse(order['date']);
        if (orderDate.year == _selectedYearRevenue) {
          int month = orderDate.month;
          monthlyRevenue[month - 1] += order['totalPrice'];
        }

        if (orderDate.year == _selectedYearCityOrders && orderDate.month == _selectedMonth) {
          String city = order['customerInfo']['address'].split(',').first;
          if (cityOrders.containsKey(city)) {
            cityOrders[city] = cityOrders[city]! + 1;
          }
        }
      }

      List<_OrderChartData> orderChartData = [];
      for (int i = 0; i < 12; i++) {
        orderChartData.add(_OrderChartData(_monthName(i + 1), monthlyRevenue[i]));
      }

      List<_CityOrderChartData> cityOrderChartData = [];
      cityOrders.forEach((city, orders) {
        cityOrderChartData.add(_CityOrderChartData(city, orders));
      });

      setState(() {
        _deliveredOrders = deliveredOrders;
        _shippedOrders = shippedOrders;
        _pendingOrders = pendingOrders;
        _processingOrders = processingOrders;
        _orderChartData = orderChartData;
        _cityOrderChartData = cityOrderChartData;
      });
    } else {
      throw Exception('Failed to load orders data');
    }
  }

  String _monthName(int monthNumber) {
    switch (monthNumber) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  List<_OrderChartData> _getOrdersDataForYear(int year) {
    return List.generate(
      12,
      (index) => _OrderChartData(_monthName(index + 1), 0.0),
    );
  }

  List<_CityOrderChartData> _getCityOrdersData() {
    return [
      _CityOrderChartData('Jerusalem', 0),
      _CityOrderChartData('Tulkarm', 0),
      _CityOrderChartData('Qalqilya', 0),
      _CityOrderChartData('Bethlehem', 0),
      _CityOrderChartData('Beit Sahour', 0),
      _CityOrderChartData('Jericho', 0),
      _CityOrderChartData('Salfit', 0),
      _CityOrderChartData('Jenin', 0),
      _CityOrderChartData('Nablus', 0),
      _CityOrderChartData('Ramallah', 0),
      _CityOrderChartData('Al-Bireh', 0),
      _CityOrderChartData('Tubas', 0),
      _CityOrderChartData('Hebron', 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
      ),
      body: isDesktop  ? SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Orders Overview',
              style: TextStyle(
                fontSize: isDesktop ? 35 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 30 : 16),
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth =
                    isDesktop ? constraints.maxWidth / 5 : constraints.maxWidth * 0.7;
                double cardHeight = isDesktop ? cardWidth / 2 : cardWidth * 0.55;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildCategoryCard('Delivered Orders', Icons.check_circle, _deliveredOrders, cardWidth, cardHeight, 'delivered'),
                      buildCategoryCard('Shipped Orders', Icons.local_shipping, _shippedOrders, cardWidth, cardHeight, 'shipped'),
                      buildCategoryCard('Processing Orders', Icons.autorenew, _processingOrders, cardWidth, cardHeight, 'processing'),
                      buildCategoryCard('Pending Orders', Icons.hourglass_empty, _pendingOrders, cardWidth, cardHeight, 'pending'),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: isDesktop ? 30: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
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
                    height: isDesktop? 550 :450,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Revenue Overview for $_selectedYearRevenue',
                          style: TextStyle(fontSize: isDesktop? 22: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: isDesktop ? 20: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Select Year: ',
                              style: TextStyle(fontSize:isDesktop ? 22: 18,
                              fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width:isDesktop? 15: 10),
                            DropdownButton<int>(
                              value: _selectedYearRevenue,
                              items: _years.map((int year) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString(),
                                  style: TextStyle( 
                                    fontSize: isDesktop ? 22: 18,
                                  )),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedYearRevenue = newValue!;
                                  _fetchOrdersDataForYear();
                                });
                              },
                            ),
                          ],
                        ),
                         SizedBox(height: isDesktop? 20: 16),
                        Expanded(
                          child: SfCartesianChart(
                            primaryXAxis:  CategoryAxis(
                              title: AxisTitle(text: 'Months', textStyle: TextStyle( 
                                fontSize: isDesktop ? 22 : 16,
                                 fontWeight: FontWeight.w500
                              )),
                              labelPosition: ChartDataLabelPosition.inside,
                            ),
                            primaryYAxis:  NumericAxis(
                              title: AxisTitle(text: 'Revenue',
                              textStyle: TextStyle( 
                                fontSize: isDesktop ? 22 : 16,
                                fontWeight: FontWeight.w500
                              )),
                            ),
                            series: <CartesianSeries>[
                              BarSeries<_OrderChartData, String>(
                                dataSource: _orderChartData,
                                xValueMapper: (_OrderChartData orders, _) =>
                                    orders.month,
                                yValueMapper: (_OrderChartData orders, _) =>
                                    orders.revenue,
                                color: Approved.PrimaryColor,
                                name: 'Revenue',
                                dataLabelSettings: DataLabelSettings(isVisible: true),
                              )
                            ],
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
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
                    height: isDesktop ? 550: 450,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Orders by City for $_selectedYearCityOrders/${_selectedMonth.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: isDesktop? 22:18, fontWeight: FontWeight.bold),
                        ),
                         SizedBox(height: isDesktop? 20: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Year: ',
                              style: TextStyle(fontSize: isDesktop? 22: 18),
                            ),
                            SizedBox(width: isDesktop ? 15:10),
                            DropdownButton<int>(
                              value: _selectedYearCityOrders,
                              items: _years.map((int year) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString(),
                                  style: TextStyle( 
                                    fontSize: isDesktop ? 22: 18,
                                    fontWeight: FontWeight.w500
                                  ),
                                  
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedYearCityOrders = newValue!;
                                  _fetchOrdersDataForYear();
                                });
                              },
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Month: ',
                              style: TextStyle(
                                 fontSize: isDesktop ? 22: 18,
                                    fontWeight: FontWeight.w500
                              ),
                            ),
                            SizedBox(width: 10),
                            DropdownButton<int>(
                              value: _selectedMonth,
                              items: _months.map((int month) {
                                return DropdownMenuItem<int>(
                                  value: month,
                                  child: Text(_monthName(month),
                                   style: TextStyle(
                                 fontSize: isDesktop ? 22: 18,
                                    fontWeight: FontWeight.w500
                              ),
                              ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedMonth = newValue!;
                                  _fetchOrdersDataForYear();
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SfCartesianChart(
                            primaryXAxis:  CategoryAxis(
                              title: AxisTitle(text: 'Cities', textStyle: TextStyle(
                                 fontSize: isDesktop ? 22: 18,
                                    fontWeight: FontWeight.w500
                              ),),
                              labelPosition: ChartDataLabelPosition.inside,
                            ),
                            primaryYAxis:  NumericAxis(
                              title: AxisTitle(text: 'Number of Orders', textStyle: TextStyle(
                                 fontSize: isDesktop ? 22: 18,
                                    fontWeight: FontWeight.w500
                              ),),
                            ),
                            series: <CartesianSeries>[
                              BarSeries<_CityOrderChartData, String>(
                                dataSource: _cityOrderChartData,
                                xValueMapper: (_CityOrderChartData orders, _) =>
                                    orders.city,
                                yValueMapper: (_CityOrderChartData orders, _) =>
                                    orders.orders,
                                color: Approved.PrimaryColor,
                                name: 'Orders',
                                dataLabelSettings: DataLabelSettings(isVisible: true),
                              )
                            ],
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )

      :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text(
                'Orders Overview',
                style: TextStyle(
                  fontSize:isDesktop?30:  24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isDesktop ? 22:16),
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = isDesktop ? constraints.maxWidth/5 :constraints.maxWidth * 0.7;
                  double cardHeight = isDesktop ? cardWidth/2 :cardWidth * 0.55;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildCategoryCard('Delivered Orders', Icons.check_circle, _deliveredOrders, cardWidth, cardHeight,  'delivered'),
                        buildCategoryCard('Shipped Orders', Icons.local_shipping, _shippedOrders, cardWidth, cardHeight, 'shipped' ),
                        buildCategoryCard('Processing Orders', Icons.autorenew, _processingOrders, cardWidth, cardHeight, 'processing'),
                        buildCategoryCard('Pending Orders', Icons.hourglass_empty, _pendingOrders, cardWidth, cardHeight, 'pending'),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
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
                height: 450,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Revenue Overview for $_selectedYearRevenue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Year: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<int>(
                          value: _selectedYearRevenue,
                          items: _years.map((int year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedYearRevenue = newValue!;
                              _fetchOrdersDataForYear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(
                          title: AxisTitle(text: 'Months'),
                          labelPosition: ChartDataLabelPosition.inside,
                        ),
                        primaryYAxis: const NumericAxis(
                          title: AxisTitle(text: 'Revenue'),
                        ),
                        series: <CartesianSeries>[
                          BarSeries<_OrderChartData, String>(
                            dataSource: _orderChartData,
                            xValueMapper: (_OrderChartData orders, _) => orders.month,
                            yValueMapper: (_OrderChartData orders, _) => orders.revenue,
                            color: Approved.PrimaryColor,
                            name: 'Revenue',
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                          )
                        ],
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
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
                height: 450,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Orders by City for $_selectedYearCityOrders/${_selectedMonth.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Year: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<int>(
                          value: _selectedYearCityOrders,
                          items: _years.map((int year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedYearCityOrders = newValue!;
                              _fetchOrdersDataForYear();
                            });
                          },
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Month: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<int>(
                          value: _selectedMonth,
                          items: _months.map((int month) {
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text(_monthName(month)),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedMonth = newValue!;
                              _fetchOrdersDataForYear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(
                          title: AxisTitle(text: 'Cities'),
                          labelPosition: ChartDataLabelPosition.inside,
                        ),
                        primaryYAxis: const NumericAxis(
                          title: AxisTitle(text: 'Number of Orders'),
                        ),
                        series: <CartesianSeries>[
                          BarSeries<_CityOrderChartData, String>(
                            dataSource: _cityOrderChartData,
                            xValueMapper: (_CityOrderChartData orders, _) => orders.city,
                            yValueMapper: (_CityOrderChartData orders, _) => orders.orders,
                            color: Approved.PrimaryColor,
                            name: 'Orders',
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                          )
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
      ),
    );
  }

  Widget buildCategoryCard(String title, IconData icon, int count, double cardWidth, double cardHeight, String orderType) {
        final isDesktop = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowOrders(orderType: orderType, userId: widget.userId,),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                 SizedBox(width: isDesktop? Approved.defaultPadding : 0,),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: isDesktop ? 60:40,
                        color: Approved.PrimaryColor,
                      ),
                    ],
                  ),
                SizedBox(width: isDesktop ? Approved.defaultPadding*2:Approved.defaultPadding,),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:  TextStyle(
                          fontSize: isDesktop ? 22:18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      Text(
                        '$count',
                        style:  TextStyle(
                          fontSize: isDesktop? 30: 20,
                          fontWeight: FontWeight.bold,
                          color: Approved.PrimaryColor,
                        ),
                      ),
                    ],
                  ),
                   SizedBox(width: isDesktop ? Approved.defaultPadding:0,),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderChartData {
  _OrderChartData(this.month, this.revenue);

  final String month;
  final double revenue;
}

class _CityOrderChartData {
  _CityOrderChartData(this.city, this.orders);

  final String city;
  final int orders;
}
