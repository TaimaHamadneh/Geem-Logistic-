
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';

class WelcomeWebPage extends StatefulWidget {
  const WelcomeWebPage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomeWebPage> {
  int currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver for the background image
          SliverToBoxAdapter(
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/admin_welcome_page.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "Geem" on the left
                          const Text(
                            'Geem',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              // Contact Us button
                              ElevatedButton(
                                onPressed: () {
                                  // Add contact us functionality
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Approved.PrimaryColor,
                                ),
                                child: const Text('Contact Us'),
                              ),
                              const SizedBox(width: 10), // Space between buttons
                              // Nav icon
                              IconButton(
                                onPressed: () {
                                  // Add nav functionality
                                },
                                icon: const Icon(Icons.menu, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '\“ Geem Is Your Gate Way to A Great Success \n In The World of Commerce \”',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Add sign in functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Approved.PrimaryColor,
                                  ),
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: const Text('Sign In'),
                                  ),
                                ),
                                const SizedBox(width: 10), // Space between buttons
                                ElevatedButton(
                                  onPressed: () {
                                    // Add sign up functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Approved.PrimaryColor,
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Container(
                                    width: 100, // Button width
                                    height: 50, // Button height
                                    alignment: Alignment.center,
                                    child: const Text('Sign Up'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Slivers for other sections
          SliverToBoxAdapter(
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              padding: const EdgeInsets.all(20),
              color: const Color.fromRGBO(255, 255, 255, 1), // Example color
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "\“About Us\”",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "A Company Fueled by Passion for Logistics",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 50),
                        Image.asset(
                          "assets/images/aboutus1.jpg",
                          fit: BoxFit.contain,
                          height: screenSize.height * 0.5, // Adjust the height as needed
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/aboutussecondimage.png",
                          fit: BoxFit.contain,
                          height: screenSize.height * 0.3, // Adjust the height as needed
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          "The Geem Journey: Our Path to Transforming Logistics\n \n As pioneers in the logistics industry, we embarked on this journey with a clear mission: to create a seamless, efficient, and user-friendly platform that redefines how customers, merchants, and employees interact. Each milestone in our journey represents a significant step towards innovation and excellence in logistics management.",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: screenSize.width,
              padding: const EdgeInsets.all(20),
              color: const Color.fromARGB(255, 248, 234, 223),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '\“Our Services\”',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Discover the comprehensive services we offer to streamline your logistics operations.',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 50),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ServiceItem(
                          icon: Icons.shopping_cart,
                          title: 'Customer Services',
                          description:
                              'Easily create accounts, browse stores, add items to your cart, and place orders.',
                        ),
                        SizedBox(height: 20),
                        ServiceItem(
                          icon: Icons.store,
                          title: 'Merchant Services',
                          description:
                              'Full control over your stores and products, with tools to manage and optimize your operations.',
                        ),
                        SizedBox(height: 20),
                        ServiceItem(
                          icon: Icons.people,
                          title: 'Employee Services',
                          description:
                              'Sales and inventory employees to enhance customer interactions and maintain stock levels.',
                        ),
                        SizedBox(height: 20),
                        ServiceItem(
                          icon: Icons.chat,
                          title: 'Communication Tools',
                          description:
                              'Integrated chat system for effective communication and issue resolution.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              padding: const EdgeInsets.all(20),
              color: const Color.fromRGBO(255, 255, 255, 1), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/whyus2.jpg",
                          fit: BoxFit.contain,
                          width: screenSize.width,
                          height: screenSize.height / 2,
                        ),
                        SizedBox(height: 50),
                        const Text(
                          "\“The Unparalleled Benefits\”",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 20),
                        const Text(
                          "Experience and Expertise: Leveraging industry knowledge to deliver exceptional logistics solutions. ",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        const Text(
                          "Reliability and Consistency: Ensuring smooth and efficient transactions with a focus on operational excellence ",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        const Text(
                          "Competitive Pricing and Value: Offering cost-effective solutions that provide significant value to all user roles",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        const Text(
                          "Client Testimonials & Success Stories: Showcasing transformative experiences and success stories from satisfied clients. ",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 50),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "\“Why Geem\”",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "A transformative experience for businesses seeking seamless logistics operations and exceptional service. As your logistics partner, we excel in connecting customers, merchants, and employees through a user-friendly platform. Our innovative application ensures smooth transactions and efficient management across all levels. Whether you're managing multiple stores, optimizing inventory, or enhancing customer satisfaction, our comprehensive solutions cater to every need. Experience significant improvements in operational efficiency and substantial user engagement with our cutting-edge logistics platform.",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 50),
                        Image.asset(
                          "assets/images/whyus1.png",
                          height: screenSize.height / 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: screenSize.width,
              padding: const EdgeInsets.all(20),
              color: const Color.fromARGB(255, 248, 234, 223),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Approved.PrimaryColor,
                    ),
                    onPressed: () {
                      if (currentPage > 0) {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                        setState(() {
                          currentPage--;
                        });
                      }
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '\“Reviews\”',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 300, // Adjust the height as needed
                        width: screenSize.width * 0.7, // Adjust the width as needed
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ReviewItem(
                                  reviewer: 'John Doe',
                                  review:
                                      'Excellent platform! The user experience is seamless, and the customer service is outstanding.',
                                  rating: 5,
                                  imageUrl: 'assets/images/user1.jpg',
                                ),
                                ReviewItem(
                                  reviewer: 'Jane Smith',
                                  review:
                                      'Great service and very reliable. Highly recommend to anyone looking for efficient logistics solutions.',
                                  rating: 4,
                                  imageUrl: 'assets/images/user2.jpg',
                                ),
                                ReviewItem(
                                  reviewer: 'Mike Johnson',
                                  review:
                                      'Good overall experience, but there is room for improvement in the inventory management features.',
                                  rating: 3,
                                  imageUrl: 'assets/images/user3.jpg',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ReviewItem(
                                  reviewer: 'Areen Jawabreh',
                                  review:
                                      'Amazing platform! The user experience is great, and the customer service is perfect.',
                                  rating: 5,
                                  imageUrl: 'assets/images/user1.jpg',
                                ),
                                // Add more reviews here
                              ],
                            ),
                            // Add more pages if needed
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Approved.PrimaryColor,
                    ),
                    onPressed: () {
                      if (currentPage < 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                        setState(() {
                          currentPage++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: screenSize.width,
              height: screenSize.height / 5,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '\“Contact Us\”',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                        ),
                        const Icon(
                          Icons.phone,
                        ),
                        SizedBox(width: 10),
                        const Text(
                          '+1 234 567 890',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 70,
                        ),
                        const Icon(
                          Icons.email,
                        ),
                        SizedBox(width: 10),
                        const Text(
                          'contact@geem.com',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Spacer(),
                        const Icon(
                          Icons.location_on,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '123 Logistics Lane, Suite 456\nCommerce City, CO 80022',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 70,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.facebook,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // Add Facebook functionality
                          },
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.snapchat_rounded,
                            color: Colors.yellowAccent,
                          ),
                          onPressed: () {
                            // Add Snapchat functionality
                          },
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.telegram,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            // Add Telegram functionality
                          },
                        ),
                      ],
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
}

class ServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const ServiceItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(icon, color: Approved.PrimaryColor, size: 40),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String reviewer;
  final String review;
  final int rating;
  final String imageUrl;

  const ReviewItem({
    required this.reviewer,
    required this.review,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(imageUrl),
                radius: 30,
              ),
              SizedBox(width: 20),
              Text(
                reviewer,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            review,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: List.generate(
              rating,
              (index) => const Icon(
                Icons.star,
                color: Approved.PrimaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

