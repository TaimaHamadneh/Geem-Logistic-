import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/pages/signin/signin_screen.dart';
import 'package:welecome_login_out/pages/verification_code_page/verification_screen.dart';
import 'package:welecome_login_out/pages/Profile/user_image.dart';
import '../../../approved.dart';
import '../../../components/have_account.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import '../../../config.dart';

final FirebaseAuth _firebase = FirebaseAuth.instance;

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _emailError;
  String? _passwordMessage;
  String? _usernameError;
  bool _isUploading = false;
  File? _selectedImage;
  String? _selectedUserType;

  bool _validateFields() {
    bool isValid = true;

    if (emailController.text.isEmpty) {
      setState(() {
        _emailError = S.of(context).EmailEmptyError;
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      setState(() {
        _emailError = S.of(context).ValidEmail;
      });
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        _passwordMessage = S.of(context).passwordEmpty;
      });
      isValid = false;
    } else if (passwordController.text.length < 8) {
      setState(() {
        _passwordMessage = S.of(context).ValidPassword;
      });
      isValid = false;
    }

    if (usernameController.text.isEmpty) {
      setState(() {
        _usernameError = S.of(context).FullNameEmptyError;
      });
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(usernameController.text)) {
      setState(() {
        _usernameError = S.of(context).ValidUserName;
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> registerUser() async {
    setState(() {
      _emailError = null;
      _passwordMessage = null;
      _usernameError = null;
      _isUploading = true;
    });

    if (_validateFields() && _selectedImage != null && _selectedUserType != null) {
      try {
        var regBody = {
          "userName": usernameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "userType": _selectedUserType,
          "about": "_",
          "location": 'other'
        };

        var response = await http.post(Uri.parse(registration),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regBody));
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse['status']);

        final UserCredential userCredential = 
        await _firebase.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text);
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': usernameController.text,
          'email': emailController.text,
          'image_url': imageUrl,
          'userType': _selectedUserType,
          'Location': 'other',
          'about': '_'
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerificationCodePage(
                      code: emailController.text,
                    )));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Authentication failed.'),
          ),
        );
        setState(() {
          _isUploading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
          ),
        );
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      setState(() {
        _isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(S.of(context).ErrorMag
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserImagePicker(
            onPickImage: (File pickedImage) {
              _selectedImage = pickedImage;
            },
          ),
          const SizedBox(height: Approved.defaultPadding * 2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Approved.defaultPadding / 2),
            child: TextField(
              controller: usernameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                errorText: _usernameError,
                hintText: S.of(context).fullName,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.person),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Approved.defaultPadding / 2),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                filled: true,
                errorText: _emailError,
                hintText: S.of(context).Email,
                labelStyle: TextStyle( fontSize:  isDesktop ? 20 : 16,),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.email),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Approved.defaultPadding / 2),
            child: TextField(
              controller: passwordController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                errorText: _passwordMessage,
                hintText: S.of(context).Password,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Approved.defaultPadding / 2),
            child: DropdownButtonFormField<String>(
              value: _selectedUserType,
              items: ['merchant', 'user']
                  .map((String userType) => DropdownMenuItem<String>(
                        value: userType,
                        child: Text(userType),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUserType = newValue;
                });
              },
              decoration: InputDecoration(
                hintText: 'User Type',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(Approved.defaultPadding),
                  child: Icon(Icons.person),
                ),
              ),
            ),
          ),
          const SizedBox(height: Approved.defaultPadding),
          if (_isUploading) const CircularProgressIndicator(),
          if (!_isUploading)
            ElevatedButton(
              onPressed: registerUser,
              child: Text(S.of(context).signUp, style: TextStyle(
                fontSize: isDesktop ? 20 : 16
              ),),
            ),
          const SizedBox(height: Approved.defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignInPage();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
