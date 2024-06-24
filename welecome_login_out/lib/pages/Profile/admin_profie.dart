// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, avoid_print, use_rethrow_when_possible

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/Screens/admin_screen.dart';

class AmdinProfilePage extends StatefulWidget {
  final UserCredential userCredential;
  final String userId;
  final String userEmail;
  final String signedInUserEmail;

  const AmdinProfilePage(
      {Key? key,
      required this.userCredential,
      required this.userId,
      required this.userEmail,
      required this.signedInUserEmail})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<AmdinProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _aboutController;
  late String _imageUrl;
  File? _image;
  bool _isUploading = false;

  String _selectedLocation = 'other';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _aboutController = TextEditingController();
    _imageUrl = '';

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userCredential.user!.uid)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>;
    setState(() {
      _usernameController.text = userData['username'];
      _emailController.text = userData['email'];
      _imageUrl = userData['image_url'];
      if (userData['Location'] != null) {
        _selectedLocation = userData['Location'];
      }
      _aboutController.text = userData['about'];
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final List<String> locations = [
      'other',
      'Jerusalem',
      'Nablus',
      'Tulkarm',
      'Qalqilya',
      'Bethlehem',
      'Beit Sahour',
      'Jericho',
      'Salfit',
      'Jenin',
      'Ramallah',
      'Al_Bireh',
      'Tubas',
      'Hebron'
    ];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Approved.PrimaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, size: isDesktop ? 30 : 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminTabsScreen(
                            userCredential: widget.userCredential,
                            userId: widget.userId,
                            signedInUserEmail: widget.signedInUserEmail,
                            userEmail: widget.userEmail,
                          )),
                );
              })),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
            isDesktop ? Approved.defaultPadding * 4 : Approved.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: Approved.defaultPadding,
            ),
            SizedBox(
              width: isDesktop ? 250 : 140,
              height: isDesktop ? 250 : 140,
              child: CircleAvatar(
                radius: isDesktop ? 100 : 70,
                backgroundImage: _image != null
                    ? FileImage(_image!) as ImageProvider
                    : NetworkImage(_imageUrl),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.camera, size: isDesktop ? 35 : 20),
                  onPressed: () {
                    _getImage(ImageSource.camera);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.upload_outlined, size: isDesktop ? 35 : 20),
                  onPressed: () {
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: Approved.defaultPadding * 2),
            SizedBox(
              height: isDesktop ? 90 : 60,
              width: isDesktop ? 900 : 400,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: S.of(context).UserName,
                  labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18),
                  prefixIcon: Icon(Icons.person, size: isDesktop ? 30 : 20),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: isDesktop ? 25 : 16),
                ),
                  style: TextStyle(fontSize: isDesktop ? 22: 18),
              ),

            ),
            const SizedBox(height: Approved.defaultPadding),
            SizedBox(
              height: isDesktop ? 90 : 60,
              width: isDesktop ? 900 : 400,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: S.of(context).Email,
                  labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18),
                  prefixIcon: Icon(Icons.email, size: isDesktop ? 30 : 20),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: isDesktop ? 25 : 16),
                ),
                 style: TextStyle(fontSize: isDesktop ? 22: 18),
              ),
            ),
            const SizedBox(height: Approved.defaultPadding),
            SizedBox(
              height: isDesktop ? 90 : 60,
              width: isDesktop ? 900 : 400,
              child: TextField(
                controller: _aboutController,
                decoration: InputDecoration(
                  labelText: S.of(context).About,
                  labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18),
                  prefixIcon: Icon(Icons.info, size: isDesktop ? 30 : 20),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: isDesktop ? 25 : 16),
                ),
                 style: TextStyle(fontSize: isDesktop ? 22: 18),
              ),
            ),
            const SizedBox(height: Approved.defaultPadding),
            SizedBox(
              height: isDesktop ? 90 : 60,
              width: isDesktop ? 900 : 400,
              child: DropdownButtonFormField<String>(
                value: _selectedLocation,
                items: locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(
                      location,
                      style: TextStyle(fontSize: isDesktop ? 22 : 18),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: S.of(context).Location,
                  labelStyle: TextStyle(fontSize: isDesktop ? 22 : 18),
                  prefixIcon:
                      Icon(Icons.location_on, size: isDesktop ? 30 : 20),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: isDesktop ? 25 : 16),
                ),
              ),
            ),
            const SizedBox(height: Approved.defaultPadding * 2),
            if (_isUploading) const CircularProgressIndicator(),
            if (!_isUploading)
              SizedBox(
                height: isDesktop ? 60 : 60,
                width: isDesktop ? 500 : 400,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text(
                    S.of(context).Update,
                    style: TextStyle(fontSize: isDesktop ? 22 : 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and email cannot be empty')),
      );
      return;
    }
    try {
      String updatedImageUrl = _imageUrl;

      if (_image != null) {
        updatedImageUrl = await _uploadImage(_image!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userCredential.user!.uid)
          .update({
        'username': _usernameController.text,
        'email': _emailController.text,
        'Location': _selectedLocation,
        'about': _aboutController.text,
        'image_url': updatedImageUrl,
      });
      var reqBody = {
        "userName": _usernameController.text,
        "email": _emailController.text,
        "about": _aboutController.text,
        "location": _selectedLocation
      };

      var response = await http.put(Uri.parse(url + '${widget.userId}'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      setState(() {
        _isUploading = false;
      });
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().millisecondsSinceEpoch}');
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      firebase_storage.TaskSnapshot storageSnapshot = await uploadTask;
      String downloadURL = await storageSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }
}
