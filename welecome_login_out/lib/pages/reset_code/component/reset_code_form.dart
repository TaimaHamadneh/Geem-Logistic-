// ignore_for_file: use_build_context_synchronously, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/resetPassword/change_password_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetCodeForm extends StatelessWidget {
  final List<TextEditingController> codeControllers;
  final String email;
  final String userId;

  const ResetCodeForm({
    Key? key,
    required this.codeControllers,
    required this.email,
    required this.userId,
  }) : super(key: key);


  Future<void> verifyUser(BuildContext context, String verificationCode) async {
    final response = await http.post(
      Uri.parse(verify),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'verificationCode': verificationCode,
      }),
    );
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChangePasswordPage(
                  email: email,
                  verificationCode: verificationCode,
                  userId: userId,
                )),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Approved.PrimaryColor,
            title: const Text('Verification Failed' , style: TextStyle(
              color: Colors.white
            ),),
            content: const Text('Invalid verification code.',
             style: TextStyle(
              color: Colors.white
            )),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK',
                 style: TextStyle(
              color: Colors.white
            )),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
        final isDesktop = MediaQuery.of(context).size.width > 600; // Adjust threshold as needed

    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(S.of(context).EnterCode,
        style:  TextStyle(
          fontSize:  isDesktop ? 32.0 : 24.0, 
        ),),
        const SizedBox(height: Approved.defaultPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => Container(
              width:  isDesktop ? 90 : 45,  
              height:  isDesktop ? 90 : 45,  
              child: TextField(
                controller: codeControllers[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: const InputDecoration(
                  counterText: "",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Approved.defaultPadding),
        ElevatedButton(
          onPressed: () {
            String enteredCode =
                codeControllers.map((controller) => controller.text).join();
            verifyUser(context, enteredCode); 
            
          },
          child: Text(
            S.of(context).Verify,
            style:  TextStyle(color: Colors.white,
            fontSize:  isDesktop ? 32.0 : 24.0, 
            
            ),
          ),
        ),
      ],
    );
  }
}
