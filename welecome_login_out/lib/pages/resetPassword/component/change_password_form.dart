// ignore_for_file: unused_field, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, use_key_in_widget_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/config.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'dart:convert';
import 'package:welecome_login_out/pages/signin/signin_screen.dart';
import 'package:http/http.dart' as http;


class ChangePasswordForm extends StatefulWidget {
  final String userId;
  final String email;
  final String verificationCode;

  const ChangePasswordForm({
    required this.email,
    required this.verificationCode,
    required this.userId,
  });

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  TextEditingController newpassController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updatePassword(BuildContext context, String newPassword) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.currentUser?.updatePassword(newPassword);
      final String apiUrl = updatePass;

      Map<String, String> requestBody = {
        'email': widget.email,
        'password': newPassword,
      };
      var response = await http.put(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInPage()));
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Failed to update password. Please try again later.'),
              actions: [
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
    } catch (e) {

      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred. Please try again later.'),
            actions: [
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: Approved.defaultPadding * 4),
        TextField(
          controller: newpassController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: S.of(context).NewPasswordMsg,
            prefixIcon: const Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: Approved.defaultPadding),
        TextField(
          controller: confirmpassController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: S.of(context).ConfirmPassword,
            prefixIcon: const Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: Approved.defaultPadding),
        ElevatedButton(
          onPressed: () async {
            if (newpassController.text == confirmpassController.text) {
              await updatePassword(context, confirmpassController.text);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(S.of(context).Wrong),
                    content: Text(S.of(context).Mismatched),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(S.of(context).OkayMsg),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Text(S.of(context).UpdatePassword,
          style: TextStyle(
            fontSize: isDesktop ? 20: 16
          ),),
        ),
        const SizedBox(height: Approved.defaultPadding),
      ],
    );
  }
}
