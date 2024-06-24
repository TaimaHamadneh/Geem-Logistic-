import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';

class OrderDetailsForMerchant extends StatefulWidget {
  const OrderDetailsForMerchant({Key? key}) : super(key: key);

  @override
  State<OrderDetailsForMerchant> createState() => _OrderDetailsForMerchantState();
}

class _OrderDetailsForMerchantState extends State<OrderDetailsForMerchant> {
  @override
  Widget build(BuildContext context) {

    List<Order> orders = [
      Order(id: '1',  totalPrice: 100.0, customerName: 'John Doe', location: '123 Main St', status: 'Pending', date: '15/10/2023'),
      Order(id: '2', totalPrice: 50.0, customerName: 'Jane Smith', location: '456 Oak St', status: 'Delivered', date: '20/10/2023'),
      Order(id: '3',  totalPrice: 150.0, customerName: 'Bob Johnson', location: '789 Elm St', status: 'Shipped', date: '25/10/2023'),
    ];

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           SizedBox(height: 16),
          Text(
              'Order Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: Column(
                    children: [

                      ListTile(
                        title: Text(
                          'Order ID: ${orders[index].id}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Divider(),

                      ListTile(
                        leading: Icon(Icons.person, color: Approved.PrimaryColor),
                        title: Text(
                          'Customer: ${orders[index].customerName}',
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          'Location: ${orders[index].location} | Pending',
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.content_copy, color: Approved.PrimaryColor),
                          onPressed: () {

                          },
                        ),
                      ),
                      Divider(),

                      ListTile(
                        leading: Icon(Icons.calendar_today, color: Approved.PrimaryColor),
                        title: Text(
                          'Date: ${orders[index].date}',
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          'Total Price: \$${orders[index].totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final String id;
 
  final double totalPrice;
  final String customerName;
  final String location;
  final String status;
  final String date;

  Order({
    required this.id,
   
    required this.totalPrice,
    required this.customerName,
    required this.location,
    required this.status,
    required this.date,
  });
}