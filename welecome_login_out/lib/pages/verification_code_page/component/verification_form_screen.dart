import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/signin/signin_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class VerificationForm extends StatelessWidget {
  final List<TextEditingController> codeControllers;
  final String email; 

  const VerificationForm({
    Key? key, 
  required this.codeControllers, 
  required this.email, 
 })
      : super(key: key);
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
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  } else {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verification Failed'),
          content: const Text('Invalid verification code.'),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(S.of(context).EnterCode),
        const SizedBox(height: Approved.defaultPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => Container(
              width: 45,
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
    style: const TextStyle(color: Colors.white),
  ),
),

      ],
    );
  }
}
