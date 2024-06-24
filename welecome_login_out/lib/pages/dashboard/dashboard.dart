import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/dashboard/merchant_dashboard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
       final isDesktop = MediaQuery.of(context).size.width > 600;

    return isDesktop ? SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: DashboardContent(
                  userId: widget.userId,
                ),
              ),
            ),
          )
    : Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Approved.PrimaryColor,
                Approved.LightColor,
                Colors.white.withOpacity(0.66),
                Colors.white.withOpacity(0.66),
              ],
              stops: const [0.0, 0.33, 0.33, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: DashboardContent(
                  userId: widget.userId,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;
  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late List<_ChartData> data = [];

  late TooltipBehavior _tooltip;

  late List<_ChartData> allData;
  late List<_ChartData> filteredData;

  int ordersCount = 0;
  double revenue = 0;
  int storeCount = 0;
  int totalQuantity = 0;
  int employeeCount = 0;

  final int currentYear = DateTime.now().year;
  int selectedYear = DateTime.now().year;
  List<DropdownMenuItem<int>> years = [];

  final List<String> monthOptions = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  int selectedMonthGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();

    _tooltip = TooltipBehavior(enable: true);
    fetchData();
    fetchStoreDetails(widget.userId);
    print('before fetchEmployeeCount');
    fetchEmployeeCount(widget.userId);
    print('after fetchEmployeeCount');
    years = List.generate(
        currentYear - 2019 + 1,
        (index) => DropdownMenuItem(
              value: 2020 + index,
              child: Text('${2020 + index}'),
            ));
  }

  Future<void> fetchData() async {
    final urlReq = url + 'merchant/${widget.userId}/orders';

    final response = await http.get(Uri.parse(urlReq));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      final List<dynamic> orders = responseBody['merchantOrders'];

      final today = DateTime.now();
      final oneMonthAgo = today.subtract(const Duration(days: 30));
      final filteredOrders = orders.where((order) {
        final orderDate = DateTime.parse(order['date']);
        return orderDate.isAfter(oneMonthAgo) && orderDate.isBefore(today);
      }).toList();

      final filteredOrdersByMonthYear = orders.where((order) {
        final orderDate = DateTime.parse(order['date']);
        return orderDate.year == selectedYear &&
            (selectedMonthGroupIndex == -1 ||
                orderDate.month == selectedMonthGroupIndex + 1);
      }).toList();

      ordersCount = filteredOrdersByMonthYear.length;
      revenue = filteredOrdersByMonthYear.fold(
          0.0, (sum, order) => sum + order['totalPrice']);
      setState(() {
        ordersCount = filteredOrdersByMonthYear.length;
        revenue = double.parse(revenue.toStringAsFixed(2));
      });

      final Map<String, double> totalPriceByMonth = {
        'Jan': 0,
        'Feb': 0,
        'Mar': 0,
        'Apr': 0,
        'May': 0,
        'Jun': 0,
        'Jul': 0,
        'Aug': 0,
        'Sep': 0,
        'Oct': 0,
        'Nov': 0,
        'Dec': 0,
      };

      final currentYear = today.year;

      orders.forEach((order) {
        final orderDate = DateTime.parse(order['date']);
        if (orderDate.year == selectedYear) {
          final month = orderDate.month;
          final monthName = monthOptions[month - 1];
          final monthAbbreviation =
              monthName.length >= 3 ? monthName.substring(0, 3) : null;
          final totalPrice = order['totalPrice'];
          if (monthAbbreviation != null) {
            totalPriceByMonth[monthAbbreviation] ??= 0;
            totalPriceByMonth[monthAbbreviation] =
                (totalPriceByMonth[monthAbbreviation] ?? 0) + totalPrice;
          }
        }
      });

      data = totalPriceByMonth.entries
          .map((entry) => _ChartData(entry.key, entry.value))
          .toList()
        ..sort((a, b) {
          final aIndex = monthOptions.indexOf(a.x);
          final bIndex = monthOptions.indexOf(b.x);
          return aIndex.compareTo(bIndex);
        });
    } else {
      print('Failed to load orders');
    }
  }

  Future<Map<String, dynamic>> fetchStoreDetails(String userId) async {
    final String urlReq = url + '$userId/storesById';
    print('url: $urlReq');
    try {
      final response = await http.get(Uri.parse(urlReq));

      if (response.statusCode == 200) {
        final List<dynamic> stores = jsonDecode(response.body);
        //print('stores: $stores');

        storeCount = stores.length;
    //    print('storeCount: $storeCount');

        for (var store in stores) {
          List<dynamic> products = store['products'];
          for (var product in products) {
            final quantity = product['quantity'];
            if (quantity != null && quantity is int) {
              totalQuantity += quantity;
            }
          }
        }

     //   print('totalQuantity: $totalQuantity');

        return {
          'storeCount': storeCount,
          'totalQuantity': totalQuantity,
        };
      } else {
        throw Exception('Failed to load store details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<int> fetchEmployeeCount(String userId) async {
  final String urlReq = url + '$userId/employees';
  print('urlReq: $urlReq');

  try {
    final response = await http.get(Uri.parse(urlReq));

    if (response.statusCode == 200) {
      final dynamic responseBody = jsonDecode(response.body);
      print('responseBody: $responseBody');

      if (responseBody is List) {
        employeeCount = responseBody.length;
        setState(() {
          employeeCount = responseBody.length;
        });
        return responseBody.length;
      } else {
        throw Exception(
            'Expected a list of employees, but received: $responseBody');
      }
    } else {
      throw Exception(
          'Failed to load employee count: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        final isDesktop = MediaQuery.of(context).size.width > 600;

    return FadeTransition(
      opacity: _animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(
             vertical: isDesktop ? 10 : 8,
              horizontal: isDesktop ? 10 : 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient:  const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Approved.LightColor, Colors.white],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding:  EdgeInsets.symmetric(
                    vertical: isDesktop ? 10 : Approved.defaultPadding / 5,
              horizontal: isDesktop ? 10 : Approved.defaultPadding / 5,
                  ),
                  child: Row(
                    mainAxisAlignment: isDesktop?MainAxisAlignment.center :  MainAxisAlignment.spaceBetween,
                    children: [
                       SizedBox(width:isDesktop? Approved.defaultPadding*6 : Approved.defaultPadding),
                      Text(
                        'Select Date:',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: isDesktop ? 22: 16,
                            fontWeight: FontWeight.w500),
                      ),
                       SizedBox(width:isDesktop? Approved.defaultPadding*2 :0),

                      DropdownButton<int>(
                        value: selectedYear,
                        items: years,
                        onChanged: (year) {
                          setState(() {
                            selectedYear = year!;
                            fetchData();
                          });
                        },
                        underline: Container(),
                        style:  TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                           fontSize: isDesktop ? 22: 16,
                        ),
                      ),
                      SizedBox(width:isDesktop? Approved.defaultPadding*2 :0),
                      DropdownButton<int>(
                        value: selectedMonthGroupIndex,
                        items: List.generate(
                          monthOptions.length,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(monthOptions[index],
                              style: TextStyle(
                            color: Colors.black,
                            fontSize: isDesktop ? 22: 16,
                            fontWeight: FontWeight.w500),),
                          ),
                        )..add(DropdownMenuItem(
                            value: -1,
                            child: Text('AllMonths',
                               style: TextStyle(
                            color: Colors.black,
                            fontSize: isDesktop ? 22: 16,
                            fontWeight: FontWeight.w500),
                            ),
                          )),
                        onChanged: (month) {
                          setState(() {
                            selectedMonthGroupIndex = month!;
                            fetchData();
                          });
                        },
                        underline: Container(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       SizedBox(width:isDesktop? Approved.defaultPadding*6 : Approved.defaultPadding),
                    ],
                  ),
                ),
                color: Colors.transparent,
              ),
            ),
          ),
           Padding(
            padding:  EdgeInsets.symmetric(
             vertical: isDesktop ? 10 : 8,
              horizontal: isDesktop ? 10 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: Approved.defaultPadding),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Approved.PrimaryColor, Approved.LightColor],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Approved.defaultPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildColumn(
                                title: S.of(context).Revenue +
                                    '/' +
                                    S.of(context).month,
                                value: '$revenue'),
                          ],
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(width: Approved.defaultPadding / 2),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Approved.PrimaryColor, Approved.LightColor],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Approved.defaultPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildColumn(
                                title: '#' +
                                    S.of(context).Orders +
                                    '/' +
                                    S.of(context).month,
                                value: '$ordersCount'),
                          ],
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(width: Approved.defaultPadding),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Approved.defaultPadding / 2),
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: Approved.defaultPadding,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).SalesTrendAnalysis,
                            style:  TextStyle(
                                fontSize: isDesktop ? 20: 14,
                                fontWeight: FontWeight.bold,
                                color: Approved.PrimaryColor),
                          ),
                        ],
                      ),
                     SizedBox(
                          height: isDesktop? 350:  250,
                          width:isDesktop? 420:  320,
                          child: SfCartesianChart(
                            primaryXAxis: const CategoryAxis(),
                            primaryYAxis: const NumericAxis(
                                minimum: 0, maximum: 5000, interval: 300),
                            tooltipBehavior: _tooltip,
                            series: <CartesianSeries<_ChartData, String>>[
                              ColumnSeries<_ChartData, String>(
                                  dataSource: data,
                                  xValueMapper: (_ChartData data, _) => data.x,
                                  yValueMapper: (_ChartData data, _) => data.y,
                                  name: 'Gold',
                                  color: Approved.PrimaryColor)
                            ],
                          ),
                        ),
                     
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     Text(
                      'More Details',
                      style: TextStyle(
                        color: Approved.PrimaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: isDesktop ? 22 : 16
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MerchantDashboard(userId: widget.userId)),
                        );
                      },
                      child:  Icon(
                        Icons.arrow_forward,
                        color: Approved.PrimaryColor,
                        size: isDesktop ? 30:  24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
          //  padding: const EdgeInsets.all(Approved.defaultPadding / 8),
             padding:  EdgeInsets.symmetric(
             vertical: isDesktop ? 10 : Approved.defaultPadding / 8,
              horizontal: isDesktop ? 10 : Approved.defaultPadding / 8,
            ),
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Approved.PrimaryColor,
                      Approved.LightColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: Approved.defaultPadding / 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircleIcon(
                          icon: Icons.home,
                          value: '$storeCount',
                          title: S.of(context).YourWarehouses,
                        ),
                        _buildCircleIcon(
                          icon: Icons.shopping_cart,
                          value: '$totalQuantity',
                          title: S.of(context).Products,
                        ),
                        _buildCircleIcon(
                          icon: Icons.people,
                          value: '$employeeCount',
                          title: S.of(context).Employee,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: Approved.defaultPadding / 3,
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

  Widget _buildColumn({required String title, required String value}) {
            final isDesktop = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        Text(
          value,
          style:  TextStyle(fontSize: isDesktop? 22: 18, fontWeight: FontWeight.bold),
        ),
       SizedBox(height: isDesktop? 10: 5),
        Text(
          title,
          style:  TextStyle(fontSize: isDesktop? 18: 16),
        ),
      ],
    );
  }

  Widget _buildCircleIcon(
      {required IconData icon, required String value, required String title}) {
               final isDesktop = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        SizedBox(height: isDesktop ? 16 :0),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: Approved.PrimaryColor,
            size: isDesktop ? 30: 20,
          ),
        ),
        const SizedBox(height: Approved.defaultPadding / 4),
        Text(
          value,
          style:  TextStyle(
              fontSize: isDesktop ? 22: 18, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: Approved.defaultPadding / 4),
        Text(
          title,
          style: TextStyle(fontSize: isDesktop ? 18 : 16, color: Colors.black54),
        ),
         SizedBox(height: isDesktop ? 16 :0),

      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
