// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';
import 'package:welecome_login_out/pages/resetPassword/component/change_password_form.dart';
import 'package:welecome_login_out/pages/resetPassword/component/change_pass_img_screen.dart';
import 'package:welecome_login_out/responsive.dart';

class ChangePasswordPage extends StatefulWidget {
  final String email;

  final String verificationCode;
  final String userId;

  const ChangePasswordPage({
    required this.email,
    required this.verificationCode,
    required this.userId,
  });
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Approved.defaultPadding),
        child: SingleChildScrollView(
          child: Responsive(
              mobile: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ChangePasswordImage(),
                  ChangePasswordForm(
                    email: widget.email,
                    verificationCode: widget.verificationCode,
                    userId: widget.userId,
                  ),
                ],
              ),
              desktop: Column(
                children: [
                  Text(
                    S.of(context).ConfirmPassword,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Approved.TextColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: Approved.defaultPadding),
                  Text(
                    S.of(context).ResetMsg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Approved.TextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Image.asset(
                          'assets/images/reset.png',
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 600,
                              child: ChangePasswordForm(
                                email: widget.email,
                                verificationCode: widget.verificationCode,
                                userId: widget.userId,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
