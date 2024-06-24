import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/dashboard/users_table.dart';
import '../../approved.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UsersPageForAdmin extends StatefulWidget {
  const UsersPageForAdmin({Key? key}) : super(key: key);


  @override
  State<UsersPageForAdmin> createState() => _UsersPageForAdminState();
}

class _UsersPageForAdminState extends State<UsersPageForAdmin> {
  int _selectedYear = 2024;
  List<String> months = [
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
    'Dec'
  ];
  late Future<List<_UserChartData>> userChartDataFuture;

  late Future<Counts> countsFuture;

  @override
  void initState() {
    super.initState();
    fetchUserChartData();
    fetchEmployeeDetails();
    countsFuture = fetchCounts();
  }

  List<_UserChartData> userChartData = [];

  Future<List<_UserChartData>> fetchUserChartData() async {
    final response = await http.get(Uri.parse(url + 'getAllUsers'));
    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body)['users'];
      print('users: $users ');

      final filteredUsers = users.where((user) {
        return DateTime.parse(user['date']).year == _selectedYear;
      }).toList();

      final Map<String, int> userCountByMonth =
          Map.fromIterable(months, key: (month) => month, value: (_) => 0);

      for (dynamic user in filteredUsers) {
        final userMonth =
            DateFormat('MMM').format(DateTime.parse(user['date']));
        userCountByMonth[userMonth] = (userCountByMonth[userMonth] ?? 0) + 1;
      }

      userChartData = months.map((month) {
        return _UserChartData(month, userCountByMonth[month] ?? 0);
      }).toList();

      setState(() {
        userChartData = userChartData;
      });
      return userChartData;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Counts> fetchCounts() async {
    final merchantCount = await fetchCount(url + 'getMerchantCount');
    final userCount = await fetchCount(url + 'getUserCount');
    final employeeCount = await fetchCount(url + 'getEmployeeCount');
    final adminCount = await fetchCount(url + 'getAdminCount');

    return Counts(
      merchantCount: merchantCount,
      userCount: userCount,
      employeeCount: employeeCount,
      adminCount: adminCount,
    );
  }

  Future<int> fetchCount(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body)['count'];
    } else {
      throw Exception('Failed to load count');
    }
  }

  Future<List<UserDetails>> fetchEmployeeDetails({String? userType}) async {
    final response = await http.get(Uri.parse(url + 'employees'));
    if (response.statusCode == 200) {
      final List<dynamic> employees = json.decode(response.body)['employees'];
      print('employees: $employees ');


      List<UserDetails> userDetailsList = employees.map((employee) {
        return UserDetails(
          name: employee['name'],
          email: employee['email'],
          location: employee[
              'city'], 
              
        );
      }).toList();

      return userDetailsList;
    } else {
      throw Exception('Failed to load employee data');
    }
  }

  Future<List<UserDetails>> fetchUserDetailsType({String? userType}) async {
    final response = await http.get(Uri.parse(url + 'getAllUsers'));
    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body)['users'];

      List<UserDetails> userDetailsList = users.where((user) {
        if (userType != null) {
          return user['userType'] == userType;
        } else {
          return true;
        }
      }).map((user) {
        return UserDetails(
          name: user['userName'],
          email: user['email'],
          location: user['location'],
        );
      }).toList();

      return userDetailsList;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    int currentYear = DateTime.now().year;
    List<int> years =
        List<int>.generate(currentYear - 2019, (index) => 2020 + index);

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isDesktop ? 32 : 0),
              Text(
                'Users Overview',
                style: TextStyle(
                  fontSize: isDesktop? 28: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isDesktop ? 32 : 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = isDesktop ? constraints.maxWidth * 0.2: constraints.maxWidth * 0.7;

                  double cardHeight = cardWidth * 0.55;

                  return FutureBuilder<Counts>(
                    future: countsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final counts = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildCategoryCard(
                                  'All Users',
                                  Icons.group,
                                  counts.userCount,
                                  cardWidth,
                                  cardHeight,
                                  context),
                              buildCategoryCard(
                                  'All Merchants',
                                  Icons.store,
                                  counts.merchantCount,
                                  cardWidth,
                                  cardHeight,
                                  context,
                                  userType: 'merchant'),
                              buildCategoryCard(
                                  'All Employees',
                                  Icons.people,
                                  counts.employeeCount,
                                  cardWidth,
                                  cardHeight,
                                  context,
                                  userType: 'employee'),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: Text('No data available'));
                      }
                    },
                  );
                },
              ),
               SizedBox(height: isDesktop ? 22 :16),
              Container(
                decoration: BoxDecoration(
                  
                    border: Border.all(
                      color: Approved.PrimaryColor,
                      width:isDesktop ? 4: 2,
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
                height: isDesktop ? 600 : 400,
                padding: EdgeInsets.all(16),
                width: isDesktop ? double.infinity: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Year: ',
                          style: TextStyle(fontSize: isDesktop ? 24: 18),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: _selectedYear,
                          items: years.map((int year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year',
                              style: TextStyle(
                                fontSize: isDesktop  ? 20:14
                              ),),
                            );
                          }).toList(),
                          onChanged: (int? newValue) async {
                            setState(() {
                              _selectedYear = newValue!;
                            });
                            await fetchUserChartData();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: isDesktop ? 20:  16),
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: 'Months', 
                          textStyle: TextStyle(
                            fontSize: isDesktop  ? 20:14
                          )
                          ),
                          labelPosition: ChartDataLabelPosition.inside,
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: 'Number of Users',
                          textStyle: TextStyle(
                            fontSize: isDesktop  ? 20:14
                          )),
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<_UserChartData, String>(
                            dataSource: userChartData,
                            xValueMapper: (_UserChartData sales, _) =>
                                sales.month,
                            yValueMapper: (_UserChartData sales, _) =>
                                sales.users,
                            color: Approved.PrimaryColor,
                            name: 'Users',
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true),
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

  Widget buildCategoryCard(String title, IconData icon, int count,
      double cardWidth, double cardHeight, BuildContext context,
      {String? userType}) {
        final isDesktop = MediaQuery.of(context).size.width > 600;
    return GestureDetector(
      onTap: () async {
        List<UserDetails> userDetailsList;
        if (userType == 'employee') {
          userDetailsList = await fetchEmployeeDetails();
        } else {
          userDetailsList = await fetchUserDetailsType(userType: userType);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UsersDetailsTable(userDetailsList: userDetailsList)),
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
         decoration: BoxDecoration(
                    border: Border.all(
                      color: Approved.PrimaryColor,
                      width: 2,
                    ),
                        borderRadius: BorderRadius.circular(10),
                  ),
        child: Card(
          margin: const EdgeInsets.all(0),
          color: Colors.white,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: Approved.defaultPadding,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: isDesktop ? 60 : 40,
                      color: Approved.PrimaryColor,
                    ),
                  ],
                ),
                const SizedBox(
                  width: Approved.defaultPadding * 1.5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: isDesktop ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: Approved.PrimaryColor),
                      maxLines: 2,
                    ),
                    SizedBox(height: isDesktop? 16:8),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: isDesktop ? 22: 18,
                        fontWeight: FontWeight.bold,
                        color: Approved.PrimaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Counts {
  final int merchantCount;
  final int userCount;
  final int adminCount;
  final int employeeCount;

  Counts({
    required this.merchantCount,
    required this.userCount,
    required this.adminCount,
    required this.employeeCount,
  });

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(
      merchantCount: json['merchantCount'],
      userCount: json['userCount'],
      adminCount: json['adminCount'],
      employeeCount: json['employeeCount'],
    );
  }
}

class _UserChartData {
  _UserChartData(this.month, this.users);

  final String month;
  final int users;
}
