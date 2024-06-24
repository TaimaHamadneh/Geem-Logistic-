import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/reset_code/reset_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordForm extends StatefulWidget {
  final String userId;

  const ForgetPasswordForm({
    required this.userId,
  });

  @override
  _ForgetPasswordFormState createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendPasswordResetCode() async {
    final Map<String, String> requestBody = {
      'email': _emailController.text.trim(),
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(forgotPassword),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Request Body: $requestBody');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Password reset code sent successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetCodePage(
              email: _emailController.text.trim(),
              userId: widget.userId,
            ),
          ),
        );
      } else {
        print('Failed to send password reset code. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send password reset code. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     final isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Approved.defaultPadding),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email, color: Approved.PrimaryColor),
              fillColor: Approved.LightColor,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: Approved.defaultPadding),
        ElevatedButton(
          onPressed: _sendPasswordResetCode,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Approved.PrimaryColor),
            minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              S.of(context).SendCode,
              style:  TextStyle(color: Colors.white,
              fontSize: isDesktop ? 24 : 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
