import 'package:flutter/material.dart';
import '../../approved.dart';

class UsersDetailsTable extends StatefulWidget {
  final List<UserDetails> userDetailsList;

  const UsersDetailsTable({Key? key, required this.userDetailsList})
      : super(key: key);

  @override
  State<UsersDetailsTable> createState() => _UsersDetailsTableState();
}

class _UsersDetailsTableState extends State<UsersDetailsTable> {
  TextEditingController _searchController = TextEditingController();
  String? _selectedLocation = 'All';
  List<UserDetails> _filteredUserDetailsList = [];

  final List<String> locations = [
    'Jerusalem',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Beit Sahour',
    'Jericho',
    'Salfit',
    'Jenin',
    'Nablus',
    'Ramallah',
    'Al-Bireh',
    'Tubas',
    'Hebron'
  ];

  @override
  void initState() {
    super.initState();
    _filteredUserDetailsList = widget.userDetailsList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final isDesktop = MediaQuery.of(context).size.width > 600;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'All Users',
              style: TextStyle(
                fontSize: isDesktop ? 32: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Approved.defaultPadding),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _filteredUserDetailsList = widget.userDetailsList
                            .where((userDetail) => userDetail.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(fontSize: isDesktop ? 22 :18),
                      prefixIcon: Icon(Icons.search, size: isDesktop ? 30 :20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.01,
                        horizontal: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    hint: Text('Location', style: TextStyle( 
                      fontSize: isDesktop ? 22 :18
                    ),),
                    items: ['All', ...locations].map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location, style: TextStyle( 
                      fontSize: isDesktop ? 22 :18
                    ),),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                        if (newValue == 'All') {
                          _filteredUserDetailsList = widget.userDetailsList;
                        } else {
                          _filteredUserDetailsList = widget.userDetailsList
                              .where((userDetail) =>
                                  userDetail.location == newValue)
                              .toList();
                        }
                      });
                    },
                    
 decoration: InputDecoration(
                      hintText: 'Location...',
                      hintStyle: TextStyle(fontSize: isDesktop ? 22 :18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.001,
                        horizontal: screenWidth * 0.02,
                      ),
                    ),
                     
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text('(${_filteredUserDetailsList.length})', 
                style: TextStyle(fontSize:  isDesktop ? 22: 18),),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      color: Colors.white,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Approved.PrimaryColor),
                        columnSpacing: 5,
                        dataRowHeight: 50,
                        columns: [
                          DataColumn(
                              label: Container(
                            width: screenWidth * 0.15,
                            child: Text('Name',
                                style: TextStyle(color: Colors.white,
                                fontSize:  isDesktop ? 22: 18
                                )),
                          )),
                          DataColumn(
                              label: Container(
                            width: screenWidth * 0.4,
                            child: Text('Email',
                                style: TextStyle(color: Colors.white,
                                fontSize:  isDesktop ? 22: 18
                                )),
                          )),
                          DataColumn(
                              label: Container(
                            width: screenWidth * 0.2,
                            child: Text('Location',
                                style: TextStyle(color: Colors.white,
                                fontSize:  isDesktop ? 22: 18
                                )),
                          )),
                        ],
                        rows: _filteredUserDetailsList.map((userDetail) {
                          return DataRow(cells: [
                            DataCell(Container(
                              width: screenWidth * 0.25,
                              color: Colors.white,
                              child: Text(userDetail.name,style: TextStyle(color: Colors.black,
                                fontSize:  isDesktop ? 22: 14
                                ) ),
                            )),
                            DataCell(Container(
                              width: screenWidth * 0.25,
                              color: Colors.white,
                              child: Text(userDetail.email, style: TextStyle(color: Colors.black,
                                fontSize:  isDesktop ? 22: 14
                                )),
                            )),
                            DataCell(Container(
                              width: screenWidth * 0.25,
                              color: Colors.white,
                              child: Text(userDetail.location, style: TextStyle(color: Colors.black,
                                fontSize:  isDesktop ? 22: 14
                                )),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetails {
  final String name;
  final String email;
  final String location;

  UserDetails(
      {required this.name, required this.email, required this.location});
}
