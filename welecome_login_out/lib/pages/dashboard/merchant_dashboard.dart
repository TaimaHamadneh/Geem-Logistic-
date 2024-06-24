import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/pages/dashboard/merchant_orders.dart';
import 'package:welecome_login_out/pages/dashboard/merchent_warehouses.dart';
import '../../approved.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key, required this.userId});
  final String userId;

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showFeedbackDialog(context);
    });
  }

  void showFeedbackDialog(BuildContext context) async {
    // Fetch feedback data for the current user
    final feedbackUrl = url + 'feedbackByUser/${widget.userId}';
    print('feedback url: $feedbackUrl');
    try {
      final response = await http.get(Uri.parse(feedbackUrl));
      if (response.statusCode == 200) {
        final List<dynamic> feedbackData = jsonDecode(response.body);
        if (feedbackData.isNotEmpty) {
          print('Feedback exists, do not show the dialog');
          return;
        }
      } else {
        throw Exception('Failed to fetch feedback data');
      }
    } catch (e) {
      print('Error fetching feedback data: $e');
    }

    double _rating = 0.0;
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDesktop = MediaQuery.of(context).size.width > 600;

        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Add Feedback',
            style: TextStyle(
                color: Approved.PrimaryColor, fontSize: isDesktop ? 22 : 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await submitFeedback(_rating, feedbackController);
              },
              child: Text(
                'Submit',
                style: TextStyle(
                    color: Approved.PrimaryColor,
                    fontSize: isDesktop ? 22 : 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitFeedback(
      double stars, TextEditingController feedbackController) async {
    final feedback = Feedback(
      userId: widget.userId,
      note: feedbackController.text, // Use feedbackController to get the text
      stars: stars,
    );

    String urlReq = url + 'addFeedback';

    try {
      final response = await http.post(
        Uri.parse(urlReq),
        body: json.encode(feedback.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201) {
        print('Feedback submitted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thank you for your feedback!')),
        );
      } else {
        print('Failed to submit feedback');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback')),
        );
      }
    } catch (e) {
      print('Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while submitting feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: isDesktop ? 30 : 0,
            ),
            Text(
              'Merchant Dashboard',
              style: TextStyle(
                fontSize: isDesktop ? 30 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: isDesktop ? 100 : 80,
            ),
            buildDashboardCard(
              title: 'Warehouses',
              icon: Icons.store,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MerchentWarehouses(userId: widget.userId)),
                );
              },
            ),
            SizedBox(height: 16),
            buildDashboardCard(
              title: 'Orders',
              icon: Icons.shopping_cart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MerchantOrders(userId: widget.userId)),
                );
              },
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = isDesktop ? 1900 : constraints.maxWidth;
        double cardHeight = isDesktop ? 190 : 150.0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Approved.PrimaryColor,
                ),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: isDesktop ? 60 : 40,
                      ),
                      SizedBox(width: isDesktop ? 32 : 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isDesktop ? 30 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Feedback {
  final String userId;
  final String note;
  final double stars;

  Feedback({
    required this.userId,
    required this.note,
    required this.stars,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'note': note,
      'stars': stars,
    };
  }
}
