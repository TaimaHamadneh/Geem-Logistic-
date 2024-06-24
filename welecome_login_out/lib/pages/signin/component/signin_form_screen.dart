// ignore_for_file: unused_field, unused_local_variable, use_key_in_widget_constructors, prefer_final_fields, non_constant_identifier_names, avoid_print, use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/components/have_account.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/Screens/admin_screen.dart';
import 'package:welecome_login_out/pages/Screens/employee_inventory.dart';
import 'package:welecome_login_out/pages/Screens/employee_screen.dart';
import 'package:welecome_login_out/pages/Screens/tab_screen.dart';
import 'package:welecome_login_out/pages/forget_password/forget_password_screen.dart';
import 'package:welecome_login_out/pages/signup/signup_screen.dart';
import 'package:http/http.dart' as http;
import 'package:welecome_login_out/config.dart';
import 'dart:convert';

import 'package:welecome_login_out/pages/userPages/Screen/userpage.dart';

final _firebase = FirebaseAuth.instance;

class SignInForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignInForm({
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isUploading = false;
  String? _emailError;
  String? _passwordMessage;
  String? userId = '';
  String? merchantId = '';

  bool _validateFields() {
    bool isValid = true;

    if (widget.emailController.text.isEmpty) {
      setState(() {
        _emailError = S.of(context).EmailEmptyError;
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(widget.emailController.text)) {
      setState(() {
        _emailError = S.of(context).ValidEmail;
      });
      isValid = false;
    }
    if (widget.passwordController.text.isEmpty) {
      setState(() {
        _passwordMessage = S.of(context).passwordEmpty;
      });
      isValid = false;
    } else if (widget.passwordController.text.length < 8) {
      setState(() {
        _passwordMessage = S.of(context).ValidPassword;
      });
      isValid = false;
    }
    return isValid;
  }

  void LoginUser() async {
    setState(() {
      _emailError = null;
      _passwordMessage = null;
      _isUploading = true;
    });
    if (_validateFields()) {
      var regBody = {
        "email": widget.emailController.text,
        "password": widget.passwordController.text
      };
      try {
        var response = await http.post(Uri.parse(login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(regBody));
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status']) {
          var userResponse = jsonDecode(response.body);
          var email = userResponse['email'];
          var idResponse = await http.get(
            Uri.parse(
                'http://192.168.0.107:3000/search?email=${widget.emailController.text}'), 
          );
          if (idResponse.statusCode == 200) {
            var userIdResponse = jsonDecode(idResponse.body);
            userId = userIdResponse['id'];
          }
          print('User ID: $userId');

          var user = jsonDecode(response.body);
          print('user: $user');
          var userType = user['userType'] as String?;
          print('userType: $userType');

          var merchantId = user['userId'] as String?;
          print('merchantId : $merchantId');
          var position = user['position'] as String?;
          print('position : $position');
          var EmployeeId = user['_id'];
          print('EmployeeId: $EmployeeId');

          final UserCredential userCredential =
              await _firebase.signInWithEmailAndPassword(
                  email: widget.emailController.text,
                  password: widget.passwordController.text);
          if (userType == 'merchant') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsScreen(
                          userCredential: userCredential,
                          userId: userId!,
                          signedInUserEmail: widget.emailController.text
                        )));
          } else if (userType == 'user') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserTabsScreen(
                  userCredential: userCredential,
                  userId: userId!,
                  signedInUserEmail: widget.emailController.text
                ),
              ),
            );
          } else if (userType == 'admin') {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminTabsScreen(
                  userCredential: userCredential,
                   userId: userId!, userEmail:  widget.emailController.text, 
                   signedInUserEmail: widget.emailController.text
                ),
              ),
            );
          } else if (userType == 'employee') {
            if(position == 'Sales Associate'){
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeTabsScreen(
                  userCredential: userCredential,
                   userId: EmployeeId!,
                   merchantId: merchantId!,
                   signedInUserEmail: widget.emailController.text
                ),
              ),
            );
            }
           else{
                 Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeInventoryTabsScreen(
                  userCredential: userCredential,
                   userId: EmployeeId!,
                   merchantId: merchantId!,
                   signedInUserEmail: widget.emailController.text
                ),
              ),
            );

            }
          }
        }
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
            content: Text(S.of(context).ErrorMag),
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

  void submit() {
    final valid = _formKey.currentState!.validate();
    if (valid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Approved.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: widget.emailController,
                decoration: InputDecoration(
                  errorText: _emailError,
                  hintText: S.of(context).Email, 
                  labelStyle: TextStyle(fontSize: isDesktop ? 20 : 16,),
                  prefixIcon:
                      const Icon(Icons.person, color: Approved.PrimaryColor),
                  fillColor: Approved.LightColor,
                  filled: true,
                  border: InputBorder.none,
                 enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(isDesktop ? 30 : 20), // Adjust border radius for desktop
      borderSide: const BorderSide(color: Approved.LightColor),
    ),
                  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(isDesktop ? 30 : 20), // Adjust border radius for desktop
      borderSide: const BorderSide(color: Approved.PrimaryColor),
    ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Approved.defaultPadding),
              TextFormField(
                controller: widget.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  errorText: _passwordMessage,
                  hintText: S.of(context).Password, 
                  labelStyle: TextStyle(fontSize: isDesktop ? 20 : 16,),
                  prefixIcon:
                      const Icon(Icons.lock, color: Approved.PrimaryColor),
                  fillColor: Approved.LightColor,
                  filled: true,
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Approved.defaultPadding * 2),
                    borderSide: const BorderSide(color: Approved.LightColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Approved.defaultPadding * 2),
                    borderSide: const BorderSide(color: Approved.PrimaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 8) {
                    return 'Please enter at least 8 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (_isUploading) const CircularProgressIndicator(),
              if (!_isUploading)
                ElevatedButton(
                  onPressed: LoginUser,
                  child: Text(S.of(context).signIn,
                      style: TextStyle(color: Colors.white,
                      fontSize: isDesktop ? 20 : 16,)),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Approved.PrimaryColor),
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Approved.defaultPadding * 2),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: Approved.defaultPadding / 2),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResetPasswordPage(
                                  userId: userId!,
                                )),
                      );
                    },
                    child: Text(S.of(context).ForgotPassword,
                        style:  TextStyle(
                          color: Approved.PrimaryColor,
                          fontSize: isDesktop ? 20 : 16,
                          
                          )),
                  ),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const SignUpPage();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
